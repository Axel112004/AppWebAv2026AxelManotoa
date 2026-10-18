<%
' =============================================================================
'  PoliMusic | Autenticacion y permisos
' -----------------------------------------------------------------------------
'  Los permisos SIEMPRE se comprueban en el servidor. Ocultar un boton en la
'  interfaz no es suficiente: cada pagina y cada accion validan la sesion y el
'  tipo de usuario antes de tocar la base de datos.
' =============================================================================

' -----------------------------------------------------------------------------
'  Estado de la sesion
' -----------------------------------------------------------------------------
Function IsLoggedIn()
    IsLoggedIn = (ToInt(Session("usuario_id")) > 0)
End Function

Function CurrentUserId()
    CurrentUserId = ToInt(Session("usuario_id"))
End Function

Function CurrentUserName()
    CurrentUserName = CStr(Nz(Session("usuario_nombre"), ""))
End Function

Function CurrentUserEmail()
    CurrentUserEmail = CStr(Nz(Session("usuario_email"), ""))
End Function

Function CurrentUserPhoto()
    CurrentUserPhoto = CStr(Nz(Session("usuario_foto"), ""))
End Function

Function CurrentUserType()
    If Not IsLoggedIn() Then
        CurrentUserType = -1
    Else
        CurrentUserType = ToInt(Session("usuario_tipo"))
    End If
End Function

Function IsAdmin()
    IsAdmin = (IsLoggedIn() And CurrentUserType() = USER_TYPE_ADMIN)
End Function

'  Etiqueta legible del tipo de usuario, tomada de TBL_CATALOG
Function CurrentUserTypeLabel()
    CurrentUserTypeLabel = CatalogLabel("1", CurrentUserType())
End Function

' -----------------------------------------------------------------------------
'  Inicio y cierre de sesion
' -----------------------------------------------------------------------------
'  Comprueba las credenciales y, si son correctas, crea la sesion.
'  Devuelve el ID_USER (>0) cuando el acceso es valido, o 0 cuando falla.
Function AuthenticateUser(ByVal usuario, ByVal clave)
    Dim rs, hash, id, guardada

    id = 0
    hash = HashPassword(clave)

    ' Se admiten dos formatos de contrasena:
    '   - Hash SHA-1 (formato que utiliza la aplicacion al registrar usuarios)
    '   - Texto plano (registros historicos cargados por BDD_PoliMusic.sql)
    Set rs = DBQuery( _
        "SELECT ID_USER, USERNAME, USER_TYPE, USER_PHOTO, EMAIL, PASSWORD " & _
        "FROM TBL_USER WHERE USERNAME = ? AND (PASSWORD = ? OR PASSWORD = ?)", _
        Array(usuario, hash, clave))

    If Not rs.EOF Then
        id = CLng(rs("ID_USER"))
        guardada = CStr(Nz(rs("PASSWORD"), ""))

        Session("usuario_id")     = id
        Session("usuario_nombre") = CStr(Nz(rs("USERNAME"), ""))
        Session("usuario_tipo")   = ToInt(rs("USER_TYPE"))
        Session("usuario_foto")   = CStr(Nz(rs("USER_PHOTO"), ""))
        Session("usuario_email")  = CStr(Nz(rs("EMAIL"), ""))

        ' Migracion transparente: si la contrasena estaba en texto plano,
        ' se vuelve a guardar ya protegida con SHA-1.
        If guardada <> hash Then
            DBExecute "UPDATE TBL_USER SET PASSWORD = ? WHERE ID_USER = ?", Array(hash, id)
        End If
    End If
    rs.Close

    AuthenticateUser = id
End Function

'  Refresca los datos de la sesion tras modificar el propio perfil
Sub RefreshSession(ByVal idUsuario)
    Dim rs
    Set rs = DBQuery("SELECT USERNAME, USER_TYPE, USER_PHOTO, EMAIL FROM TBL_USER WHERE ID_USER = ?", Array(idUsuario))
    If Not rs.EOF Then
        Session("usuario_nombre") = CStr(Nz(rs("USERNAME"), ""))
        Session("usuario_tipo")   = ToInt(rs("USER_TYPE"))
        Session("usuario_foto")   = CStr(Nz(rs("USER_PHOTO"), ""))
        Session("usuario_email")  = CStr(Nz(rs("EMAIL"), ""))
    End If
    rs.Close
End Sub

Sub DestroySession()
    Session.Contents.RemoveAll()
    Session.Abandon()
End Sub

' -----------------------------------------------------------------------------
'  Guardias de acceso
' -----------------------------------------------------------------------------
Sub RequireLogin()
    If Not IsLoggedIn() Then
        SetFlash "Inicia sesion para continuar.", "aviso"
        Response.Redirect Base() & "login.asp?next=" & UrlEnc(Request.ServerVariables("URL"))
        Response.End
    End If
End Sub

Sub RequireAdmin()
    If Not IsLoggedIn() Then
        SetFlash "Inicia sesion con una cuenta de administrador.", "aviso"
        Response.Redirect Base() & "login.asp?next=" & UrlEnc(Request.ServerVariables("URL"))
        Response.End
    End If
    If Not IsAdmin() Then
        SetFlash "Solo el administrador puede acceder a ese modulo.", "error"
        Response.Redirect Base() & "index.asp"
        Response.End
    End If
End Sub

'  Evita redirecciones abiertas: solo se aceptan rutas internas del sitio
Function SafeNext(ByVal valor)
    Dim s
    s = Clean(valor)
    If s = "" Then
        SafeNext = Base() & "index.asp"
        Exit Function
    End If
    If InStr(s, ":") > 0 Or InStr(s, "//") > 0 Or Left(s, 1) <> "/" Then
        SafeNext = Base() & "index.asp"
        Exit Function
    End If
    SafeNext = s
End Function

' -----------------------------------------------------------------------------
'  Permisos sobre playlists
' -----------------------------------------------------------------------------
'  El propietario y el administrador pueden modificar una playlist.
Function CanManagePlaylist(ByVal idPlaylist)
    If Not IsLoggedIn() Then
        CanManagePlaylist = False
        Exit Function
    End If
    If IsAdmin() Then
        CanManagePlaylist = True
        Exit Function
    End If
    CanManagePlaylist = DBExists( _
        "SELECT 1 FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ? AND ID_USER = ?", _
        Array(idPlaylist, CurrentUserId()))
End Function

'  Una playlist se puede consultar si es publica, propia o si es el admin.
Function CanViewPlaylist(ByVal idPlaylist)
    If Not IsLoggedIn() Then
        CanViewPlaylist = False
        Exit Function
    End If
    If IsAdmin() Then
        CanViewPlaylist = True
        Exit Function
    End If
    CanViewPlaylist = DBExists( _
        "SELECT 1 FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ? AND (ID_USER = ? OR TYPE = ?)", _
        Array(idPlaylist, CurrentUserId(), PLAYLIST_PUBLIC))
End Function
%>
