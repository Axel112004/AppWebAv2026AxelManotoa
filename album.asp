<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Detalle de un album con su lista de pistas
' =============================================================================
Dim idAlbum, rs, idx, cover, artistas, preview, acciones, opciones
Dim tituloAlbum, anioAlbum, totalCanciones, subtitulo

PageTitle   = "Album"
PageSection = "albumes"

idAlbum = ToInt(Request.QueryString("id"))
If idAlbum <= 0 Then AbortPage "Album no encontrado", "La direccion solicitada no es valida."

Set rs = DBQuery(SqlAlbumSelect(0) & "WHERE al.ID_ALBUM = ?", Array(idAlbum))
If rs.EOF Then
    rs.Close
    AbortPage "Album no encontrado", "El album que buscas no existe o fue eliminado del catalogo."
End If

tituloAlbum    = Clean(rs("TITLE_ALBUM"))
anioAlbum      = ToInt(rs("ANIO"))
cover          = CoverUrl(rs("ALBUM_IMAGE_PATH"), tituloAlbum, rs("ID_ALBUM"))
totalCanciones = ToInt(rs("CANCIONES"))
rs.Close

PageTitle = tituloAlbum

If IsLoggedIn() Then
    opciones = PlaylistOptions(CurrentUserId())
Else
    opciones = ""
End If

If anioAlbum > 0 Then
    subtitulo = anioAlbum & " - " & Plural(totalCanciones, "cancion", "canciones")
Else
    subtitulo = Plural(totalCanciones, "cancion", "canciones")
End If

QueueReset "album"
%>
<!--#include file="includes/header.asp"-->

<div class="pm-page-head">
  <img src="<%=H(cover)%>" alt="Portada de <%=H(tituloAlbum)%>"
       style="width:112px;height:112px;border-radius:16px;object-fit:cover;box-shadow:0 12px 28px rgba(15,44,135,.18)">
  <div class="pm-page-head__txt">
    <span class="pm-eyebrow"><%=Icon("disc")%>Album</span>
    <h1 class="pm-title"><%=H(tituloAlbum)%></h1>
    <p class="pm-subtitle"><%=H(subtitulo)%></p>
  </div>
  <div class="pm-page-head__actions">
    <a class="pm-btn pm-btn--ghost" href="<%=Base()%>albums.asp"><%=Icon("arrow-left")%><span>Todos los albumes</span></a>
  </div>
</div>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("list")%> Lista de pistas</h2>
  </div>

  <%
  Set rs = DBQuery(SqlSongSelect(0) & _
      "WHERE s.ID_SONG IN (SELECT t.ID_SONG FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = ?) " & _
      "ORDER BY s.SONG_NAME", Array(idAlbum))

  If rs.EOF Then
      Response.Write EmptyState("music", "Este album no tiene canciones", _
          "El administrador puede asociar canciones al album desde el panel.", "")
  Else
  %>
  <div class="pm-list">
  <%
      Do While Not rs.EOF
          preview  = SongIsPreview(rs("SONG_PATH"))
          artistas = Clean(rs("ARTISTAS"))
          If artistas = "" Then artistas = "Artista desconocido"

          idx = QueueAdd(rs("ID_SONG"), rs("SONG_NAME"), artistas, tituloAlbum, _
                         StreamUrl(rs("ID_SONG")), cover, preview)
          acciones = AddToPlaylistWidget(rs("ID_SONG"), opciones)

          Response.Write SongRow(idx, "album", rs("ID_SONG"), rs("SONG_NAME"), artistas, _
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
