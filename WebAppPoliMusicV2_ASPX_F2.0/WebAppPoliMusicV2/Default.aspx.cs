using System;

namespace WebAppPoliMusicV2
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                Response.Redirect("Song.aspx");
            }
        }
    }
}
