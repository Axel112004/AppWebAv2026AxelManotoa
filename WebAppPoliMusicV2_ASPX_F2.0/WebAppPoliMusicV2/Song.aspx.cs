using System;
using System.Configuration;
using System.Data;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                LoadUserInformation();
                LoadSongs();
            }
        }

        /// <summary>
        /// Shows in the sidebar the data of the user stored in the session.
        /// </summary>
        private void LoadUserInformation()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            if (user != null)
            {
                lblUserName.Text = Server.HtmlEncode(user.UserName);
                lblUserRole.Text = (user.UserType == Util.Constants.ID_USER_ADMIN) ? "Administrator" : "User";
                if (!string.IsNullOrEmpty(user.Photo))
                {
                    imgAvatar.ImageUrl = ResolveUrl(user.Photo);
                }
                else
                {
                    imgAvatar.ImageUrl = ResolveUrl("~/UserImages/default.jpg");
                }
            }
            else
            {
                lblUserName.Text = Server.HtmlEncode(Page.User.Identity.Name);
                lblUserRole.Text = "User";
                imgAvatar.ImageUrl = ResolveUrl("~/UserImages/default.jpg");
            }
        }

        /// <summary>
        /// Fills the GridView with the songs returned by the business layer.
        /// </summary>
        private void LoadSongs()
        {
            DataTable dtSong = new BLL.Song(strConnString).Read();
            gvSongs.DataSource = dtSong;
            gvSongs.DataBind();
            lblTotal.Text = dtSong.Rows.Count.ToString() + (dtSong.Rows.Count == 1 ? " song" : " songs");
        }

        /// <summary>
        /// Sends the selected song to the player and updates its play counter.
        /// </summary>
        protected void gvSongs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "PlaySong")
            {
                return;
            }
            LinkButton button = e.CommandSource as LinkButton;
            if (button == null)
            {
                return;
            }
            GridViewRow row = button.NamingContainer as GridViewRow;
            if (row == null)
            {
                return;
            }
            int index = row.RowIndex;
            int idSong = Convert.ToInt32(gvSongs.DataKeys[index].Value);
            string songName = Convert.ToString(gvSongs.DataKeys[index].Values["SONG_NAME"]);
            string songPath = Convert.ToString(gvSongs.DataKeys[index].Values["SONG_PATH"]);

            // Update the counter through the BLL and the DAL.
            new BLL.Song(strConnString).IncrementPlays(idSong);

            // Refresh the list so the new value of PLAYS is displayed.
            LoadSongs();

            string url = ResolveUrl(songPath);
            ClientScript.RegisterStartupScript(this.GetType(), "pmPlaySong",
                "pmPlaySong('" + JsEscape(url) + "', '" + JsEscape(songName) + "');", true);
        }

        /// <summary>
        /// Escapes a text so it can be embedded inside a JavaScript string literal.
        /// </summary>
        private static string JsEscape(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return string.Empty;
            }
            return value.Replace("\\", "\\\\")
                        .Replace("'", "\\'")
                        .Replace("\r", " ")
                        .Replace("\n", " ")
                        .Replace("<", "\\u003c")
                        .Replace(">", "\\u003e");
        }
    }
}
