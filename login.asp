<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Inicio de sesion
' =============================================================================
Dim usuario, clave, destino, errorMsg, idAutenticado

PageTitle    = "Iniciar sesion"
PageSubtitle = "Bienvenido de nuevo"

If IsLoggedIn() Then
    Response.Redirect Base() & "index.asp"
    Response.End
End If

destino  = SafeNext(Request.QueryString("next"))
errorMsg = ""

If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    usuario = Clean(Request.Form("usuario"))
    clave   = CStr(Nz(Request.Form("clave"), ""))
    destino = SafeNext(Request.Form("next"))

    If usuario = "" Or clave = "" Then
        errorMsg = "Escribe tu nombre de usuario y tu contrasena."
    Else
        idAutenticado = AuthenticateUser(usuario, clave)
        If idAutenticado > 0 Then
            SetFlash "Bienvenido, " & CurrentUserName() & ".", "ok"
            CloseConn
            Response.Redirect destino
            Response.End
        Else
            errorMsg = "Usuario o contrasena incorrectos. Revisa tus datos e intentalo de nuevo."
        End If
    End If
End If
%>
<!--#include file="includes/auth_head.asp"-->

      <h1>Iniciar sesion</h1>
      <p class="pm-sub">Accede con tu cuenta para reproducir y gestionar tus playlists.</p>

      <% If errorMsg <> "" Then %>
      <div class="pm-alert pm-alert--error" role="alert">
        <span class="pm-alert__ico"><%=Icon("alert")%></span>
        <span class="pm-alert__txt"><%=H(errorMsg)%></span>
      </div>
      <% End If %>
      <%=RenderFlash()%>

      <form class="pm-form" method="post" action="<%=Base()%>login.asp" autocomplete="on">
        <%=CsrfField()%>
        <input type="hidden" name="next" value="<%=H(destino)%>">

        <div class="pm-field">
          <label for="usuario">Usuario <span class="pm-req">*</span></label>
          <input class="pm-input" id="usuario" name="usuario" type="text" required maxlength="50"
                 value="<%=H(usuario)%>" autocomplete="username" placeholder="Tu nombre de usuario">
        </div>

        <div class="pm-field">
          <label for="clave">Contrasena <span class="pm-req">*</span></label>
          <input class="pm-input" id="clave" name="clave" type="password" required
                 autocomplete="current-password" placeholder="Tu contrasena">
        </div>

        <button class="pm-btn pm-btn--primary pm-btn--block" type="submit">
          <%=Icon("login")%><span>Entrar</span>
        </button>
      </form>

      <div class="pm-demo">
        <h4>Cuentas de prueba</h4>
        <ul>
          <li><strong>Administrador:</strong> <code>userAdmin</code> / <code>12345678</code></li>
          <li><strong>Usuario normal:</strong> <code>Axel.Manotoa</code> / <code>12345678</code></li>
          <li><strong>Usuario normal:</strong> <code>Claudio Penaherrera</code> / <code>claudio10</code></li>
        </ul>
      </div>

      <p class="pm-auth__foot">No tienes cuenta? <a href="<%=Base()%>register.asp">Registrate aqui</a></p>

<!--#include file="includes/auth_foot.asp"-->
