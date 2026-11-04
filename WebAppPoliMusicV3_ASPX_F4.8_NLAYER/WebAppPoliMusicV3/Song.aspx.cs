using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace WebAppPoliMusicV3
{
    public partial class Song : Page
    {
        private readonly string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadSongs();
        }
        private void LoadSongs()
        {
            DataTable songs = new BLL.PoliMusicV3.Song(strConnString).Read();
            gvSongs.DataSource = songs;
            gvSongs.DataBind();
            if (gvSongs.HeaderRow != null) gvSongs.HeaderRow.TableSection = TableRowSection.TableHeader;
            lblTotal.Text = songs.Rows.Count + " canciones";
        }
        protected bool SongAvailable(object path)
        {
            string value = Convert.ToString(path);
            if (!value.StartsWith("~/songFiles/", StringComparison.OrdinalIgnoreCase) || value.Contains("..")) return false;
            return File.Exists(Server.MapPath(value));
        }
        protected void gvSongs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "PlaySong") return;
            if (Session[EntityLayer.PoliMusicV3.Util.Constants.USER] == null)
            {
                Response.Redirect("~/Login", true);
                return;
            }
            int idSong;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idSong)) return;
            BLL.PoliMusicV3.Song service = new BLL.PoliMusicV3.Song(strConnString);
            DataTable result = service.Read(idSong);
            if (result.Rows.Count != 1) return;
            DataRow song = result.Rows[0];
            string path = Convert.ToString(song["SONG_PATH"]);
            if (!SongAvailable(path))
            {
                lblMessage.Text = "El archivo de esta canción no está disponible.";
                return;
            }
            service.IncrementPlays(idSong);
            LoadSongs();
            string url = HttpUtility.JavaScriptStringEncode(ResolveUrl(path), true);
            string title = HttpUtility.JavaScriptStringEncode(Convert.ToString(song["SONG_NAME"]), true);
            ScriptManager.RegisterStartupScript(upSongs, GetType(), "pmPlaySong", "pmPlaySong(" + url + "," + title + ");", true);
        }
    }
}
