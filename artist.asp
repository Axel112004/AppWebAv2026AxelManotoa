<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Detalle de un artista
' =============================================================================
Dim idArtista, rs, idx, cover, artistas, preview, acciones, opciones
Dim nombreArtista, fotoArtista, totalCanciones, subtitulo

PageTitle   = "Artista"
PageSection = "artistas"

idArtista = ToInt(Request.QueryString("id"))
If idArtista <= 0 Then AbortPage "Artista no encontrado", "La direccion solicitada no es valida."

Set rs = DBQuery(SqlArtistSelect(0) & "WHERE a.ID_ARTIST = ?", Array(idArtista))
If rs.EOF Then
    rs.Close
    AbortPage "Artista no encontrado", "El artista que buscas no existe o fue eliminado del catalogo."
End If

nombreArtista  = ArtistFullName(rs("ARTIST_NAME"), rs("ARTIST_LASTNAME"))
fotoArtista    = CoverUrl(rs("ARTIST_IMAGE"), nombreArtista, rs("ID_ARTIST"))
totalCanciones = ToInt(rs("CANCIONES"))
rs.Close

PageTitle = nombreArtista

If IsLoggedIn() Then
    opciones = PlaylistOptions(CurrentUserId())
Else
    opciones = ""
End If

QueueReset "artista"
%>
<!--#include file="includes/header.asp"-->

<div class="pm-page-head">
  <img src="<%=H(fotoArtista)%>" alt="<%=H(nombreArtista)%>"
       style="width:104px;height:104px;border-radius:50%;object-fit:cover;box-shadow:0 12px 28px rgba(15,44,135,.18)">
  <div class="pm-page-head__txt">
    <span class="pm-eyebrow"><%=Icon("mic")%>Artista</span>
    <h1 class="pm-title"><%=H(nombreArtista)%></h1>
    <p class="pm-subtitle"><%=H(Plural(totalCanciones, "cancion en el catalogo", "canciones en el catalogo"))%></p>
  </div>
  <div class="pm-page-head__actions">
    <a class="pm-btn pm-btn--ghost" href="<%=Base()%>artists.asp"><%=Icon("arrow-left")%><span>Todos los artistas</span></a>
  </div>
</div>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("music")%> Canciones</h2>
  </div>

  <%
  Set rs = DBQuery(SqlSongSelect(0) & _
      "WHERE s.ID_SONG IN (SELECT p.ID_SONG FROM TBL_PLAYER p WHERE p.ID_ARTIST = ?) " & _
      "ORDER BY s.SONG_NAME", Array(idArtista))

  If rs.EOF Then
      Response.Write EmptyState("music", "Sin canciones registradas", _
          "Este artista todavia no tiene canciones asociadas en el catalogo.", "")
  Else
  %>
  <div class="pm-list">
  <%
      Do While Not rs.EOF
          preview  = SongIsPreview(rs("SONG_PATH"))
          cover    = SongCover(rs("ALBUM_IMG"), rs("ALBUM"), rs("ID_ALBUM"), rs("SONG_NAME"))
          artistas = Clean(rs("ARTISTAS"))
          If artistas = "" Then artistas = nombreArtista

          subtitulo = artistas
          If Clean(rs("ALBUM")) <> "" Then subtitulo = subtitulo & " &middot; " & Clean(rs("ALBUM"))

          idx = QueueAdd(rs("ID_SONG"), rs("SONG_NAME"), artistas, rs("ALBUM"), _
                         StreamUrl(rs("ID_SONG")), cover, preview)
          acciones = AddToPlaylistWidget(rs("ID_SONG"), opciones)

          Response.Write SongRow(idx, "artista", rs("ID_SONG"), rs("SONG_NAME"), subtitulo, _
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

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("disc")%> Albumes en los que participa</h2>
  </div>
  <div class="pm-grid pm-grid--covers">
  <%
  Set rs = DBQuery(SqlAlbumSelect(0) & _
      "WHERE al.ID_ALBUM IN (SELECT t.ID_ALBUM FROM TBL_TRACKLIST t " & _
      "INNER JOIN TBL_PLAYER p ON p.ID_SONG = t.ID_SONG WHERE p.ID_ARTIST = ?) " & _
      "ORDER BY al.RELEASE_YEAR", Array(idArtista))

  If rs.EOF Then
      Response.Write EmptyState("disc", "Sin albumes asociados", _
          "Las canciones de este artista todavia no forman parte de un album.", "")
  Else
      Do While Not rs.EOF
          cover = CoverUrl(rs("ALBUM_IMAGE_PATH"), rs("TITLE_ALBUM"), rs("ID_ALBUM"))
          Response.Write AlbumCard(rs("ID_ALBUM"), rs("TITLE_ALBUM"), rs("ANIO"), cover, rs("CANCIONES"), "")
          rs.MoveNext
      Loop
  End If
  rs.Close
  %>
  </div>
</section>

<!--#include file="includes/footer.asp"-->
