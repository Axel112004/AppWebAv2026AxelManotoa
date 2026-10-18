<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Administracion de artistas
' =============================================================================
RequireAdmin

Dim accion, modoForm, idEdit, errorMsg, rs, nuevoId, idEliminar
Dim fNombre, fApellido, fImagen, total, nombreCompleto, nCanciones

PageTitle   = "Artistas"
PageSection = "admin-artistas"

accion   = LCase(Clean(Request.Form("accion")))
modoForm = ""
errorMsg = ""

If LCase(Clean(Request.QueryString("accion"))) = "nuevo" Then modoForm = "nuevo"
idEdit = ToInt(Request.QueryString("editar"))

' ---------------------------------------------------------------------------
'  Acciones
' ---------------------------------------------------------------------------
If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    If accion = "guardar" Then
        idEdit    = ToInt(Request.Form("id_artist"))
        fNombre   = Clean(Request.Form("nombre"))
        fApellido = Clean(Request.Form("apellido"))
        fImagen   = Clean(Request.Form("imagen"))

        If fNombre = "" Then
            errorMsg = "El nombre del artista es obligatorio."
        ElseIf Len(fNombre) > 100 Or Len(fApellido) > 100 Then
            errorMsg = "El nombre y el apellido no pueden superar los 100 caracteres."
        ElseIf Not ValidFileIn(DIR_ARTIST, fImagen) Then
            errorMsg = "La imagen seleccionada no es valida."
        Else
            If idEdit > 0 Then
                DBExecute "UPDATE TBL_ARTIST SET ARTIST_NAME = ?, ARTIST_LASTNAME = ?, ARTIST_IMAGE = ? WHERE ID_ARTIST = ?", _
                          Array(fNombre, fApellido, fImagen, idEdit)
            Else
                idEdit = DBInsert("INSERT INTO TBL_ARTIST (ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE) VALUES (?, ?, ?)", _
                                  Array(fNombre, fApellido, fImagen))
            End If

            If idEdit > 0 Then
                SetFlash "El artista se guardo correctamente.", "ok"
                CloseConn
                Response.Redirect Base() & "admin-artistas.asp"
                Response.End
            Else
                errorMsg = "No se pudo guardar el artista."
            End If
        End If
        modoForm = "form"

    ElseIf accion = "eliminar" Then
        idEliminar = ToInt(Request.Form("id_artist"))

        If Not DBExists("SELECT 1 FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(idEliminar)) Then
            errorMsg = "El artista ya no existe."
        Else
            DBExecute "DELETE FROM TBL_PLAYER WHERE ID_ARTIST = ?", Array(idEliminar)
            DBExecute "DELETE FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(idEliminar)
            SetFlash "El artista se elimino correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "admin-artistas.asp"
            Response.End
        End If
    End If
End If

' ---------------------------------------------------------------------------
'  Formulario
' ---------------------------------------------------------------------------
If modoForm = "" And idEdit > 0 Then modoForm = "form"

fNombre   = ""
fApellido = ""
fImagen   = ""

If modoForm = "form" And idEdit > 0 Then
    Set rs = DBQuery("SELECT ARTIST_NAME, ISNULL(ARTIST_LASTNAME, '') AS APELLIDO, ARTIST_IMAGE FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(idEdit))
    If rs.EOF Then
        rs.Close
        AbortPage "Artista no encontrado", "El artista solicitado no existe."
    End If
    fNombre   = Clean(rs("ARTIST_NAME"))
    fApellido = Clean(rs("APELLIDO"))
    fImagen   = Clean(rs("ARTIST_IMAGE"))
    rs.Close
End If

total = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_ARTIST", Null))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Administracion", "mic", "Artistas", _
    Plural(total, "artista registrado", "artistas registrados"), _
    "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "admin-artistas.asp?accion=nuevo"">" & _
    Icon("plus") & "<span>Nuevo artista</span></a>")%>

<% If errorMsg <> "" Then %>
<div class="pm-alert pm-alert--error" role="alert">
  <span class="pm-alert__ico"><%=Icon("alert")%></span>
  <span class="pm-alert__txt"><%=H(errorMsg)%></span>
</div>
<% End If %>

<% If modoForm <> "" Then %>
<section class="pm-section">
  <div class="pm-panel">
    <div class="pm-panel__head">
      <span class="pm-section__title"><%=Icon("mic")%> <% If idEdit > 0 Then %>Editar artista<% Else %>Nuevo artista<% End If %></span>
    </div>
    <form method="post" action="<%=Base()%>admin-artistas.asp">
      <div class="pm-panel__body">
        <%=CsrfField()%>
        <input type="hidden" name="accion" value="guardar">
        <input type="hidden" name="id_artist" value="<%=idEdit%>">

        <div class="pm-form pm-form--2">
          <div class="pm-field">
            <label for="nombre">Nombre <span class="pm-req">*</span></label>
            <input class="pm-input" id="nombre" name="nombre" type="text" required maxlength="100"
                   value="<%=H(fNombre)%>" placeholder="Por ejemplo: Juan">
          </div>

          <div class="pm-field">
            <label for="apellido">Apellido</label>
            <input class="pm-input" id="apellido" name="apellido" type="text" maxlength="100"
                   value="<%=H(fApellido)%>" placeholder="Por ejemplo: Gabriel">
          </div>

          <div class="pm-field pm-span-2">
            <label for="imagen">Fotografia</label>
            <select class="pm-select" id="imagen" name="imagen">
              <option value="">Sin imagen (se genera una)</option>
              <%=ImageOptions(DIR_ARTIST, fImagen)%>
            </select>
            <span class="pm-hint">Coloca las fotografias en la carpeta <%=H(DIR_ARTIST)%>.</span>
          </div>
        </div>
      </div>
      <div class="pm-panel__foot">
        <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("save")%><span>Guardar</span></button>
        <a class="pm-btn pm-btn--ghost" href="<%=Base()%>admin-artistas.asp">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<div class="pm-toolbar">
  <div class="pm-toolbar__search">
    <span class="pm-ico"><%=Icon("search")%></span>
    <label class="pm-sr" for="pmFiltro">Filtrar artistas</label>
    <input class="pm-input" id="pmFiltro" type="search" placeholder="Filtrar por nombre o apellido" autocomplete="off">
  </div>
</div>

<div class="pm-tablewrap">
  <table class="pm-table">
    <thead>
      <tr>
        <th>Artista</th>
        <th>Canciones asociadas</th>
        <th>Imagen</th>
        <th style="text-align:right">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <%
    Set rs = DBQuery(SqlArtistSelect(0) & "ORDER BY a.ARTIST_NAME, a.ARTIST_LASTNAME", Null)
    If rs.EOF Then
        Response.Write "<tr><td colspan=""4"" class=""pm-hint"">No hay artistas registrados.</td></tr>"
    Else
        Do While Not rs.EOF
            nombreCompleto = ArtistFullName(rs("ARTIST_NAME"), rs("ARTIST_LASTNAME"))
            nCanciones = ToInt(rs("CANCIONES"))
    %>
      <tr data-fila="<%=H(nombreCompleto)%>">
        <td>
          <div class="pm-table__main">
            <img class="pm-table__thumb" style="border-radius:50%" src="<%=H(CoverUrl(rs("ARTIST_IMAGE"), nombreCompleto, rs("ID_ARTIST")))%>" alt="">
            <div>
              <div class="pm-table__title"><%=H(nombreCompleto)%></div>
              <div class="pm-table__sub">ID <%=ToInt(rs("ID_ARTIST"))%></div>
            </div>
          </div>
        </td>
        <td class="pm-num"><%=nCanciones%></td>
        <td class="pm-table__sub"><%=H(Nz(rs("ARTIST_IMAGE"), "-"))%></td>
        <td>
          <div class="pm-table__actions">
            <a class="pm-iconbtn pm-iconbtn--sm" title="Editar" href="<%=Base()%>admin-artistas.asp?editar=<%=ToInt(rs("ID_ARTIST"))%>"><%=Icon("edit")%></a>
            <form method="post" action="<%=Base()%>admin-artistas.asp" data-confirmar="Eliminar al artista <%=H(nombreCompleto)%>? Sus canciones quedaran sin interprete.">
              <%=CsrfField()%>
              <input type="hidden" name="accion" value="eliminar">
              <input type="hidden" name="id_artist" value="<%=ToInt(rs("ID_ARTIST"))%>">
              <button class="pm-iconbtn pm-iconbtn--sm pm-iconbtn--danger" type="submit" title="Eliminar"><%=Icon("trash")%></button>
            </form>
          </div>
        </td>
      </tr>
    <%
            rs.MoveNext
        Loop
    End If
    rs.Close
    %>
    </tbody>
  </table>
</div>

<!--#include file="includes/footer.asp"-->
