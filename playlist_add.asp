<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Agregar una cancion a una playlist (desde las tarjetas)
'  Solo acepta POST, valida la sesion, el token CSRF y la propiedad de la
'  playlist antes de escribir en la base de datos.
' =============================================================================
RequireLogin

Dim idCancion, idPlaylist, destino, ref, corte, mensaje

If UCase(CStr(Request.ServerVariables("REQUEST_METHOD"))) <> "POST" Then
    Response.Redirect Base() & "songs.asp"
    Response.End
End If

CheckCsrf

idCancion  = ToInt(Request.Form("id_song"))
idPlaylist = ToInt(Request.Form("id_playlist"))

' Pagina de regreso: se toma solo la ruta interna del referente
destino = Base() & "songs.asp"
ref = CStr(Request.ServerVariables("HTTP_REFERER"))
corte = InStr(ref, "://")
If corte > 0 Then
    ref = Mid(ref, corte + 3)
    corte = InStr(ref, "/")
    If corte > 0 Then
        ref = Mid(ref, corte)
        If Left(ref, 1) = "/" And InStr(ref, "//") = 0 Then destino = ref
    End If
End If

If idCancion <= 0 Or idPlaylist <= 0 Then
    SetFlash "Debes elegir una playlist para agregar la cancion.", "error"
ElseIf Not CanManagePlaylist(idPlaylist) Then
    SetFlash "Solo puedes agregar canciones a tus propias playlists.", "error"
ElseIf Not DBExists("SELECT 1 FROM TBL_SONG WHERE ID_SONG = ?", Array(idCancion)) Then
    SetFlash "La cancion seleccionada no existe en el catalogo.", "error"
ElseIf DBExists("SELECT 1 FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", _
                Array(idPlaylist, idCancion)) Then
    SetFlash "Esa cancion ya forma parte de la playlist.", "aviso"
Else
    DBExecute "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (?, ?)", _
              Array(idPlaylist, idCancion)
    SetFlash "La cancion se agrego a tu playlist.", "ok"
End If

CloseConn
Response.Redirect destino
Response.End
%>
