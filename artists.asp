<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Catalogo de artistas
' =============================================================================
Dim rs, cover, nombre, total

PageTitle   = "Artistas"
PageSection = "artistas"

total = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_ARTIST", Null))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Catalogo", "mic", "Artistas", _
    Plural(total, "artista registrado", "artistas registrados"), "")%>

<div class="pm-toolbar">
  <div class="pm-toolbar__search">
    <span class="pm-ico"><%=Icon("search")%></span>
    <label class="pm-sr" for="pmFiltro">Filtrar artistas</label>
    <input class="pm-input" id="pmFiltro" type="search" placeholder="Filtrar por nombre" autocomplete="off">
  </div>
</div>

<div class="pm-grid pm-grid--people">
<%
Set rs = DBQuery(SqlArtistSelect(0) & "ORDER BY a.ARTIST_NAME, a.ARTIST_LASTNAME", Null)
If rs.EOF Then
    Response.Write EmptyState("mic", "Todavia no hay artistas", _
        "El administrador puede registrar artistas desde el panel de administracion.", "")
Else
    Do While Not rs.EOF
        nombre = ArtistFullName(rs("ARTIST_NAME"), rs("ARTIST_LASTNAME"))
        cover  = CoverUrl(rs("ARTIST_IMAGE"), nombre, rs("ID_ARTIST"))
        Response.Write "<div data-fila=""" & H(nombre) & """>"
        Response.Write ArtistCard(rs("ID_ARTIST"), nombre, cover, rs("CANCIONES"))
        Response.Write "</div>"
        rs.MoveNext
    Loop
End If
rs.Close
%>
</div>

<!--#include file="includes/footer.asp"-->
