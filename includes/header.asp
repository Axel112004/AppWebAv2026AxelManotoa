<%
' =============================================================================
'  PoliMusic | Cabecera comun (menu lateral + barra superior)
'  La pagina debe haber definido antes: PageTitle, PageSubtitle, PageSection
' =============================================================================
Dim pmQ, pmFlashed
pmQ = CStr(Nz(Request.QueryString("q"), ""))
pmFlashed = MessageFromQuery(Request.QueryString("m"))
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="PoliMusic: catalogo musical con canciones, artistas, albumes y playlists.">
<meta name="theme-color" content="#16307F">
<title><%=H(PageTitle)%> | <%=H(APP_NAME)%></title>
<link rel="icon" href="<%=LogoFavicon()%>">
<link rel="stylesheet" href="<%=Base()%>assets/css/polimusic.css">
</head>
<body class="pm-body">
<a class="pm-skip" href="#pmMain">Saltar al contenido principal</a>

<aside class="pm-sidebar" id="pmSidebar" aria-label="Menu principal">
  <a class="pm-brand" href="<%=Base()%>index.asp">
    <%=LogoMark(36)%>
    <span class="pm-brand__text">Poli<span>Music</span></span>
  </a>

  <nav class="pm-nav">
    <p class="pm-nav__label">Explorar</p>
    <a class="pm-nav__link<%=NavActive("inicio")%>" href="<%=Base()%>index.asp"><%=Icon("home")%><span>Inicio</span></a>
    <a class="pm-nav__link<%=NavActive("canciones")%>" href="<%=Base()%>songs.asp"><%=Icon("music")%><span>Canciones</span></a>
    <a class="pm-nav__link<%=NavActive("artistas")%>" href="<%=Base()%>artists.asp"><%=Icon("mic")%><span>Artistas</span></a>
    <a class="pm-nav__link<%=NavActive("albumes")%>" href="<%=Base()%>albums.asp"><%=Icon("disc")%><span>Albumes</span></a>

    <% If IsLoggedIn() Then %>
    <p class="pm-nav__label">Mi musica</p>
    <a class="pm-nav__link<%=NavActive("playlists")%>" href="<%=Base()%>playlists.asp"><%=Icon("playlist")%><span>Mis playlists</span></a>
    <a class="pm-nav__link<%=NavActive("explorar-playlists")%>" href="<%=Base()%>playlists.asp?ver=publicas"><%=Icon("sparkle")%><span>Playlists publicas</span></a>
    <a class="pm-nav__link<%=NavActive("perfil")%>" href="<%=Base()%>profile.asp"><%=Icon("user")%><span>Mi perfil</span></a>
    <% End If %>

    <% If IsAdmin() Then %>
    <p class="pm-nav__label">Administracion</p>
    <a class="pm-nav__link<%=NavActive("admin")%>" href="<%=Base()%>admin-panel.asp"><%=Icon("grid")%><span>Panel general</span></a>
    <a class="pm-nav__link<%=NavActive("admin-usuarios")%>" href="<%=Base()%>admin-usuarios.asp"><%=Icon("users")%><span>Usuarios</span></a>
    <a class="pm-nav__link<%=NavActive("admin-canciones")%>" href="<%=Base()%>admin-canciones.asp"><%=Icon("music")%><span>Canciones</span></a>
    <a class="pm-nav__link<%=NavActive("admin-artistas")%>" href="<%=Base()%>admin-artistas.asp"><%=Icon("mic")%><span>Artistas</span></a>
    <a class="pm-nav__link<%=NavActive("admin-albumes")%>" href="<%=Base()%>admin-albumes.asp"><%=Icon("disc")%><span>Albumes</span></a>
    <a class="pm-nav__link<%=NavActive("admin-playlists")%>" href="<%=Base()%>admin-playlists.asp"><%=Icon("playlist")%><span>Playlists</span></a>
    <a class="pm-nav__link<%=NavActive("admin-catalogo")%>" href="<%=Base()%>admin-catalogos.asp"><%=Icon("settings")%><span>Catalogos</span></a>
    <% End If %>
  </nav>

  <div class="pm-sidebar__foot">
    <% If IsLoggedIn() Then %>
    <div class="pm-usercard">
      <img class="pm-usercard__img" src="<%=AvatarUrl(CurrentUserPhoto(), CurrentUserName(), CurrentUserId())%>" alt="">
      <div class="pm-usercard__meta">
        <div class="pm-usercard__name"><%=H(CurrentUserName())%></div>
        <div class="pm-usercard__role"><%=H(CurrentUserTypeLabel())%></div>
      </div>
      <a class="pm-usercard__out" href="<%=Base()%>logout.asp" title="Cerrar sesion"><%=Icon("logout")%></a>
    </div>
    <% Else %>
    <div class="pm-sidebar__guest">
      <p>Inicia sesion para reproducir y crear tus playlists.</p>
      <a class="pm-btn pm-btn--on-hero pm-btn--sm pm-btn--block" href="<%=Base()%>login.asp">Iniciar sesion</a>
    </div>
    <% End If %>
  </div>
</aside>

<div class="pm-scrim" id="pmScrim"></div>

<div class="pm-shell">
  <header class="pm-topbar">
    <button class="pm-burger" id="pmBurger" type="button" aria-label="Abrir menu" aria-controls="pmSidebar" aria-expanded="false"><%=Icon("menu")%></button>

    <form class="pm-search" role="search" action="<%=Base()%>search.asp" method="get">
      <span class="pm-search__ico"><%=Icon("search")%></span>
      <label class="pm-sr" for="pmQ">Buscar en el catalogo</label>
      <input id="pmQ" type="search" name="q" value="<%=H(pmQ)%>" placeholder="Buscar canciones, artistas, albumes o playlists" autocomplete="off">
    </form>

    <div class="pm-topbar__actions">
      <% If IsLoggedIn() Then %>
        <% If IsAdmin() Then %>
        <a class="pm-btn pm-btn--soft pm-btn--sm pm-hide-sm" href="<%=Base()%>admin-panel.asp"><%=Icon("shield")%><span>Panel admin</span></a>
        <% End If %>
        <a class="pm-iconbtn" href="<%=Base()%>profile.asp" title="Mi perfil" aria-label="Mi perfil"><%=Icon("user")%></a>
        <a class="pm-iconbtn" href="<%=Base()%>logout.asp" title="Cerrar sesion" aria-label="Cerrar sesion"><%=Icon("logout")%></a>
      <% Else %>
        <a class="pm-btn pm-btn--ghost pm-btn--sm" href="<%=Base()%>login.asp">Iniciar sesion</a>
        <a class="pm-btn pm-btn--primary pm-btn--sm" href="<%=Base()%>register.asp">Registrarse</a>
      <% End If %>
    </div>
  </header>

  <main class="pm-main" id="pmMain">
    <%=RenderFlash()%>
    <% If pmFlashed <> "" Then %>
    <div class="pm-alert pm-alert--ok" role="status">
      <span class="pm-alert__ico"><%=Icon("check")%></span>
      <span class="pm-alert__txt"><%=H(pmFlashed)%></span>
    </div>
    <% End If %>
