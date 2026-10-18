<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Cierre de sesion
'  Se elimina toda la informacion de la sesion y se vuelve al acceso.
' =============================================================================
Dim pmNombre
pmNombre = CurrentUserName()

' Se limpia por completo el contenido de la sesion (usuario, permisos, token)
Session.Contents.RemoveAll()

SetFlash "Tu sesion se cerro correctamente. Hasta pronto.", "ok"

CloseConn
Response.Redirect Base() & "login.asp"
Response.End
%>
