<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Perfil del usuario
'  Permite actualizar los datos propios y cambiar la contrasena.
'  Ningun usuario puede modificar datos de otra cuenta desde aqui: el ID se
'  toma siempre de la sesion, nunca del formulario.
' =============================================================================
RequireLogin

Dim accion, errorMsg, exitoMsg, rs
Dim fCorreo, fCumple, fFoto, cActual, cNueva, cNueva2
Dim correoActual, cumpleActual, fotoActual, tipoEtiqueta, nPlaylists, nCanciones

PageTitle   = "Mi perfil"
PageSection = "perfil"

accion   = LCase(Clean(Request.Form("accion")))
errorMsg = ""

' ---------------------------------------------------------------------------
'  Acciones
' ---------------------------------------------------------------------------
If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    If accion = "datos" Then
        fCorreo  = Clean(Request.Form("correo"))
        fCumple  = Clean(Request.Form("cumple"))
        fFoto    = Clean(Request.Form("foto"))

        If Not IsValidEmail(fCorreo) Then
            errorMsg = "Escribe un correo electronico valido."
        ElseIf DBExists("SELECT 1 FROM TBL_USER WHERE EMAIL = ? AND ID_USER <> ?", _
                        Array(fCorreo, CurrentUserId())) Then
            errorMsg = "Ese correo ya esta asociado a otra cuenta."
        ElseIf Not ValidUserPhoto(fFoto) Then
            errorMsg = "La imagen de perfil seleccionada no es valida."
        Else
            DBExecute "UPDATE TBL_USER SET EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ? WHERE ID_USER = ?", _
                      Array(fCorreo, ParseDateInput(fCumple), fFoto, CurrentUserId())
            RefreshSession CurrentUserId()
            SetFlash "Tus datos se actualizaron correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "profile.asp"
            Response.End
        End If

    ElseIf accion = "clave" Then
        cActual = CStr(Nz(Request.Form("clave_actual"), ""))
        cNueva  = CStr(Nz(Request.Form("clave_nueva"), ""))
        cNueva2 = CStr(Nz(Request.Form("clave_nueva2"), ""))

        If cActual = "" Or cNueva = "" Or cNueva2 = "" Then
            errorMsg = "Completa los tres campos de contrasena."
        ElseIf Len(cNueva) < MIN_PASSWORD_LEN Then
            errorMsg = "La nueva contrasena debe tener al menos " & MIN_PASSWORD_LEN & " caracteres."
        ElseIf cNueva <> cNueva2 Then
            errorMsg = "La nueva contrasena y su confirmacion no coinciden."
        ElseIf Not DBExists("SELECT 1 FROM TBL_USER WHERE ID_USER = ? AND (PASSWORD = ? OR PASSWORD = ?)", _
                            Array(CurrentUserId(), HashPassword(cActual), cActual)) Then
            errorMsg = "La contrasena actual no es correcta."
        Else
            DBExecute "UPDATE TBL_USER SET PASSWORD = ? WHERE ID_USER = ?", _
                      Array(HashPassword(cNueva), CurrentUserId())
            SetFlash "Tu contrasena se cambio correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "profile.asp"
            Response.End
        End If
    End If
End If

' ---------------------------------------------------------------------------
'  Datos actuales
' ---------------------------------------------------------------------------
Set rs = DBQuery("SELECT USERNAME, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE FROM TBL_USER WHERE ID_USER = ?", _
                 Array(CurrentUserId()))
If rs.EOF Then
    rs.Close
    DestroySession
    Response.Redirect Base() & "login.asp"
    Response.End
End If

correoActual = Clean(rs("EMAIL"))
cumpleActual = FormatDateInput(rs("BIRTHDAY"))
fotoActual   = Clean(rs("USER_PHOTO"))
tipoEtiqueta = CatalogLabel("1", ToInt(rs("USER_TYPE")))
rs.Close

nPlaylists = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST WHERE ID_USER = ?", Array(CurrentUserId())))
nCanciones = ToInt(DBScalar( _
    "SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps INNER JOIN TBL_PLAYLIST pl ON pl.ID_PLAYLIST = ps.ID_PLAYLIST " & _
    "WHERE pl.ID_USER = ?", Array(CurrentUserId())))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Mi cuenta", "user", "Mi perfil", _
    "Administra tus datos personales y tu contrasena.", "")%>

<% If errorMsg <> "" Then %>
<div class="pm-alert pm-alert--error" role="alert">
  <span class="pm-alert__ico"><%=Icon("alert")%></span>
  <span class="pm-alert__txt"><%=H(errorMsg)%></span>
</div>
<% End If %>

<div class="pm-stats">
  <div class="pm-stat">
    <span class="pm-stat__ico"><%=Icon("playlist")%></span>
    <span><span class="pm-stat__n"><%=nPlaylists%></span><br><span class="pm-stat__l">Playlists creadas</span></span>
  </div>
  <div class="pm-stat">
    <span class="pm-stat__ico pm-stat__ico--accent"><%=Icon("music")%></span>
    <span><span class="pm-stat__n"><%=nCanciones%></span><br><span class="pm-stat__l">Canciones guardadas</span></span>
  </div>
  <div class="pm-stat">
    <span class="pm-stat__ico pm-stat__ico--ok"><%=Icon("shield")%></span>
    <span><span class="pm-stat__n" style="font-size:17px"><%=H(tipoEtiqueta)%></span><br><span class="pm-stat__l">Tipo de cuenta</span></span>
  </div>
</div>

<div class="pm-grid pm-grid--wide">
  <div class="pm-panel">
    <div class="pm-panel__head">
      <img src="<%=AvatarUrl(fotoActual, CurrentUserName(), CurrentUserId())%>" alt=""
           style="width:46px;height:46px;border-radius:50%;object-fit:cover">
      <div>
        <h2><%=H(CurrentUserName())%></h2>
        <span class="pm-hint">Los datos se guardan de forma segura en el servidor.</span>
      </div>
    </div>
    <form method="post" action="<%=Base()%>profile.asp">
      <div class="pm-panel__body">
        <%=CsrfField()%>
        <input type="hidden" name="accion" value="datos">

        <div class="pm-form">
          <div class="pm-field">
            <label for="correo">Correo electronico <span class="pm-req">*</span></label>
            <input class="pm-input" id="correo" name="correo" type="email" required maxlength="50"
                   value="<%=H(correoActual)%>">
          </div>

          <div class="pm-field">
            <label for="cumple">Fecha de nacimiento</label>
            <input class="pm-input" id="cumple" name="cumple" type="date" value="<%=H(cumpleActual)%>">
          </div>

          <div class="pm-field">
            <label for="foto">Imagen de perfil</label>
            <select class="pm-select" id="foto" name="foto">
              <option value="">Sin imagen (se genera una)</option>
              <%=ImageOptions(DIR_USER, fotoActual)%>
            </select>
          </div>

          <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("save")%><span>Guardar cambios</span></button>
        </div>
      </div>
    </form>
  </div>

  <div class="pm-panel">
    <div class="pm-panel__head">
      <span class="pm-section__title"><%=Icon("key")%> Cambiar contrasena</span>
    </div>
    <form method="post" action="<%=Base()%>profile.asp">
      <div class="pm-panel__body">
        <%=CsrfField()%>
        <input type="hidden" name="accion" value="clave">

        <div class="pm-form">
          <div class="pm-field">
            <label for="clave_actual">Contrasena actual <span class="pm-req">*</span></label>
            <input class="pm-input" id="clave_actual" name="clave_actual" type="password" required
                   autocomplete="current-password">
          </div>

          <div class="pm-field">
            <label for="clave_nueva">Nueva contrasena <span class="pm-req">*</span></label>
            <input class="pm-input" id="clave_nueva" name="clave_nueva" type="password" required
                   minlength="<%=MIN_PASSWORD_LEN%>" autocomplete="new-password">
            <span class="pm-hint">Minimo <%=MIN_PASSWORD_LEN%> caracteres.</span>
          </div>

          <div class="pm-field">
            <label for="clave_nueva2">Repite la nueva contrasena <span class="pm-req">*</span></label>
            <input class="pm-input" id="clave_nueva2" name="clave_nueva2" type="password" required
                   minlength="<%=MIN_PASSWORD_LEN%>" autocomplete="new-password">
          </div>

          <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("key")%><span>Cambiar contrasena</span></button>
        </div>
      </div>
    </form>
  </div>
</div>

<!--#include file="includes/footer.asp"-->
