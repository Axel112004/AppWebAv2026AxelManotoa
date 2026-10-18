<%
' =============================================================================
'  PoliMusic | Consultas SQL reutilizables
' -----------------------------------------------------------------------------
'  Se centralizan aqui para que todas las paginas usen exactamente los mismos
'  criterios de orden y las mismas columnas calculadas.
'  El parametro  limite  agrega TOP n cuando es mayor que cero.
' =============================================================================

'  Proyeccion base de canciones: nombre, ruta, reproducciones, artistas
'  concatenados, album principal y su caratula.
Function SqlSongSelect(ByVal limite)
    Dim t
    t = ""
    If ToInt(limite) > 0 Then t = "TOP " & ToInt(limite) & " "

    SqlSongSelect = _
      "SELECT " & t & "s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS, 0) AS PLAYS, " & _
      "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
        "FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "WHERE p.ID_SONG = s.ID_SONG FOR XML PATH('')), 1, 2, '')), '') AS ARTISTAS, " & _
      "ISNULL((SELECT TOP 1 al.TITLE_ALBUM FROM TBL_TRACKLIST t " & _
        "INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
        "WHERE t.ID_SONG = s.ID_SONG), '') AS ALBUM, " & _
      "ISNULL((SELECT TOP 1 al.ALBUM_IMAGE_PATH FROM TBL_TRACKLIST t " & _
        "INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
        "WHERE t.ID_SONG = s.ID_SONG), '') AS ALBUM_IMG, " & _
      "ISNULL((SELECT TOP 1 t.ID_ALBUM FROM TBL_TRACKLIST t " & _
        "WHERE t.ID_SONG = s.ID_SONG), 0) AS ID_ALBUM " & _
      "FROM TBL_SONG s "
End Function

'  Proyeccion base de albumes con el numero de canciones de su lista de pistas
Function SqlAlbumSelect(ByVal limite)
    Dim t
    t = ""
    If ToInt(limite) > 0 Then t = "TOP " & ToInt(limite) & " "

    SqlAlbumSelect = _
      "SELECT " & t & "al.ID_ALBUM, al.TITLE_ALBUM, ISNULL(al.RELEASE_YEAR, 0) AS ANIO, " & _
      "al.ALBUM_IMAGE_PATH, " & _
      "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS CANCIONES " & _
      "FROM TBL_ALBUM al "
End Function

'  Proyeccion base de artistas con el numero de canciones asociadas
Function SqlArtistSelect(ByVal limite)
    Dim t
    t = ""
    If ToInt(limite) > 0 Then t = "TOP " & ToInt(limite) & " "

    SqlArtistSelect = _
      "SELECT " & t & "a.ID_ARTIST, a.ARTIST_NAME, ISNULL(a.ARTIST_LASTNAME, '') AS ARTIST_LASTNAME, " & _
      "a.ARTIST_IMAGE, " & _
      "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS CANCIONES " & _
      "FROM TBL_ARTIST a "
End Function

'  Proyeccion base de playlists con propietario y numero de canciones
Function SqlPlaylistSelect(ByVal limite)
    Dim t
    t = ""
    If ToInt(limite) > 0 Then t = "TOP " & ToInt(limite) & " "

    SqlPlaylistSelect = _
      "SELECT " & t & "pl.ID_PLAYLIST, pl.TITLE, pl.TYPE, pl.CREATION_DATE, pl.PHOTO, " & _
      "pl.ID_USER, u.USERNAME AS PROPIETARIO, " & _
      "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = pl.ID_PLAYLIST) AS CANCIONES " & _
      "FROM TBL_PLAYLIST pl INNER JOIN TBL_USER u ON u.ID_USER = pl.ID_USER "
End Function

'  Nombre completo del artista
Function ArtistFullName(ByVal nombre, ByVal apellido)
    Dim n, a
    n = Clean(nombre)
    a = Clean(apellido)
    If a = "" Then
        ArtistFullName = n
    Else
        ArtistFullName = n & " " & a
    End If
End Function

'  Etiqueta del tipo de playlist. El valor se toma de TBL_CATALOG y se
'  presenta en espanol para la interfaz.
Function PlaylistTypeLabel(ByVal tipo)
    Dim etiqueta
    etiqueta = LCase(Clean(CatalogLabel("2", tipo)))

    Select Case etiqueta
        Case "public", "publica"
            PlaylistTypeLabel = "Publica"
        Case "private", "privada"
            PlaylistTypeLabel = "Privada"
        Case Else
            If ToInt(tipo) = PLAYLIST_PRIVATE Then
                PlaylistTypeLabel = "Privada"
            Else
                PlaylistTypeLabel = "Publica"
            End If
    End Select
End Function
%>
