<%
' =============================================================================
'  PoliMusic | Reproductor global
'  Barra fija inferior: reproduccion, pausa, avance, progreso y volumen.
'  Un unico elemento <audio> es controlado por assets/js/polimusic.js
' =============================================================================
%>
<audio id="pmAudio" preload="metadata"></audio>

<div class="pm-player" id="pmPlayer">

  <div class="pm-now">
    <img class="pm-now__cover" id="pmCover" src="<%=PlaceholderCover("Poli Music", 0)%>"
         data-default="<%=PlaceholderCover("Poli Music", 0)%>" alt="Portada de la pista actual">
    <div class="pm-now__meta">
      <div class="pm-now__title" id="pmTitle">Selecciona una cancion</div>
      <div class="pm-now__artist" id="pmArtist">Elige un tema del catalogo para empezar</div>
    </div>
  </div>

  <div class="pm-player__center">
    <div class="pm-controls">
      <button class="pm-ctrl" id="pmPrev" type="button" aria-label="Cancion anterior" disabled><%=Icon("prev")%></button>
      <button class="pm-ctrl pm-ctrl--main" id="pmPlay" type="button" aria-label="Reproducir">
        <span class="pm-ico-play"><%=Icon("play")%></span>
        <span class="pm-ico-pause"><%=Icon("pause")%></span>
      </button>
      <button class="pm-ctrl" id="pmNext" type="button" aria-label="Cancion siguiente" disabled><%=Icon("next")%></button>
    </div>

    <div class="pm-trackline">
      <span class="pm-time" id="pmCur">0:00</span>
      <label class="pm-sr" for="pmSeek">Progreso de la cancion</label>
      <input class="pm-range" id="pmSeek" type="range" min="0" max="100" step="0.1" value="0" disabled>
      <span class="pm-time" id="pmDur">0:00</span>
    </div>
  </div>

  <div class="pm-player__right">
    <div class="pm-vol">
      <button class="pm-ctrl" id="pmVolBtn" type="button" aria-label="Silenciar o activar sonido">
        <span id="pmVolIco">
          <span class="pm-vol-on"><%=Icon("volume")%></span>
          <span class="pm-vol-off"><%=Icon("volume-mute")%></span>
        </span>
      </button>
      <label class="pm-sr" for="pmVol">Volumen</label>
      <input class="pm-range" id="pmVol" type="range" min="0" max="100" step="1" value="80" aria-label="Volumen">
    </div>
  </div>
</div>

<div class="pm-player__hint" id="pmHint"></div>
