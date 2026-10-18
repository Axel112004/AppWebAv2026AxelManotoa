<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Administracion de canciones
'  Crear, consultar, actualizar y eliminar canciones, incluyendo su relacion
'  con artistas (TBL_PLAYER) y con su album (TBL_TRACKLIST).
' =============================================================================
RequireAdmin

Dim accion, modoForm, idEdit, errorMsg, rs, nuevoId, idEliminar
Dim fNombre, fRuta, fReproducciones, fAlbum, fArtistas, i, j
Dim artistasSeleccionados, listaArtistas, opcionesArtistas, opcionesAlbum
Dim total, fila, partes, pid, marcado, artistasTexto, existeArchivo

PageTitle   = "Canciones"
PageSection = "admin-canciones"

accion   = LCase(Clean(Request.Form("accion")))
modoForm = ""
errorMsg = ""

If LCase(Clean(Request.QueryString("accion"))) = "nueva" Then modoForm = "nuevo"
idEdit = ToInt(Request.QueryString("editar"))

Set artistasSeleccionados = Server.CreateObject("Scripting.Dictionary")
artistasSeleccionados.CompareMode = 1

' ---------------------------------------------------------------------------
'  Acciones
' ---------------------------------------------------------------------------
If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) = "POST" Then
    CheckCsrf

    If accion = "guardar" Then
        idEdit          = ToInt(Request.Form("id_song"))
        fNombre         = Clean(Request.Form("nombre"))
        fRuta           = Clean(Request.Form("ruta"))
        fReproducciones = ToInt(Request.Form("reproducciones"))
        fAlbum          = ToInt(Request.Form("album"))
        fArtistas       = CStr(Nz(Request.Form("artistas"), ""))

        If fNombre = "" Then
            errorMsg = "El nombre de la cancion es obligatorio."
        ElseIf Len(fNombre) > 50 Then
            errorMsg = "El nombre no puede superar los 50 caracteres."
        ElseIf fRuta = "" Then
            errorMsg = "Debes indicar el archivo de audio de la cancion."
        ElseIf Not ValidSongPath(fRuta) Then
            errorMsg = "El archivo indicado no existe en la carpeta " & DIR_SONGS & "."
        ElseIf fReproducciones < 0 Then
            errorMsg = "El numero de reproducciones no puede ser negativo."
        Else
            If idEdit > 0 Then
                DBExecute "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?", _
                          Array(fNombre, fRuta, fReproducciones, idEdit)
            Else
                idEdit = DBInsert("INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, ?)", _
                                  Array(fNombre, fRuta, fReproducciones))
            End If

            If idEdit > 0 Then
                ' --- Artistas: se reemplaza la relacion completa ---
                DBExecute "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(idEdit)

                partes = Split(fArtistas, ",")
                For i = 0 To UBound(partes)
                    pid = ToInt(Trim(partes(i)))
                    If pid > 0 Then
                        If DBExists("SELECT 1 FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(pid)) Then
                            If Not DBExists("SELECT 1 FROM TBL_PLAYER WHERE ID_SONG = ? AND ID_ARTIST = ?", Array(idEdit, pid)) Then
                                DBExecute "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (?, ?)", Array(idEdit, pid)
                            End If
                        End If
                    End If
                Next

                ' --- Album: una cancion pertenece a un album principal ---
                DBExecute "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(idEdit)
                If fAlbum > 0 Then
                    If DBExists("SELECT 1 FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(fAlbum)) Then
                        DBExecute "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)", Array(fAlbum, idEdit)
                    End If
                End If

                SetFlash "La cancion se guardo correctamente.", "ok"
                CloseConn
                Response.Redirect Base() & "admin-canciones.asp"
                Response.End
            Else
                errorMsg = "No se pudo guardar la cancion."
            End If
        End If
        modoForm = "form"

    ElseIf accion = "eliminar" Then
        idEliminar = ToInt(Request.Form("id_song"))

        If Not DBExists("SELECT 1 FROM TBL_SONG WHERE ID_SONG = ?", Array(idEliminar)) Then
            errorMsg = "La cancion ya no existe."
        Else
            DBExecute "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(idEliminar)
            DBExecute "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(idEliminar)
            DBExecute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?", Array(idEliminar)
            DBExecute "DELETE FROM TBL_SONG WHERE ID_SONG = ?", Array(idEliminar)
            SetFlash "La cancion se elimino correctamente.", "ok"
            CloseConn
            Response.Redirect Base() & "admin-canciones.asp"
            Response.End
        End If
    End If
End If

' ---------------------------------------------------------------------------
'  Formulario
' ---------------------------------------------------------------------------
If modoForm = "" And idEdit > 0 Then modoForm = "form"

fNombre         = ""
fRuta           = ""
fReproducciones = 0
fAlbum          = 0

If modoForm = "form" And idEdit > 0 Then
    Set rs = DBQuery("SELECT SONG_NAME, SONG_PATH, ISNULL(PLAYS, 0) AS PLAYS FROM TBL_SONG WHERE ID_SONG = ?", Array(idEdit))
    If rs.EOF Then
        rs.Close
        AbortPage "Cancion no encontrada", "La cancion solicitada no existe."
    End If
    fNombre         = Clean(rs("SONG_NAME"))
    fRuta           = Clean(rs("SONG_PATH"))
    fReproducciones = ToInt(rs("PLAYS"))
    rs.Close

    ' Album actual
    Set rs = DBQuery("SELECT TOP 1 ID_ALBUM FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(idEdit))
    If Not rs.EOF Then fAlbum = ToInt(rs("ID_ALBUM"))
    rs.Close

    ' Artistas actuales
    Set rs = DBQuery("SELECT ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?", Array(idEdit))
    Do While Not rs.EOF
        artistasSeleccionados(CStr(ToInt(rs("ID_ARTIST")))) = True
        rs.MoveNext
    Loop
    rs.Close
End If

' Opciones de artistas (multi seleccion)
opcionesArtistas = ""
Set rs = DBQuery("SELECT ID_ARTIST, ARTIST_NAME, ISNULL(ARTIST_LASTNAME, '') AS APELLIDO FROM TBL_ARTIST ORDER BY ARTIST_NAME", Null)
Do While Not rs.EOF
    marcado = IIfStr(artistasSeleccionados.Exists(CStr(ToInt(rs("ID_ARTIST")))), " selected", "")
    opcionesArtistas = opcionesArtistas & "<option value=""" & ToInt(rs("ID_ARTIST")) & """" & marcado & ">" & _
                       H(ArtistFullName(rs("ARTIST_NAME"), rs("APELLIDO"))) & "</option>"
    rs.MoveNext
Loop
rs.Close

' Opciones de album
opcionesAlbum = "<option value=""0"">Sin album asignado</option>"
Set rs = DBQuery("SELECT ID_ALBUM, TITLE_ALBUM FROM TBL_ALBUM ORDER BY TITLE_ALBUM", Null)
Do While Not rs.EOF
    opcionesAlbum = opcionesAlbum & "<option value=""" & ToInt(rs("ID_ALBUM")) & """" & _
                    IIfStr(fAlbum = ToInt(rs("ID_ALBUM")), " selected", "") & ">" & H(rs("TITLE_ALBUM")) & "</option>"
    rs.MoveNext
Loop
rs.Close

total = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_SONG", Null))

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Administracion", "music", "Canciones", _
    Plural(total, "cancion registrada", "canciones registradas"), _
    "<a class=""pm-btn pm-btn--primary"" href=""" & Base() & "admin-canciones.asp?accion=nueva"">" & _
    Icon("plus") & "<span>Nueva cancion</span></a>")%>

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
      <span class="pm-section__title"><%=Icon("music")%> <% If idEdit > 0 Then %>Editar cancion<% Else %>Nueva cancion<% End If %></span>
    </div>
    <form method="post" action="<%=Base()%>admin-canciones.asp">
      <div class="pm-panel__body">
        <%=CsrfField()%>
        <input type="hidden" name="accion" value="guardar">
        <input type="hidden" name="id_song" value="<%=idEdit%>">

        <div class="pm-form pm-form--2">
          <div class="pm-field">
            <label for="nombre">Nombre de la cancion <span class="pm-req">*</span></label>
            <input class="pm-input" id="nombre" name="nombre" type="text" required
                   maxlength="50" value="<%=H(fNombre)%>" placeholder="Por ejemplo: Adventure">
          </div>

          <div class="pm-field">
            <label for="reproducciones">Reproducciones</label>
            <input class="pm-input" id="reproducciones" name="reproducciones" type="number"
                   min="0" value="<%=fReproducciones%>">
          </div>

          <div class="pm-field pm-span-2">
            <label for="ruta">Archivo de audio <span class="pm-req">*</span></label>
            <select class="pm-select" id="ruta" name="ruta" required>
              <option value="">Selecciona un archivo de la carpeta <%=H(DIR_SONGS)%>...</option>
              <%=AudioFileOptions(fRuta)%>
            </select>
            <span class="pm-hint">Solo se muestran los archivos que existen en la carpeta <%=H(DIR_SONGS)%>.</span>
          </div>

          <div class="pm-field">
            <label for="album">Album</label>
            <select class="pm-select" id="album" name="album"><%=opcionesAlbum%></select>
          </div>

          <div class="pm-field">
            <label for="artistas">Artistas</label>
            <select class="pm-select" id="artistas" name="artistas" multiple size="5"><%=opcionesArtistas%></select>
            <span class="pm-hint">Manten pulsada la tecla Ctrl para elegir varios artistas.</span>
          </div>
        </div>
      </div>
      <div class="pm-panel__foot">
        <button class="pm-btn pm-btn--primary" type="submit"><%=Icon("save")%><span>Guardar</span></button>
        <a class="pm-btn pm-btn--ghost" href="<%=Base()%>admin-canciones.asp">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<div class="pm-toolbar">
  <div class="pm-toolbar__search">
    <span class="pm-ico"><%=Icon("search")%></span>
    <label class="pm-sr" for="pmFiltro">Filtrar canciones</label>
    <input class="pm-input" id="pmFiltro" type="search" placeholder="Filtrar por nombre, artista o album" autocomplete="off">
  </div>
</div>

<div class="pm-tablewrap">
  <table class="pm-table">
    <thead>
      <tr>
        <th>Cancion</th>
        <th>Album</th>
        <th>Archivo</th>
        <th>Reproducciones</th>
        <th style="text-align:right">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <%
    Set rs = DBQuery(SqlSongSelect(0) & "ORDER BY s.SONG_NAME", Null)
    If rs.EOF Then
        Response.Write "<tr><td colspan=""5"" class=""pm-hint"">No hay canciones registradas.</td></tr>"
    Else
        Do While Not rs.EOF
            existeArchivo = Not SongIsPreview(rs("SONG_PATH"))
            artistasTexto = Clean(rs("ARTISTAS"))
            If artistasTexto = "" Then artistasTexto = "Sin artistas"
    %>
      <tr data-fila="<%=H(rs("SONG_NAME") & " " & artistasTexto & " " & rs("ALBUM"))%>">
        <td>
          <div class="pm-table__main">
            <img class="pm-table__thumb" src="<%=H(SongCover(rs("ALBUM_IMG"), rs("ALBUM"), rs("ID_ALBUM"), rs("SONG_NAME")))%>" alt="">
            <div>
              <div class="pm-table__title"><%=H(rs("SONG_NAME"))%></div>
              <div class="pm-table__sub"><%=H(artistasTexto)%></div>
            </div>
          </div>
        </td>
        <td class="pm-table__sub"><%=H(Nz(rs("ALBUM"), "-"))%></td>
        <td>
          <% If existeArchivo Then %>
          <span class="pm-badge pm-badge--ok"><%=Icon("check")%>Disponible</span>
          <% Else %>
          <span class="pm-badge pm-badge--warn"><%=Icon("alert")%>No encontrado</span>
          <% End If %>
        </td>
        <td class="pm-num"><%=ToInt(rs("PLAYS"))%></td>
        <td>
          <div class="pm-table__actions">
            <a class="pm-iconbtn pm-iconbtn--sm" title="Editar" href="<%=Base()%>admin-canciones.asp?editar=<%=ToInt(rs("ID_SONG"))%>"><%=Icon("edit")%></a>
            <form method="post" action="<%=Base()%>admin-canciones.asp" data-confirmar="Eliminar la cancion <%=H(rs("SONG_NAME"))%>? Tambien se quitara de los albumes y playlists.">
              <%=CsrfField()%>
              <input type="hidden" name="accion" value="eliminar">
              <input type="hidden" name="id_song" value="<%=ToInt(rs("ID_SONG"))%>">
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
