<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Administracion de playlists
'  El administrador puede consultar y modificar las playlists de cualquier
'  usuario, incluyendo su contenido (agregar y quitar canciones).
' =============================================================================
RequireAdmin

Dim accion, modoForm, idEdit, errorMsg, rs, idEliminar, nuevoId
Dim fTitulo, fTipo, fFoto, fPropietario, opcionesImagen, opcionesUsuarios
Dim total, nPublicas, nPrivadas, tiposHtml, i, etiquetaTipo, filtroUsuario

PageTitle   = "Playlists"
PageSection = "admin-playlists"

accion   = LCase(Clean(Request.Form("accion")))
modoForm = ""
errorMsg = ""

If LCase(Clean(Request.QueryString("accion"))) = "nueva" Then modoForm = "nuevo"
idEdit = ToInt(Request.QueryString("editar"))

' ---------------------------------------------------------------------------
'  Acciones
' ---------------------------------------------------------------------------
If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    If accion = "guardar" Then
        idEdit       = ToInt(Request.Form("id_playlist"))
        fTitulo      = Clean(Request.Form("titulo"))
        fTipo        = ToInt(Request.Form("tipo"))
        fFoto        = Clean(Request.Form("foto"))
        fPropietario = ToInt(Request.Form("propietario"))

        If fTitulo = "" Then
            errorMsg = "El titulo de la playlist es obligatorio."
        ElseIf Len(fTitulo) > MAX_TITLE_LEN Then
            errorMsg = "El titulo no puede superar los " & MAX_TITLE_LEN & " caracteres."
        ElseIf fTipo <> PLAYLIST_PUBLIC And fTipo <> PLAYLIST_PRIVATE Then
            errorMsg = "El tipo de playlist no es valido."
        ElseIf Not ValidPlaylistPhoto(fFoto) Then
            errorMsg = "La imagen seleccionada no es valida."
        ElseIf Not DBExists("SELECT 1 FROM TBL_USER WHERE ID_USER = ?", Array(fPropietario)) Then
            errorMsg = "El propietario seleccionado no existe."
        Else
            If idEdit > 0 Then
                DBExecute "UPDATE TBL_PLAYLIST SET TITLE = ?, TYPE = ?, PHOTO = ?, ID_USER = ? WHERE ID_PLAYLIST = ?", _
                          Array(fTitulo, fTipo, fFoto, fPropietario, idEdit)
            Else
                idEdit = DBInsert( _
                    "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO) VALUES (?, ?, GETDATE(), ?, ?)", _
                    Array(fPropietario, fTitulo, fTipo, fFoto))
            End If

            If idEdit > 0 Then
                SetFlash "La playlist se guardo correctamente.", "ok"
                CloseConn
                Response.Redirect Base() & "playlist.asp?id=" & idEdit
                Response.End
            Else
                errorMsg = "No se pudo guardar la playlist."
            End If
        End If
        modoForm = "form"

    ElseIf accion = "eliminar" Then
        idEliminar = ToInt(Request.Form("id_playlist"))

        If Not DBExists("SELECT 1 FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(idEliminar)) Then
            errorMsg = "La playlist ya no existe."
        Else
            DBExecute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", Array(idEliminar)
            DBExecute "DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(idEliminar)
            SetFlash "La playlist se elimino correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "admin-playlists.asp"
            Response.End
        End If
    End If
End If

' ---------------------------------------------------------------------------
'  Formulario
' ---------------------------------------------------------------------------
If modoForm = "" And idEdit > 0 Then modoForm = "form"

fTitulo      = ""
fTipo        = PLAYLIST_PUBLIC
fFoto        = ""
fPropietario = CurrentUserId()

If modoForm = "form" And idEdit > 0 Then
    Set rs = DBQuery("SELECT TITLE, TYPE, PHOTO, ID_USER FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(idEdit))
    If rs.EOF Then
        rs.Close
        AbortPage "Playlist no encontrada", "La playlist solicitada no existe."
    End If
    fTitulo      = Clean(rs("TITLE"))
    fTipo        = ToInt(rs("TYPE"))
    fFoto        = Clean(rs("PHOTO"))
    fPropietario = ToInt(rs("ID_USER"))
    rs.Close
End If

tiposHtml = ""
For i = 0 To 1
    tiposHtml = tiposHtml & "<option value=""" & i & """" & IIfStr(fTipo = i, " selected", "") & ">" & _
                H(PlaylistTypeLabel(i)) & "</option>"
Next

opcionesImagen = ImageOptions(DIR_PLAYLIST, fFoto)

opcionesUsuarios = ""
Set rs = DBQuery("SELECT ID_USER, USERNAME FROM TBL_USER ORDER BY USERNAME", Null)
Do While Not rs.EOF
    opcionesUsuarios = opcionesUsuarios & "<option value=""" & ToInt(rs("ID_USER")) & """" & _
        IIfStr(fPropietario = ToInt(rs("ID_USER")), " selected", "") & ">" & H(rs("USERNAME")) & "</option>"
    rs.MoveNext
Loop
rs.Close

total     = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST", Null))
nPublicas = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST WHERE TYPE = ?", Array(PLAYLIST_PUBLIC)))
nPrivadas = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_PLAYLIST WHERE TYPE = ?", Array(PLAYLIST_PRIVATE)))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Administracion", "playlist", "Playlists", _
    Plural(total, "playlist registrada", "playlists registradas") & " (" & nPublicas & " publicas, " & nPrivadas & " privadas)", _
    "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "admin-playlists.asp?accion=nueva"">" & _
    Icon("plus") & "<span>Nueva playlist</span></a>")%>

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
      <span class="pm-section__title"><%=Icon("playlist")%> <% If idEdit > 0 Then %>Editar playlist<% Else %>Nueva playlist<% End If %></span>
    </div>
    <form method="post" action="<%=Base()%>admin-playlists.asp">
      <div class="pm-panel__body">
        <%=CsrfField()%>
        <input type="hidden" name="accion" value="guardar">
        <input type="hidden" name="id_playlist" value="<%=idEdit%>">

        <div class="pm-form pm-form--2">
          <div class="pm-field">
            <label for="titulo">Titulo <span class="pm-req">*</span></label>
            <input class="pm-input" id="titulo" name="titulo" type="text" required
                   maxlength="<%=MAX_TITLE_LEN%>" value="<%=H(fTitulo)%>">
          </div>

          <div class="pm-field">
            <label for="propietario">Propietario</label>
            <select class="pm-select" id="propietario" name="propietario"><%=opcionesUsuarios%></select>
          </div>

          <div class="pm-field">
            <label for="tipo">Visibilidad</label>
            <select class="pm-select" id="tipo" name="tipo"><%=tiposHtml%></select>
          </div>

          <div class="pm-field">
            <label for="foto">Portada</label>
            <select class="pm-select" id="foto" name="foto">
              <option value="">Sin imagen (se genera una)</option>
              <%=opcionesImagen%>
            </select>
          </div>
        </div>
      </div>
      <div class="pm-panel__foot">
        <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("save")%><span>Guardar</span></button>
        <a class="pm-btn pm-btn--ghost" href="<%=Base()%>admin-playlists.asp">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<div class="pm-toolbar">
  <div class="pm-toolbar__search">
    <span class="pm-ico"><%=Icon("search")%></span>
    <label class="pm-sr" for="pmFiltro">Filtrar playlists</label>
    <input class="pm-input" id="pmFiltro" type="search" placeholder="Filtrar por titulo, propietario o tipo" autocomplete="off">
  </div>
</div>

<div class="pm-tablewrap">
  <table class="pm-table">
    <thead>
      <tr>
        <th>Playlist</th>
        <th>Propietario</th>
        <th>Tipo</th>
        <th>Canciones</th>
        <th>Creada</th>
        <th style="text-align:right">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <%
    Set rs = DBQuery(SqlPlaylistSelect(0) & "ORDER BY pl.CREATION_DATE DESC, pl.ID_PLAYLIST DESC", Null)
    If rs.EOF Then
        Response.Write "<tr><td colspan=""6"" class=""pm-hint"">No hay playlists registradas.</td></tr>"
    Else
        Do While Not rs.EOF
            etiquetaTipo = PlaylistTypeLabel(rs("TYPE"))
    %>
      <tr data-fila="<%=H(rs("TITLE") & " " & rs("PROPIETARIO") & " " & etiquetaTipo)%>">
        <td>
          <div class="pm-table__main">
            <img class="pm-table__thumb" src="<%=H(CoverUrl(rs("PHOTO"), rs("TITLE"), rs("ID_PLAYLIST")))%>" alt="">
            <div>
              <div class="pm-table__title"><%=H(rs("TITLE"))%></div>
              <div class="pm-table__sub">ID <%=ToInt(rs("ID_PLAYLIST"))%></div>
            </div>
          </div>
        </td>
        <td class="pm-table__sub"><%=H(rs("PROPIETARIO"))%></td>
        <td>
          <% If ToInt(rs("TYPE")) = PLAYLIST_PUBLIC Then %>
          <span class="pm-badge pm-badge--ok"><%=H(etiquetaTipo)%></span>
          <% Else %>
          <span class="pm-badge pm-badge--muted"><%=H(etiquetaTipo)%></span>
          <% End If %>
        </td>
        <td class="pm-num"><%=ToInt(rs("CANCIONES"))%></td>
        <td class="pm-table__sub"><%=H(FormatDate(rs("CREATION_DATE")))%></td>
        <td>
          <div class="pm-table__actions">
            <a class="pm-iconbtn pm-iconbtn--sm" title="Ver y editar canciones" href="<%=Base()%>playlist.asp?id=<%=ToInt(rs("ID_PLAYLIST"))%>"><%=Icon("list")%></a>
            <a class="pm-iconbtn pm-iconbtn--sm" title="Editar datos" href="<%=Base()%>admin-playlists.asp?editar=<%=ToInt(rs("ID_PLAYLIST"))%>"><%=Icon("edit")%></a>
            <form method="post" action="<%=Base()%>admin-playlists.asp" data-confirmar="Eliminar la playlist <%=H(rs("TITLE"))%>?">
              <%=CsrfField()%>
              <input type="hidden" name="accion" value="eliminar">
              <input type="hidden" name="id_playlist" value="<%=ToInt(rs("ID_PLAYLIST"))%>">
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
