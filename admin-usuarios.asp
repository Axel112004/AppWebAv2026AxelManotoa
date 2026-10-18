<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Administracion de usuarios
'  Crear, consultar, actualizar y eliminar cuentas (solo ADMIN).
' =============================================================================
RequireAdmin

Dim accion, modoForm, idEdit, errorMsg, rs, nuevoId
Dim fUsuario, fCorreo, fClave, fClave2, fCumple, fFoto, fTipo
Dim total, idEliminar, tiposHtml, i, etiquetaTipo

PageTitle   = "Usuarios"
PageSection = "admin-usuarios"

accion   = LCase(Clean(Request.Form("accion")))
modoForm = ""
errorMsg = ""

If LCase(Clean(Request.QueryString("accion"))) = "nuevo" Then modoForm = "nuevo"
idEdit = ToInt(Request.QueryString("editar"))

' ---------------------------------------------------------------------------
'  Acciones
' ---------------------------------------------------------------------------
If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    If accion = "guardar" Then
        idEdit  = ToInt(Request.Form("id_user"))
        fUsuario = Clean(Request.Form("usuario"))
        fCorreo  = Clean(Request.Form("correo"))
        fClave   = CStr(Nz(Request.Form("clave"), ""))
        fClave2  = CStr(Nz(Request.Form("clave2"), ""))
        fCumple  = Clean(Request.Form("cumple"))
        fFoto    = Clean(Request.Form("foto"))
        fTipo    = ToInt(Request.Form("tipo"))

        If Len(fUsuario) < 3 Then
            errorMsg = "El nombre de usuario debe tener al menos 3 caracteres."
        ElseIf Len(fUsuario) > 50 Then
            errorMsg = "El nombre de usuario no puede superar los 50 caracteres."
        ElseIf Not IsValidEmail(fCorreo) Then
            errorMsg = "Escribe un correo electronico valido."
        ElseIf fTipo <> USER_TYPE_NORMAL And fTipo <> USER_TYPE_ADMIN Then
            errorMsg = "El tipo de usuario seleccionado no es valido."
        ElseIf Not ValidUserPhoto(fFoto) Then
            errorMsg = "La imagen de perfil seleccionada no es valida."
        ElseIf idEdit <= 0 And Len(fClave) < MIN_PASSWORD_LEN Then
            errorMsg = "La contrasena debe tener al menos " & MIN_PASSWORD_LEN & " caracteres."
        ElseIf fClave <> "" And Len(fClave) < MIN_PASSWORD_LEN Then
            errorMsg = "La contrasena debe tener al menos " & MIN_PASSWORD_LEN & " caracteres."
        ElseIf fClave <> fClave2 Then
            errorMsg = "Las dos contrasenas no coinciden."
        ElseIf DBExists("SELECT 1 FROM TBL_USER WHERE USERNAME = ? AND ID_USER <> ?", Array(fUsuario, idEdit)) Then
            errorMsg = "Ese nombre de usuario ya esta en uso."
        ElseIf DBExists("SELECT 1 FROM TBL_USER WHERE EMAIL = ? AND ID_USER <> ?", Array(fCorreo, idEdit)) Then
            errorMsg = "Ese correo ya esta asociado a otra cuenta."
        ElseIf idEdit > 0 Then
            If fClave <> "" Then
                DBExecute "UPDATE TBL_USER SET USERNAME = ?, EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ?, USER_TYPE = ?, PASSWORD = ? WHERE ID_USER = ?", _
                          Array(fUsuario, fCorreo, ParseDateInput(fCumple), fFoto, fTipo, HashPassword(fClave), idEdit)
            Else
                DBExecute "UPDATE TBL_USER SET USERNAME = ?, EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ?, USER_TYPE = ? WHERE ID_USER = ?", _
                          Array(fUsuario, fCorreo, ParseDateInput(fCumple), fFoto, fTipo, idEdit)
            End If
            SetFlash "El usuario se actualizo correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "admin-usuarios.asp"
            Response.End
        Else
            nuevoId = DBInsert( _
                "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) VALUES (?, ?, ?, ?, ?, ?)", _
                Array(fUsuario, HashPassword(fClave), fCorreo, ParseDateInput(fCumple), fFoto, fTipo))
            If nuevoId > 0 Then
                SetFlash "El usuario se creo correctamente.", "ok"
                CloseConn
                Response.Redirect Base() & "admin-usuarios.asp"
                Response.End
            Else
                errorMsg = "No se pudo crear el usuario."
            End If
        End If
        modoForm = "form"

    ElseIf accion = "eliminar" Then
        idEliminar = ToInt(Request.Form("id_user"))

        If idEliminar = CurrentUserId() Then
            errorMsg = "No puedes eliminar tu propia cuenta mientras la estas usando."
        ElseIf Not DBExists("SELECT 1 FROM TBL_USER WHERE ID_USER = ?", Array(idEliminar)) Then
            errorMsg = "El usuario ya no existe."
        Else
            ' Se eliminan primero las playlists del usuario y sus canciones asociadas
            DBExecute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST IN " & _
                      "(SELECT ID_PLAYLIST FROM TBL_PLAYLIST WHERE ID_USER = ?)", Array(idEliminar)
            DBExecute "DELETE FROM TBL_PLAYLIST WHERE ID_USER = ?", Array(idEliminar)
            DBExecute "DELETE FROM TBL_USER WHERE ID_USER = ?", Array(idEliminar)
            SetFlash "El usuario y sus playlists se eliminaron correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "admin-usuarios.asp"
            Response.End
        End If
    End If
End If

' ---------------------------------------------------------------------------
'  Formulario
' ---------------------------------------------------------------------------
If modoForm = "" And idEdit > 0 Then modoForm = "form"

fUsuario = ""
fCorreo  = ""
fCumple  = ""
fFoto    = ""
fTipo    = USER_TYPE_NORMAL
fClave   = ""
fClave2  = ""

If modoForm = "form" And idEdit > 0 Then
    Set rs = DBQuery("SELECT USERNAME, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE FROM TBL_USER WHERE ID_USER = ?", Array(idEdit))
    If rs.EOF Then
        rs.Close
        AbortPage "Usuario no encontrado", "El usuario solicitado no existe."
    End If
    fUsuario = Clean(rs("USERNAME"))
    fCorreo  = Clean(rs("EMAIL"))
    fCumple  = FormatDateInput(rs("BIRTHDAY"))
    fFoto    = Clean(rs("USER_PHOTO"))
    fTipo    = ToInt(rs("USER_TYPE"))
    rs.Close
End If

' Opciones del tipo de usuario tomadas de TBL_CATALOG (USER TYPE)
tiposHtml = ""
For i = 0 To 1
    etiquetaTipo = CatalogLabel("1", i)
    If etiquetaTipo = "" Then
        If i = USER_TYPE_ADMIN Then
            etiquetaTipo = "ADMIN"
        Else
            etiquetaTipo = "USER"
        End If
    End If
    tiposHtml = tiposHtml & "<option value=""" & i & """" & _
               IIfStr(fTipo = i, " selected", "") & ">" & H(etiquetaTipo) & "</option>"
Next

total = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_USER", Null))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Administracion", "users", "Usuarios", _
    Plural(total, "cuenta registrada", "cuentas registradas"), _
    "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "admin-usuarios.asp?accion=nuevo"">" & _
    Icon("plus") & "<span>Nuevo usuario</span></a>")%>

<% If errorMsg <> "" Then %>
<div class="pm-alert pm-alert--error" role="alert">
  <span class="pm-alert__ico"><%=Icon("alert")%></span>
  <span class="pm-alert__txt"><%=H(errorMsg)%></span>
</div>
<% End If %>

<% If modoForm <> "" Then %>
<section class="pm-section">
  <div class="pm-panel">
    <div class="pm-panel__head">
      <span class="pm-section__title"><%=Icon("user")%> <% If idEdit > 0 Then %>Editar usuario<% Else %>Nuevo usuario<% End If %></span>
    </div>
    <form method="post" action="<%=Base()%>admin-usuarios.asp">
      <div class="pm-panel__body">
        <%=CsrfField()%>
        <input type="hidden" name="accion" value="guardar">
        <input type="hidden" name="id_user" value="<%=idEdit%>">

        <div class="pm-form pm-form--3">
          <div class="pm-field">
            <label for="usuario">Nombre de usuario <span class="pm-req">*</span></label>
            <input class="pm-input" id="usuario" name="usuario" type="text" required
                   maxlength="50" value="<%=H(fUsuario)%>" placeholder="Sin espacios">
          </div>

          <div class="pm-field">
            <label for="correo">Correo electronico <span class="pm-req">*</span></label>
            <input class="pm-input" id="correo" name="correo" type="email" required
                   maxlength="50" value="<%=H(fCorreo)%>">
          </div>

          <div class="pm-field">
            <label for="tipo">Tipo de usuario</label>
            <select class="pm-select" id="tipo" name="tipo"><%=tiposHtml%></select>
          </div>

          <div class="pm-field">
            <label for="clave">Contrasena <% If idEdit <= 0 Then %><span class="pm-req">*</span><% End If %></label>
            <input class="pm-input" id="clave" name="clave" type="password" autocomplete="new-password"
                   placeholder="<% If idEdit > 0 Then %>Dejar vacio para no cambiarla<% Else %>Minimo <%=MIN_PASSWORD_LEN%> caracteres<% End If %>">
          </div>

          <div class="pm-field">
            <label for="clave2">Repite la contrasena</label>
            <input class="pm-input" id="clave2" name="clave2" type="password" autocomplete="new-password">
          </div>

          <div class="pm-field">
            <label for="cumple">Fecha de nacimiento</label>
            <input class="pm-input" id="cumple" name="cumple" type="date" value="<%=H(fCumple)%>">
          </div>

          <div class="pm-field pm-span-2">
            <label for="foto">Imagen de perfil</label>
            <select class="pm-select" id="foto" name="foto">
              <option value="">Sin imagen (se genera una)</option>
              <%=ImageOptions(DIR_USER, fFoto)%>
            </select>
          </div>
        </div>
      </div>
      <div class="pm-panel__foot">
        <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("save")%><span>Guardar</span></button>
        <a class="pm-btn pm-btn--ghost" href="<%=Base()%>admin-usuarios.asp">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<div class="pm-toolbar">
  <div class="pm-toolbar__search">
    <span class="pm-ico"><%=Icon("search")%></span>
    <label class="pm-sr" for="pmFiltro">Filtrar usuarios</label>
    <input class="pm-input" id="pmFiltro" type="search" placeholder="Filtrar por usuario, correo o tipo" autocomplete="off">
  </div>
</div>

<div class="pm-tablewrap">
  <table class="pm-table">
    <thead>
      <tr>
        <th>Usuario</th>
        <th>Correo</th>
        <th>Tipo</th>
        <th>Nacimiento</th>
        <th>Playlists</th>
        <th style="text-align:right">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <%
    Set rs = DBQuery( _
        "SELECT u.ID_USER, u.USERNAME, u.EMAIL, u.BIRTHDAY, u.USER_PHOTO, u.USER_TYPE, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST pl WHERE pl.ID_USER = u.ID_USER) AS PLAYLISTS " & _
        "FROM TBL_USER u ORDER BY u.USER_TYPE DESC, u.USERNAME", Null)

    If rs.EOF Then
        Response.Write "<tr><td colspan=""6"" class=""pm-hint"">No hay usuarios registrados.</td></tr>"
    Else
        Do While Not rs.EOF
            etiquetaTipo = CatalogLabel("1", rs("USER_TYPE"))
            If etiquetaTipo = "" Then etiquetaTipo = "USER"
    %>
      <tr data-fila="<%=H(rs("USERNAME") & " " & rs("EMAIL") & " " & etiquetaTipo)%>">
        <td>
          <div class="pm-table__main">
            <img class="pm-table__thumb" style="border-radius:50%" src="<%=AvatarUrl(rs("USER_PHOTO"), rs("USERNAME"), rs("ID_USER"))%>" alt="">
            <div>
              <div class="pm-table__title">
                <%=H(rs("USERNAME"))%>
                <% If ToInt(rs("ID_USER")) = CurrentUserId() Then %><span class="pm-badge">Tu</span><% End If %>
              </div>
              <div class="pm-table__sub">ID <%=ToInt(rs("ID_USER"))%></div>
            </div>
          </div>
        </td>
        <td class="pm-table__sub"><%=H(rs("EMAIL"))%></td>
        <td>
          <% If ToInt(rs("USER_TYPE")) = USER_TYPE_ADMIN Then %>
          <span class="pm-badge pm-badge--accent"><%=Icon("shield")%><%=H(etiquetaTipo)%></span>
          <% Else %>
          <span class="pm-badge pm-badge--muted"><%=H(etiquetaTipo)%></span>
          <% End If %>
        </td>
        <td class="pm-table__sub"><%=H(FormatDate(rs("BIRTHDAY")))%></td>
        <td class="pm-num"><%=ToInt(rs("PLAYLISTS"))%></td>
        <td>
          <div class="pm-table__actions">
            <a class="pm-iconbtn pm-iconbtn--sm" title="Editar" href="<%=Base()%>admin-usuarios.asp?editar=<%=ToInt(rs("ID_USER"))%>"><%=Icon("edit")%></a>
            <% If ToInt(rs("ID_USER")) <> CurrentUserId() Then %>
            <form method="post" action="<%=Base()%>admin-usuarios.asp" data-confirmar="Eliminar al usuario <%=H(rs("USERNAME"))%>? Tambien se borraran sus playlists.">
              <%=CsrfField()%>
              <input type="hidden" name="accion" value="eliminar">
              <input type="hidden" name="id_user" value="<%=ToInt(rs("ID_USER"))%>">
              <button class="pm-iconbtn pm-iconbtn--sm pm-iconbtn--danger" type="submit" title="Eliminar"><%=Icon("trash")%></button>
            </form>
            <% End If %>
          </div>
        </td>
      </tr>
    <%
            rs.MoveNext
        Loop
    End If
    rs.Close
    %>
    </tbody>
  </table>
</div>

<!--#include file="includes/footer.asp"-->
