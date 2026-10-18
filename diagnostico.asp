<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' =============================================================================
'  PoliMusic | Diagnostico de la instalacion
'  Comprueba la conexion, las tablas, los usuarios de prueba y los archivos
'  multimedia. Es la primera pagina que conviene abrir despues de publicar.
' =============================================================================
Dim rs, okConexion, detalleError, tablas, i, faltantes, totalTablas, nombreTabla
Dim usuarios, ruta, archivos, objCarpeta, fso, f, nArchivos, carpetaInfo
Dim carpetas, okTodo, nUsuarios, nAdmins, conteo, tipoClave

PageTitle   = "Diagnostico"
PageSection = ""

okConexion   = False
detalleError = ""
nUsuarios    = 0
nAdmins      = 0

' --- Comprobacion de la conexion -------------------------------------------
On Error Resume Next
Set rs = DBQuery("SELECT COUNT(*) FROM TBL_USER", Null)
If Err.Number <> 0 Then
    detalleError = Err.Description
    Err.Clear
Else
    okConexion = True
    If Not rs.EOF Then nUsuarios = ToInt(rs(0))
    rs.Close
End If
On Error GoTo 0

If okConexion Then
    nAdmins = ToInt(DBScalar("SELECT COUNT(*) FROM TBL_USER WHERE USER_TYPE = ?", Array(USER_TYPE_ADMIN)))
End If

' --- Tablas esperadas -------------------------------------------------------
tablas = Array("TBL_USER", "TBL_SONG", "TBL_ARTIST", "TBL_ALBUM", "TBL_TRACKLIST", _
               "TBL_PLAYER", "TBL_PLAYLIST", "TBL_PLAYLIST_SONG", "TBL_CATALOG")
faltantes   = 0
totalTablas = 0

QueueReset ""
%>
<!--#include file="includes/header.asp"-->

<% Response.Write PageHead("Soporte", "settings", "Diagnostico de la instalacion", _
    "Comprobacion rapida de la base de datos y de los archivos multimedia.", "")%>

<div class="pm-grid pm-grid--wide">

  <div class="pm-panel">
    <div class="pm-panel__head">
      <span class="pm-section__title"><%=Icon("settings")%> Entorno del servidor</span>
    </div>
    <div class="pm-panel__body">
      <table class="pm-table" style="font-size:14px">
        <tbody>
          <tr><td class="pm-table__sub">Servidor web</td><td><%=H(Request.ServerVariables("SERVER_SOFTWARE"))%></td></tr>
          <tr><td class="pm-table__sub">Motor de script</td><td>ASP clasico con VBScript</td></tr>
          <tr><td class="pm-table__sub">Ruta fisica</td><td style="word-break:break-all"><%=H(PhysicalPath(""))%></td></tr>
          <tr><td class="pm-table__sub">Codificacion</td><td>UTF-8 (<%=Response.CodePage%>)</td></tr>
          <tr><td class="pm-table__sub">Prefijo relativo</td><td><%=H(IIfStr(Base() = "", "(raiz de la aplicacion)", Base()))%></td></tr>
        </tbody>
      </table>
    </div>
  </div>

  <div class="pm-panel">
    <div class="pm-panel__head">
      <span class="pm-section__title"><%=Icon("shield")%> Conexion a SQL Server</span>
    </div>
    <div class="pm-panel__body">
      <% If okConexion Then %>
      <div class="pm-alert pm-alert--ok" style="margin-bottom:14px">
        <span class="pm-alert__ico"><%=Icon("check")%></span>
        <span class="pm-alert__txt">Conexion establecida correctamente con la base de datos <strong><%=H(DB_NAME)%></strong>.</span>
      </div>
      <% Else %>
      <div class="pm-alert pm-alert--error" style="margin-bottom:14px">
        <span class="pm-alert__ico"><%=Icon("alert")%></span>
        <span class="pm-alert__txt">
          No se pudo consultar la base de datos.<br>
          <strong>Detalle:</strong> <%=H(detalleError)%>
        </span>
      </div>
      <% End If %>

      <table class="pm-table" style="font-size:14px">
        <tbody>
          <tr><td class="pm-table__sub">Proveedor</td><td><%=H(DB_PROVIDER)%></td></tr>
          <tr><td class="pm-table__sub">Servidor</td><td><%=H(DB_SERVER)%></td></tr>
          <tr><td class="pm-table__sub">Base de datos</td><td><%=H(DB_NAME)%></td></tr>
          <tr><td class="pm-table__sub">Usuario</td><td><%=H(DB_USER)%></td></tr>
          <tr><td class="pm-table__sub">Usuarios registrados</td><td><%=nUsuarios%> (<%=nAdmins%> administrador/es)</td></tr>
        </tbody>
      </table>

      <% If okConexion And nAdmins = 0 Then %>
      <div class="pm-alert pm-alert--aviso" style="margin:14px 0 0">
        <span class="pm-alert__ico"><%=Icon("alert")%></span>
        <span class="pm-alert__txt">No existe ningun usuario de tipo ADMIN. Ejecuta el script de la base de datos para crearlo.</span>
      </div>
      <% End If %>
    </div>
  </div>
</div>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("folder")%> Tablas de la base de datos</h2>
  </div>
  <div class="pm-tablewrap">
    <table class="pm-table">
      <thead><tr><th>Tabla</th><th>Estado</th><th>Registros</th></tr></thead>
      <tbody>
      <%
      For i = 0 To UBound(tablas)
          nombreTabla = tablas(i)
          totalTablas = totalTablas + 1
          If okConexion Then
              On Error Resume Next
              conteo = -1
              conteo = ToInt(DBScalar("SELECT COUNT(*) FROM " & nombreTabla, Null))
              If Err.Number <> 0 Then
                  Err.Clear
                  conteo = -1
              End If
              On Error GoTo 0
          Else
              conteo = -1
          End If

          If conteo < 0 Then faltantes = faltantes + 1
      %>
      <tr>
        <td class="pm-table__title"><%=H(nombreTabla)%></td>
        <td>
          <% If conteo >= 0 Then %>
          <span class="pm-badge pm-badge--ok"><%=Icon("check")%>Disponible</span>
          <% Else %>
          <span class="pm-badge pm-badge--warn"><%=Icon("alert")%>No encontrada</span>
          <% End If %>
        </td>
        <td class="pm-num"><% If conteo >= 0 Then %><%=conteo%><% Else %>-<% End If %></td>
      </tr>
      <%
      Next
      %>
      </tbody>
    </table>
  </div>
</section>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("headphones")%> Carpetas multimedia</h2>
  </div>
  <div class="pm-grid pm-grid--wide">
    <%
    carpetas = Array( _
        Array(DIR_SONGS, "Archivos de audio (.mp3)"), _
        Array(DIR_USER, "Imagenes de perfil"), _
        Array(DIR_PLAYLIST, "Portadas de playlists"), _
        Array(DIR_ALBUM, "Caratulas de albumes"), _
        Array(DIR_ARTIST, "Fotografias de artistas"))

    For i = 0 To UBound(carpetas)
        ruta = PhysicalPath(carpetas(i)(0))
        nArchivos = 0
        On Error Resume Next
        Set fso = Server.CreateObject("Scripting.FileSystemObject")
        Set objCarpeta = fso.GetFolder(ruta)
        nArchivos = objCarpeta.Files.Count
        If Err.Number <> 0 Then nArchivos = -1
        Err.Clear
        On Error GoTo 0
    %>
    <div class="pm-card" style="padding:16px;gap:6px">
      <span class="pm-section__title" style="font-size:15px"><%=Icon("folder")%> <%=H(carpetas(i)(0))%></span>
      <span class="pm-hint"><%=H(carpetas(i)(1))%></span>
      <% If nArchivos < 0 Then %>
      <span class="pm-badge pm-badge--warn" style="margin-top:6px"><%=Icon("alert")%>Carpeta no accesible</span>
      <% ElseIf nArchivos = 0 Then %>
      <span class="pm-badge pm-badge--muted" style="margin-top:6px">Vacia (se usaran portadas generadas)</span>
      <% Else %>
      <span class="pm-badge pm-badge--ok" style="margin-top:6px"><%=Icon("check")%><%=nArchivos%> archivo(s)</span>
      <% End If %>
      <span class="pm-hint" style="word-break:break-all;margin-top:6px"><%=H(ruta)%></span>
    </div>
    <%
    Next
    %>
  </div>
</section>

<section class="pm-section">
  <div class="pm-section__head">
    <h2 class="pm-section__title"><%=Icon("users")%> Cuentas de prueba</h2>
  </div>
  <div class="pm-tablewrap">
    <table class="pm-table">
      <thead><tr><th>Usuario</th><th>Tipo</th><th>Contrasena almacenada</th></tr></thead>
      <tbody>
      <%
      If okConexion Then
          Set rs = DBQuery("SELECT USERNAME, USER_TYPE, PASSWORD FROM TBL_USER ORDER BY USER_TYPE DESC, USERNAME", Null)
          If rs.EOF Then
              Response.Write "<tr><td colspan=""3"" class=""pm-hint"">No hay usuarios.</td></tr>"
          Else
              Do While Not rs.EOF
                  If Len(Clean(rs("PASSWORD"))) = 40 Then
                      tipoClave = "Hash SHA-1"
                  Else
                      tipoClave = "Texto plano (se convertira al iniciar sesion)"
                  End If
      %>
      <tr>
        <td class="pm-table__title"><%=H(rs("USERNAME"))%></td>
        <td class="pm-table__sub"><%=H(CatalogLabel("1", rs("USER_TYPE")))%></td>
        <td class="pm-table__sub"><%=H(tipoClave)%></td>
      </tr>
      <%
                  rs.MoveNext
              Loop
          End If
          rs.Close
      Else
          Response.Write "<tr><td colspan=""3"" class=""pm-hint"">Sin conexion a la base de datos.</td></tr>"
      End If
      %>
      </tbody>
    </table>
  </div>
</section>

<div class="pm-alert pm-alert--info">
  <span class="pm-alert__ico"><%=Icon("info")%></span>
  <span class="pm-alert__txt">
    Si todas las tablas aparecen como disponibles y la conexion es correcta, la aplicacion esta lista.
    Puedes eliminar este archivo (<strong>diagnostico.asp</strong>) antes de entregar el proyecto si lo prefieres.
  </span>
</div>

<!--#include file="includes/footer.asp"-->
