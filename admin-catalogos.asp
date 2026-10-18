<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Catalogos del sistema (TBL_CATALOG)
'  Vista de consulta de los valores genericos que utiliza la aplicacion:
'  tipos de usuario y tipos de playlist.
' =============================================================================
RequireAdmin

Dim rs, total, uso, tablas, i

PageTitle   = "Catalogos"
PageSection = "admin-catalogo"

total = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_CATALOG", Null))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Administracion", "settings", "Catalogos del sistema", _
    "Valores genericos almacenados en TBL_CATALOG. La aplicacion los utiliza para las listas y etiquetas.", "")%>

<div class="pm-alert pm-alert--info">
  <span class="pm-alert__ico"><%=Icon("info")%></span>
  <span class="pm-alert__txt">
    Los catalogos se mantienen desde el script de la base de datos
    (<strong>BDD_PoliMusic.sql</strong>). Esta pantalla es solo de consulta para verificar
    que los codigos y sus etiquetas coincidan con la logica de la aplicacion.
  </span>
</div>

<%
Set rs = DBQuery( _
    "SELECT ID_CATALOG, ISNULL(COD_CATALOG_PARENT, '') AS PADRE, ISNULL(COD_CATALOG, '') AS CODIGO, VALUE " & _
    "FROM TBL_CATALOG ORDER BY ISNULL(COD_CATALOG_PARENT, ''), ISNULL(COD_CATALOG, '')", Null)

If rs.EOF Then
    Response.Write EmptyState("settings", "Sin catalogos", "La tabla TBL_CATALOG no tiene registros.", "")
Else
%>
<div class="pm-tablewrap">
  <table class="pm-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Codigo padre</th>
        <th>Codigo</th>
        <th>Valor</th>
        <th>Uso en la aplicacion</th>
      </tr>
    </thead>
    <tbody>
    <%
    Do While Not rs.EOF
        uso = "-"
        If Clean(rs("PADRE")) = "" And Clean(rs("CODIGO")) = "1" Then
            uso = "Grupo: tipo de usuario"
        ElseIf Clean(rs("PADRE")) = "" And Clean(rs("CODIGO")) = "2" Then
            uso = "Grupo: tipo de playlist"
        ElseIf Clean(rs("PADRE")) = "1" Then
            uso = "TBL_USER.USER_TYPE = " & H(rs("CODIGO"))
        ElseIf Clean(rs("PADRE")) = "2" Then
            uso = "TBL_PLAYLIST.TYPE = " & H(rs("CODIGO"))
        End If
    %>
      <tr>
        <td class="pm-num"><%=ToInt(rs("ID_CATALOG"))%></td>
        <td class="pm-table__sub"><%=H(rs("PADRE"))%></td>
        <td class="pm-num"><%=H(rs("CODIGO"))%></td>
        <td class="pm-table__title"><%=H(rs("VALUE"))%></td>
        <td class="pm-table__sub"><%=uso%></td>
      </tr>
    <%
        rs.MoveNext
    Loop
    rs.Close
    %>
    </tbody>
  </table>
</div>
<%
End If
%>

<section class="pm-section" style="margin-top:26px">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("grid")%> Estructura de la base de datos</h2>
  </div>
  <div class="pm-grid pm-grid--wide">
    <%
    tablas = Array( _
        Array("TBL_USER", "Cuentas de usuario y su tipo (USER / ADMIN)"), _
        Array("TBL_SONG", "Canciones del catalogo con su archivo y reproducciones"), _
        Array("TBL_ARTIST", "Interpretes y su fotografia"), _
        Array("TBL_ALBUM", "Albumes con anio y caratula"), _
        Array("TBL_TRACKLIST", "Relacion album - cancion"), _
        Array("TBL_PLAYER", "Relacion cancion - artista"), _
        Array("TBL_PLAYLIST", "Playlists creadas por los usuarios"), _
        Array("TBL_PLAYLIST_SONG", "Relacion playlist - cancion"), _
        Array("TBL_CATALOG", "Valores genericos del sistema"))

    For i = 0 To UBound(tablas)
    %>
    <div class="pm-card" style="padding:15px;gap:4px">
      <span class="pm-section__title" style="font-size:14.5px"><%=Icon("folder")%> <%=H(tablas(i)(0))%></span>
      <span class="pm-hint"><%=H(tablas(i)(1))%></span>
      <span class="pm-badge" style="margin-top:8px"><%=ToInt(DBScalar("SELECT COUNT(*) FROM " & tablas(i)(0), Null))%> registros</span>
    </div>
    <%
    Next
    %>
  </div>
</section>

<!--#include file="includes/footer.asp"-->
