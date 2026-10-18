/* =============================================================================
   PoliMusic | Reproductor global
   -----------------------------------------------------------------------------
   Un unico elemento <audio> controla toda la aplicacion. Cada pagina publica su
   propia cola de reproduccion en  window.PM_QUEUE  y los botones de las
   tarjetas llaman a  PM.playIndex(n).
   ========================================================================== */
(function (window, document) {
  'use strict';

  var audio = document.getElementById('pmAudio');
  if (!audio) { return; }

  /* ------------------------------------------------------------------ */
  /* Referencias del interfaz                                            */
  /* ------------------------------------------------------------------ */
  var ui = {
    player:  document.getElementById('pmPlayer'),
    cover:   document.getElementById('pmCover'),
    title:   document.getElementById('pmTitle'),
    artist:  document.getElementById('pmArtist'),
    play:    document.getElementById('pmPlay'),
    prev:    document.getElementById('pmPrev'),
    next:    document.getElementById('pmNext'),
    seek:    document.getElementById('pmSeek'),
    cur:     document.getElementById('pmCur'),
    dur:     document.getElementById('pmDur'),
    vol:     document.getElementById('pmVol'),
    volBtn:  document.getElementById('pmVolBtn'),
    hint:    document.getElementById('pmHint')
  };

  /* ------------------------------------------------------------------ */
  /* Estado                                                              */
  /* ------------------------------------------------------------------ */
  var state = {
    queue: [],
    index: -1,
    queueName: '',
    seeking: false,
    lastVolume: 0.8,
    ready: false
  };

  var STORAGE_KEY = 'polimusic.volume';

  /* ------------------------------------------------------------------ */
  /* Utilidades                                                          */
  /* ------------------------------------------------------------------ */
  function formatTime(seg) {
    if (!isFinite(seg) || seg < 0) { return '0:00'; }
    var total = Math.floor(seg);
    var min = Math.floor(total / 60);
    var s = total % 60;
    return min + ':' + (s < 10 ? '0' + s : s);
  }

  function setHint(texto) {
    if (!ui.hint) { return; }
    ui.hint.textContent = texto || '';
  }

  function currentTrack() {
    if (state.index < 0 || state.index >= state.queue.length) { return null; }
    return state.queue[state.index];
  }

  /* ------------------------------------------------------------------ */
  /* Sincronizacion visual de los botones de las tarjetas               */
  /* ------------------------------------------------------------------ */
  function syncButtons() {
    var nodos = document.querySelectorAll('[data-pm-queue][data-pm-index]');
    var i, n, activo;

    for (i = 0; i < nodos.length; i++) {
      n = nodos[i];
      activo = (n.getAttribute('data-pm-queue') === state.queueName) &&
               (parseInt(n.getAttribute('data-pm-index'), 10) === state.index) &&
               !audio.paused;
      if (activo) {
        n.classList.add('is-playing');
        n.setAttribute('aria-label', 'Pausar');
      } else {
        n.classList.remove('is-playing');
        n.setAttribute('aria-label', 'Reproducir');
      }
    }
  }

  /* ------------------------------------------------------------------ */
  /* Interfaz del reproductor                                            */
  /* ------------------------------------------------------------------ */
  function renderTrack() {
    var t = currentTrack();

    if (!t) {
      if (ui.title)  { ui.title.textContent  = 'Selecciona una cancion'; }
      if (ui.artist) { ui.artist.textContent = 'Elige un tema del catalogo para empezar'; }
      if (ui.cover)  { ui.cover.src = ui.cover.getAttribute('data-default') || ''; }
      if (ui.seek)   { ui.seek.disabled = true; ui.seek.value = 0; }
      if (ui.cur)    { ui.cur.textContent = '0:00'; }
      if (ui.dur)    { ui.dur.textContent = '0:00'; }
      if (ui.prev)   { ui.prev.disabled = true; }
      if (ui.next)   { ui.next.disabled = true; }
      setHint('');
      updateMediaSession(null);
      return;
    }

    if (ui.title)  { ui.title.textContent  = t.title; }
    if (ui.artist) { ui.artist.textContent = t.artist || 'Artista desconocido'; }
    if (ui.cover)  { ui.cover.src = t.cover; }
    if (ui.seek)   { ui.seek.disabled = false; }
    if (ui.prev)   { ui.prev.disabled = false; }
    if (ui.next)   { ui.next.disabled = false; }
    setHint(t.preview ? 'Pista de demostracion: el archivo original no esta disponible.' : '');
    updateMediaSession(t);
  }

  function paintProgress() {
    if (state.seeking) { return; }
    var dur = audio.duration;
    if (!isFinite(dur) || dur <= 0) {
      if (ui.cur) { ui.cur.textContent = '0:00'; }
      if (ui.dur) { ui.dur.textContent = '0:00'; }
      return;
    }
    var pct = (audio.currentTime / dur) * 100;
    if (ui.seek) { ui.seek.value = pct; }
    if (ui.cur)  { ui.cur.textContent = formatTime(audio.currentTime); }
    if (ui.dur)  { ui.dur.textContent = formatTime(dur); }
    paintBuffered();
  }

  function paintBuffered() {
    if (!ui.seek || !audio.buffered || audio.buffered.length === 0) { return; }
    var dur = audio.duration;
    if (!isFinite(dur) || dur <= 0) { return; }
    var fin = audio.buffered.end(audio.buffered.length - 1);
    var pctBuffered = Math.min(100, (fin / dur) * 100);
    var pctActual = parseFloat(ui.seek.value) || 0;
    ui.seek.style.background =
      'linear-gradient(to right,' +
      ' #2455E6 0%, #2455E6 ' + pctActual + '%,' +
      ' #C9D8FA ' + pctActual + '%, #C9D8FA ' + pctBuffered + '%,' +
      ' #E3E9F5 ' + pctBuffered + '%, #E3E9F5 100%)';
  }

  function paintVolume() {
    var v = Math.round(audio.volume * 100);
    if (ui.vol) {
      ui.vol.value = v;
      ui.vol.style.background = 'linear-gradient(to right,' +
        ' #2455E6 0%, #2455E6 ' + v + '%, #E3E9F5 ' + v + '%, #E3E9F5 100%)';
    }
    if (ui.player) {
      ui.player.classList.toggle('is-muted', (audio.volume === 0 || audio.muted));
    }
  }

  function setPlayingClass() {
    if (ui.player) { ui.player.classList.toggle('is-playing', !audio.paused); }
    if (ui.play) {
      ui.play.setAttribute('aria-label', audio.paused ? 'Reproducir' : 'Pausar');
    }
    syncButtons();
  }

  /* ------------------------------------------------------------------ */
  /* Media Session (teclas multimedia del sistema)                       */
  /* ------------------------------------------------------------------ */
  function updateMediaSession(t) {
    if (!('mediaSession' in navigator) || !window.MediaMetadata) { return; }
    try {
      if (!t) { navigator.mediaSession.metadata = null; return; }
      navigator.mediaSession.metadata = new window.MediaMetadata({
        title: t.title,
        artist: t.artist || '',
        album: t.album || 'PoliMusic',
        artwork: [{ src: t.cover, sizes: '320x320', type: 'image/png' }]
      });
    } catch (e) { /* navegadores sin soporte completo */ }
  }

  /* ------------------------------------------------------------------ */
  /* API publica                                                         */
  /* ------------------------------------------------------------------ */
  var PM = {
    canPlay: true,

    setQueue: function (lista, nombre) {
      state.queue = lista || [];
      state.queueName = nombre || '';
      syncButtons();
    },

    playIndex: function (indice, lista, nombre) {
      if (lista) { this.setQueue(lista, nombre); }
      indice = parseInt(indice, 10);
      if (isNaN(indice) || indice < 0 || indice >= state.queue.length) { return; }

      state.index = indice;
      var t = state.queue[indice];
      renderTrack();

      audio.src = t.url;
      audio.load();

      var promesa = audio.play();
      if (promesa && typeof promesa.catch === 'function') {
        promesa.catch(function () {
          setHint('El navegador bloqueo la reproduccion automatica. Pulsa el boton de reproducir.');
          setPlayingClass();
        });
      }
    },

    toggle: function () {
      if (state.index < 0) {
        if (state.queue.length > 0) { this.playIndex(0); }
        return;
      }
      if (audio.paused) {
        audio.play();
      } else {
        audio.pause();
      }
    },

    next: function () {
      if (state.queue.length === 0) { return; }
      var n = state.index + 1;
      if (n >= state.queue.length) { n = 0; }
      this.playIndex(n);
    },

    prev: function () {
      if (state.queue.length === 0) { return; }
      if (audio.currentTime > 3) { audio.currentTime = 0; return; }
      var p = state.index - 1;
      if (p < 0) { p = state.queue.length - 1; }
      this.playIndex(p);
    },

    volume: function (valor) {
      var v = Math.max(0, Math.min(1, valor));
      audio.volume = v;
      audio.muted = (v === 0);
      state.lastVolume = v > 0 ? v : state.lastVolume;
      try { window.localStorage.setItem(STORAGE_KEY, String(audio.volume)); } catch (e) {}
      paintVolume();
    },

    toggleMute: function () {
      if (audio.volume > 0 && !audio.muted) {
        state.lastVolume = audio.volume;
        this.volume(0);
      } else {
        this.volume(state.lastVolume || 0.8);
      }
    }
  };

  window.PM = PM;

  /* ------------------------------------------------------------------ */
  /* Eventos del elemento de audio                                       */
  /* ------------------------------------------------------------------ */
  audio.addEventListener('play',  setPlayingClass);
  audio.addEventListener('pause', setPlayingClass);

  audio.addEventListener('loadedmetadata', function () {
    state.ready = true;
    paintProgress();
  });

  audio.addEventListener('timeupdate', paintProgress);
  audio.addEventListener('progress', paintBuffered);

  audio.addEventListener('ended', function () {
    if (state.queue.length > 1) {
      PM.next();
    } else {
      setPlayingClass();
    }
  });

  audio.addEventListener('error', function () {
    setHint('No se pudo cargar el audio. Verifica que el archivo exista en la carpeta songFiles.');
    setPlayingClass();
  });

  /* Animacion suave de la barra de progreso */
  (function loop() {
    if (!audio.paused) { paintProgress(); }
    window.requestAnimationFrame(loop);
  }());

  /* ------------------------------------------------------------------ */
  /* Controles                                                           */
  /* ------------------------------------------------------------------ */
  if (ui.play)   { ui.play.addEventListener('click', function () { PM.toggle(); }); }
  if (ui.next)   { ui.next.addEventListener('click', function () { PM.next(); }); }
  if (ui.prev)   { ui.prev.addEventListener('click', function () { PM.prev(); }); }
  if (ui.volBtn) { ui.volBtn.addEventListener('click', function () { PM.toggleMute(); }); }

  if (ui.seek) {
    ui.seek.addEventListener('input', function () {
      state.seeking = true;
      var dur = audio.duration;
      if (isFinite(dur) && dur > 0) {
        if (ui.cur) { ui.cur.textContent = formatTime((ui.seek.value / 100) * dur); }
      }
      paintBuffered();
    });
    ui.seek.addEventListener('change', function () {
      var dur = audio.duration;
      if (isFinite(dur) && dur > 0) {
        audio.currentTime = (ui.seek.value / 100) * dur;
      }
      state.seeking = false;
      paintProgress();
    });
  }

  if (ui.vol) {
    ui.vol.addEventListener('input', function () { PM.volume(ui.vol.value / 100); });
  }

  /* ------------------------------------------------------------------ */
  /* Botones de reproduccion de toda la aplicacion                       */
  /* ------------------------------------------------------------------ */
  document.addEventListener('click', function (ev) {
    if (!ev.target.closest) { return; }

    /* Reproducir toda una lista desde el principio */
    var playAll = ev.target.closest('[data-pm-playall]');
    if (playAll) {
      ev.preventDefault();
      if (!PM.canPlay) {
        window.location.href = playAll.getAttribute('data-pm-login') || 'login.asp';
        return;
      }
      PM.playIndex(0, window.PM_QUEUE || [], playAll.getAttribute('data-pm-playall'));
      return;
    }

    /* Boton de reproduccion de una tarjeta o fila */
    var boton = ev.target.closest('[data-pm-index]');
    if (!boton) { return; }
    ev.preventDefault();

    if (!PM.canPlay) {
      window.location.href = boton.getAttribute('data-pm-login') || 'login.asp';
      return;
    }

    var idx = parseInt(boton.getAttribute('data-pm-index'), 10);
    var nombre = boton.getAttribute('data-pm-queue') || '';

    if (state.queueName === nombre && state.index === idx) {
      PM.toggle();
    } else {
      PM.playIndex(idx, window.PM_QUEUE || [], nombre);
    }
  });

  /* ------------------------------------------------------------------ */
  /* Atajos de teclado                                                   */
  /* ------------------------------------------------------------------ */
  document.addEventListener('keydown', function (ev) {
    var etiqueta = (ev.target.tagName || '').toLowerCase();
    if (etiqueta === 'input' || etiqueta === 'textarea' || etiqueta === 'select') { return; }

    if (ev.code === 'Space' || ev.key === ' ') {
      ev.preventDefault();
      PM.toggle();
    } else if (ev.key === 'ArrowRight' && ev.altKey) {
      audio.currentTime = Math.min(audio.duration || 0, audio.currentTime + 5);
    } else if (ev.key === 'ArrowLeft' && ev.altKey) {
      audio.currentTime = Math.max(0, audio.currentTime - 5);
    } else if (ev.key === 'ArrowUp' && ev.altKey) {
      PM.volume(audio.volume + 0.05);
    } else if (ev.key === 'ArrowDown' && ev.altKey) {
      PM.volume(audio.volume - 0.05);
    }
  });

  /* ------------------------------------------------------------------ */
  /* Arranque                                                            */
  /* ------------------------------------------------------------------ */
  if (typeof window.PM_CAN_PLAY === 'boolean') { PM.canPlay = window.PM_CAN_PLAY; }

  var guardado = null;
  try { guardado = window.localStorage.getItem(STORAGE_KEY); } catch (e) {}
  audio.volume = guardado === null ? 0.8 : Math.max(0, Math.min(1, parseFloat(guardado)));
  if (isNaN(audio.volume)) { audio.volume = 0.8; }

  if (window.PM_QUEUE && window.PM_QUEUE.length > 0) {
    state.queue = window.PM_QUEUE;
    state.queueName = window.PM_QUEUE_NAME || '';
  }

  renderTrack();
  paintVolume();
  setPlayingClass();

  if ('mediaSession' in navigator) {
    try {
      navigator.mediaSession.setActionHandler('play', function () { audio.play(); });
      navigator.mediaSession.setActionHandler('pause', function () { audio.pause(); });
      navigator.mediaSession.setActionHandler('nexttrack', function () { PM.next(); });
      navigator.mediaSession.setActionHandler('previoustrack', function () { PM.prev(); });
    } catch (e) {}
  }

  /* ------------------------------------------------------------------ */
  /* Imagenes que no cargan: se sustituyen por una portada generada      */
  /* ------------------------------------------------------------------ */
  var PORTADA_RESPALDO = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 320'>" +
    "<defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'>" +
    "<stop offset='0' stop-color='#2455E6'/><stop offset='1' stop-color='#0F2C87'/>" +
    "</linearGradient></defs><rect width='320' height='320' fill='url(#g)'/>" +
    "<circle cx='160' cy='160' r='86' fill='#ffffff' fill-opacity='0.12'/>" +
    "<g fill='#ffffff'><rect x='128' y='188' width='10' height='26' rx='5'/>" +
    "<rect x='146' y='168' width='10' height='46' rx='5'/>" +
    "<rect x='164' y='148' width='10' height='66' rx='5'/>" +
    "<rect x='182' y='176' width='10' height='38' rx='5'/></g></svg>");

  document.addEventListener('error', function (ev) {
    var el = ev.target;
    if (!el || el.tagName !== 'IMG') { return; }
    if (el.getAttribute('data-pm-respaldo') === '1') { return; }
    el.setAttribute('data-pm-respaldo', '1');
    el.src = PORTADA_RESPALDO;
  }, true);

  /* ------------------------------------------------------------------ */
  /* Navegacion movil (menu lateral)                                     */
  /* ------------------------------------------------------------------ */
  var burger = document.getElementById('pmBurger');
  var sidebar = document.getElementById('pmSidebar');
  var scrim = document.getElementById('pmScrim');

  function cerrarMenu() {
    if (sidebar) { sidebar.classList.remove('is-open'); }
    if (scrim)   { scrim.classList.remove('is-open'); }
    if (burger)  { burger.setAttribute('aria-expanded', 'false'); }
  }

  if (burger && sidebar) {
    burger.addEventListener('click', function () {
      var abierto = sidebar.classList.toggle('is-open');
      if (scrim) { scrim.classList.toggle('is-open', abierto); }
      burger.setAttribute('aria-expanded', abierto ? 'true' : 'false');
    });
  }
  if (scrim) { scrim.addEventListener('click', cerrarMenu); }
  document.addEventListener('keydown', function (ev) {
    if (ev.key === 'Escape') { cerrarMenu(); }
  });

  /* ------------------------------------------------------------------ */
  /* Confirmacion de acciones destructivas                               */
  /* ------------------------------------------------------------------ */
  document.addEventListener('submit', function (ev) {
    var form = ev.target;
    if (form.hasAttribute && form.hasAttribute('data-confirmar')) {
      if (!window.confirm(form.getAttribute('data-confirmar'))) {
        ev.preventDefault();
      }
    }
  });

  /* Filtro instantaneo de las tablas del panel administrativo */
  var filtro = document.getElementById('pmFiltro');
  if (filtro) {
    filtro.addEventListener('input', function () {
      var q = filtro.value.toLowerCase().trim();
      var filas = document.querySelectorAll('[data-fila]');
      for (var i = 0; i < filas.length; i++) {
        var texto = (filas[i].getAttribute('data-fila') || '').toLowerCase();
        filas[i].style.display = (q === '' || texto.indexOf(q) > -1) ? '' : 'none';
      }
    });
  }
}(window, document));
