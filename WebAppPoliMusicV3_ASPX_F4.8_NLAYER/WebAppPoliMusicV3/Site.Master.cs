using System;
using EntityLayer.PoliMusicV3;
using EntityLayer.PoliMusicV3.Util;
namespace WebAppPoliMusicV3
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            User user = Session[Constants.USER] as User;
            if (user == null)
            {
                System.Web.Security.FormsAuthentication.SignOut();
                Response.Redirect("~/Login", true);
                return;
            }
            lblUserName.Text = Server.HtmlEncode(user.UserName);
            lblWelcome.Text = Server.HtmlEncode(user.UserName);
            lblUserRole.Text = user.UserType == Constants.ID_USER_ADMIN ? "Administrador" : "Usuario";
            imgAvatar.ImageUrl = string.IsNullOrEmpty(user.Photo) ? "~/UserImages/default.jpg" : user.Photo;
            string page = Page.AppRelativeVirtualPath;
            navSongs.Attributes["class"] = "pm-nav__link" + (page.EndsWith("Song.aspx", StringComparison.OrdinalIgnoreCase) ? " is-active" : "");
            navHome.Attributes["class"] = "pm-nav__link" + (page.EndsWith("Default.aspx", StringComparison.OrdinalIgnoreCase) ? " is-active" : "");
        }
    }
}
