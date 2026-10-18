<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Entrega de audio
'  ---------------------------------------------------------------------------
'  Los archivos de la carpeta songFiles nunca se exponen directamente: todas
'  las peticiones pasan por aqui, donde se valida la sesion, se cuenta la
'  reproduccion y se responde con soporte de rangos (necesario para poder
'  avanzar o retroceder dentro de la pista).
' =============================================================================
Response.Buffer = False

Dim idCancion, rs, urlAudio, rutaFisica, esPreview, archivo
Dim fso, objArchivo, tamano, rango, partes, inicio, fin, longitud, parcial
Dim stm, metodo, pedirDesdeCero, restante, n

' Tamano de cada bloque de escritura (32 KB)
Const BLOQUE_AUDIO = 32768

' ---------------------------------------------------------------------------
'  1. Control de acceso
' ---------------------------------------------------------------------------
If Not IsLoggedIn() Then
    Response.Status = "401 Unauthorized"
    Response.ContentType = "text/plain; charset=utf-8"
    Response.Write "Debes iniciar sesion para reproducir musica."
    Response.End
End If

idCancion = ToInt(Request.QueryString("id"))
If idCancion <= 0 Then
    Response.Status = "400 Bad Request"
    Response.ContentType = "text/plain; charset=utf-8"
    Response.Write "Solicitud de audio no valida."
    Response.End
End If

' ---------------------------------------------------------------------------
'  2. Localizacion del archivo
' ---------------------------------------------------------------------------
Set rs = DBQuery("SELECT SONG_NAME, SONG_PATH FROM TBL_SONG WHERE ID_SONG = ?", Array(idCancion))
If rs.EOF Then
    rs.Close
    CloseConn
    Response.Status = "404 Not Found"
    Response.ContentType = "text/plain; charset=utf-8"
    Response.Write "La cancion solicitada no existe en el catalogo."
    Response.End
End If

urlAudio = ResolveUrl(rs("SONG_PATH"))
rs.Close
CloseConn

esPreview = False
rutaFisica = ""

If urlAudio <> "" And FileExists(urlAudio) Then
    rutaFisica = PhysicalPath(urlAudio)
Else
    ' El archivo original no esta disponible: se entrega la pista de
    ' demostracion incluida en la carpeta songFiles.
    esPreview = True
    archivo = DemoAudio()
    If archivo <> "" Then rutaFisica = PhysicalPath(DIR_SONGS & "/" & archivo)
End If

If rutaFisica = "" Then
    Response.Status = "404 Not Found"
    Response.ContentType = "text/plain; charset=utf-8"
    Response.Write "El archivo de audio no esta disponible en el servidor."
    Response.End
End If

On Error Resume Next
Set fso = Server.CreateObject("Scripting.FileSystemObject")
Set objArchivo = fso.GetFile(rutaFisica)
tamano = objArchivo.Size
If Err.Number <> 0 Then
    Err.Clear
    On Error GoTo 0
    Response.Status = "404 Not Found"
    Response.ContentType = "text/plain; charset=utf-8"
    Response.Write "No se pudo leer el archivo de audio."
    Response.End
End If
On Error GoTo 0

' ---------------------------------------------------------------------------
'  3. Interpretacion de la cabecera Range (bytes=inicio-fin)
' ---------------------------------------------------------------------------
inicio  = 0
fin     = tamano - 1
parcial = False

rango = CStr(Request.ServerVariables("HTTP_RANGE"))
If rango <> "" And InStr(LCase(rango), "bytes=") > 0 Then
    rango = Mid(rango, InStr(LCase(rango), "bytes=") + 6)
    If InStr(rango, ",") > 0 Then rango = Left(rango, InStr(rango, ",") - 1)

    partes = Split(rango, "-")
    If UBound(partes) >= 1 Then
        If Trim(partes(0)) = "" Then
            ' Rango por sufijo: bytes=-N  (ultimos N bytes)
            longitud = ToInt(partes(1))
            If longitud > 0 Then inicio = tamano - longitud
            If inicio < 0 Then inicio = 0
        Else
            inicio = ToInt(partes(0))
            If Trim(partes(1)) <> "" Then fin = ToInt(partes(1))
        End If
        parcial = True
    End If

    If inicio < 0 Then inicio = 0
    If fin >= tamano Then fin = tamano - 1
    If fin < inicio Then
        inicio = 0
        fin = tamano - 1
        parcial = False
    End If
End If

longitud = fin - inicio + 1

' ---------------------------------------------------------------------------
'  4. Conteo de reproducciones
'  Solo se cuenta la peticion inicial (sin cabecera Range o desde el byte 0),
'  para no sumar cada fragmento que solicita el navegador.
' ---------------------------------------------------------------------------
pedirDesdeCero = (rango = "") Or (inicio = 0)
If pedirDesdeCero Then
    DBExecute "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 WHERE ID_SONG = ?", Array(idCancion)
    CloseConn
End If

' ---------------------------------------------------------------------------
'  5. Respuesta
' ---------------------------------------------------------------------------
'  OJO: no se debe fijar Content-Length manualmente. Al hacerlo, IIS aborta
'  la respuesta (la conexion se reinicia). Con Buffer = False IIS usa
'  Transfer-Encoding: chunked, que los navegadores reproducen sin problema.
Response.ContentType = "audio/mpeg"
Response.AddHeader "Accept-Ranges", "bytes"
Response.AddHeader "Cache-Control", "no-store"
If esPreview Then Response.AddHeader "X-PoliMusic-Preview", "1"

If parcial Then
    Response.Status = "206 Partial Content"
    Response.AddHeader "Content-Range", "bytes " & inicio & "-" & fin & "/" & tamano
End If

metodo = UCase(CStr(Request.ServerVariables("REQUEST_METHOD")))
If metodo <> "HEAD" Then
    Set stm = Server.CreateObject("ADODB.Stream")
    stm.Type = 1              ' binario
    stm.Open
    stm.LoadFromFile rutaFisica
    stm.Position = inicio

    ' Se escribe por bloques: ASP tiene un limite de buffer de respuesta
    ' (4 MB por defecto) y una sola escritura de todo el archivo lo supera
    ' con el error ASP 0251.
    restante = longitud
    Do While restante > 0
        n = BLOQUE_AUDIO
        If n > restante Then n = restante
        Response.BinaryWrite stm.Read(n)
        restante = restante - n
    Loop

    stm.Close
    Set stm = Nothing
End If

Set objArchivo = Nothing
Set fso = Nothing
Response.End
%>
