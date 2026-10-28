<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="WebAppPoliMusicV2.SignUp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Register new user | PoliMusic</title>
    <link href="Content/polimusic.css" rel="stylesheet" />
</head>
<body class="pm-body pm-auth">
    <form id="formLogin" runat="server" class="pm-auth__card pm-auth__card--wide">
        <div class="pm-auth__brand">
            <div class="pm-auth__logo">P</div>
            <div class="pm-auth__name">Poli<span>Music</span></div>
        </div>

        <h1 class="pm-auth__title">Register new user</h1>
        <p class="pm-auth__sub">Fields marked with * are required.</p>

        <div class="pm-auth__form">
            <div class="pm-row">
                <div class="pm-field">
                    <label class="pm-field__label" for="txtUserName">User name*</label>
                    <asp:TextBox ID="txtUserName" runat="server" CssClass="pm-input" placeholder="john.doe"></asp:TextBox>
                </div>
                <div class="pm-field">
                    <label class="pm-field__label" for="txtEmail">Email*</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="pm-input" placeholder="john.doe@epn.edu.ec"></asp:TextBox>
                </div>
            </div>

            <div class="pm-row">
                <div class="pm-field">
                    <label class="pm-field__label" for="txtPassword">Password*</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="pm-input" TextMode="Password" placeholder="••••••••" />
                </div>
                <div class="pm-field">
                    <label class="pm-field__label" for="txtConfirmPassword">Confirm password*</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="pm-input" TextMode="Password" placeholder="••••••••" />
                </div>
            </div>

            <div class="pm-row">
                <div class="pm-field">
                    <label class="pm-field__label" for="txtBirthDate">Birth date</label>
                    <asp:TextBox ID="txtBirthDate" runat="server" CssClass="pm-input" placeholder="dd/MM/yyyy" />
                    <div class="pm-field__hint">Format: dd/MM/yyyy</div>
                </div>
                <div class="pm-field">
                    <label class="pm-field__label" for="fupPhoto">Photo</label>
                    <asp:FileUpload ID="fupPhoto" runat="server" CssClass="pm-input pm-input--file" />
                    <div class="pm-field__hint">JPEG or PNG, up to 10 MB.</div>
                </div>
            </div>

            <asp:Panel ID="frmConfirmation" Visible="true" runat="server">
                <asp:Label ID="lblMessage" runat="server" CssClass="pm-alert" Font-Bold="true"></asp:Label>
            </asp:Panel>

            <div class="pm-auth__foot">
                <asp:HyperLink ID="HyperLink1" NavigateUrl="~/Login.aspx" runat="server" CssClass="pm-btn pm-btn--ghost pm-btn--sm">Back to Login</asp:HyperLink>
                <asp:Button ID="btnSumbit" runat="server" CssClass="pm-btn" Text="Submit" OnClick="btnSumbit_Click" />
            </div>
        </div>
    </form>
</body>
</html>
