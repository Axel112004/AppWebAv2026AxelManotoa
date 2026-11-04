<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WebAppPoliMusicV3.Default" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pm-hero">
        <div class="pm-eyebrow">Hecho para escuchar</div>
        <h1>Tu música.<br />Tu momento.</h1>
        <p>Bienvenido a PoliMusic. Explora el catálogo, encuentra tu próxima canción y dale play a tu día.</p>
        <a class="pm-btn" runat="server" href="~/Song">&#9654; Explorar canciones</a>
    </section>
    <section class="pm-stats" aria-label="Tu catálogo">
        <div class="pm-card pm-stat"><strong><asp:Label ID="lblSongs" runat="server" /></strong><span>Canciones en el catálogo</span></div>
        <div class="pm-card pm-stat"><strong><asp:Label ID="lblPlays" runat="server" /></strong><span>Reproducciones</span></div>
        <div class="pm-card pm-stat"><strong>&#9835;</strong><span>Una biblioteca para descubrir</span></div>
    </section>
    <section class="pm-card"><div class="pm-card__head"><div><div class="pm-card__title">Tu espacio musical</div><p class="pm-note">Abre Canciones para consultar el catálogo y escuchar los archivos disponibles.</p></div><a runat="server" href="~/Song" class="pm-btn pm-btn--sm">Ver catálogo</a></div></section>
</asp:Content>
