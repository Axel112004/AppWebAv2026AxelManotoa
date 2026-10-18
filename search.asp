<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Buscador del catalogo
'  Busca de forma simultanea en canciones, artistas, albumes y playlists.
'  Todas las condiciones viajan como parametros (sin concatenar el texto).
' =============================================================================
Dim q, patron, rs, idx, cover, artistas, preview, acciones, opciones
Dim nCanciones, nArtistas, nAlbumes, nPlaylists, total

PageTitle   = "Buscar"
PageSection = ""

q = Clean(Request.QueryString("q"))

' Se neutralizan los comodines para que el texto del usuario se busque literal
patron = "%" & Replace(Replace(Replace(q, "[", "[[]"), "%", "[%]"), "_", "[_]") & "%"

If IsLoggedIn() Then
    opciones = PlaylistOptions(CurrentUserId())
Else
    opciones = ""
End If

nCanciones  = 0
nArtistas   = 0
nAlbumes    = 0
nPlaylists  = 0

QueueReset "busqueda"
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Buscador", "search", "Resultados de la busqueda", _
    "Mostrando coincidencias para: " & q, "")%>

<% If q = "" Then %>

  <% Response.Write EmptyState("search", "Escribe algo para buscar", _
      "Puedes buscar por nombre de cancion, artista, album o playlist. Usa el buscador de la barra superior.", "")%>

<% Else %>

  <%
  ' ---------------------------------------------------------------- Canciones
  Set rs = DBQuery(SqlSongSelect(0) & _
      "WHERE s.SONG_NAME LIKE ? " & _
      "OR EXISTS (SELECT 1 FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
      "           WHERE p.ID_SONG = s.ID_SONG AND (a.ARTIST_NAME LIKE ? OR a.ARTIST_LASTNAME LIKE ?)) " & _
      "OR EXISTS (SELECT 1 FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
      "           WHERE t.ID_SONG = s.ID_SONG AND al.TITLE_ALBUM LIKE ?) " & _
      "ORDER BY ISNULL(s.PLAYS, 0) DESC, s.SONG_NAME", _
      Array(patron, patron, patron, patron))
  If Not rs.EOF Then
  %>
  <section class="pm-section">
    <div class="pm-section__head">
      <h2 class="pm-section__title"><%=Icon("music")%> Canciones</h2>
    </div>
    <div class="pm-grid pm-grid--songs">
    <%
        Do While Not rs.EOF
            nCanciones = nCanciones + 1
            preview  = SongIsPreview(rs("SONG_PATH"))
            cover    = SongCover(rs("ALBUM_IMG"), rs("ALBUM"), rs("ID_ALBUM"), rs("SONG_NAME"))
            artistas = Clean(rs("ARTISTAS"))
            If artistas = "" Then artistas = "Artista desconocido"

            idx = QueueAdd(rs("ID_SONG"), rs("SONG_NAME"), artistas, rs("ALBUM"), _
                           StreamUrl(rs("ID_SONG")), cover, preview)
            acciones = AddToPlaylistWidget(rs("ID_SONG"), opciones)

            Response.Write SongCard(idx, "busqueda", rs("ID_SONG"), rs("SONG_NAME"), artistas, _
                                    rs("ALBUM"), rs("PLAYS"), cover, preview, acciones)
            rs.MoveNext
        Loop
    %>
    </div>
  </section>
  <%
  End If
  rs.Close

  ' ---------------------------------------------------------------- Artistas
  Set rs = DBQuery(SqlArtistSelect(0) & _
      "WHERE a.ARTIST_NAME LIKE ? OR a.ARTIST_LASTNAME LIKE ? ORDER BY a.ARTIST_NAME", _
      Array(patron, patron))
  If Not rs.EOF Then
  %>
  <section class="pm-section">
    <div class="pm-section__head">
      <h2 class="pm-section__title"><%=Icon("mic")%> Artistas</h2>
    </div>
    <div class="pm-grid pm-grid--people">
    <%
        Do While Not rs.EOF
            nArtistas = nArtistas + 1
            cover = CoverUrl(rs("ARTIST_IMAGE"), ArtistFullName(rs("ARTIST_NAME"), rs("ARTIST_LASTNAME")), rs("ID_ARTIST"))
            Response.Write ArtistCard(rs("ID_ARTIST"), ArtistFullName(rs("ARTIST_NAME"), rs("ARTIST_LASTNAME")), cover, rs("CANCIONES"))
            rs.MoveNext
        Loop
    %>
    </div>
  </section>
  <%
  End If
  rs.Close

  ' ---------------------------------------------------------------- Albumes
  Set rs = DBQuery(SqlAlbumSelect(0) & "WHERE al.TITLE_ALBUM LIKE ? ORDER BY al.TITLE_ALBUM", Array(patron))
  If Not rs.EOF Then
  %>
  <section class="pm-section">
    <div class="pm-section__head">
      <h2 class="pm-section__title"><%=Icon("disc")%> Albumes</h2>
    </div>
    <div class="pm-grid pm-grid--covers">
    <%
        Do While Not rs.EOF
            nAlbumes = nAlbumes + 1
            cover = CoverUrl(rs("ALBUM_IMAGE_PATH"), rs("TITLE_ALBUM"), rs("ID_ALBUM"))
            Response.Write AlbumCard(rs("ID_ALBUM"), rs("TITLE_ALBUM"), rs("ANIO"), cover, rs("CANCIONES"), "")
            rs.MoveNext
        Loop
    %>
    </div>
  </section>
  <%
  End If
  rs.Close

  ' ---------------------------------------------------------------- Playlists
  ' Solo se muestran las playlists publicas y las propias del usuario
  If IsLoggedIn() Then
      Set rs = DBQuery(SqlPlaylistSelect(0) & _
          "WHERE pl.TITLE LIKE ? AND (pl.TYPE = ? OR pl.ID_USER = ?) ORDER BY pl.TITLE", _
          Array(patron, PLAYLIST_PUBLIC, CurrentUserId()))
      If Not rs.EOF Then
  %>
  <section class="pm-section">
    <div class="pm-section__head">
      <h2 class="pm-section__title"><%=Icon("playlist")%> Playlists</h2>
    </div>
    <div class="pm-grid pm-grid--covers">
    <%
          Do While Not rs.EOF
              nPlaylists = nPlaylists + 1
              cover = CoverUrl(rs("PHOTO"), rs("TITLE"), rs("ID_PLAYLIST"))
              Response.Write PlaylistCard(rs("ID_PLAYLIST"), rs("TITLE"), PlaylistTypeLabel(rs("TYPE")), _
                                          rs("PROPIETARIO"), cover, rs("CANCIONES"), "")
              rs.MoveNext
          Loop
    %>
    </div>
  </section>
  <%
      End If
      rs.Close
  End If

  total = nCanciones + nArtistas + nAlbumes + nPlaylists
  If total = 0 Then
      Response.Write EmptyState("search", "No encontramos resultados", _
          "No hay coincidencias para '" & q & "'. Prueba con otras palabras o revisa la ortografia.", _
          "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "songs.asp"">" & Icon("music") & "<span>Ver todo el catalogo</span></a>")
  Else
  %>
  <p class="pm-subtitle" style="margin-top:22px">
    <%=H(Plural(total, "resultado encontrado", "resultados encontrados"))%>:
    <%=nCanciones%> canciones, <%=nArtistas%> artistas, <%=nAlbumes%> albumes, <%=nPlaylists%> playlists.
  </p>
  <%
  End If
  %>

<% End If %>

<!--#include file="includes/footer.asp"-->
