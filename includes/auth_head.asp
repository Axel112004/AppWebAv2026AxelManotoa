<%
' =============================================================================
'  PoliMusic | Cabecera de las paginas de acceso (sin menu lateral)
'  La pagina debe definir antes: PageTitle y PageSubtitle
' =============================================================================
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="theme-color" content="#16307F">
<title><%=H(PageTitle)%> | <%=H(APP_NAME)%></title>
<link rel="icon" href="<%=LogoFavicon()%>">
<link rel="stylesheet" href="<%=Base()%>assets/css/polimusic.css">
</head>
<body class="pm-body">
<div class="pm-auth">

  <aside class="pm-auth__aside">
    <div class="pm-auth__aside-in">
      <a class="pm-auth__brand" href="<%=Base()%>index.asp">
        <%=LogoMark(44)%>
        <span>Poli<em>Music</em></span>
      </a>
      <h2><%=H(PageSubtitle)%></h2>
      <p>Un catalogo musical sencillo y ordenado: canciones, artistas, albumes y tus propias playlists en un mismo lugar.</p>
      <ul class="pm-auth__list">
        <li><%=Icon("music")%><span>Reproduce el catalogo completo</span></li>
        <li><%=Icon("playlist")%><span>Crea y edita tus playlists</span></li>
        <li><%=Icon("heart")%><span>Agrega o quita canciones cuando quieras</span></li>
        <li><%=Icon("headphones")%><span>Disenado para computadora, tablet y celular</span></li>
      </ul>
    </div>
  </aside>

  <div class="pm-auth__panel">
    <div class="pm-auth__card">
