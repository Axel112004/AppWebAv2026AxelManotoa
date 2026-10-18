<%
' =============================================================================
'  PoliMusic | Capa de acceso a datos
' -----------------------------------------------------------------------------
'  TODAS las consultas que reciben datos del usuario son PARAMETRIZADAS.
'  Nunca se concatenan valores en el texto de la consulta: de esta forma se
'  evita por completo la inyeccion SQL.
'
'  Los parametros se escriben con el marcador  ?  en el orden en que se pasan
'  dentro del arreglo de valores.
'
'  Ejemplo:
'      Set rs = DBQuery("SELECT * FROM TBL_SONG WHERE ID_SONG = ?", Array(id))
' =============================================================================

' --- Constantes ADO ----------------------------------------------------------
Const adCmdText       = 1
Const adParamInput    = 1
Const adInteger       = 3
Const adDouble        = 5
Const adBoolean       = 11
Const adDBTimeStamp   = 135
Const adVarWChar      = 202
Const adOpenForwardOnly = 0
Const adOpenStatic      = 3
Const adLockReadOnly    = 1

' -----------------------------------------------------------------------------
'  Cadena de conexion
' -----------------------------------------------------------------------------
Function ConnectionString()
    Dim cs
    If UCase(DB_PROVIDER) = "MSOLEDBSQL" Then
        cs = "Provider=MSOLEDBSQL;Server=" & DB_SERVER & ";Database=" & DB_NAME & _
             ";UID=" & DB_USER & ";PWD=" & DB_PASS & _
             ";TrustServerCertificate=Yes;Encrypt=Optional;"
    Else
        cs = "Provider=SQLOLEDB;Server=" & DB_SERVER & ";Database=" & DB_NAME & _
             ";UID=" & DB_USER & ";PWD=" & DB_PASS & ";"
    End If
    ConnectionString = cs
End Function

' -----------------------------------------------------------------------------
'  Conexion compartida durante toda la peticion (una sola por pagina)
' -----------------------------------------------------------------------------
Dim gConn
Dim gConnAbierta

Function Conn()
    If Not gConnAbierta Then
        Set gConn = OpenConnection()
        gConnAbierta = True
    End If
    Set Conn = gConn
End Function

Function OpenConnection()
    Dim cn, detalle
    Set cn = Server.CreateObject("ADODB.Connection")
    cn.ConnectionTimeout = 10
    cn.CommandTimeout = 30

    On Error Resume Next
    cn.Open ConnectionString()
    If Err.Number <> 0 Then
        detalle = Err.Description
        Err.Clear
        On Error GoTo 0
        Set cn = Nothing
        AbortPage "No se pudo conectar con la base de datos", _
                  "Verifica que el servicio de SQL Server este activo y que los datos " & _
                  "de conexion definidos en includes/config.asp sean correctos.<br><br>" & _
                  "<strong>Detalle tecnico:</strong> " & Server.HTMLEncode(detalle)
    End If
    On Error GoTo 0

    Set OpenConnection = cn
End Function

Sub CloseConn()
    On Error Resume Next
    If gConnAbierta Then
        If Not (gConn Is Nothing) Then
            If gConn.State = 1 Then gConn.Close
        End If
    End If
    Set gConn = Nothing
    gConnAbierta = False
    Err.Clear
    On Error GoTo 0
End Sub

' -----------------------------------------------------------------------------
'  Traduce el tipo del valor VBScript al tipo de parametro ADO
' -----------------------------------------------------------------------------
Function ParamType(ByVal v)
    Select Case VarType(v)
        Case 2, 3
            ParamType = adInteger
        Case 4, 5, 6
            ParamType = adDouble
        Case 7
            ParamType = adDBTimeStamp
        Case 11
            ParamType = adBoolean
        Case Else
            ParamType = adVarWChar
    End Select
End Function

' -----------------------------------------------------------------------------
'  Construye un ADODB.Command con sus parametros ya enlazados
' -----------------------------------------------------------------------------
Function PrepareCommand(ByRef cn, ByVal sql, ByVal params)
    Dim cmd, i, valor, tipo, tam

    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = cn
    cmd.CommandType = adCmdText
    cmd.CommandText = "SET NOCOUNT ON; " & sql

    If IsArray(params) Then
        For i = 0 To UBound(params)
            valor = params(i)
            If IsNull(valor) Or IsEmpty(valor) Then
                cmd.Parameters.Append cmd.CreateParameter("@p" & i, adVarWChar, adParamInput, 4000, Null)
            Else
                tipo = ParamType(valor)
                If tipo = adVarWChar Then
                    tam = Len(CStr(valor)) + 1
                    If tam < 4000 Then tam = 4000
                Else
                    tam = 0
                End If
                cmd.Parameters.Append cmd.CreateParameter("@p" & i, tipo, adParamInput, tam, valor)
            End If
        Next
    End If

    Set PrepareCommand = cmd
End Function

' -----------------------------------------------------------------------------
'  SELECT -> Recordset de solo lectura y solo avance
' -----------------------------------------------------------------------------
Function DBQuery(ByVal sql, ByVal params)
    Dim cmd
    Set cmd = PrepareCommand(Conn(), sql, params)
    Set DBQuery = cmd.Execute
End Function

' -----------------------------------------------------------------------------
'  SELECT -> primer valor de la primera fila (Null si no hay resultados)
' -----------------------------------------------------------------------------
Function DBScalar(ByVal sql, ByVal params)
    Dim rs, v
    v = Null
    Set rs = DBQuery(sql, params)
    If Not rs Is Nothing Then
        If rs.State = 1 Then
            If Not rs.EOF Then v = rs(0)
            rs.Close
        End If
    End If
    DBScalar = v
End Function

' -----------------------------------------------------------------------------
'  SELECT -> True si la consulta devuelve al menos una fila
' -----------------------------------------------------------------------------
Function DBExists(ByVal sql, ByVal params)
    Dim rs, hay
    hay = False
    Set rs = DBQuery(sql, params)
    If Not rs Is Nothing Then
        If rs.State = 1 Then
            If Not rs.EOF Then hay = True
            rs.Close
        End If
    End If
    DBExists = hay
End Function

' -----------------------------------------------------------------------------
'  INSERT / UPDATE / DELETE -> numero de filas afectadas
' -----------------------------------------------------------------------------
Function DBExecute(ByVal sql, ByVal params)
    Dim cmd, rs, filas
    filas = 0
    Set cmd = PrepareCommand(Conn(), sql & "; SELECT CAST(@@ROWCOUNT AS INT) AS FILAS;", params)
    Set rs = cmd.Execute
    If rs.State = 1 Then
        If Not rs.EOF Then
            If Not IsNull(rs(0)) Then filas = CLng(rs(0))
        End If
        rs.Close
    End If
    DBExecute = filas
End Function

' -----------------------------------------------------------------------------
'  INSERT -> devuelve el IDENTITY generado (o 0 si no se pudo obtener)
' -----------------------------------------------------------------------------
Function DBInsert(ByVal sql, ByVal params)
    Dim cmd, rs, nuevo
    nuevo = 0
    Set cmd = PrepareCommand(Conn(), sql & "; SELECT CAST(SCOPE_IDENTITY() AS INT) AS NUEVO_ID;", params)
    Set rs = cmd.Execute
    If rs.State = 1 Then
        If Not rs.EOF Then
            If Not IsNull(rs(0)) Then nuevo = CLng(rs(0))
        End If
        rs.Close
    End If
    DBInsert = nuevo
End Function

' -----------------------------------------------------------------------------
'  Calculo del hash SHA-1 de una contrasena.
'  Se delega en SQL Server (HASHBYTES) para no depender de librerias externas.
'  Se fuerza VARCHAR para que el hash coincida con el formato almacenado.
' -----------------------------------------------------------------------------
Function HashPassword(ByVal clave)
    Dim h
    h = DBScalar("SELECT CONVERT(VARCHAR(40), HASHBYTES('SHA1', CAST(? AS VARCHAR(100))), 2)", Array(clave))
    If IsNull(h) Then
        HashPassword = ""
    Else
        HashPassword = h
    End If
End Function
%>
