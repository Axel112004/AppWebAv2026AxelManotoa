<%@ Page Title="Canciones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="pm-page-intro"><h1>Listado de canciones</h1><p>Encuentra tu ritmo. Dale play a lo que te mueve.</p></section>
    <asp:UpdatePanel ID="upSongs" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <section class="pm-card">
            <div class="pm-card__head"><div class="pm-card__title">Song List</div><asp:Label ID="lblTotal" runat="server" CssClass="pm-card__count" /></div>
            <div class="pm-table-scroll">
            <asp:GridView ID="gvSongs" runat="server" AutoGenerateColumns="false" CssClass="pm-grid"
                DataKeyNames="ID_SONG,SONG_NAME,SONG_PATH" GridLines="None" UseAccessibleHeader="true"
                OnRowCommand="gvSongs_RowCommand" BorderWidth="0" CellPadding="0" CellSpacing="0">
                <Columns>
                    <asp:TemplateField HeaderText="#"><ItemTemplate><span class="pm-grid__num"><%# Container.DataItemIndex + 1 %></span></ItemTemplate></asp:TemplateField>
                    <asp:TemplateField HeaderText="Canción"><ItemTemplate>
                        <div class="pm-song-cell"><span class="pm-song-art">&#9835;</span><div><span class="pm-grid__name"><%# Server.HtmlEncode(Convert.ToString(Eval("SONG_NAME"))) %></span><div class="pm-song-sub">PoliMusic &middot; MP3</div></div></div>
                    </ItemTemplate></asp:TemplateField>
                    <asp:BoundField DataField="ARTIST" HeaderText="Artista" HtmlEncode="true" />
                    <asp:BoundField DataField="ALBUM" HeaderText="Álbum" HtmlEncode="true" />
                    <asp:BoundField DataField="PLAYS" HeaderText="Reproducciones" ItemStyle-CssClass="pm-grid__plays" />
                    <asp:TemplateField HeaderText="Reproducir" ItemStyle-CssClass="pm-grid__actions"><ItemTemplate>
                        <asp:LinkButton ID="btnPlay" runat="server" CssClass="pm-play" CommandName="PlaySong" CommandArgument='<%# Eval("ID_SONG") %>' CausesValidation="false" Visible='<%# SongAvailable(Eval("SONG_PATH")) %>'><span class="pm-play__ico"></span> Play</asp:LinkButton>
                        <asp:Label ID="lblUnavailable" runat="server" CssClass="pm-unavailable" Visible='<%# !SongAvailable(Eval("SONG_PATH")) %>' Text="Archivo no disponible" />
                    </ItemTemplate></asp:TemplateField>
                </Columns>
                <EmptyDataTemplate><div class="pm-empty">Todavía no hay canciones en el catálogo.</div></EmptyDataTemplate>
            </asp:GridView>
            </div>
        </section>
        <asp:Label ID="lblMessage" runat="server" CssClass="pm-note" />
    </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
