<%
' =============================================================================
'  PoliMusic | Componentes de interfaz reutilizables
'  Tarjetas y filas que comparten todas las paginas para mantener un diseno
'  coherente y evitar duplicar marcado.
' =============================================================================

' -----------------------------------------------------------------------------
'  Boton de reproduccion.
'  Si el visitante no ha iniciado sesion se convierte en un enlace al acceso,
'  de modo que la restriccion tambien se entiende sin JavaScript.
' -----------------------------------------------------------------------------
Function PlayButton(ByVal idx, ByVal nombreCola, ByVal etiqueta, ByVal clase)
    Dim html
    If IsLoggedIn() Then
        html = "<button class=""" & clase & """ type=""button"" data-pm-index=""" & ToInt(idx) & """" & _
               " data-pm-queue=""" & H(nombreCola) & """" & _
               " aria-label=""Reproducir " & H(etiqueta) & """ title=""Reproducir"">" & _
               Icon("play") & "</button>"
    Else
        html = "<a class=""" & clase & """ href=""" & Base() & "login.asp"" title=""Inicia sesion para reproducir""" & _
               " aria-label=""Inicia sesion para reproducir " & H(etiqueta) & """>" & Icon("play") & "</a>"
    End If
    PlayButton = html
End Function

' -----------------------------------------------------------------------------
'  Tarjeta de cancion
' -----------------------------------------------------------------------------
Function SongCard(ByVal idx, ByVal nombreCola, ByVal id, ByVal nombre, ByVal artistas, _
                  ByVal album, ByVal plays, ByVal cover, ByVal esPreview, ByVal acciones)
    Dim html, titulo
    titulo = Clean(nombre)

    html = "<article class=""pm-card pm-song"" data-fila=""" & _
           H(titulo & " " & artistas & " " & Clean(album)) & """>" & _
           "<div class=""pm-song__cover"">" & _
           "<img src=""" & H(cover) & """ alt=""Portada de " & H(titulo) & """ loading=""lazy"">" & _
           PlayButton(idx, nombreCola, titulo, "pm-play") & _
           "</div>" & _
           "<div class=""pm-song__body"">" & _
           "<h3 class=""pm-song__name"" title=""" & H(titulo) & """>" & H(titulo) & "</h3>" & _
           "<p class=""pm-song__artist"">" & H(artistas) & "</p>" & _
           "<div class=""pm-song__foot"">" & _
           "<span class=""pm-badge"" title=""Reproducciones"">" & Icon("headphones") & ToInt(plays) & "</span>"

    If esPreview Then
        html = html & "<span class=""pm-badge pm-badge--warn"" title=""El archivo de audio original no esta disponible"">Vista previa</span>"
    End If
    If Clean(album) <> "" Then
        html = html & "<span class=""pm-badge pm-badge--muted"" title=""Album"">" & H(Truncate(album, 20)) & "</span>"
    End If

    html = html & "</div>" & acciones & "</div></article>"
    SongCard = html
End Function

' -----------------------------------------------------------------------------
'  Fila de cancion (listados dentro de album o playlist)
' -----------------------------------------------------------------------------
Function SongRow(ByVal idx, ByVal nombreCola, ByVal id, ByVal nombre, ByVal subtitulo, _
                 ByVal plays, ByVal esPreview, ByVal acciones)
    Dim html, titulo
    titulo = Clean(nombre)

    html = "<div class=""pm-row"">" & _
           PlayButton(idx, nombreCola, titulo, "pm-row__play") & _
           "<div class=""pm-row__main"">" & _
           "<div class=""pm-row__name"">" & H(titulo) & "</div>" & _
           "<div class=""pm-row__sub"">" & H(subtitulo)
    If esPreview Then
        html = html & " <span class=""pm-badge pm-badge--warn"">Vista previa</span>"
    End If
    html = html & "</div></div>" & _
           "<span class=""pm-badge"" title=""Reproducciones"">" & Icon("headphones") & ToInt(plays) & "</span>" & _
           "<div class=""pm-row__tools"">" & acciones & "</div></div>"
    SongRow = html
End Function

' -----------------------------------------------------------------------------
'  Tarjeta de album
' -----------------------------------------------------------------------------
Function AlbumCard(ByVal id, ByVal titulo, ByVal anio, ByVal cover, ByVal numCanciones, ByVal acciones)
    Dim html, meta, url
    url = Base() & "album.asp?id=" & ToInt(id)

    meta = Plural(numCanciones, "cancion", "canciones")
    If ToInt(anio) > 0 Then meta = ToInt(anio) & " &middot; " & meta

    html = "<article class=""pm-card"">" & _
           "<a class=""pm-cover"" href=""" & url & """ tabindex=""-1"" aria-hidden=""true"">" & _
           "<img src=""" & H(cover) & """ alt="""" loading=""lazy"">" & _
           "</a>" & _
           "<div class=""pm-cover__body"">" & _
           "<a class=""pm-cover__title"" href=""" & url & """ title=""" & H(titulo) & """>" & H(titulo) & "</a>" & _
           "<div class=""pm-cover__meta"">" & meta & "</div>" & _
           acciones & "</div></article>"
    AlbumCard = html
End Function

' -----------------------------------------------------------------------------
'  Tarjeta de artista
' -----------------------------------------------------------------------------
Function ArtistCard(ByVal id, ByVal nombre, ByVal foto, ByVal numCanciones)
    Dim html, url
    url = Base() & "artist.asp?id=" & ToInt(id)

    html = "<article class=""pm-card pm-artist"">" & _
           "<a class=""pm-artist__photo"" href=""" & url & """ tabindex=""-1"" aria-hidden=""true"">" & _
           "<img src=""" & H(foto) & """ alt="""" loading=""lazy"">" & _
           "</a>" & _
           "<div class=""pm-cover__body"">" & _
           "<a class=""pm-cover__title"" href=""" & url & """ title=""" & H(nombre) & """>" & H(nombre) & "</a>" & _
           "<div class=""pm-cover__meta"">" & H(Plural(numCanciones, "cancion", "canciones")) & "</div>" & _
           "</div></article>"
    ArtistCard = html
End Function

' -----------------------------------------------------------------------------
'  Tarjeta de playlist
' -----------------------------------------------------------------------------
Function PlaylistCard(ByVal id, ByVal titulo, ByVal etiquetaTipo, ByVal propietario, _
                      ByVal cover, ByVal numCanciones, ByVal acciones)
    Dim html, url, badgeClase
    url = Base() & "playlist.asp?id=" & ToInt(id)

    If LCase(CStr(etiquetaTipo)) = "public" Then
        badgeClase = "pm-badge--ok"
    Else
        badgeClase = "pm-badge--muted"
    End If

    html = "<article class=""pm-card"">" & _
           "<a class=""pm-cover"" href=""" & url & """ tabindex=""-1"" aria-hidden=""true"">" & _
           "<img src=""" & H(cover) & """ alt="""" loading=""lazy"">" & _
           "</a>" & _
           "<div class=""pm-cover__body"">" & _
           "<div class=""pm-song__foot"" style=""margin:0 0 7px"">" & _
           "<span class=""pm-badge " & badgeClase & """>" & H(etiquetaTipo) & "</span>" & _
           "<span class=""pm-badge pm-badge--line"">" & H(Plural(numCanciones, "cancion", "canciones")) & "</span>" & _
           "</div>" & _
           "<a class=""pm-cover__title"" href=""" & url & """ title=""" & H(titulo) & """>" & H(titulo) & "</a>" & _
           "<div class=""pm-cover__meta"">de " & H(propietario) & "</div>" & _
           acciones & "</div></article>"
    PlaylistCard = html
End Function

' -----------------------------------------------------------------------------
'  Selector rapido "agregar a una playlist"
' -----------------------------------------------------------------------------
'  Devuelve las playlists propias del usuario como etiquetas <option>
Function PlaylistOptions(ByVal idUsuario)
    Dim rs, html
    html = ""
    Set rs = DBQuery("SELECT ID_PLAYLIST, TITLE FROM TBL_PLAYLIST WHERE ID_USER = ? ORDER BY TITLE", Array(idUsuario))
    Do While Not rs.EOF
        html = html & "<option value=""" & ToInt(rs("ID_PLAYLIST")) & """>" & H(rs("TITLE")) & "</option>"
        rs.MoveNext
    Loop
    rs.Close
    PlaylistOptions = html
End Function

'  Boton desplegable que agrega la cancion a una de las playlists del usuario.
'  Si todavia no tiene playlists se ofrece crear una.
Function AddToPlaylistWidget(ByVal idSong, ByVal opciones)
    Dim html
    If Not IsLoggedIn() Then
        AddToPlaylistWidget = ""
        Exit Function
    End If

    If Clean(opciones) = "" Then
        AddToPlaylistWidget = "<div class=""pm-addto"">" & _
            "<a class=""pm-btn pm-btn--ghost pm-btn--sm"" href=""" & Base() & "playlists.asp"">" & _
            Icon("plus") & "Crear playlist</a></div>"
        Exit Function
    End If

    html = "<details class=""pm-addto"">" & _
        "<summary class=""pm-btn pm-btn--ghost pm-btn--sm"" title=""Agregar a una de mis playlists"">" & _
        Icon("plus") & "Agregar</summary>" & _
        "<form class=""pm-addto__form"" method=""post"" action=""" & Base() & "playlist_add.asp"">" & _
        CsrfField() & _
        "<input type=""hidden"" name=""id_song"" value=""" & ToInt(idSong) & """>" & _
        "<label class=""pm-field""><span class=""pm-hint"">Agregar a la playlist:</span>" & _
        "<select class=""pm-select"" name=""id_playlist"">" & opciones & "</select></label>" & _
        "<button class=""pm-btn pm-btn--primary pm-btn--sm pm-btn--block"" type=""submit"">" & _
        Icon("check") & "Agregar</button>" & _
        "</form></details>"

    AddToPlaylistWidget = html
End Function

' -----------------------------------------------------------------------------
'  Estado vacio
' -----------------------------------------------------------------------------
Function EmptyState(ByVal icono, ByVal titulo, ByVal texto, ByVal accionHtml)
    EmptyState = "<div class=""pm-empty"">" & _
        "<div class=""pm-empty__ico"">" & Icon(icono) & "</div>" & _
        "<h3>" & H(titulo) & "</h3>" & _
        "<p>" & H(texto) & "</p>" & accionHtml & _
        "</div>"
End Function

' -----------------------------------------------------------------------------
'  Cabecera de pagina reutilizable
' -----------------------------------------------------------------------------
Function PageHead(ByVal eyebrow, ByVal icono, ByVal titulo, ByVal subtitulo, ByVal accionesHtml)
    Dim html
    html = "<div class=""pm-page-head""><div class=""pm-page-head__txt"">"
    If Clean(eyebrow) <> "" Then
        html = html & "<span class=""pm-eyebrow"">" & Icon(icono) & H(eyebrow) & "</span>"
    End If
    html = html & "<h1 class=""pm-title"">" & H(titulo) & "</h1>"
    If Clean(subtitulo) <> "" Then
        html = html & "<p class=""pm-subtitle"">" & H(subtitulo) & "</p>"
    End If
    html = html & "</div>"
    If Clean(accionesHtml) <> "" Then
        html = html & "<div class=""pm-page-head__actions"">" & accionesHtml & "</div>"
    End If
    html = html & "</div>"
    PageHead = html
End Function
%>
