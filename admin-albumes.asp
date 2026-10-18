<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Administracion de albumes
'  Incluye la gestion de la lista de pistas (TBL_TRACKLIST).
' =============================================================================
RequireAdmin

Dim accion, modoForm, idEdit, errorMsg, rs, nuevoId, idEliminar
Dim fTitulo, fAnio, fImagen, fCanciones, i, sid, partes
Dim cancionesSeleccionadas, opcionesCanciones, total, anioTexto

PageTitle   = "Albumes"
PageSection = "admin-albumes"

accion   = LCase(Clean(Request.Form("accion")))
modoForm = ""
errorMsg = ""

If LCase(Clean(Request.QueryString("accion"))) = "nuevo" Then modoForm = "nuevo"
idEdit = ToInt(Request.QueryString("editar"))

Set cancionesSeleccionadas = Server.CreateObject("Scripting.Dictionary")
cancionesSeleccionadas.CompareMode = 1

' ---------------------------------------------------------------------------
'  Acciones
' ---------------------------------------------------------------------------
If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    If accion = "guardar" Then
        idEdit      = ToInt(Request.Form("id_album"))
        fTitulo     = Clean(Request.Form("titulo"))
        fAnio       = ToInt(Request.Form("anio"))
        fImagen     = Clean(Request.Form("imagen"))
        fCanciones  = CStr(Nz(Request.Form("canciones"), ""))

        If fTitulo = "" Then
            errorMsg = "El titulo del album es obligatorio."
        ElseIf Len(fTitulo) > 50 Then
            errorMsg = "El titulo no puede superar los 50 caracteres."
        ElseIf fAnio < 0 Or fAnio > 2200 Then
            errorMsg = "El anio de publicacion no es valido."
        ElseIf Not ValidFileIn(DIR_ALBUM, fImagen) Then
            errorMsg = "La imagen seleccionada no es valida."
        Else
            If idEdit > 0 Then
                DBExecute "UPDATE TBL_ALBUM SET TITLE_ALBUM = ?, RELEASE_YEAR = ?, ALBUM_IMAGE_PATH = ? WHERE ID_ALBUM = ?", _
                          Array(fTitulo, fAnio, fImagen, idEdit)
            Else
                idEdit = DBInsert("INSERT INTO TBL_ALBUM (TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH) VALUES (?, ?, ?)", _
                                  Array(fTitulo, fAnio, fImagen))
            End If

            If idEdit > 0 Then
                ' --- Lista de pistas: se reemplaza por completo ---
                DBExecute "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(idEdit)

                partes = Split(fCanciones, ",")
                For i = 0 To UBound(partes)
                    sid = ToInt(Trim(partes(i)))
                    If sid > 0 Then
                        If DBExists("SELECT 1 FROM TBL_SONG WHERE ID_SONG = ?", Array(sid)) Then
                            If Not DBExists("SELECT 1 FROM TBL_TRACKLIST WHERE ID_ALBUM = ? AND ID_SONG = ?", Array(idEdit, sid)) Then
                                DBExecute "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)", Array(idEdit, sid)
                            End If
                        End If
                    End If
                Next

                SetFlash "El album se guardo correctamente.", "ok"
                CloseConn
                Response.Redirect Base() & "admin-albumes.asp"
                Response.End
            Else
                errorMsg = "No se pudo guardar el album."
            End If
        End If
        modoForm = "form"

    ElseIf accion = "eliminar" Then
        idEliminar = ToInt(Request.Form("id_album"))

        If Not DBExists("SELECT 1 FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(idEliminar)) Then
            errorMsg = "El album ya no existe."
        Else
            DBExecute "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(idEliminar)
            DBExecute "DELETE FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(idEliminar)
            SetFlash "El album se elimino correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "admin-albumes.asp"
            Response.End
        End If
    End If
End If

' ---------------------------------------------------------------------------
'  Formulario
' ---------------------------------------------------------------------------
If modoForm = "" And idEdit > 0 Then modoForm = "form"

fTitulo = ""
fAnio   = 0
fImagen = ""

If modoForm = "form" And idEdit > 0 Then
    Set rs = DBQuery("SELECT TITLE_ALBUM, ISNULL(RELEASE_YEAR, 0) AS ANIO, ALBUM_IMAGE_PATH FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(idEdit))
    If rs.EOF Then
        rs.Close
        AbortPage "Album no encontrado", "El album solicitado no existe."
    End If
    fTitulo = Clean(rs("TITLE_ALBUM"))
    fAnio   = ToInt(rs("ANIO"))
    fImagen = Clean(rs("ALBUM_IMAGE_PATH"))
    rs.Close

    Set rs = DBQuery("SELECT ID_SONG FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(idEdit))
    Do While Not rs.EOF
        cancionesSeleccionadas(CStr(ToInt(rs("ID_SONG")))) = True
        rs.MoveNext
    Loop
    rs.Close
End If

opcionesCanciones = ""
Set rs = DBQuery("SELECT ID_SONG, SONG_NAME FROM TBL_SONG ORDER BY SONG_NAME", Null)
Do While Not rs.EOF
    opcionesCanciones = opcionesCanciones & "<option value=""" & ToInt(rs("ID_SONG")) & """" & _
        IIfStr(cancionesSeleccionadas.Exists(CStr(ToInt(rs("ID_SONG")))), " selected", "") & ">" & _
        H(rs("SONG_NAME")) & "</option>"
    rs.MoveNext
Loop
rs.Close

total = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_ALBUM", Null))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Administracion", "disc", "Albumes", _
    Plural(total, "album registrado", "albumes registrados"), _
    "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "admin-albumes.asp?accion=nuevo"">" & _
    Icon("plus") & "<span>Nuevo album</span></a>")%>

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
      <span class="pm-section__title"><%=Icon("disc")%> <% If idEdit > 0 Then %>Editar album<% Else %>Nuevo album<% End If %></span>
    </div>
    <form method="post" action="<%=Base()%>admin-albumes.asp">
      <div class="pm-panel__body">
        <%=CsrfField()%>
        <input type="hidden" name="accion" value="guardar">
        <input type="hidden" name="id_album" value="<%=idEdit%>">

        <div class="pm-form pm-form--2">
          <div class="pm-field">
            <label for="titulo">Titulo del album <span class="pm-req">*</span></label>
            <input class="pm-input" id="titulo" name="titulo" type="text" required maxlength="50"
                   value="<%=H(fTitulo)%>" placeholder="Por ejemplo: Rock Album">
          </div>

          <div class="pm-field">
            <label for="anio">Anio de publicacion</label>
            <input class="pm-input" id="anio" name="anio" type="number" min="0" max="2200" value="<%=fAnio%>">
          </div>

          <div class="pm-field">
            <label for="imagen">Caratula</label>
            <select class="pm-select" id="imagen" name="imagen">
              <option value="">Sin imagen (se genera una)</option>
              <%=ImageOptions(DIR_ALBUM, fImagen)%>
            </select>
          </div>

          <div class="pm-field">
            <label for="canciones">Lista de pistas</label>
            <select class="pm-select" id="canciones" name="canciones" multiple size="6"><%=opcionesCanciones%></select>
            <span class="pm-hint">Usa Ctrl para seleccionar varias canciones.</span>
          </div>
        </div>
      </div>
      <div class="pm-panel__foot">
        <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("save")%><span>Guardar</span></button>
        <a class="pm-btn pm-btn--ghost" href="<%=Base()%>admin-albumes.asp">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<div class="pm-toolbar">
  <div class="pm-toolbar__search">
    <span class="pm-ico"><%=Icon("search")%></span>
    <label class="pm-sr" for="pmFiltro">Filtrar albumes</label>
    <input class="pm-input" id="pmFiltro" type="search" placeholder="Filtrar por titulo o anio" autocomplete="off">
  </div>
</div>

<div class="pm-tablewrap">
  <table class="pm-table">
    <thead>
      <tr>
        <th>Album</th>
        <th>Anio</th>
        <th>Canciones</th>
        <th>Caratula</th>
        <th style="text-align:right">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <%
    Set rs = DBQuery(SqlAlbumSelect(0) & "ORDER BY al.TITLE_ALBUM", Null)
    If rs.EOF Then
        Response.Write "<tr><td colspan=""5"" class=""pm-hint"">No hay albumes registrados.</td></tr>"
    Else
        Do While Not rs.EOF
            If ToInt(rs("ANIO")) > 0 Then
                anioTexto = CStr(ToInt(rs("ANIO")))
            Else
                anioTexto = "-"
            End If
    %>
      <tr data-fila="<%=H(rs("TITLE_ALBUM") & " " & anioTexto)%>">
        <td>
          <div class="pm-table__main">
            <img class="pm-table__thumb" src="<%=H(CoverUrl(rs("ALBUM_IMAGE_PATH"), rs("TITLE_ALBUM"), rs("ID_ALBUM")))%>" alt="">
            <div>
              <div class="pm-table__title"><%=H(rs("TITLE_ALBUM"))%></div>
              <div class="pm-table__sub">ID <%=ToInt(rs("ID_ALBUM"))%></div>
            </div>
          </div>
        </td>
        <td class="pm-table__sub"><%=anioTexto%></td>
        <td class="pm-num"><%=ToInt(rs("CANCIONES"))%></td>
        <td class="pm-table__sub"><%=H(Nz(rs("ALBUM_IMAGE_PATH"), "-"))%></td>
        <td>
          <div class="pm-table__actions">
            <a class="pm-iconbtn pm-iconbtn--sm" title="Editar" href="<%=Base()%>admin-albumes.asp?editar=<%=ToInt(rs("ID_ALBUM"))%>"><%=Icon("edit")%></a>
            <form method="post" action="<%=Base()%>admin-albumes.asp" data-confirmar="Eliminar el album <%=H(rs("TITLE_ALBUM"))%>? Las canciones no se borraran, solo dejaran de pertenecer al album.">
              <%=CsrfField()%>
              <input type="hidden" name="accion" value="eliminar">
              <input type="hidden" name="id_album" value="<%=ToInt(rs("ID_ALBUM"))%>">
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
