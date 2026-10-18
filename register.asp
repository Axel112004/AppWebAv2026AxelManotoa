<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Registro de usuarios normales
'  Todo usuario que se registra obtiene el tipo USER (0) definido en TBL_CATALOG.
' =============================================================================
Dim usuario, correo, clave, clave2, cumple, errorMsg, errores, nuevoId
Dim yaExisteUsuario, yaExisteCorreo, fechaNac, fotoDefecto

PageTitle    = "Crear cuenta"
PageSubtitle = "Crea tu cuenta gratuita"

If IsLoggedIn() Then
    Response.Redirect Base() & "index.asp"
    Response.End
End If

usuario  = ""
correo   = ""
cumple   = ""
errorMsg = ""

If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    usuario = Clean(Request.Form("usuario"))
    correo  = Clean(Request.Form("correo"))
    clave   = CStr(Nz(Request.Form("clave"), ""))
    clave2  = CStr(Nz(Request.Form("clave2"), ""))
    cumple  = Clean(Request.Form("cumple"))

    If Len(usuario) < 3 Then
        errorMsg = "El nombre de usuario debe tener al menos 3 caracteres."
    ElseIf Len(usuario) > 50 Then
        errorMsg = "El nombre de usuario no puede superar los 50 caracteres."
    ElseIf InStr(usuario, " ") > 0 Then
        errorMsg = "El nombre de usuario no puede contener espacios."
    ElseIf Not IsValidEmail(correo) Then
        errorMsg = "Escribe un correo electronico valido (por ejemplo nombre@dominio.com)."
    ElseIf Len(clave) < MIN_PASSWORD_LEN Then
        errorMsg = "La contrasena debe tener al menos " & MIN_PASSWORD_LEN & " caracteres."
    ElseIf clave <> clave2 Then
        errorMsg = "Las dos contrasenas no coinciden."
    Else
        ' Comprobacion de duplicados con consultas parametrizadas
        yaExisteUsuario = DBExists("SELECT 1 FROM TBL_USER WHERE USERNAME = ?", Array(usuario))
        yaExisteCorreo  = DBExists("SELECT 1 FROM TBL_USER WHERE EMAIL = ?", Array(correo))

        If yaExisteUsuario Then
            errorMsg = "Ese nombre de usuario ya esta en uso. Elige otro."
        ElseIf yaExisteCorreo Then
            errorMsg = "Ese correo ya tiene una cuenta registrada."
        Else
            fechaNac    = ParseDateInput(cumple)
            fotoDefecto = "~/userImages/default.jpg"

            nuevoId = DBInsert( _
                "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) " & _
                "VALUES (?, ?, ?, ?, ?, ?)", _
                Array(usuario, HashPassword(clave), correo, fechaNac, fotoDefecto, USER_TYPE_NORMAL))

            If nuevoId > 0 Then
                SetFlash "Tu cuenta se creo correctamente. Ya puedes iniciar sesion.", "ok"
                CloseConn
                Response.Redirect Base() & "login.asp"
                Response.End
            Else
                errorMsg = "No se pudo crear la cuenta. Intentalo de nuevo en unos segundos."
            End If
        End If
    End If
End If
%>
<!--#include file="includes/auth_head.asp"-->

      <h1>Crear cuenta</h1>
      <p class="pm-sub">Solo toma un momento. Con tu cuenta podras reproducir musica y crear playlists.</p>

      <% If errorMsg <> "" Then %>
      <div class="pm-alert pm-alert--error" role="alert">
        <span class="pm-alert__ico"><%=Icon("alert")%></span>
        <span class="pm-alert__txt"><%=H(errorMsg)%></span>
      </div>
      <% End If %>

      <form class="pm-form" method="post" action="<%=Base()%>register.asp" autocomplete="on">
        <%=CsrfField()%>

        <div class="pm-field">
          <label for="usuario">Nombre de usuario <span class="pm-req">*</span></label>
          <input class="pm-input" id="usuario" name="usuario" type="text" required
                 minlength="3" maxlength="50" value="<%=H(usuario)%>"
                 autocomplete="username" placeholder="Sin espacios, por ejemplo Axel.Manotoa">
          <span class="pm-hint">Entre 3 y 50 caracteres, sin espacios.</span>
        </div>

        <div class="pm-field">
          <label for="correo">Correo electronico <span class="pm-req">*</span></label>
          <input class="pm-input" id="correo" name="correo" type="email" required maxlength="50"
                 value="<%=H(correo)%>" autocomplete="email" placeholder="nombre@dominio.com">
        </div>

        <div class="pm-field">
          <label for="cumple">Fecha de nacimiento</label>
          <input class="pm-input" id="cumple" name="cumple" type="date" value="<%=H(cumple)%>">
          <span class="pm-hint">Opcional.</span>
        </div>

        <div class="pm-field">
          <label for="clave">Contrasena <span class="pm-req">*</span></label>
          <input class="pm-input" id="clave" name="clave" type="password" required
                 minlength="<%=MIN_PASSWORD_LEN%>" autocomplete="new-password"
                 placeholder="Minimo <%=MIN_PASSWORD_LEN%> caracteres">
        </div>

        <div class="pm-field">
          <label for="clave2">Repite la contrasena <span class="pm-req">*</span></label>
          <input class="pm-input" id="clave2" name="clave2" type="password" required
                 minlength="<%=MIN_PASSWORD_LEN%>" autocomplete="new-password"
                 placeholder="Escribe la misma contrasena">
        </div>

        <button class="pm-btn pm-btn--primary pm-btn--block" type="submit">
          <%=Icon("check")%><span>Crear mi cuenta</span>
        </button>
      </form>

      <p class="pm-auth__foot">Ya tienes cuenta? <a href="<%=Base()%>login.asp">Inicia sesion</a></p>

<!--#include file="includes/auth_foot.asp"-->
