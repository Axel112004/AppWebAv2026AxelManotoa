<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Detalle de una playlist
'  Permite consultar la lista y, si la playlist es propia (o el usuario es
'  administrador), agregar y quitar canciones.
' =============================================================================
RequireLogin

Dim idPlaylist, rs, idx, cover, artistas, preview, subtitulo
Dim tituloPlaylist, tipoPlaylist, propietario, totalCanciones, puedoEditar
Dim accion, idCancion, errorMsg, opcionesCanciones, hayDisponibles, acciones

PageTitle   = "Playlist"
PageSection = "playlists"

idPlaylist = ToInt(Request.QueryString("id"))
If idPlaylist <= 0 Then AbortPage "Playlist no encontrada", "La direccion solicitada no es valida."

If Not CanViewPlaylist(idPlaylist) Then
    AbortPage "Playlist privada", "Esta playlist es privada y no tienes permiso para consultarla."
End If

' ---------------------------------------------------------------------------
'  Acciones: agregar o quitar canciones
' ---------------------------------------------------------------------------
errorMsg = ""

If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    accion    = LCase(Clean(Request.Form("accion")))
    idCancion = ToInt(Request.Form("id_song"))

    If Not CanManagePlaylist(idPlaylist) Then
        SetFlash "No tienes permisos para modificar esa playlist.", "error"
        CloseConn
        Response.Redirect Base() & "playlist.asp?id=" & idPlaylist
        Response.End
    End If

    If idCancion <= 0 Then
        errorMsg = "Debes seleccionar una cancion valida."
    ElseIf accion = "agregar" Then
        If Not DBExists("SELECT 1 FROM TBL_SONG WHERE ID_SONG = ?", Array(idCancion)) Then
            errorMsg = "La cancion seleccionada no existe en el catalogo."
        ElseIf DBExists("SELECT 1 FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", _
                        Array(idPlaylist, idCancion)) Then
            errorMsg = "Esa cancion ya forma parte de la playlist."
        Else
            DBExecute "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (?, ?)", _
                      Array(idPlaylist, idCancion)
            SetFlash "La cancion se agrego a la playlist.", "ok"
            CloseConn
            Response.Redirect Base() & "playlist.asp?id=" & idPlaylist
            Response.End
        End If
    ElseIf accion = "quitar" Then
        DBExecute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", _
                  Array(idPlaylist, idCancion)
        SetFlash "La cancion se quito de la playlist.", "ok"
        CloseConn
        Response.Redirect Base() & "playlist.asp?id=" & idPlaylist
        Response.End
    End If
End If

' ---------------------------------------------------------------------------
'  Datos de la playlist
' ---------------------------------------------------------------------------
Set rs = DBQuery(SqlPlaylistSelect(0) & "WHERE pl.ID_PLAYLIST = ?", Array(idPlaylist))
If rs.EOF Then
    rs.Close
    AbortPage "Playlist no encontrada", "La playlist que buscas no existe o fue eliminada."
End If

tituloPlaylist = Clean(rs("TITLE"))
tipoPlaylist   = PlaylistTypeLabel(rs("TYPE"))
propietario    = Clean(rs("PROPIETARIO"))
totalCanciones = ToInt(rs("CANCIONES"))
cover          = CoverUrl(rs("PHOTO"), tituloPlaylist, rs("ID_PLAYLIST"))
rs.Close

puedoEditar = CanManagePlaylist(idPlaylist)

PageTitle = tituloPlaylist

' Canciones que todavia no estan en la playlist
opcionesCanciones = ""
Set rs = DBQuery("SELECT s.ID_SONG, s.SONG_NAME FROM TBL_SONG s " & _
    "WHERE s.ID_SONG NOT IN (SELECT ps.ID_SONG FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = ?) " & _
    "ORDER BY s.SONG_NAME", Array(idPlaylist))
Do While Not rs.EOF
    opcionesCanciones = opcionesCanciones & "<option value=""" & ToInt(rs("ID_SONG")) & """>" & H(rs("SONG_NAME")) & "</option>"
    rs.MoveNext
Loop
rs.Close
hayDisponibles = (opcionesCanciones <> "")

QueueReset "playlist"
%>
<!--#include file="includes/header.asp"-->

<div class="pm-page-head">
  <img src="<%=H(cover)%>" alt="Portada de <%=H(tituloPlaylist)%>"
       style="width:112px;height:112px;border-radius:16px;object-fit:cover;box-shadow:0 12px 28px rgba(15,44,135,.18)">
  <div class="pm-page-head__txt">
    <span class="pm-eyebrow"><%=Icon("playlist")%>Playlist <%=H(tipoPlaylist)%></span>
    <h1 class="pm-title"><%=H(tituloPlaylist)%></h1>
    <p class="pm-subtitle">
      Creada por <strong><%=H(propietario)%></strong> &middot;
      <%=H(Plural(totalCanciones, "cancion", "canciones"))%>
    </p>
  </div>
  <div class="pm-page-head__actions">
    <a class="pm-btn pm-btn--ghost" href="<%=Base()%>playlists.asp"><%=Icon("arrow-left")%><span>Mis playlists</span></a>
    <% If puedoEditar Then %>
    <a class="pm-btn pm-btn--ghost" href="<%=Base()%>playlists.asp?editar=<%=idPlaylist%>"><%=Icon("edit")%><span>Editar datos</span></a>
    <% End If %>
  </div>
</div>

<% If errorMsg <> "" Then %>
<div class="pm-alert pm-alert--error" role="alert">
  <span class="pm-alert__ico"><%=Icon("alert")%></span>
  <span class="pm-alert__txt"><%=H(errorMsg)%></span>
</div>
<% End If %>

<% If puedoEditar And hayDisponibles Then %>
<div class="pm-panel" style="margin-bottom:24px">
  <form method="post" action="<%=Base()%>playlist.asp?id=<%=idPlaylist%>">
    <div class="pm-panel__body" style="display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap">
      <%=CsrfField()%>
      <input type="hidden" name="accion" value="agregar">
      <div class="pm-field" style="flex:1 1 260px">
        <label for="id_song">Agregar una cancion del catalogo</label>
        <select class="pm-select" id="id_song" name="id_song" required>
          <option value="">Selecciona una cancion...</option>
          <%=opcionesCanciones%>
        </select>
      </div>
      <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("plus")%><span>Agregar</span></button>
    </div>
  </form>
</div>
<% End If %>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("list")%> Canciones de la playlist</h2>
    <% If totalCanciones > 0 Then %>
    <a class="pm-btn pm-btn--soft pm-btn--sm" href="#pmMain" data-pm-playall="playlist"<% If Not IsLoggedIn() Then %> data-pm-login="<%=Base()%>login.asp"<% End If %>>
      <%=Icon("play")%><span>Reproducir todo</span>
    </a>
    <% End If %>
  </div>

  <%
  Set rs = DBQuery(SqlSongSelect(0) & _
      "WHERE s.ID_SONG IN (SELECT ps.ID_SONG FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = ?) " & _
      "ORDER BY s.SONG_NAME", Array(idPlaylist))

  If rs.EOF Then
      Response.Write EmptyState("music", "Esta playlist esta vacia", _
          "Usa el selector de arriba para agregar canciones del catalogo.", "")
  Else
  %>
  <div class="pm-list">
  <%
      Do While Not rs.EOF
          preview  = SongIsPreview(rs("SONG_PATH"))
          artistas = Clean(rs("ARTISTAS"))
          If artistas = "" Then artistas = "Artista desconocido"

          subtitulo = artistas
          If Clean(rs("ALBUM")) <> "" Then subtitulo = subtitulo & " &middot; " & Clean(rs("ALBUM"))

          idx = QueueAdd(rs("ID_SONG"), rs("SONG_NAME"), artistas, rs("ALBUM"), _
                         StreamUrl(rs("ID_SONG")), cover, preview)

          If puedoEditar Then
              acciones = "<form method=""post"" action=""" & Base() & "playlist.asp?id=" & idPlaylist & """" & _
                  " data-confirmar=""Quitar esta cancion de la playlist?"">" & _
                  CsrfField() & "<input type=""hidden"" name=""accion"" value=""quitar"">" & _
                  "<input type=""hidden"" name=""id_song"" value=""" & ToInt(rs("ID_SONG")) & """>" & _
                  "<button class=""pm-btn pm-btn--danger pm-btn--sm"" type=""submit"" title=""Quitar de la playlist"">" & _
                  Icon("trash") & "Quitar</button></form>"
          Else
              acciones = ""
          End If

          Response.Write SongRow(idx, "playlist", rs("ID_SONG"), rs("SONG_NAME"), subtitulo, _
                                rs("PLAYS"), preview, acciones)
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
