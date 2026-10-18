<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Panel administrativo - Vista general
'  Acceso exclusivo para el usuario de tipo ADMIN (validado en el servidor).
' =============================================================================
RequireAdmin

Dim rs, nUsuarios, nAdmins, nCanciones, nArtistas, nAlbumes, nPlaylists, nReproducciones, nPistas

PageTitle   = "Panel general"
PageSection = "admin"

nUsuarios       = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_USER", Null))
nAdmins         = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_USER WHERE USER_TYPE = ?", Array(USER_TYPE_ADMIN)))
nCanciones      = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_SONG", Null))
nArtistas       = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_ARTIST", Null))
nAlbumes        = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_ALBUM", Null))
nPlaylists      = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST", Null))
nPistas         = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST_SONG", Null))
nReproducciones = ToInt(DBScalar("SELECT ISNULL(SUM(PLAYS), 0) FROM TBL_SONG", Null))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Administracion", "grid", "Panel general", _
    "Resumen del catalogo y accesos directos a cada modulo de gestion.", _
    "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "admin-canciones.asp?accion=nueva"">" & _
    Icon("plus") & "<span>Nueva cancion</span></a>")%>

<div class="pm-stats">
  <a class="pm-stat" href="<%=Base()%>admin-usuarios.asp">
    <span class="pm-stat__ico"><%=Icon("users")%></span>
    <span><span class="pm-stat__n"><%=nUsuarios%></span><br><span class="pm-stat__l">Usuarios (<%=nAdmins%> admin)</span></span>
  </a>
  <a class="pm-stat" href="<%=Base()%>admin-canciones.asp">
    <span class="pm-stat__ico pm-stat__ico--accent"><%=Icon("music")%></span>
    <span><span class="pm-stat__n"><%=nCanciones%></span><br><span class="pm-stat__l">Canciones</span></span>
  </a>
  <a class="pm-stat" href="<%=Base()%>admin-artistas.asp">
    <span class="pm-stat__ico pm-stat__ico--ok"><%=Icon("mic")%></span>
    <span><span class="pm-stat__n"><%=nArtistas%></span><br><span class="pm-stat__l">Artistas</span></span>
  </a>
  <a class="pm-stat" href="<%=Base()%>admin-albumes.asp">
    <span class="pm-stat__ico pm-stat__ico--warn"><%=Icon("disc")%></span>
    <span><span class="pm-stat__n"><%=nAlbumes%></span><br><span class="pm-stat__l">Albumes</span></span>
  </a>
  <a class="pm-stat" href="<%=Base()%>admin-playlists.asp">
    <span class="pm-stat__ico"><%=Icon("playlist")%></span>
    <span><span class="pm-stat__n"><%=nPlaylists%></span><br><span class="pm-stat__l">Playlists</span></span>
  </a>
  <a class="pm-stat" href="<%=Base()%>songs.asp">
    <span class="pm-stat__ico pm-stat__ico--accent"><%=Icon("headphones")%></span>
    <span><span class="pm-stat__n"><%=nReproducciones%></span><br><span class="pm-stat__l">Reproducciones</span></span>
  </a>
</div>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("settings")%> Modulos de gestion</h2>
  </div>
  <div class="pm-grid pm-grid--wide">
    <a class="pm-card" href="<%=Base()%>admin-usuarios.asp" style="padding:18px;gap:6px">
      <span class="pm-stat__ico"><%=Icon("users")%></span>
      <span class="pm-section__title" style="font-size:16px">Usuarios</span>
      <span class="pm-hint">Crear, consultar, actualizar y eliminar cuentas. Asignar el tipo de usuario.</span>
    </a>
    <a class="pm-card" href="<%=Base()%>admin-canciones.asp" style="padding:18px;gap:6px">
      <span class="pm-stat__ico pm-stat__ico--accent"><%=Icon("music")%></span>
      <span class="pm-section__title" style="font-size:16px">Canciones</span>
      <span class="pm-hint">Registrar canciones, indicar su archivo y asociarlas a artistas y albumes.</span>
    </a>
    <a class="pm-card" href="<%=Base()%>admin-artistas.asp" style="padding:18px;gap:6px">
      <span class="pm-stat__ico pm-stat__ico--ok"><%=Icon("mic")%></span>
      <span class="pm-section__title" style="font-size:16px">Artistas</span>
      <span class="pm-hint">Mantener el catalogo de interpretes y su fotografia.</span>
    </a>
    <a class="pm-card" href="<%=Base()%>admin-albumes.asp" style="padding:18px;gap:6px">
      <span class="pm-stat__ico pm-stat__ico--warn"><%=Icon("disc")%></span>
      <span class="pm-section__title" style="font-size:16px">Albumes</span>
      <span class="pm-hint">Crear albumes con su anio de publicacion y su lista de pistas.</span>
    </a>
    <a class="pm-card" href="<%=Base()%>admin-playlists.asp" style="padding:18px;gap:6px">
      <span class="pm-stat__ico"><%=Icon("playlist")%></span>
      <span class="pm-section__title" style="font-size:16px">Playlists</span>
      <span class="pm-hint">Supervisar las playlists de todos los usuarios y su contenido.</span>
    </a>
    <a class="pm-card" href="<%=Base()%>admin-catalogos.asp" style="padding:18px;gap:6px">
      <span class="pm-stat__ico pm-stat__ico--ok"><%=Icon("settings")%></span>
      <span class="pm-section__title" style="font-size:16px">Catalogos</span>
      <span class="pm-hint">Consultar los valores genericos de TBL_CATALOG usados por la aplicacion.</span>
    </a>
  </div>
</section>

<div class="pm-grid pm-grid--wide">
  <div class="pm-panel">
    <div class="pm-panel__head">
      <span class="pm-section__title"><%=Icon("music")%> Canciones mas reproducidas</span>
      <a class="pm-section__link" href="<%=Base()%>admin-canciones.asp" style="margin-left:auto">Gestionar</a>
    </div>
    <div class="pm-tablewrap" style="border:0;border-radius:0;box-shadow:none">
      <table class="pm-table">
        <thead><tr><th>Cancion</th><th>Album</th><th>Reproducciones</th></tr></thead>
        <tbody>
        <%
        Set rs = DBQuery(SqlSongSelect(5) & "ORDER BY ISNULL(s.PLAYS, 0) DESC, s.SONG_NAME", Null)
        If rs.EOF Then
            Response.Write "<tr><td colspan=""3"" class=""pm-hint"">Sin datos.</td></tr>"
        Else
            Do While Not rs.EOF
                Response.Write "<tr>" & _
                    "<td><div class=""pm-table__main""><img class=""pm-table__thumb"" src=""" & _
                    H(SongCover(rs("ALBUM_IMG"), rs("ALBUM"), rs("ID_ALBUM"), rs("SONG_NAME"))) & _
                    """ alt=""""><div><div class=""pm-table__title"">" & H(rs("SONG_NAME")) & "</div>" & _
                    "<div class=""pm-table__sub"">" & H(Nz(rs("ARTISTAS"), "-")) & "</div></div></div></td>" & _
                    "<td class=""pm-table__sub"">" & H(Nz(rs("ALBUM"), "-")) & "</td>" & _
                    "<td class=""pm-num"">" & ToInt(rs("PLAYS")) & "</td></tr>"
                rs.MoveNext
            Loop
        End If
        rs.Close
        %>
        </tbody>
      </table>
    </div>
  </div>

  <div class="pm-panel">
    <div class="pm-panel__head">
      <span class="pm-section__title"><%=Icon("playlist")%> Playlists recientes</span>
      <a class="pm-section__link" href="<%=Base()%>admin-playlists.asp" style="margin-left:auto">Gestionar</a>
    </div>
    <div class="pm-tablewrap" style="border:0;border-radius:0;box-shadow:none">
      <table class="pm-table">
        <thead><tr><th>Playlist</th><th>Propietario</th><th>Canciones</th></tr></thead>
        <tbody>
        <%
        Set rs = DBQuery(SqlPlaylistSelect(5) & "ORDER BY pl.CREATION_DATE DESC, pl.ID_PLAYLIST DESC", Null)
        If rs.EOF Then
            Response.Write "<tr><td colspan=""3"" class=""pm-hint"">Sin datos.</td></tr>"
        Else
            Do While Not rs.EOF
                Response.Write "<tr>" & _
                    "<td><div class=""pm-table__main""><img class=""pm-table__thumb"" src=""" & _
                    H(CoverUrl(rs("PHOTO"), rs("TITLE"), rs("ID_PLAYLIST"))) & """ alt="""">" & _
                    "<div><div class=""pm-table__title"">" & H(rs("TITLE")) & "</div>" & _
                    "<div class=""pm-table__sub"">" & H(PlaylistTypeLabel(rs("TYPE"))) & "</div></div></div></td>" & _
                    "<td class=""pm-table__sub"">" & H(rs("PROPIETARIO")) & "</td>" & _
                    "<td class=""pm-num"">" & ToInt(rs("CANCIONES")) & "</td></tr>"
                rs.MoveNext
            Loop
        End If
        rs.Close
        %>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!--#include file="includes/footer.asp"-->
