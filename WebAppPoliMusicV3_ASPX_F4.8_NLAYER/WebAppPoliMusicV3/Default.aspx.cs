using System;
using System.Configuration;
using System.Data;
namespace WebAppPoliMusicV3
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            DataTable songs = new BLL.PoliMusicV3.Song(ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString).Read();
            lblSongs.Text = songs.Rows.Count.ToString();
            long plays = 0;
            foreach (DataRow song in songs.Rows) plays += Convert.ToInt64(song["PLAYS"]);
            lblPlays.Text = plays.ToString();
        }
    }
}
