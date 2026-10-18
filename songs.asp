<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Listado de canciones (Song List)
'  La guia del laboratorio pide una TABLA HTML con el listado de canciones,
'  por eso esta pagina usa <table> (las tarjetas se conservan en el inicio).
' =============================================================================
Dim orden, sqlOrden, rs, idx, cover, artistas, preview, acciones, opciones, total
Dim fila, subTexto, albumTexto, nombre

PageTitle   = "Canciones"
PageSection = "canciones"

opciones = ""
If IsLoggedIn() Then opciones = PlaylistOptions(CurrentUserId())

orden = LCase(Clean(Request.QueryString("orden")))
If orden = "" Then orden = "populares"

Select Case orden
    Case "nombre"
        sqlOrden = "ORDER BY s.SONG_NAME"
    Case "album"
        sqlOrden = "ORDER BY ALBUM, s.SONG_NAME"
    Case Else
        orden = "populares"
        sqlOrden = "ORDER BY ISNULL(s.PLAYS, 0) DESC, s.SONG_NAME"
End Select

total = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_SONG", Null))

QueueReset "canciones"
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Catalogo", "music", "Listado de canciones (Song List)", _
    Plural(total, "cancion disponible en el catalogo", "canciones disponibles en el catalogo"), "")%>

<div class="pm-toolbar">
  <div class="pm-toolbar__search">
    <span class="pm-ico"><%=Icon("search")%></span>
    <label class="pm-sr" for="pmFiltro">Filtrar canciones</label>
    <input class="pm-input" id="pmFiltro" type="search" placeholder="Filtrar por nombre, artista o album" autocomplete="off">
  </div>
  <div class="pm-chips">
    <a class="pm-chip<% If orden = "populares" Then %> is-active<% End If %>" href="<%=Base()%>songs.asp?orden=populares"><%=Icon("chart")%>Mas escuchadas</a>
    <a class="pm-chip<% If orden = "nombre" Then %> is-active<% End If %>" href="<%=Base()%>songs.asp?orden=nombre"><%=Icon("list")%>A - Z</a>
    <a class="pm-chip<% If orden = "album" Then %> is-active<% End If %>" href="<%=Base()%>songs.asp?orden=album"><%=Icon("disc")%>Por album</a>
  </div>
</div>

<%
Set rs = DBQuery(SqlSongSelect(0) & sqlOrden, Null)

If rs.EOF Then
    Response.Write EmptyState("music", "El catalogo esta vacio", _
        "Todavia no hay canciones registradas. El administrador puede agregarlas desde el panel.", "")
Else
    Response.Write "<div class=""pm-tablewrap"">" & _
        "<table class=""pm-table pm-table--songs"">" & _
        "<thead><tr>" & _
        "<th style=""width:52px"">ID</th>" & _
        "<th>Cancion</th>" & _
        "<th>Artista</th>" & _
        "<th>Album</th>" & _
        "<th style=""width:130px"">Reproducciones</th>" & _
        "<th style=""width:80px;text-align:center"">Play</th>" & _
        "<th style=""width:120px;text-align:right"">Playlist</th>" & _
        "</tr></thead><tbody>"

    fila = 0
    Do While Not rs.EOF
        fila = fila + 1
        preview  = SongIsPreview(rs("SONG_PATH"))
        cover    = SongCover(rs("ALBUM_IMG"), rs("ALBUM"), rs("ID_ALBUM"), rs("SONG_NAME"))
        nombre   = Clean(rs("SONG_NAME"))
        artistas = Clean(rs("ARTISTAS"))
        albumTexto = Clean(rs("ALBUM"))

        If artistas = "" Then artistas = "Artista desconocido"
        If albumTexto = "" Then albumTexto = "-"
        If preview Then subTexto = "Vista previa" Else subTexto = "Disponible"

        idx = QueueAdd(rs("ID_SONG"), nombre, artistas, albumTexto, _
                       StreamUrl(rs("ID_SONG")), cover, preview)
        acciones = AddToPlaylistWidget(rs("ID_SONG"), opciones)

        Response.Write "<tr data-fila=""" & H(nombre & " " & artistas & " " & albumTexto) & """>" & _
            "<td class=""pm-num"">" & fila & "</td>" & _
            "<td><div class=""pm-table__main"">" & _
                "<img class=""pm-table__thumb"" src=""" & H(cover) & """ alt="""">" & _
                "<div><div class=""pm-table__title"">" & H(nombre) & "</div>" & _
                "<div class=""pm-table__sub"">" & H(subTexto) & "</div>" & _
                "</div></div></td>" & _
            "<td class=""pm-table__sub"">" & H(artistas) & "</td>" & _
            "<td class=""pm-table__sub"">" & H(albumTexto) & "</td>" & _
            "<td class=""pm-num"">" & ToInt(rs("PLAYS")) & "</td>" & _
            "<td style=""text-align:center"">" & _
                PlayButton(idx, "canciones", nombre, "pm-row__play") & "</td>" & _
            "<td style=""text-align:right"">" & acciones & "</td>" & _
            "</tr>"

        rs.MoveNext
    Loop

    Response.Write "</tbody></table></div>"
End If
rs.Close
%>

<!--#include file="includes/footer.asp"-->
