<% Option Explicit %>
<%
' =============================================================================
'  PoliMusic | Configuracion general de la aplicacion
'  Aplicacion Web - ASP clasico + SQL Server
' =============================================================================
'  Este archivo es el primero que se incluye en TODAS las paginas.
'  Aqui se centralizan: codificacion, credenciales, carpetas y reglas de negocio.
'
'  NOTA: "Option Explicit" va en su propio bloque y como PRIMERA instruccion,
'  tal como exige VBScript. Asi se obliga a declarar todas las variables.
' =============================================================================

' --- Codificacion de caracteres (acentos, enie, simbolos) --------------------
Response.CodePage = 65001
Response.Charset  = "utf-8"

' --- Identidad de la aplicacion ---------------------------------------------
Const APP_NAME    = "PoliMusic"
Const APP_TAGLINE = "Tu musica, tu ritmo"
Const APP_VERSION = "1.0.0"

' --- Conexion a SQL Server ---------------------------------------------------
'   DB_PROVIDER admite:
'       "SQLOLEDB"   -> proveedor incluido en Windows. Opcion por defecto.
'       "MSOLEDBSQL" -> Microsoft OLE DB Driver 18/19 (mas moderno).
'   Si la instancia es SQLEXPRESS, usar por ejemplo  DB_SERVER = "localhost\SQLEXPRESS"
Const DB_PROVIDER = "SQLOLEDB"
Const DB_SERVER   = "localhost"
Const DB_NAME     = "BDD_PoliMusic"
Const DB_USER     = "usr_polimusic"
Const DB_PASS     = "Politecnica1"

' --- Carpetas de archivos multimedia (relativas a la raiz de la aplicacion) --
Const DIR_SONGS    = "songFiles"
Const DIR_USER     = "userImages"
Const DIR_PLAYLIST = "playlistImages"
Const DIR_ALBUM    = "albumImages"
Const DIR_ARTIST   = "artistImages"

' --- Reglas de negocio (se corresponden con TBL_CATALOG) --------------------
Const USER_TYPE_NORMAL = 0    ' TBL_CATALOG > USER TYPE > 0 = USER
Const USER_TYPE_ADMIN  = 1    ' TBL_CATALOG > USER TYPE > 1 = ADMIN
Const PLAYLIST_PUBLIC  = 0    ' TBL_CATALOG > PLAYLIST TYPE > 0 = Public
Const PLAYLIST_PRIVATE = 1    ' TBL_CATALOG > PLAYLIST TYPE > 1 = Private

Const MIN_PASSWORD_LEN = 6
Const MAX_TITLE_LEN    = 50
Const PAGE_SIZE        = 12

' --- Variables compartidas por todas las paginas ----------------------------
'   Las paginas asignan PageTitle / PageSubtitle / PageSection antes de incluir
'   la cabecera. gBase es el prefijo relativo hacia la raiz de la aplicacion:
'   al estar TODAS las paginas en la raiz, su valor es siempre "".
Dim PageTitle, PageSubtitle, PageSection, gBase
PageTitle    = APP_NAME
PageSubtitle = ""
PageSection  = ""
gBase        = ""
%>
