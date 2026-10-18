<%
' =============================================================================
'  PoliMusic | Funciones de apoyo (utilidades, rutas, mensajes, seguridad)
' =============================================================================

' -----------------------------------------------------------------------------
'  Texto y conversion de tipos
' -----------------------------------------------------------------------------
'  H()  escapa cualquier valor antes de imprimirlo en HTML (evita XSS)
Function H(ByVal v)
    If IsNull(v) Or IsEmpty(v) Then
        H = ""
    Else
        H = Server.HTMLEncode(CStr(v))
    End If
End Function

'  Nz()  devuelve el valor por defecto cuando el dato es Null o vacio
Function Nz(ByVal v, ByVal porDefecto)
    If IsNull(v) Or IsEmpty(v) Then
        Nz = porDefecto
    Else
        Nz = v
    End If
End Function

'  ToInt()  conversion segura a entero
Function ToInt(ByVal v)
    Dim n
    n = 0
    If IsNull(v) Or IsEmpty(v) Then
        ToInt = 0
        Exit Function
    End If
    If IsNumeric(v) Then
        On Error Resume Next
        n = CLng(v)
        If Err.Number <> 0 Then n = 0
        Err.Clear
        On Error GoTo 0
    End If
    ToInt = n
End Function

'  Clean()  recorta espacios y elimina caracteres de control
Function Clean(ByVal v)
    Dim s, i, c, r
    If IsNull(v) Or IsEmpty(v) Then
        Clean = ""
        Exit Function
    End If
    s = Trim(CStr(v))
    r = ""
    For i = 1 To Len(s)
        c = AscW(Mid(s, i, 1))
        If c >= 32 Then r = r & Mid(s, i, 1)
    Next
    Clean = Trim(r)
End Function

Function IsBlank(ByVal v)
    IsBlank = (Clean(v) = "")
End Function

'  Truncate()  recorta texto largo para las tarjetas
Function Truncate(ByVal v, ByVal maximo)
    Dim s
    s = Clean(Nz(v, ""))
    If Len(s) <= maximo Then
        Truncate = s
    Else
        Truncate = Left(s, maximo - 1) & "..."
    End If
End Function

'  UrlEnc()  codifica para usar dentro de una URL (los espacios como %20)
Function UrlEnc(ByVal v)
    Dim r
    r = Server.URLEncode(CStr(Nz(v, "")))
    r = Replace(r, "+", "%20")
    UrlEnc = r
End Function

'  FormatDate()  fecha en formato dd/mm/aaaa
Function FormatDate(ByVal v)
    If IsNull(v) Or IsEmpty(v) Then
        FormatDate = "-"
        Exit Function
    End If
    On Error Resume Next
    FormatDate = Right("0" & Day(v), 2) & "/" & Right("0" & Month(v), 2) & "/" & Year(v)
    If Err.Number <> 0 Then
        FormatDate = "-"
        Err.Clear
    End If
    On Error GoTo 0
End Function

'  FormatDateInput()  fecha en formato aaaa-mm-dd para <input type="date">
Function FormatDateInput(ByVal v)
    If IsNull(v) Or IsEmpty(v) Then
        FormatDateInput = ""
        Exit Function
    End If
    On Error Resume Next
    FormatDateInput = Year(v) & "-" & Right("0" & Month(v), 2) & "-" & Right("0" & Day(v), 2)
    If Err.Number <> 0 Then
        FormatDateInput = ""
        Err.Clear
    End If
    On Error GoTo 0
End Function

'  ParseDateInput()  convierte "aaaa-mm-dd" (input type=date) en fecha o Null
Function ParseDateInput(ByVal valor)
    Dim s, partes, a, m, d, f

    ParseDateInput = Null
    s = Clean(valor)
    If s = "" Then Exit Function

    partes = Split(s, "-")
    If UBound(partes) <> 2 Then Exit Function

    a = ToInt(partes(0))
    m = ToInt(partes(1))
    d = ToInt(partes(2))
    If a < 1900 Or a > 2200 Then Exit Function
    If m < 1 Or m > 12 Then Exit Function
    If d < 1 Or d > 31 Then Exit Function

    On Error Resume Next
    f = DateSerial(a, m, d)
    If Err.Number = 0 Then
        ' DateSerial normaliza fechas invalidas (por ejemplo 31/02); se comprueba
        If Year(f) = a And Month(f) = m And Day(f) = d Then ParseDateInput = f
    End If
    Err.Clear
    On Error GoTo 0
End Function

Function IsValidEmail(ByVal correo)
    Dim s, p, d
    s = Clean(correo)
    IsValidEmail = False
    If Len(s) < 6 Then Exit Function
    If InStr(s, " ") > 0 Then Exit Function
    p = InStr(s, "@")
    If p < 2 Then Exit Function
    d = InStr(p + 1, s, ".")
    If d < p + 3 Then Exit Function
    If d = Len(s) Then Exit Function
    IsValidEmail = True
End Function

'  Plural()  "1 cancion" / "3 canciones"
'  OJO: el tercer parametro NO puede llamarse "plural" porque VBScript no
'  distingue mayusculas y chocaria con el nombre de la propia funcion
'  (error 800a0411 "Nombre redefinido").
Function Plural(ByVal cantidad, ByVal singular, ByVal pluralTexto)
    If ToInt(cantidad) = 1 Then
        Plural = cantidad & " " & singular
    Else
        Plural = cantidad & " " & pluralTexto
    End If
End Function

' -----------------------------------------------------------------------------
'  Rutas y archivos multimedia
' -----------------------------------------------------------------------------
'  gBase es "" en la raiz de la aplicacion y "../" dentro de /admin.
Function Base()
    Base = gBase
End Function

'  Ruta fisica del archivo a partir de su ruta relativa a la raiz de la app.
'  No se usan rutas con ".." porque IIS las bloquea por defecto
'  (AspEnableParentPaths = false).
Function PhysicalPath(ByVal relUrl)
    Dim p, r
    p = ""
    r = Clean(relUrl)
    If r = "" Then r = "."
    On Error Resume Next
    p = Server.MapPath(r)
    If Err.Number <> 0 Then
        p = ""
        Err.Clear
    End If
    On Error GoTo 0
    PhysicalPath = p
End Function

'  Convierte una ruta almacenada en la BD (ej: ~/songFiles/x.mp3) en una URL
'  publica valida, normalizando el nombre de la carpeta.
Function ResolveUrl(ByVal dbPath)
    Dim p, pos, carpeta, archivo
    p = Replace(Clean(dbPath), "\", "/")
    If p = "" Then
        ResolveUrl = ""
        Exit Function
    End If
    If Left(p, 2) = "~/" Then p = Mid(p, 3)

    pos = InStr(p, "/")
    If pos > 0 Then
        carpeta = LCase(Left(p, pos - 1))
        archivo = Mid(p, pos + 1)
    Else
        carpeta = ""
        archivo = p
    End If

    Select Case carpeta
        Case "songfiles"
            carpeta = DIR_SONGS
        Case "userimages"
            carpeta = DIR_USER
        Case "playlistimages"
            carpeta = DIR_PLAYLIST
        Case "albumimages"
            carpeta = DIR_ALBUM
        Case "artistimages"
            carpeta = DIR_ARTIST
    End Select

    If carpeta = "" Then
        ResolveUrl = archivo
    Else
        ResolveUrl = carpeta & "/" & archivo
    End If
End Function

'  Comprueba si un archivo existe (con cache para no repetir consultas al disco)
Dim gFileCache
Function FileExists(ByVal relUrl)
    Dim fso, existe
    If relUrl = "" Then
        FileExists = False
        Exit Function
    End If

    If Not IsObject(gFileCache) Then
        Set gFileCache = Server.CreateObject("Scripting.Dictionary")
        gFileCache.CompareMode = 1
    End If
    If gFileCache.Exists(relUrl) Then
        FileExists = gFileCache(relUrl)
        Exit Function
    End If

    existe = False
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    existe = fso.FileExists(PhysicalPath(relUrl))
    If Err.Number <> 0 Then existe = False
    Err.Clear
    On Error GoTo 0

    gFileCache(relUrl) = existe
    FileExists = existe
End Function

'  Primer archivo MP3 disponible en la carpeta de canciones.
'  Se usa como pista de demostracion cuando la BD apunta a un archivo ausente.
Dim gDemoAudio
Function DemoAudio()
    Dim fso, carpeta, f, nombre
    If Not IsEmpty(gDemoAudio) Then
        DemoAudio = gDemoAudio
        Exit Function
    End If
    nombre = ""
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    Set carpeta = fso.GetFolder(PhysicalPath(DIR_SONGS))
    For Each f In carpeta.Files
        If LCase(fso.GetExtensionName(f.Name)) = "mp3" Then
            nombre = f.Name
            Exit For
        End If
    Next
    If Err.Number <> 0 Then nombre = ""
    Err.Clear
    On Error GoTo 0
    gDemoAudio = nombre
    DemoAudio = nombre
End Function

'  URL de la caratula de un album / playlist / artista.
'  Si la imagen no existe se genera una portada SVG con las iniciales.
Function CoverUrl(ByVal dbPath, ByVal etiqueta, ByVal semilla)
    Dim u
    u = ResolveUrl(dbPath)
    If u <> "" And FileExists(u) Then
        CoverUrl = Base() & u
    Else
        CoverUrl = PlaceholderCover(etiqueta, semilla)
    End If
End Function

'  URL del avatar de un usuario
Function AvatarUrl(ByVal dbPath, ByVal etiqueta, ByVal semilla)
    Dim u
    u = ResolveUrl(dbPath)
    If u <> "" And FileExists(u) Then
        AvatarUrl = Base() & u
    Else
        AvatarUrl = PlaceholderCover(etiqueta, semilla)
    End If
End Function

' -----------------------------------------------------------------------------
'  Utilidades de audio y caratulas
' -----------------------------------------------------------------------------
'  URL del punto de streaming. El archivo nunca se expone directamente: pasa
'  siempre por stream.asp, que valida la sesion y cuenta las reproducciones.
Function StreamUrl(ByVal idSong)
    StreamUrl = Base() & "stream.asp?id=" & ToInt(idSong)
End Function

'  Indica si el archivo de audio de la cancion no esta disponible en disco.
'  En ese caso el reproductor usa la pista de demostracion.
Function SongIsPreview(ByVal songPath)
    Dim u
    u = ResolveUrl(songPath)
    If u = "" Then
        SongIsPreview = True
    Else
        SongIsPreview = Not FileExists(u)
    End If
End Function

'  Caratula de una cancion: usa la del album cuando existe
Function SongCover(ByVal albumImg, ByVal albumTitulo, ByVal albumId, ByVal cancion)
    If Clean(albumTitulo) <> "" Then
        SongCover = CoverUrl(albumImg, albumTitulo, albumId)
    Else
        SongCover = PlaceholderCover(cancion, Len(cancion))
    End If
End Function

'  Portada SVG generada al vuelo (data URI) para los elementos sin imagen
Function PlaceholderCover(ByVal etiqueta, ByVal semilla)
    Dim paleta, par, c1, c2, idx, ini, svg
    paleta = Array("#2455E6|#0F2C87", "#1B7FE0|#0B4A8F", "#3F51B5|#1A237E", _
                   "#00897B|#00574B", "#6D4BC7|#33209E", "#0E7490|#0B3B4A")
    idx = Abs(ToInt(semilla)) Mod (UBound(paleta) + 1)
    par = Split(paleta(idx), "|")
    c1 = par(0)
    c2 = par(1)
    ini = Initials(etiqueta)

    svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 320' width='320' height='320'>" & _
          "<defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'>" & _
          "<stop offset='0' stop-color='" & c1 & "'/>" & _
          "<stop offset='1' stop-color='" & c2 & "'/>" & _
          "</linearGradient></defs>" & _
          "<rect width='320' height='320' fill='url(#g)'/>" & _
          "<circle cx='160' cy='160' r='112' fill='#ffffff' fill-opacity='0.10'/>" & _
          "<circle cx='160' cy='160' r='78' fill='#ffffff' fill-opacity='0.08'/>" & _
          "<text x='160' y='164' text-anchor='middle' dominant-baseline='central' " & _
          "font-family='Segoe UI,Arial,sans-serif' font-size='104' font-weight='700' " & _
          "fill='#ffffff'>" & ini & "</text></svg>"

    PlaceholderCover = "data:image/svg+xml;charset=utf-8," & UrlEnc(svg)
End Function

'  Iniciales (1 o 2 letras) de un texto, para las portadas generadas
Function Initials(ByVal texto)
    Dim t, partes, i, p, r
    t = Clean(texto)
    If t = "" Then
        Initials = "PM"
        Exit Function
    End If
    partes = Split(Replace(t, "-", " "), " ")
    r = ""
    For i = 0 To UBound(partes)
        p = Trim(partes(i))
        If Len(p) > 0 Then
            r = r & UCase(Left(p, 1))
            If Len(r) = 2 Then Exit For
        End If
    Next
    If Len(r) = 0 Then r = "PM"
    If Len(r) = 1 And Len(t) > 1 Then r = r & UCase(Mid(t, 2, 1))
    Initials = r
End Function

' -----------------------------------------------------------------------------
'  Marcado de la opcion activa del menu lateral
' -----------------------------------------------------------------------------
Function NavActive(ByVal seccion)
    If LCase(CStr(Nz(PageSection, ""))) = LCase(CStr(seccion)) Then
        NavActive = " is-active"
    Else
        NavActive = ""
    End If
End Function

' -----------------------------------------------------------------------------
'  Catalogo generico (TBL_CATALOG) leido una sola vez por peticion
' -----------------------------------------------------------------------------
Dim gCatalog
Sub LoadCatalog()
    Dim rs
    Set gCatalog = Server.CreateObject("Scripting.Dictionary")
    gCatalog.CompareMode = 1
    Set rs = DBQuery("SELECT COD_CATALOG_PARENT, COD_CATALOG, VALUE FROM TBL_CATALOG", Null)
    Do While Not rs.EOF
        gCatalog(CStr(Nz(rs("COD_CATALOG_PARENT"), "")) & "|" & CStr(Nz(rs("COD_CATALOG"), ""))) = CStr(rs("VALUE"))
        rs.MoveNext
    Loop
    rs.Close
End Sub

Function CatalogLabel(ByVal padre, ByVal codigo)
    Dim clave
    If Not IsObject(gCatalog) Then LoadCatalog
    clave = CStr(Nz(padre, "")) & "|" & CStr(Nz(codigo, ""))
    If gCatalog.Exists(clave) Then
        CatalogLabel = gCatalog(clave)
    Else
        CatalogLabel = ""
    End If
End Function

' -----------------------------------------------------------------------------
'  Mensajes al usuario (se conservan durante una redireccion)
' -----------------------------------------------------------------------------
Sub SetFlash(ByVal mensaje, ByVal tipo)
    Session("flash_msg") = mensaje
    Session("flash_tipo") = tipo
End Sub

Function RenderFlash()
    Dim m, t, clase, ico
    m = CStr(Nz(Session("flash_msg"), ""))
    t = CStr(Nz(Session("flash_tipo"), "info"))
    Session("flash_msg") = ""
    Session("flash_tipo") = ""

    If m = "" Then
        RenderFlash = ""
        Exit Function
    End If

    Select Case LCase(t)
        Case "ok", "exito"
            clase = "pm-alert--ok"
            ico = "check"
        Case "error"
            clase = "pm-alert--error"
            ico = "alert"
        Case "aviso"
            clase = "pm-alert--aviso"
            ico = "alert"
        Case Else
            clase = "pm-alert--info"
            ico = "info"
    End Select

    RenderFlash = "<div class=""pm-alert " & clase & """ role=""status"">" & _
                  "<span class=""pm-alert__ico"">" & Icon(ico) & "</span>" & _
                  "<span class=""pm-alert__txt"">" & H(m) & "</span>" & _
                  "<button type=""button"" class=""pm-alert__x"" onclick=""this.parentNode.remove()"" " & _
                  "aria-label=""Cerrar"">" & Icon("close") & "</button></div>"
End Function

'  Muestra el mensaje que llega por la barra de direcciones (?m=clave)
Function MessageFromQuery(ByVal clave)
    Select Case LCase(CStr(Nz(clave, "")))
        Case "guardado"
            MessageFromQuery = "Los cambios se guardaron correctamente."
        Case "creado"
            MessageFromQuery = "El registro se creo correctamente."
        Case "eliminado"
            MessageFromQuery = "El registro se elimino correctamente."
        Case "agregada"
            MessageFromQuery = "La cancion se agrego a la playlist."
        Case "quitada"
            MessageFromQuery = "La cancion se quito de la playlist."
        Case "sinpermiso"
            MessageFromQuery = "No tienes permisos para realizar esa accion."
        Case Else
            MessageFromQuery = ""
    End Select
End Function

' -----------------------------------------------------------------------------
'  Proteccion CSRF: token por sesion incluido en todos los formularios POST
' -----------------------------------------------------------------------------
Function CsrfToken()
    Dim s, i, g
    If CStr(Nz(Session("csrf"), "")) = "" Then
        Randomize
        s = ""
        For i = 1 To 40
            g = Int(Rnd() * 16)
            s = s & Mid("0123456789abcdef", g + 1, 1)
        Next
        Session("csrf") = s
    End If
    CsrfToken = Session("csrf")
End Function

'  Campo oculto listo para insertar dentro de un <form method="post">
Function CsrfField()
    CsrfField = "<input type=""hidden"" name=""csrf"" value=""" & H(CsrfToken()) & """>"
End Function

Sub CheckCsrf()
    Dim enviado
    enviado = CStr(Nz(Request.Form("csrf"), ""))
    If enviado = "" Or enviado <> CStr(Nz(Session("csrf"), "")) Then
        AbortPage "Solicitud no valida", _
                  "El formulario expiro o no es valido. Regresa a la pagina anterior e intentalo de nuevo."
    End If
End Sub

'  Lista las imagenes disponibles en una carpeta multimedia y las devuelve
'  como etiquetas <option> con el mismo formato de ruta que usa la base de datos.
Function ImageOptions(ByVal carpeta, ByVal seleccionada)
    Dim fso, objCarpeta, f, html, ext, ruta, marca
    html = ""
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    Set objCarpeta = fso.GetFolder(PhysicalPath(carpeta))
    For Each f In objCarpeta.Files
        ext = LCase(fso.GetExtensionName(f.Name))
        If ext = "jpg" Or ext = "jpeg" Or ext = "png" Or ext = "webp" Or ext = "gif" Then
            ruta = "~/" & carpeta & "/" & f.Name
            If LCase(ruta) = LCase(CStr(Nz(seleccionada, ""))) Then
                marca = " selected"
            Else
                marca = ""
            End If
            html = html & "<option value=""" & H(ruta) & """" & marca & ">" & H(f.Name) & "</option>"
        End If
    Next
    If Err.Number <> 0 Then html = ""
    Err.Clear
    On Error GoTo 0
    ImageOptions = html
End Function

'  Lista los archivos de audio disponibles en la carpeta de canciones y los
'  devuelve como etiquetas <option> con el formato de ruta de la base de datos.
Function AudioFileOptions(ByVal seleccionada)
    Dim fso, objCarpeta, f, html, ext, ruta, haySeleccion, sel
    html = ""
    haySeleccion = False
    sel = LCase(Clean(seleccionada))

    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    Set objCarpeta = fso.GetFolder(PhysicalPath(DIR_SONGS))
    For Each f In objCarpeta.Files
        ext = LCase(fso.GetExtensionName(f.Name))
        If ext = "mp3" Or ext = "wav" Or ext = "ogg" Or ext = "m4a" Then
            ruta = "~/" & DIR_SONGS & "/" & f.Name
            If LCase(ruta) = sel Then haySeleccion = True
            html = html & "<option value=""" & H(ruta) & """" & _
                   IIfStr(LCase(ruta) = sel, " selected", "") & ">" & H(f.Name) & "</option>"
        End If
    Next
    If Err.Number <> 0 Then html = ""
    Err.Clear
    On Error GoTo 0

    ' Si el registro apunta a un archivo que ya no esta en disco, se conserva
    If sel <> "" And Not haySeleccion Then
        html = "<option value=""" & H(seleccionada) & """ selected>" & H(seleccionada) & " (archivo no encontrado)</option>" & html
    End If

    AudioFileOptions = html
End Function

'  Valida que la ruta de audio apunte a la carpeta de canciones
Function ValidSongPath(ByVal ruta)
    ValidSongPath = ValidFileIn(DIR_SONGS, ruta)
End Function

' -----------------------------------------------------------------------------
'  Valida que una imagen elegida en un formulario exista y pertenezca a la
'  carpeta permitida (evita rutas manipuladas desde el cliente)
Function ValidFileIn(ByVal carpeta, ByVal ruta)
    Dim u, prefijo
    u = ResolveUrl(ruta)
    If u = "" Then
        ValidFileIn = True
        Exit Function
    End If
    prefijo = LCase(carpeta) & "/"
    If LCase(Left(u, Len(prefijo))) <> prefijo Then
        ValidFileIn = False
        Exit Function
    End If
    ValidFileIn = FileExists(u)
End Function

'  Imagen de una playlist
Function ValidPlaylistPhoto(ByVal ruta)
    ValidPlaylistPhoto = ValidFileIn(DIR_PLAYLIST, ruta)
End Function

'  Imagen de perfil de un usuario
Function ValidUserPhoto(ByVal ruta)
    ValidUserPhoto = ValidFileIn(DIR_USER, ruta)
End Function

'  Cola de reproduccion de la pagina
' -----------------------------------------------------------------------------
'  Cada pagina arma su propia cola. Los botones de las tarjetas guardan el
'  indice que devuelve QueueAdd y el reproductor global la reproduce.
' -----------------------------------------------------------------------------
Dim gQueueBuf, gQueueCount, gQueueName
gQueueBuf = ""
gQueueCount = 0
gQueueName = ""

Sub QueueReset(ByVal nombre)
    gQueueBuf = ""
    gQueueCount = 0
    gQueueName = CStr(Nz(nombre, ""))
End Sub

'  Agrega una pista a la cola y devuelve su indice (0, 1, 2, ...)
Function QueueAdd(ByVal id, ByVal titulo, ByVal artista, ByVal album, ByVal url, ByVal portada, ByVal esPreview)
    Dim item, idx
    idx = gQueueCount
    item = "{" & _
        """id"":" & ToInt(id) & "," & _
        """title"":" & JsStr(titulo) & "," & _
        """artist"":" & JsStr(artista) & "," & _
        """album"":" & JsStr(album) & "," & _
        """url"":" & JsStr(url) & "," & _
        """cover"":" & JsStr(portada) & "," & _
        """preview"":" & JsBool(esPreview) & "}"
    If gQueueBuf <> "" Then gQueueBuf = gQueueBuf & ","
    gQueueBuf = gQueueBuf & item
    gQueueCount = gQueueCount + 1
    QueueAdd = idx
End Function

Function QueueJson()
    QueueJson = "[" & gQueueBuf & "]"
End Function

'  Cadena segura para incrustar dentro de un bloque <script>
Function JsStr(ByVal v)
    Dim r
    r = CStr(Nz(v, ""))
    r = Replace(r, "\", "\\")
    r = Replace(r, """", "\""")
    r = Replace(r, "/", "\/")
    r = Replace(r, "<", "\u003c")
    r = Replace(r, ">", "\u003e")
    r = Replace(r, vbCr, " ")
    r = Replace(r, vbLf, " ")
    r = Replace(r, vbTab, " ")
    JsStr = """" & r & """"
End Function

Function JsBool(ByVal v)
    If v Then
        JsBool = "true"
    Else
        JsBool = "false"
    End If
End Function

'  Devuelve un texto u otro segun la condicion (util en atributos HTML)
Function IIfStr(ByVal condicion, ByVal siVerdadero, ByVal siFalso)
    If condicion Then
        IIfStr = siVerdadero
    Else
        IIfStr = siFalso
    End If
End Function

' -----------------------------------------------------------------------------
'  Pagina de error controlada
' -----------------------------------------------------------------------------
Sub AbortPage(ByVal titulo, ByVal detalle)
    Response.Write "<!DOCTYPE html><html lang=""es""><head><meta charset=""utf-8"">" & _
        "<meta name=""viewport"" content=""width=device-width, initial-scale=1"">" & _
        "<title>" & H(titulo) & " | " & H(APP_NAME) & "</title>" & _
        "<style>body{margin:0;font-family:'Segoe UI',system-ui,Arial,sans-serif;" & _
        "background:#F3F6FC;color:#0E1B33;display:flex;min-height:100vh;align-items:center;" & _
        "justify-content:center;padding:24px}" & _
        ".box{background:#fff;border:1px solid #E3E9F5;border-radius:18px;padding:32px;" & _
        "max-width:640px;box-shadow:0 18px 40px rgba(15,44,135,.10)}" & _
        "h1{margin:0 0 8px;font-size:22px;color:#16307F}" & _
        ".tag{display:inline-block;background:#EAF0FF;color:#2455E6;font-weight:700;" & _
        "font-size:12px;letter-spacing:.08em;text-transform:uppercase;padding:5px 10px;" & _
        "border-radius:999px;margin-bottom:14px}" & _
        "p{line-height:1.65;color:#41506B;margin:0 0 18px}" & _
        "a{display:inline-block;background:#2455E6;color:#fff;text-decoration:none;" & _
        "padding:11px 20px;border-radius:11px;font-weight:600}" & _
        "a:hover{background:#16307F}</style></head><body><div class=""box"">" & _
        "<span class=""tag"">" & H(APP_NAME) & "</span><h1>" & H(titulo) & "</h1>" & _
        "<p>" & detalle & "</p>" & _
        "<a href=""" & Base() & "index.asp"">Volver al inicio</a>" & _
        "</div></body></html>"
    CloseConn
    Response.End
End Sub
%>
