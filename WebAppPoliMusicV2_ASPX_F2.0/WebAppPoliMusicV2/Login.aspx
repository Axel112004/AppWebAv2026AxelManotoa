<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="WebAppPoliMusicV2.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sign in | PoliMusic</title>
    <link href="Content/polimusic.css" rel="stylesheet" />
</head>
<body class="pm-body pm-auth">
    <form id="formLogin" runat="server" class="pm-auth__card">
        <div class="pm-auth__brand">
            <div class="pm-auth__logo">P</div>
            <div class="pm-auth__name">Poli<span>Music</span></div>
        </div>

        <h1 class="pm-auth__title">Welcome back</h1>
        <p class="pm-auth__sub">Sign in to listen to your music catalog.</p>

        <div class="pm-auth__form">
            <div class="pm-field">
                <label class="pm-field__label" for="txtLogin">Username</label>
                <asp:TextBox ID="txtLogin" runat="server" CssClass="pm-input" placeholder="Username"></asp:TextBox>
            </div>

            <div class="pm-field">
                <label class="pm-field__label" for="txtPassword">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="pm-input" TextMode="Password" placeholder="Password"></asp:TextBox>
            </div>

            <asp:Button ID="btnLogin" runat="server" CssClass="pm-btn pm-btn--block" Text="Sign in" OnClick="BtnLogin_Click" />

            <asp:Label ID="lblMessage" runat="server" CssClass="pm-alert"></asp:Label>

            <div class="pm-auth__foot">
                <span>New to PoliMusic?</span>
                <asp:LinkButton ID="LinkButtonNewUser" runat="server" CssClass="pm-btn pm-btn--ghost pm-btn--sm" OnClick="LinkButtonNewUser_Click">Enroll new user</asp:LinkButton>
            </div>
        </div>
    </form>
</body>
</html>
