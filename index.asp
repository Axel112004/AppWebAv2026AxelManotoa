<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Pantalla principal
'  Catalogo musical, buscador y acceso a canciones, artistas, albumes y
'  playlists.
' =============================================================================
Dim rs, idx, cover, artistas, album, preview, acciones, opcionesPlaylist
Dim nCanciones, nArtistas, nAlbumes, nPlaylists, seccion

PageTitle   = "Inicio"
PageSection = "inicio"

If IsLoggedIn() Then
    opcionesPlaylist = PlaylistOptions(CurrentUserId())
Else
    opcionesPlaylist = ""
End If

nCanciones = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_SONG", Null))
nArtistas  = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_ARTIST", Null))
nAlbumes   = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_ALBUM", Null))
nPlaylists = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST WHERE TYPE = ?", Array(PLAYLIST_PUBLIC)))

QueueReset "inicio"
%>
<!--#include file="includes/header.asp"-->

<section class="pm-hero">
  <div class="pm-hero__in">
    <span class="pm-hero__tag"><%=Icon("wave")%> <%=H(APP_TAGLINE)%></span>
    <% If IsLoggedIn() Then %>
    <h1>Hola, <%=H(CurrentUserName())%>. Que escuchamos hoy?</h1>
    <p>Explora el catalogo, arma tus playlists y reproduce tus canciones favoritas desde cualquier dispositivo.</p>
    <% Else %>
    <h1>Tu musica, ordenada a tu manera</h1>
    <p>Explora canciones, artistas y albumes. Inicia sesion para reproducir y crear tus propias playlists.</p>
    <% End If %>
    <div class="pm-hero__btns">
      <a class="pm-btn pm-btn--on-hero" href="<%=Base()%>songs.asp"><%=Icon("music")%><span>Ver canciones</span></a>
      <% If IsLoggedIn() Then %>
      <a class="pm-btn pm-btn--on-hero-ghost" href="<%=Base()%>playlists.asp"><%=Icon("playlist")%><span>Mis playlists</span></a>
      <% Else %>
      <a class="pm-btn pm-btn--on-hero-ghost" href="<%=Base()%>login.asp"><%=Icon("login")%><span>Iniciar sesion</span></a>
      <% End If %>
    </div>
  </div>
  <div class="pm-eq" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span><span></span></div>
</section>

<div class="pm-stats">
  <a class="pm-stat" href="<%=Base()%>songs.asp">
    <span class="pm-stat__ico"><%=Icon("music")%></span>
    <span><span class="pm-stat__n"><%=nCanciones%></span><br><span class="pm-stat__l">Canciones en el catalogo</span></span>
  </a>
  <a class="pm-stat" href="<%=Base()%>artists.asp">
    <span class="pm-stat__ico pm-stat__ico--accent"><%=Icon("mic")%></span>
    <span><span class="pm-stat__n"><%=nArtistas%></span><br><span class="pm-stat__l">Artistas registrados</span></span>
  </a>
  <a class="pm-stat" href="<%=Base()%>albums.asp">
    <span class="pm-stat__ico pm-stat__ico--ok"><%=Icon("disc")%></span>
    <span><span class="pm-stat__n"><%=nAlbumes%></span><br><span class="pm-stat__l">Albumes publicados</span></span>
  </a>
  <a class="pm-stat" href="<%=Base()%>playlists.asp?ver=publicas">
    <span class="pm-stat__ico pm-stat__ico--warn"><%=Icon("playlist")%></span>
    <span><span class="pm-stat__n"><%=nPlaylists%></span><br><span class="pm-stat__l">Playlists publicas</span></span>
  </a>
</div>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("music")%> Canciones mas escuchadas</h2>
    <a class="pm-section__link" href="<%=Base()%>songs.asp">Ver todas <%=Icon("chevron-right")%></a>
  </div>
  <div class="pm-grid pm-grid--songs">
  <%
  Set rs = DBQuery(SqlSongSelect(8) & "ORDER BY ISNULL(s.PLAYS, 0) DESC, s.SONG_NAME", Null)
  Do While Not rs.EOF
      preview  = SongIsPreview(rs("SONG_PATH"))
      cover    = SongCover(rs("ALBUM_IMG"), rs("ALBUM"), rs("ID_ALBUM"), rs("SONG_NAME"))
      artistas = Clean(rs("ARTISTAS"))
      If artistas = "" Then artistas = "Artista desconocido"

      idx = QueueAdd(rs("ID_SONG"), rs("SONG_NAME"), artistas, rs("ALBUM"), _
                     StreamUrl(rs("ID_SONG")), cover, preview)
      acciones = AddToPlaylistWidget(rs("ID_SONG"), opcionesPlaylist)

      Response.Write SongCard(idx, "inicio", rs("ID_SONG"), rs("SONG_NAME"), artistas, _
                              rs("ALBUM"), rs("PLAYS"), cover, preview, acciones)
      rs.MoveNext
  Loop
  rs.Close
  %>
  </div>
</section>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("disc")%> Albumes</h2>
    <a class="pm-section__link" href="<%=Base()%>albums.asp">Ver todos <%=Icon("chevron-right")%></a>
  </div>
  <div class="pm-grid pm-grid--covers">
  <%
  Set rs = DBQuery(SqlAlbumSelect(5) & "ORDER BY al.TITLE_ALBUM", Null)
  Do While Not rs.EOF
      cover = CoverUrl(rs("ALBUM_IMAGE_PATH"), rs("TITLE_ALBUM"), rs("ID_ALBUM"))
      Response.Write AlbumCard(rs("ID_ALBUM"), rs("TITLE_ALBUM"), rs("ANIO"), cover, rs("CANCIONES"), "")
      rs.MoveNext
  Loop
  rs.Close
  %>
  </div>
</section>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("mic")%> Artistas</h2>
    <a class="pm-section__link" href="<%=Base()%>artists.asp">Ver todos <%=Icon("chevron-right")%></a>
  </div>
  <div class="pm-grid pm-grid--people">
  <%
  Set rs = DBQuery(SqlArtistSelect(6) & "ORDER BY a.ARTIST_NAME", Null)
  Do While Not rs.EOF
      cover = CoverUrl(rs("ARTIST_IMAGE"), ArtistFullName(rs("ARTIST_NAME"), rs("ARTIST_LASTNAME")), rs("ID_ARTIST"))
      Response.Write ArtistCard(rs("ID_ARTIST"), ArtistFullName(rs("ARTIST_NAME"), rs("ARTIST_LASTNAME")), cover, rs("CANCIONES"))
      rs.MoveNext
  Loop
  rs.Close
  %>
  </div>
</section>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("sparkle")%> Playlists publicas</h2>
    <a class="pm-section__link" href="<%=Base()%>playlists.asp?ver=publicas">Ver todas <%=Icon("chevron-right")%></a>
  </div>
  <div class="pm-grid pm-grid--covers">
  <%
  Set rs = DBQuery(SqlPlaylistSelect(4) & "WHERE pl.TYPE = ? ORDER BY pl.CREATION_DATE DESC", Array(PLAYLIST_PUBLIC))
  If rs.EOF Then
      Response.Write EmptyState("playlist", "Todavia no hay playlists publicas", _
          "Cuando los usuarios compartan sus playlists apareceran aqui.", "")
  Else
      Do While Not rs.EOF
          cover = CoverUrl(rs("PHOTO"), rs("TITLE"), rs("ID_PLAYLIST"))
          Response.Write PlaylistCard(rs("ID_PLAYLIST"), rs("TITLE"), PlaylistTypeLabel(rs("TYPE")), _
                                      rs("PROPIETARIO"), cover, rs("CANCIONES"), "")
          rs.MoveNext
      Loop
  End If
  rs.Close
  %>
  </div>
</section>

<!--#include file="includes/footer.asp"-->
