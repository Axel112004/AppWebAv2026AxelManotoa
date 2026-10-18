<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Catalogo de albumes
' =============================================================================
Dim rs, cover, total

PageTitle   = "Albumes"
PageSection = "albumes"

total = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_ALBUM", Null))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Catalogo", "disc", "Albumes", _
    Plural(total, "album publicado", "albumes publicados"), "")%>

<div class="pm-toolbar">
  <div class="pm-toolbar__search">
    <span class="pm-ico"><%=Icon("search")%></span>
    <label class="pm-sr" for="pmFiltro">Filtrar albumes</label>
    <input class="pm-input" id="pmFiltro" type="search" placeholder="Filtrar por titulo o anio" autocomplete="off">
  </div>
</div>

<div class="pm-grid pm-grid--covers">
<%
Set rs = DBQuery(SqlAlbumSelect(0) & "ORDER BY al.RELEASE_YEAR DESC, al.TITLE_ALBUM", Null)
If rs.EOF Then
    Response.Write EmptyState("disc", "Todavia no hay albumes", _
        "El administrador puede registrar albumes desde el panel de administracion.", "")
Else
    Do While Not rs.EOF
        cover = CoverUrl(rs("ALBUM_IMAGE_PATH"), rs("TITLE_ALBUM"), rs("ID_ALBUM"))
        Response.Write "<div data-fila=""" & H(rs("TITLE_ALBUM") & " " & rs("ANIO")) & """>"
        Response.Write AlbumCard(rs("ID_ALBUM"), rs("TITLE_ALBUM"), rs("ANIO"), cover, rs("CANCIONES"), "")
        Response.Write "</div>"
        rs.MoveNext
    Loop
End If
rs.Close
%>
</div>

<!--#include file="includes/footer.asp"-->
