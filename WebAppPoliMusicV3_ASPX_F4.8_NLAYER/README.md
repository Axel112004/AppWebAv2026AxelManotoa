# PoliMusic V3 — Laboratorio 4

Axel Manotoa · ISWD823

Aplicación ASP.NET WebForms en .NET Framework 4.8. Conserva el diseño azul de PoliMusic y separa entidades, acceso a datos, negocio y presentación en cuatro proyectos. La V1 ASP y la V2 .NET Framework 2.0 se conservan en la solución original.

## Ejecutar

En este equipo, abrir `Iniciar-V3.cmd`. Restaura paquetes, compila e inicia IIS Express en `http://localhost:52130/`.

Desde Visual Studio 2026 Community:

1. Abrir `SlnAppPoliMusic.slnx` en la raíz del repositorio.
2. Ejecutar `Restaurar-Paquetes.ps1` si faltan las dependencias. También se pueden restaurar los paquetes NuGet desde Visual Studio.
3. Establecer `WebAppPoliMusicV3` como proyecto de inicio y `Default.aspx` como página de inicio.
4. Ejecutar con F5. La aplicación solicita autenticación y luego presenta Inicio. Abrir Canciones desde el menú.

Requisitos: Visual Studio con desarrollo ASP.NET, herramientas de .NET Framework 4.8, IIS Express y SQL Server con `BDD_PoliMusic` ya creada. La conexión está en `WebAppPoliMusicV3/Web.config`. No es necesario volver a crear la base existente: el script SQL original elimina la base antes de crearla.

Cuenta del estudiante: `Axel.Manotoa`, contraseña de la práctica `12345678`.

## Dependencias entre proyectos

```text
WebAppPoliMusicV3 ──► BLL.PoliMusicV3 ──► DAL.PoliMusicV3 ──► SQL Server
       │                    │                  │
       └────────────────────┴──────────────────┴──► EntityLayer.PoliMusicV3
```

Todos los proyectos V3 usan .NET Framework 4.8. La presentación no referencia DAL ni ejecuta SQL. `EntityLayer` contiene User, Song y Util (Constants y Hash). La guía conserva SHA1 en el flujo de autenticación; HashPassword también está definido según el ejemplo del laboratorio.

La web incorpora Site.Master, Friendly URLs (`/Login`, `/Default`, `/Song`, `/SignUp`, `/Logout`), ScriptManager/UpdatePanel para AJAX, Bootstrap, jQuery, Modernizr y bundles. Site.Master muestra `PoliMusic - Axel.Manotoa`, el usuario de sesión y el menú Inicio/Canciones/Cerrar sesión.

## Pruebas y recursos

Se verificaron acceso anónimo, credenciales incorrectas y correctas, registro y sus validaciones, inicio con la cuenta recién registrada, foto predeterminada, navegación, cierre de sesión, vista móvil, reproducción real y contador mediante AJAX. Las evidencias están en `evidencias/`.

La base contiene cinco canciones y los recursos proporcionados incluyen únicamente `bensound-adventure.mp3`. Adventure se reproduce; las otras cuatro muestran Archivo no disponible. Al añadir sus MP3 originales a SongFiles con los nombres registrados en la base, el botón Play se habilita automáticamente.

La plantilla menciona un DesktopAdmin que no crea; la V3 permite que ambos roles entren al inicio sin redirigir a una página inexistente. Los CRUD de usuarios y canciones permanecen disponibles como métodos DAL/BLL. Este laboratorio no exige una nueva interfaz administrativa.

La guía mezcla Azure DevOps y GitHub; esta entrega continúa en el repositorio GitHub acordado: https://github.com/Axel112004/AppWebAv2026AxelManotoa.

Los paquetes y compilados se excluyen de Git. Restaurar-Paquetes.ps1 utiliza primero los paquetes de la plantilla instalada de Visual Studio y, si faltan, los descarga desde NuGet. Los archivos del diseño web se incluyen en el código fuente.
