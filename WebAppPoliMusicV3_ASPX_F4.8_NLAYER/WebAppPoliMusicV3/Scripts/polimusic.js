function pmPlaySong(url, title) {
    var audio = document.getElementById('pmAudio');
    var titleBox = document.getElementById('pmPlayerTitle');
    var subBox = document.getElementById('pmPlayerSub');
    if (!audio) return;
    titleBox.textContent = title;
    subBox.textContent = 'Preparando tu canción…';
    audio.src = url;
    audio.load();
    audio.onerror = function () { subBox.textContent = 'No se pudo cargar el archivo de audio.'; };
    audio.onended = function () { subBox.textContent = '¿La escuchamos otra vez?'; };
    var promise = audio.play();
    if (promise && typeof promise.then === 'function') {
        promise.then(function () { subBox.textContent = 'Reproduciendo ahora'; })
            .catch(function () { subBox.textContent = 'Presiona play para escuchar'; });
    }
}
