<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Songs | PoliMusic</title>
    <link href="Content/polimusic.css" rel="stylesheet" />
</head>
<body class="pm-body">
    <form id="form1" runat="server">

        <!-- Barra lateral -->
        <aside class="pm-sidebar">
            <div class="pm-brand">
                <div class="pm-auth__logo">P</div>
                <div class="pm-brand__text">Poli<span>Music</span></div>
            </div>

            <nav class="pm-nav">
                <div class="pm-nav__label">Library</div>
                <a class="pm-nav__link is-active" href="Song.aspx">
                    <span>&#9835;</span> Songs
                </a>
                <a class="pm-nav__link" href="SignUp.aspx">
                    <span>&#43;</span> Register user
                </a>

                <div class="pm-nav__label">Account</div>
                <a class="pm-nav__link" href="Logout.aspx">
                    <span>&#9099;</span> Sign out
                </a>
            </nav>

            <div class="pm-sidebar__foot">
                <div class="pm-sidebar__who">
                    <asp:Image ID="imgAvatar" runat="server" CssClass="pm-avatar" AlternateText="User photo" />
                    <div>
                        <div class="pm-sidebar__name">
                            <asp:Label ID="lblUserName" runat="server"></asp:Label>
                        </div>
                        <div class="pm-sidebar__role">
                            <asp:Label ID="lblUserRole" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Barra superior -->
        <header class="pm-topbar">
            <div>
                <div class="pm-topbar__title">Song catalog</div>
                <div class="pm-topbar__sub">Data read from TBL_SONG through BLL and DAL</div>
            </div>
            <a class="pm-btn pm-btn--ghost pm-btn--sm" href="Logout.aspx">Sign out</a>
        </header>

        <!-- Contenido -->
        <main class="pm-main">
            <section class="pm-card">
                <div class="pm-card__head">
                    <div class="pm-card__title">All songs</div>
                    <asp:Label ID="lblTotal" runat="server" CssClass="pm-card__count"></asp:Label>
                </div>

                <asp:GridView ID="gvSongs" runat="server" AutoGenerateColumns="false" CssClass="pm-grid"
                    DataKeyNames="ID_SONG,SONG_NAME,SONG_PATH" GridLines="None" UseAccessibleHeader="true"
                    OnRowCommand="gvSongs_RowCommand" BorderWidth="0" CellPadding="0" CellSpacing="0">
                    <Columns>
                        <asp:TemplateField HeaderText="#">
                            <ItemTemplate>
                                <span class="pm-grid__num"><%# Container.DataItemIndex + 1 %></span>
                            </ItemTemplate>
                            <ItemStyle CssClass="pm-grid__num" />
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Song">
                            <ItemTemplate>
                                <span class="pm-grid__name"><%# Server.HtmlEncode(Convert.ToString(Eval("SONG_NAME"))) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Artist">
                            <ItemTemplate>
                                <span class="pm-pill"><%# Server.HtmlEncode(Convert.ToString(Eval("ARTIST"))) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Album">
                            <ItemTemplate>
                                <span class="pm-pill pm-pill--muted"><%# Server.HtmlEncode(Convert.ToString(Eval("ALBUM"))) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Plays">
                            <ItemTemplate>
                                <span class="pm-grid__plays"><%# Eval("PLAYS") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnPlay" runat="server" CssClass="pm-play" CommandName="PlaySong"
                                    CommandArgument='<%# Eval("ID_SONG") %>' CausesValidation="false">
                                    <span class="pm-play__ico"></span> Play
                                </asp:LinkButton>
                            </ItemTemplate>
                            <ItemStyle CssClass="pm-grid__actions" />
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="pm-empty">There are no songs registered in the database yet.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </section>
        </main>

        <!-- Reproductor -->
        <footer class="pm-player">
            <div class="pm-player__art">&#9835;</div>
            <div class="pm-player__meta">
                <div class="pm-player__title" id="pmPlayerTitle">Nothing playing</div>
                <div class="pm-player__sub" id="pmPlayerSub">Select a song and press Play</div>
            </div>
            <audio id="pmAudio" class="pm-player__audio" controls="controls" preload="none"></audio>
        </footer>

    </form>

    <script type="text/javascript">
        function pmPlaySong(url, title) {
            var audio = document.getElementById('pmAudio');
            var titleBox = document.getElementById('pmPlayerTitle');
            var subBox = document.getElementById('pmPlayerSub');
            if (!audio) { return; }
            titleBox.innerHTML = title;
            audio.src = url;
            audio.load();
            var promise = audio.play();
            if (promise && typeof promise.then === 'function') {
                promise.then(function () {
                    subBox.innerHTML = 'Playing now';
                }).catch(function () {
                    subBox.innerHTML = 'Ready to play - press the play button';
                });
            } else {
                subBox.innerHTML = 'Playing now';
            }
        }
    </script>
</body>
</html>
