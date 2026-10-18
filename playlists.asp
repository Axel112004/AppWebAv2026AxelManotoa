<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Playlists del usuario
'  El usuario normal solo puede crear, consultar, actualizar y eliminar sus
'  PROPIAS playlists. La propiedad se comprueba siempre en el servidor.
' =============================================================================
RequireLogin

Dim accion, modoForm, idEdit, fTitulo, fTipo, fFoto, errorMsg, exitoMsg, nuevoId
Dim rs, cover, nMis, nPublicas, idEliminar, opcionesImagen, sqlLista
Dim esNueva, registroValido, propietarioOk, acciones

PageTitle   = "Mis playlists"
PageSection = "playlists"

accion  = LCase(Clean(Request.Form("accion")))
modoForm = ""
idEdit   = ToInt(Request.QueryString("editar"))
errorMsg = ""
exitoMsg = ""

If LCase(Clean(Request.QueryString("accion"))) = "nueva" Then modoForm = "nueva"

' ---------------------------------------------------------------------------
'  Acciones del formulario (POST)
' ---------------------------------------------------------------------------
If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    If accion = "guardar" Then
        idEdit  = ToInt(Request.Form("id_playlist"))
        fTitulo = Clean(Request.Form("titulo"))
        fTipo   = ToInt(Request.Form("tipo"))
        fFoto   = Clean(Request.Form("foto"))

        If fTitulo = "" Then
            errorMsg = "El titulo de la playlist es obligatorio."
        ElseIf Len(fTitulo) > MAX_TITLE_LEN Then
            errorMsg = "El titulo no puede superar los " & MAX_TITLE_LEN & " caracteres."
        ElseIf fTipo <> PLAYLIST_PUBLIC And fTipo <> PLAYLIST_PRIVATE Then
            errorMsg = "El tipo de playlist seleccionado no es valido."
        ElseIf Not ValidPlaylistPhoto(fFoto) Then
            errorMsg = "La imagen seleccionada no es valida."
        ElseIf idEdit > 0 Then
            ' --- Actualizacion: solo el propietario (o el admin) puede editar ---
            If Not CanManagePlaylist(idEdit) Then
                errorMsg = "No tienes permisos para modificar esa playlist."
            Else
                DBExecute "UPDATE TBL_PLAYLIST SET TITLE = ?, TYPE = ?, PHOTO = ? WHERE ID_PLAYLIST = ?", _
                          Array(fTitulo, fTipo, fFoto, idEdit)
                SetFlash "La playlist se actualizo correctamente.", "ok"
                CloseConn
                Response.Redirect Base() & "playlist.asp?id=" & idEdit
                Response.End
            End If
        Else
            ' --- Creacion: la playlist siempre pertenece al usuario de la sesion ---
            nuevoId = DBInsert( _
                "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO) VALUES (?, ?, GETDATE(), ?, ?)", _
                Array(CurrentUserId(), fTitulo, fTipo, fFoto))

            If nuevoId > 0 Then
                SetFlash "La playlist se creo correctamente. Ya puedes agregar canciones.", "ok"
                CloseConn
                Response.Redirect Base() & "playlist.asp?id=" & nuevoId
                Response.End
            Else
                errorMsg = "No se pudo crear la playlist. Intentalo de nuevo."
            End If
        End If

        modoForm = "form"

    ElseIf accion = "eliminar" Then
        idEliminar = ToInt(Request.Form("id_playlist"))

        If Not CanManagePlaylist(idEliminar) Then
            errorMsg = "No tienes permisos para eliminar esa playlist."
        Else
            ' Primero se quitan las canciones asociadas y luego la playlist
            DBExecute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", Array(idEliminar)
            DBExecute "DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(idEliminar)
            SetFlash "La playlist se elimino correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "playlists.asp"
            Response.End
        End If
    End If
End If

' ---------------------------------------------------------------------------
'  Datos para el formulario
' ---------------------------------------------------------------------------
If modoForm = "" And idEdit > 0 Then modoForm = "form"

fTitulo = ""
fTipo   = PLAYLIST_PUBLIC
fFoto   = ""

If modoForm = "form" And idEdit > 0 Then
    ' Carga de la playlist a editar (solo si es propia o el usuario es admin)
    If Not CanManagePlaylist(idEdit) Then
        AbortPage "Playlist no disponible", "La playlist que intentas editar no existe o no te pertenece."
    End If
    Set rs = DBQuery("SELECT TITLE, TYPE, PHOTO FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(idEdit))
    If Not rs.EOF Then
        fTitulo = Clean(rs("TITLE"))
        fTipo   = ToInt(rs("TYPE"))
        fFoto   = Clean(rs("PHOTO"))
    End If
    rs.Close
End If

opcionesImagen = ImageOptions(DIR_PLAYLIST, fFoto)

nMis      = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST WHERE ID_USER = ?", Array(CurrentUserId())))
nPublicas = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST WHERE TYPE = ? AND ID_USER <> ?", _
                           Array(PLAYLIST_PUBLIC, CurrentUserId())))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Mi musica", "playlist", "Mis playlists", _
    "Crea, edita y organiza tus listas. Solo tu puedes modificar las tuyas.", _
    "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "playlists.asp?accion=nueva"">" & _
    Icon("plus") & "<span>Nueva playlist</span></a>")%>

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
      <span class="pm-section__title"><%=Icon("edit")%> <% If idEdit > 0 Then %>Editar playlist<% Else %>Nueva playlist<% End If %></span>
    </div>
    <form method="post" action="<%=Base()%>playlists.asp">
      <div class="pm-panel__body">
        <%=CsrfField()%>
        <input type="hidden" name="accion" value="guardar">
        <input type="hidden" name="id_playlist" value="<%=idEdit%>">

        <div class="pm-form pm-form--2">
          <div class="pm-field pm-span-2">
            <label for="titulo">Titulo de la playlist <span class="pm-req">*</span></label>
            <input class="pm-input" id="titulo" name="titulo" type="text" required
                   maxlength="<%=MAX_TITLE_LEN%>" value="<%=H(fTitulo)%>"
                   placeholder="Por ejemplo: Mis favoritas de siempre">
          </div>

          <div class="pm-field">
            <label for="tipo">Visibilidad</label>
            <select class="pm-select" id="tipo" name="tipo">
              <option value="<%=PLAYLIST_PUBLIC%>"<% If fTipo = PLAYLIST_PUBLIC Then %> selected<% End If %>>
                <%=H(PlaylistTypeLabel(PLAYLIST_PUBLIC))%> - cualquiera puede verla
              </option>
              <option value="<%=PLAYLIST_PRIVATE%>"<% If fTipo = PLAYLIST_PRIVATE Then %> selected<% End If %>>
                <%=H(PlaylistTypeLabel(PLAYLIST_PRIVATE))%> - solo tu puedes verla
              </option>
            </select>
          </div>

          <div class="pm-field">
            <label for="foto">Imagen de portada</label>
            <select class="pm-select" id="foto" name="foto">
              <option value="">Sin imagen (portada generada)</option>
              <%=opcionesImagen%>
            </select>
          </div>
        </div>
      </div>
      <div class="pm-panel__foot">
        <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("save")%><span>Guardar</span></button>
        <a class="pm-btn pm-btn--ghost" href="<%=Base()%>playlists.asp">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("playlist")%> Mis playlists</h2>
    <span class="pm-badge"><%=nMis%></span>
  </div>

  <%
  Set rs = DBQuery(SqlPlaylistSelect(0) & "WHERE pl.ID_USER = ? ORDER BY pl.CREATION_DATE DESC, pl.TITLE", _
                   Array(CurrentUserId()))
  If rs.EOF Then
      Response.Write EmptyState("playlist", "Todavia no tienes playlists", _
          "Crea tu primera lista y empieza a agrupar las canciones que mas te gustan.", _
          "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "playlists.asp?accion=nueva"">" & _
          Icon("plus") & "<span>Nueva playlist</span></a>")
  Else
  %>
  <div class="pm-grid pm-grid--covers">
  <%
      Do While Not rs.EOF
          cover = CoverUrl(rs("PHOTO"), rs("TITLE"), rs("ID_PLAYLIST"))
          acciones = "<div class=""pm-song__foot"" style=""margin-top:11px"">" & _
              "<a class=""pm-btn pm-btn--ghost pm-btn--sm"" href=""" & Base() & "playlist.asp?id=" & ToInt(rs("ID_PLAYLIST")) & """>" & Icon("playlist") & "Abrir</a>" & _
              "<a class=""pm-btn pm-btn--ghost pm-btn--sm"" href=""" & Base() & "playlists.asp?editar=" & ToInt(rs("ID_PLAYLIST")) & """>" & Icon("edit") & "Editar</a>" & _
              "</div>" & _
              "<form method=""post"" action=""" & Base() & "playlists.asp"" data-confirmar=""Seguro que deseas eliminar la playlist &quot;" & H(rs("TITLE")) & "&quot;? Esta accion no se puede deshacer."">" & _
              CsrfField() & "<input type=""hidden"" name=""accion"" value=""eliminar"">" & _
              "<input type=""hidden"" name=""id_playlist"" value=""" & ToInt(rs("ID_PLAYLIST")) & """>" & _
              "<button class=""pm-btn pm-btn--danger pm-btn--sm pm-btn--block"" type=""submit"" style=""margin-top:7px"">" & _
              Icon("trash") & "Eliminar</button></form>"

          Response.Write PlaylistCard(rs("ID_PLAYLIST"), rs("TITLE"), PlaylistTypeLabel(rs("TYPE")), _
                                      rs("PROPIETARIO"), cover, rs("CANCIONES"), acciones)
          rs.MoveNext
      Loop
  %>
  </div>
  <%
  End If
  rs.Close
  %>
</section>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("sparkle")%> Playlists publicas de la comunidad</h2>
    <span class="pm-badge"><%=nPublicas%></span>
  </div>

  <%
  Set rs = DBQuery(SqlPlaylistSelect(0) & _
      "WHERE pl.TYPE = ? AND pl.ID_USER <> ? ORDER BY pl.CREATION_DATE DESC", _
      Array(PLAYLIST_PUBLIC, CurrentUserId()))
  If rs.EOF Then
      Response.Write EmptyState("sparkle", "Aun no hay playlists publicas", _
          "Cuando otros usuarios compartan sus listas apareceran en esta seccion.", "")
  Else
  %>
  <div class="pm-grid pm-grid--covers">
  <%
      Do While Not rs.EOF
          cover = CoverUrl(rs("PHOTO"), rs("TITLE"), rs("ID_PLAYLIST"))
          Response.Write PlaylistCard(rs("ID_PLAYLIST"), rs("TITLE"), PlaylistTypeLabel(rs("TYPE")), _
                                      rs("PROPIETARIO"), cover, rs("CANCIONES"), "")
          rs.MoveNext
      Loop
  %>
  </div>
  <%
  End If
  rs.Close
  %>
</section>

<!--#include file="includes/footer.asp"-->
