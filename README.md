# PoliMusic

Aplicación web de música desarrollada con **ASP clásico (VBScript)** y **SQL Server**.
Permite explorar un catálogo de canciones, artistas y álbumes, reproducir música desde
el navegador y crear playlists propias. Incluye un panel administrativo completo.

El diseño es original: azul como color principal, superficies claras, tarjetas
redondeadas y una barra de reproducción fija. La interfaz se adapta a computadoras,
tablets y celulares.

---

## 1. Tecnologías

| Componente | Detalle |
|---|---|
| Servidor web | IIS 8 / 10 / IIS Express (con ASP clásico habilitado) |
| Lenguaje servidor | VBScript (ASP clásico) |
| Base de datos | SQL Server 2016 o superior |
| Acceso a datos | ADODB con **consultas parametrizadas** |
| Cliente | HTML5, CSS3 (propio, sin frameworks) y JavaScript sin dependencias |

No requiere librerías externas, ni Node.js, ni paquetes NuGet: solo IIS y SQL Server.

---

## 2. Requisitos previos

1. **Windows** con IIS y el servicio **ASP** habilitado.
   Panel de control → Programas → Activar o desactivar características de Windows →
   *Internet Information Services* → *World Wide Web Services* → *Application Development Features*
   → marcar **ASP**.
2. **SQL Server** (o SQL Server Express) en ejecución, con autenticación SQL habilitada.
3. Permisos de administrador para publicar la aplicación en IIS.

---

## 3. Estructura del proyecto

```
AppWebAv2026AxelManotoa/
├── BDD_PoliMusic.sql              Script original de la base de datos (no modificar)
├── database/
│   └── PoliMusic_Datos_Extra.sql  Script opcional: usuarios de prueba + hash de claves
├── web.config                     Configuración de IIS (documento predeterminado)
├── README.md
│
├── index.asp                      Pantalla principal (catálogo, buscador, accesos)
├── login.asp / register.asp / logout.asp
├── songs.asp                      Catálogo de canciones
├── artists.asp / artist.asp       Catálogo y detalle de artistas
├── albums.asp  / album.asp        Catálogo y detalle de álbumes
├── playlists.asp                  Mis playlists (crear, editar, eliminar)
├── playlist.asp                   Detalle: agregar y quitar canciones
├── playlist_add.asp               Acción POST: agregar canción desde las tarjetas
├── profile.asp                    Perfil y cambio de contraseña
├── search.asp                     Buscador global
├── stream.asp                     Entrega de audio (con soporte de rangos)
├── diagnostico.asp                Comprobación de la instalación
│
├── admin-panel.asp                Panel general (resumen y accesos)
├── admin-usuarios.asp             CRUD de usuarios
├── admin-canciones.asp            CRUD de canciones
├── admin-artistas.asp             CRUD de artistas
├── admin-albumes.asp              CRUD de álbumes (incluye lista de pistas)
├── admin-playlists.asp            CRUD de playlists de todos los usuarios
├── admin-catalogos.asp            Consulta de TBL_CATALOG
│
├── includes/                      Código compartido (no se abre directamente)
│   ├── config.asp                 Credenciales y parámetros generales
│   ├── db.asp                     Capa de datos: consultas parametrizadas
│   ├── functions.asp              Utilidades, rutas, mensajes, CSRF, cola de audio
│   ├── queries.asp                Consultas SQL reutilizables
│   ├── auth.asp                   Sesión, permisos y validación de propiedad
│   ├── icons.asp                  Iconografía SVG
│   ├── cards.asp                  Tarjetas y componentes de interfaz
│   ├── init.asp                   Agrupa todas las inclusiones anteriores
│   ├── header.asp / footer.asp    Estructura común de las páginas
│   ├── player.asp                 Barra del reproductor
│   └── auth_head.asp / auth_foot.asp  Plantilla de las pantallas de acceso
│
├── assets/
│   ├── css/polimusic.css          Hoja de estilos completa
│   └── js/polimusic.js            Reproductor global y comportamiento de la interfaz
│
├── songFiles/                     Archivos de audio (.mp3)
├── userImages/                    Imágenes de perfil
├── playlistImages/                Portadas de playlists
├── albumImages/                   Carátulas de álbumes (vacía: se generan portadas)
├── artistImages/                  Fotografías de artistas (vacía: se generan portadas)
└── capturas/                      Vistas de referencia del diseño
```

> **¿Por qué el panel administrativo está en la raíz y no en una carpeta `admin/`?**
>
> Porque IIS bloquea por defecto las rutas padre (`AspEnableParentPaths = false`).
> Si los archivos del panel estuvieran en una subcarpeta, sus `<!--#include file="../includes/...-->`
> fallarían con el error **ASP 0131 – Disallowed Parent Path** al publicar en un IIS
> recién instalado. Al mantener todas las páginas en la raíz, la aplicación funciona
> sin necesidad de cambiar ninguna configuración del servidor.

---

## 4. Vistas del diseño

Las imágenes de la carpeta `capturas/` muestran el aspecto final de la interfaz. Se
generaron con la **misma hoja de estilos** (`assets/css/polimusic.css`) y el **mismo
reproductor** (`assets/js/polimusic.js`) que utiliza la aplicación, por lo que reflejan
fielmente el resultado al ejecutarla.

| Archivo | Vista |
|---|---|
| `01-escritorio.png` | Pantalla principal en computadora (1440 px) |
| `02-tablet.png` | Pantalla principal en tablet (820 px): el menú lateral se convierte en panel deslizable |
| `03-celular.png` | Pantalla principal en celular (390 px): rejilla de 2 columnas y reproductor apilado |
| `04-acceso.png` | Pantalla de inicio de sesión |
| `05-reproductor.png` | Barra del reproductor (reproducción, progreso y volumen) |

### Paleta y decisiones de diseño

| Elemento | Valor |
|---|---|
| Color principal | `#2455E6` (azul) |
| Azul profundo (menú lateral) | `#16307F` → `#0B1B45` |
| Acento | `#FF7A45` (coral, solo en la pista en reproducción) |
| Fondo / superficies | `#F3F6FC` / `#FFFFFF` |
| Tipografía | Segoe UI con respaldo en las fuentes del sistema |
| Radios | 18 px en tarjetas, 12 px en botones |

Puntos de quiebre: **1024 px** (el menú lateral pasa a panel deslizable) y
**780 px** (reproductor apilado y rejillas más compactas).

---

## 5. Instalación paso a paso

### Paso 1 — Crear la base de datos

Ejecutar el script original en SQL Server. Crea la base `BDD_PoliMusic`, el inicio de
sesión `usr_polimusic` (contraseña `Politecnica1`), las 9 tablas y los datos de ejemplo.

```bash
sqlcmd -S localhost -E -i "BDD_PoliMusic.sql"
```

> También se puede abrir el archivo en SQL Server Management Studio y ejecutarlo (F5).
>
> ⚠️ El script incluye `DROP DATABASE IF EXISTS [BDD_PoliMusic]`, por lo que **borra y
> vuelve a crear** la base de datos. Si ya tiene datos que desea conservar, haga una
> copia de seguridad antes.

### Paso 2 — (Opcional) Cargar los usuarios de la práctica

El script original crea `userNormal`, `userAdmin` y `username1`. Si además desea los
usuarios normales indicados en el enunciado, ejecute:

```bash
sqlcmd -S localhost -E -i "database\PoliMusic_Datos_Extra.sql"
```

Este script crea **Axel.Manotoa** y **Claudio Penaherrera** si no existen y convierte a
hash SHA-1 las contraseñas que sigan en texto plano. Es idempotente.

### Paso 3 — Publicar la aplicación en IIS

**Opción A: sitio web propio (recomendado)**

1. Abrir el *Administrador de IIS* (`inetmgr`).
2. Clic derecho en **Sitios** → **Agregar sitio web**.
3. Configurar:
   - *Nombre del sitio*: `PoliMusic`
   - *Ruta de acceso física*: la carpeta del proyecto
     (`C:\Users\A\Proyectos\AppWebAv2026AxelManotoa`)
   - *Puerto*: `80` (o `8080` si el 80 está ocupado)
4. Aceptar y abrir en el navegador: `http://localhost/`

**Opción B: aplicación dentro del sitio predeterminado**

```cmd
appcmd add app /site.name:"Default Web Site" /path:/PoliMusic ^
  /physicalPath:"C:\Users\A\Proyectos\AppWebAv2026AxelManotoa"
```

Luego abrir `http://localhost/PoliMusic/`.

**Opción C: IIS Express (sin permisos de administrador)**

```cmd
"C:\Program Files\IIS Express\iisexpress.exe" ^
  /path:"C:\Users\A\Proyectos\AppWebAv2026AxelManotoa" /port:8080
```

> **Sobre el archivo `web.config`**
>
> El proyecto incluye un `web.config` que declara `index.asp` como documento
> predeterminado. Es necesario porque IIS **no** incluye `index.asp` en su lista
> por defecto (solo `Default.htm`, `Default.asp`, `index.htm`, `index.html`,
> `iisstart.htm` y `default.aspx`). Sin él, al abrir la carpeta del sitio en el
> navegador aparece el error **403.14 – Forbidden**.
>
> Al publicar, **copie también el `web.config`** junto con el resto de archivos.

### Paso 4 — Dar permiso de lectura a la identidad de IIS

Si IIS responde **404** a todos los archivos (incluidos los `.css`), la identidad del
grupo de aplicaciones no puede leer la carpeta del proyecto. Soluciónelo desde una
consola **como administrador**:

```cmd
icacls "C:\Users\A\Proyectos\AppWebAv2026AxelManotoa" ^
  /grant "IIS_IUSRS:(OI)(CI)(RX)" /T
```

Si usa un grupo de aplicaciones con identidad propia, otorgue también el permiso:

```cmd
icacls "C:\Users\A\Proyectos\AppWebAv2026AxelManotoa" ^
  /grant "IIS APPPOOL\PoliMusic:(OI)(CI)(RX)" /T
```

### Paso 5 — Verificar la instalación

Abrir en el navegador la ruta **completa** de la aplicación (incluyendo la carpeta
donde la publicó):

```
http://localhost/webapppolimusicv1_asp/
http://localhost/webapppolimusicv1_asp/diagnostico.asp
```

> ⚠️ `http://localhost/diagnostico.asp` **no** funciona si la aplicación está dentro
> de una carpeta: esa dirección apunta a la raíz del sitio, no a la aplicación.

Esta página comprueba la conexión a SQL Server, la existencia de las 9 tablas, las
carpetas multimedia y el formato de las contraseñas almacenadas. Si todo aparece en
verde, la aplicación está lista.

### Paso 6 — Configurar la conexión (si es necesario)

Las credenciales están centralizadas en `includes/config.asp`:

```vbscript
Const DB_PROVIDER = "SQLOLEDB"      ' o "MSOLEDBSQL"
Const DB_SERVER   = "localhost"     ' o "localhost\SQLEXPRESS"
Const DB_NAME     = "BDD_PoliMusic"
Const DB_USER     = "usr_polimusic"
Const DB_PASS     = "Politecnica1"
```

- `SQLOLEDB` viene incluido en Windows y es la opción por defecto.
- Si tiene instalado *Microsoft OLE DB Driver 18/19*, puede usar `MSOLEDBSQL`.
- Si la instancia es Express, escriba `DB_SERVER = "localhost\SQLEXPRESS"`.

---

## 6. Credenciales de prueba

| Rol | Usuario | Contraseña |
|---|---|---|
| **Administrador** | `userAdmin` | `12345678` |
| Usuario normal | `Axel.Manotoa` | `12345678` |
| Usuario normal | `Claudio Penaherrera` | `claudio10` |
| Usuario normal | `userNormal` | `12345678` |

También puede crear una cuenta nueva desde **Registrarse**; el registro siempre asigna
el tipo `USER` (0) según `TBL_CATALOG`.

---

## 7. Funcionalidades

### Visitante (sin sesión)
- Consultar el catálogo: canciones, artistas, álbumes y playlists públicas.
- Usar el buscador global.
- Los botones de reproducción lo llevan al inicio de sesión.

### Usuario normal (`Axel.Manotoa`, `Claudio Penaherrera`)
- **Reproducir** cualquier canción con el reproductor global (reproducción, pausa,
  progreso arrastrable y control de volumen).
- Consultar artistas y álbumes.
- **Crear, consultar, actualizar y eliminar sus propias playlists**, incluyendo
  **agregar y quitar canciones**.
- Marcar sus playlists como públicas o privadas.
- Editar su perfil y cambiar su contraseña.

### Administrador (`userAdmin`)
- Todo lo anterior, más el **panel administrativo**:
  - **Usuarios**: crear, consultar, actualizar y eliminar cuentas, y asignar el tipo.
  - **Canciones**: CRUD, selección del archivo de audio, artistas y álbum.
  - **Artistas**: CRUD con su fotografía.
  - **Álbumes**: CRUD con año de publicación y lista de pistas.
  - **Playlists**: supervisar y modificar las playlists de todos los usuarios.
  - **Catálogos**: consulta de `TBL_CATALOG` y resumen de la base de datos.

---

## 8. Seguridad implementada

| Medida | Dónde |
|---|---|
| **Consultas parametrizadas** en el 100 % de las sentencias (sin concatenar datos del usuario) | `includes/db.asp` |
| **Validación de permisos en el servidor** (no basta con ocultar botones) | `includes/auth.asp`, `RequireLogin()`, `RequireAdmin()` |
| **Validación de propiedad** de las playlists antes de modificarlas | `CanManagePlaylist()`, `CanViewPlaylist()` |
| **Contraseñas con hash SHA-1** calculado por SQL Server (`HASHBYTES`) | `HashPassword()` |
| **Migración automática**: si una contraseña está en texto plano, se convierte a SHA-1 al iniciar sesión | `AuthenticateUser()` |
| **Protección CSRF** con token por sesión en todos los formularios POST | `CsrfToken()`, `CheckCsrf()` |
| **Escape HTML** de todo dato mostrado (evita XSS) | `H()` |
| **Validación de rutas de archivos**: las imágenes y audios deben estar en la carpeta permitida | `ValidFileIn()` |
| **Control de acceso al audio**: `stream.asp` exige sesión activa | `stream.asp` |
| **Redirecciones seguras**: solo se aceptan rutas internas del sitio | `SafeNext()` |
| **Comillas y comodines escapados** en el buscador | `search.asp` |

---

## 9. Sobre los archivos multimedia

`SongFilesAndImages_resources` incluye **un solo archivo de audio**
(`bensound-adventure.mp3`), mientras que la base de datos referencia cinco canciones.
Para que la aplicación siga siendo utilizable:

- Si el archivo de una canción **existe**, se reproduce normalmente.
- Si **no existe**, `stream.asp` entrega la pista de demostración disponible y la
  tarjeta muestra la etiqueta **«Vista previa»**.

Para tener las cinco canciones reales, copie los archivos correspondientes a
`songFiles/` con estos nombres:

```
songFiles/bensound-adventure.mp3
songFiles/bensound-dreams.mp3
songFiles/bensound-energy.mp3
songFiles/bensound-scifi.mp3
songFiles/bensound-tomorrow.mp3
```

**Álbumes y artistas**: las carpetas `albumImages/` y `artistImages/` están vacías.
Cuando falta una imagen, la aplicación **genera una portada SVG** con las iniciales y un
degradado azul, de modo que el catálogo siempre se ve completo. Si agrega imágenes a
esas carpetas, aparecerán automáticamente en los formularios del panel administrativo.

---

## 10. Cómo funciona el reproductor

- Un único elemento `<audio>` controla toda la aplicación.
- Cada página publica su propia cola en `window.PM_QUEUE`; los botones de las tarjetas
  guardan su índice y llaman a `PM.playIndex()`.
- El audio nunca se expone como archivo estático: pasa por `stream.asp`, que valida la
  sesión, cuenta la reproducción y responde con **soporte de rangos HTTP** (necesario
  para poder avanzar o retroceder dentro de la pista).
- El volumen se guarda en `localStorage`.
- Atajos de teclado: `Espacio` reproduce o pausa; `Alt + ←/→` retrocede o avanza 5 s;
  `Alt + ↑/↓` sube o baja el volumen.

---

## 11. Solución de problemas

> **Nota:** en esta instalación se dejó activado `scriptErrorSentToBrowser`, de modo
> que si algo falla el navegador muestra el error real de ASP en lugar de un 500
> genérico. Para desactivarlo antes de publicar en un servidor real:
>
> ```cmd
> %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/asp ^
>   /scriptErrorSentToBrowser:"False" /commit:apphost
> ```

| Síntoma | Causa y solución |
|---|---|
| **403.14 – Forbidden** al abrir la carpeta del sitio | IIS no encuentra documento predeterminado porque `index.asp` no está en su lista. Copie el `web.config` del proyecto a la carpeta publicada (o agregue `index.asp` en IIS → *Documento predeterminado*). |
| **500** en todas las páginas, sin detalle | Active los errores detallados de ASP (consola **como administrador**): `%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/asp /scriptErrorSentToBrowser:"True" /commit:apphost`. Vuelva a abrir la página y verá la línea exacta. En esta instalación ya quedó activado. |
| **800a0411 – Nombre redefinido** | Un parámetro se llama igual que su propia función (VBScript no distingue mayúsculas). Ocurrió con `Function Plural(..., ByVal plural)`; se corrigió renombrando el parámetro. |
| **800a0400 – Se esperaba una instrucción** | Un bloque `<%= expresión %>` ocupaba varias líneas. `<%= %>` no admite continuación con `_`; debe usarse `<% Response.Write expresión %>`. |
| **ASP 0251 – Límite del búfer superado** | Se intentó enviar un archivo grande en un solo `Response.BinaryWrite`. `stream.asp` ahora escribe el audio en bloques de 32 KB. |
| **ADODB 3709 – La conexión está cerrada** | Se cerraba la conexión y se intentaba reutilizar. `Conn()` ahora usa la bandera `gConnAbierta` para reabrirla correctamente. |
| **800a01f4 – Variable no definida** | Falta un `Dim` (la aplicación usa `Option Explicit`). |
| **ASP 0131 – Disallowed Parent Path** | Algún `#include` usa `../`. Esta versión del proyecto ya no usa rutas padre; si agrega archivos en subcarpetas, evítelas. |
| IIS devuelve **404** para todos los archivos, incluido el CSS | La identidad de IIS no puede leer la carpeta. Ejecute el `icacls` del **Paso 4**. |
| «No se pudo conectar con la base de datos» | Revise el servicio de SQL Server y los datos en `includes/config.asp`. Compruebe con `diagnostico.asp`. |
| «Login failed for user 'usr_polimusic'» | La autenticación SQL está deshabilitada. Habilite *SQL Server and Windows Authentication mode* y reinicie el servicio. |
| El navegador descarga el `.asp` en lugar de ejecutarlo | La característica **ASP** no está instalada en IIS. Actívela (sección 2) y reinicie IIS (`iisreset`). |
| No se escucha nada al reproducir | El archivo de audio no está en `songFiles/`. Consulte la sección 9. |
| Acentos mal codificados | Verifique que los archivos se guardaron en UTF-8 y que existe la directiva `<%@ CodePage="65001" %>`. |
| La sesión se pierde al navegar | Compruebe que las *cookies de sesión* están habilitadas y que no hay un `web.config` que las bloquee. |

---

## 12. Estado verificado

La aplicación fue publicada y probada sobre **IIS 10 + SQL Server 2025** con la base
`BDD_PoliMusic` real. Resultado de las pruebas:

| Prueba | Resultado |
|---|---|
| Páginas y rutas con parámetros (29 variantes) | **200** en todas |
| Acceso por perfil: visitante / usuario normal / administrador | Correcto (el visitante es redirigido al login en las páginas privadas) |
| Reproducción de audio | Archivo entregado **idéntico byte a byte** (SHA-256 comprobado) |
| Avance dentro de la pista | **206 Partial Content** con `Content-Range` y `Accept-Ranges` |
| Canción sin archivo en disco | Entrega la pista de demostración y añade `X-PoliMusic-Preview` |
| Audio sin sesión iniciada | **401 Unauthorized** |
| CRUD de playlists (crear, agregar/quitar canción, editar, eliminar) | Correcto |
| Registro e inicio de sesión de un usuario nuevo | Correcto |
| Playlist privada de otro usuario | **Bloqueada** para el usuario normal; visible para el administrador |
| Panel administrativo con usuario normal | **Bloqueado** |

---

## 13. Notas finales

- La aplicación se puede eliminar del servidor borrando el sitio en IIS; el único cambio
  permanente en el sistema es el permiso de lectura otorgado en el Paso 4
  (`icacls ... /remove "IIS_IUSRS"` para revertirlo).
- `diagnostico.asp` es una página de apoyo: puede eliminarla antes de la entrega si lo
  prefiere; el resto de la aplicación no depende de ella.
- El script `BDD_PoliMusic.sql` **no fue modificado**; se respetó su estructura y sus datos.
