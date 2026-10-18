<%
' =============================================================================
'  PoliMusic | Iconografia SVG en linea (sin librerias externas)
'  Cada icono hereda el color del texto mediante currentColor.
' =============================================================================

Function Icon(ByVal nombre)
    Dim n, cuerpo, relleno
    n = LCase(Clean(nombre))
    cuerpo = ""
    relleno = "none"

    Select Case n
        Case "home"
            cuerpo = "<path d='M3.2 10.7 12 3.4l8.8 7.3'/><path d='M5.6 9.5V20a1 1 0 0 0 1 1h3.2v-5.6h4.4V21h3.2a1 1 0 0 0 1-1V9.5'/>"
        Case "music"
            cuerpo = "<path d='M9 18V6.2l10-2.1V16'/><circle cx='6.6' cy='18' r='2.5'/><circle cx='16.6' cy='16' r='2.5'/>"
        Case "song"
            cuerpo = "<path d='M9 18V6.2l10-2.1V16'/><circle cx='6.6' cy='18' r='2.5'/><circle cx='16.6' cy='16' r='2.5'/>"
        Case "mic", "artist"
            cuerpo = "<rect x='9' y='2.5' width='6' height='11' rx='3'/><path d='M5.4 11.4a6.6 6.6 0 0 0 13.2 0'/><path d='M12 18v3.2'/><path d='M8.6 21.2h6.8'/>"
        Case "disc", "album"
            cuerpo = "<circle cx='12' cy='12' r='9'/><circle cx='12' cy='12' r='2.8'/><path d='M12 3.2v3.4'/>"
        Case "list", "playlist"
            cuerpo = "<path d='M4 6.5h11'/><path d='M4 12h11'/><path d='M4 17.5h7'/><path d='M18.5 11v8'/><circle cx='16.6' cy='19' r='2.1'/>"
        Case "users", "user-admin"
            cuerpo = "<circle cx='9.2' cy='8.2' r='3.6'/><path d='M2.8 20.2a6.4 6.4 0 0 1 12.8 0'/><path d='M17 4.8a3.6 3.6 0 0 1 0 6.8'/><path d='M18.6 20.2a6.4 6.4 0 0 0-2.9-5.4'/>"
        Case "user"
            cuerpo = "<circle cx='12' cy='8' r='4'/><path d='M4.5 20.5a7.5 7.5 0 0 1 15 0'/>"
        Case "shield"
            cuerpo = "<path d='M12 3.2 19 6v6.1c0 4.3-2.9 7.8-7 9.1-4.1-1.3-7-4.8-7-9.1V6z'/><path d='m9.2 12 2 2 3.6-3.8'/>"
        Case "search"
            cuerpo = "<circle cx='11' cy='11' r='7'/><path d='m20.4 20.4-4-4'/>"
        Case "play"
            relleno = "currentColor"
            cuerpo = "<path d='M7.5 4.8a1 1 0 0 1 1.5-.87l10 6.2a1 1 0 0 1 0 1.74l-10 6.2a1 1 0 0 1-1.5-.87z' stroke='none'/>"
        Case "pause"
            relleno = "currentColor"
            cuerpo = "<rect x='7' y='4.6' width='3.6' height='14.8' rx='1.3' stroke='none'/><rect x='13.4' y='4.6' width='3.6' height='14.8' rx='1.3' stroke='none'/>"
        Case "next"
            relleno = "currentColor"
            cuerpo = "<path d='M5.4 5.6a.9.9 0 0 1 1.35-.78l8 4.9a.9.9 0 0 1 0 1.56l-8 4.9A.9.9 0 0 1 5.4 15.4z' stroke='none'/><rect x='16.4' y='5' width='2.6' height='14' rx='1.2' stroke='none'/>"
        Case "prev"
            relleno = "currentColor"
            cuerpo = "<path d='M18.6 5.6a.9.9 0 0 0-1.35-.78l-8 4.9a.9.9 0 0 0 0 1.56l8 4.9a.9.9 0 0 0 1.35-.78z' stroke='none'/><rect x='5' y='5' width='2.6' height='14' rx='1.2' stroke='none'/>"
        Case "volume"
            cuerpo = "<path d='M4 9.4h3.1L11.6 6v12L7.1 14.6H4z'/><path d='M15.6 9.3a3.9 3.9 0 0 1 0 5.4'/><path d='M18.2 6.7a7.6 7.6 0 0 1 0 10.6'/>"
        Case "volume-mute"
            cuerpo = "<path d='M4 9.4h3.1L11.6 6v12L7.1 14.6H4z'/><path d='m16 10 4 4'/><path d='m20 10-4 4'/>"
        Case "plus"
            cuerpo = "<path d='M12 5.2v13.6'/><path d='M5.2 12h13.6'/>"
        Case "minus"
            cuerpo = "<path d='M5.2 12h13.6'/>"
        Case "edit"
            cuerpo = "<path d='M4 20h4.2L19 9.2a2.1 2.1 0 0 0 0-3l-1.2-1.2a2.1 2.1 0 0 0-3 0L4 15.8z'/><path d='m14.4 6.4 3.2 3.2'/>"
        Case "trash"
            cuerpo = "<path d='M4 7h16'/><path d='M9.5 7V4.6h5V7'/><path d='M6.4 7 7.6 20.2h8.8L17.6 7'/><path d='M10.4 10.8v5.6'/><path d='M13.6 10.8v5.6'/>"
        Case "logout"
            cuerpo = "<path d='M14.6 4H18a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3.4'/><path d='M10 8.4 6.4 12l3.6 3.6'/><path d='M6.6 12h9.4'/>"
        Case "login"
            cuerpo = "<path d='M9.4 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h3.4'/><path d='m14 8.4 3.6 3.6L14 15.6'/><path d='M17.4 12H8'/>"
        Case "menu"
            cuerpo = "<path d='M4 7h16'/><path d='M4 12h16'/><path d='M4 17h16'/>"
        Case "close"
            cuerpo = "<path d='m6.4 6.4 11.2 11.2'/><path d='M17.6 6.4 6.4 17.6'/>"
        Case "check"
            cuerpo = "<circle cx='12' cy='12' r='9'/><path d='m8.2 12.2 2.6 2.6 5-5.4'/>"
        Case "alert"
            cuerpo = "<circle cx='12' cy='12' r='9'/><path d='M12 7.6v5.2'/><path d='M12 16.4h.01'/>"
        Case "info"
            cuerpo = "<circle cx='12' cy='12' r='9'/><path d='M12 11v5.4'/><path d='M12 7.8h.01'/>"
        Case "calendar"
            cuerpo = "<rect x='3.6' y='5.2' width='16.8' height='15' rx='2.4'/><path d='M3.6 9.8h16.8'/><path d='M8.2 3.4v3.6'/><path d='M15.8 3.4v3.6'/>"
        Case "mail"
            cuerpo = "<rect x='3' y='5.4' width='18' height='13.2' rx='2.4'/><path d='m4 7.4 8 5.6 8-5.6'/>"
        Case "lock"
            cuerpo = "<rect x='4.6' y='10.4' width='14.8' height='9.6' rx='2.2'/><path d='M8.2 10.4V8a3.8 3.8 0 0 1 7.6 0v2.4'/><path d='M12 14.2v2.4'/>"
        Case "eye"
            cuerpo = "<path d='M2.6 12S6 5.8 12 5.8 21.4 12 21.4 12 18 18.2 12 18.2 2.6 12 2.6 12z'/><circle cx='12' cy='12' r='3.2'/>"
        Case "chart"
            cuerpo = "<path d='M4 20h16'/><rect x='5.6' y='11' width='3.4' height='6' rx='1'/><rect x='10.3' y='7' width='3.4' height='10' rx='1'/><rect x='15' y='13.4' width='3.4' height='3.6' rx='1'/>"
        Case "clock"
            cuerpo = "<circle cx='12' cy='12' r='8.6'/><path d='M12 7.4V12l3.2 2'/>"
        Case "heart"
            cuerpo = "<path d='M12 20.2S3.6 15 3.6 9.4A4.6 4.6 0 0 1 12 6.6a4.6 4.6 0 0 1 8.4 2.8c0 5.6-8.4 10.8-8.4 10.8z'/>"
        Case "star"
            cuerpo = "<path d='m12 3.8 2.6 5.4 5.9.85-4.25 4.15 1 5.9L12 17.3l-5.25 2.8 1-5.9L3.5 10.05l5.9-.85z'/>"
        Case "headphones"
            cuerpo = "<path d='M4.4 15v-3a7.6 7.6 0 0 1 15.2 0v3'/><rect x='2.6' y='13.6' width='4.4' height='7' rx='2.2'/><rect x='17' y='13.6' width='4.4' height='7' rx='2.2'/>"
        Case "wave"
            cuerpo = "<path d='M3 12h2.4'/><path d='M8 6.5v11'/><path d='M12 3.5v17'/><path d='M16 7.5v9'/><path d='M20 10.5v3'/>"
        Case "folder"
            cuerpo = "<path d='M3.4 7.2a2 2 0 0 1 2-2h3.1l2 2.4h7.1a2 2 0 0 1 2 2v7.6a2 2 0 0 1-2 2H5.4a2 2 0 0 1-2-2z'/>"
        Case "chevron-right"
            cuerpo = "<path d='m9.4 5.6 6.4 6.4-6.4 6.4'/>"
        Case "arrow-left"
            cuerpo = "<path d='M19 12H5'/><path d='m11 6-6 6 6 6'/>"
        Case "arrow-right"
            cuerpo = "<path d='M5 12h14'/><path d='m13 6 6 6-6 6'/>"
        Case "save"
            cuerpo = "<path d='M5 3.8h11L20.2 8v12.2H5z'/><path d='M8.4 3.8v5.6h7V3.8'/><rect x='8.4' y='13' width='7.2' height='7.2'/>"
        Case "key"
            cuerpo = "<circle cx='8.4' cy='15.6' r='3.6'/><path d='m11 13 8-8'/><path d='m16.4 7.6 2 2'/><path d='m14 10 2 2'/>"
        Case "grid"
            cuerpo = "<rect x='4' y='4' width='7' height='7' rx='1.6'/><rect x='13' y='4' width='7' height='7' rx='1.6'/><rect x='4' y='13' width='7' height='7' rx='1.6'/><rect x='13' y='13' width='7' height='7' rx='1.6'/>"
        Case "sparkle"
            cuerpo = "<path d='M12 3.6 13.9 9l5.4 1.9-5.4 1.9L12 18.2l-1.9-5.4L4.7 10.9 10.1 9z'/>"
        Case "settings"
            cuerpo = "<circle cx='12' cy='12' r='3.2'/><path d='M19.2 14.4a1.7 1.7 0 0 0 .34 1.87l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.7 1.7 0 0 0-2.87 1.2v.17a2 2 0 1 1-4 0v-.09a1.7 1.7 0 0 0-2.93-1.16l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.7 1.7 0 0 0 3.9 13.6H3.7a2 2 0 1 1 0-4h.09A1.7 1.7 0 0 0 4.95 6.7l-.06-.06A2 2 0 1 1 7.72 3.8l.06.06a1.7 1.7 0 0 0 1.87.34h.09a1.7 1.7 0 0 0 1.03-1.56V2.4a2 2 0 1 1 4 0v.09a1.7 1.7 0 0 0 2.93 1.16l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.7 1.7 0 0 0-.34 1.87v.09a1.7 1.7 0 0 0 1.56 1.03h.17a2 2 0 1 1 0 4h-.09a1.7 1.7 0 0 0-1.56 1.03z'/>"
        Case "power"
            cuerpo = "<path d='M12 3.6v8'/><path d='M6.8 6.4a8 8 0 1 0 10.4 0'/>"
        Case Else
            cuerpo = "<circle cx='12' cy='12' r='8.4'/><path d='M12 11v5.4'/><path d='M12 7.8h.01'/>"
    End Select

    Icon = "<svg class='pm-ico' viewBox='0 0 24 24' width='20' height='20' " & _
           "fill='" & relleno & "' stroke='currentColor' stroke-width='1.75' " & _
           "stroke-linecap='round' stroke-linejoin='round' aria-hidden='true' " & _
           "focusable='false'>" & cuerpo & "</svg>"
End Function

' -----------------------------------------------------------------------------
'  Marca grafica de PoliMusic (barras de ecualizador dentro de un circulo)
' -----------------------------------------------------------------------------
Function LogoMark(ByVal tamano)
    Dim t
    t = ToInt(tamano)
    If t <= 0 Then t = 34

    LogoMark = "<svg viewBox='0 0 48 48' width='" & t & "' height='" & t & "' " & _
        "aria-hidden='true' focusable='false'>" & _
        "<defs><linearGradient id='pmLogo' x1='0' y1='0' x2='1' y2='1'>" & _
        "<stop offset='0' stop-color='#3E7BFF'/><stop offset='1' stop-color='#16307F'/>" & _
        "</linearGradient></defs>" & _
        "<rect x='1' y='1' width='46' height='46' rx='14' fill='url(#pmLogo)'/>" & _
        "<g fill='#ffffff'>" & _
        "<rect x='12' y='19' width='3.4' height='10' rx='1.7'/>" & _
        "<rect x='18.6' y='13' width='3.4' height='22' rx='1.7'/>" & _
        "<rect x='25.2' y='9' width='3.4' height='30' rx='1.7'/>" & _
        "<rect x='31.8' y='16' width='3.4' height='16' rx='1.7'/>" & _
        "</g></svg>"
End Function

'  Version reducida del logo (data URI) para el favicon
Function LogoFavicon()
    Dim svg
    svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 48 48'>" & _
        "<defs><linearGradient id='a' x1='0' y1='0' x2='1' y2='1'>" & _
        "<stop offset='0' stop-color='#3E7BFF'/><stop offset='1' stop-color='#16307F'/>" & _
        "</linearGradient></defs>" & _
        "<rect width='48' height='48' rx='14' fill='url(#a)'/>" & _
        "<g fill='#ffffff'><rect x='12' y='19' width='3.4' height='10' rx='1.7'/>" & _
        "<rect x='18.6' y='13' width='3.4' height='22' rx='1.7'/>" & _
        "<rect x='25.2' y='9' width='3.4' height='30' rx='1.7'/>" & _
        "<rect x='31.8' y='16' width='3.4' height='16' rx='1.7'/></g></svg>"
    LogoFavicon = "data:image/svg+xml;charset=utf-8," & UrlEnc(svg)
End Function
%>
