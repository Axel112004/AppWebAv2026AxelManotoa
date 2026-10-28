using System;
using System.Data;
using System.Data.SqlClient;

namespace WebAppPoliMusicV2.DAL
{
    /// <summary>
    /// Data Access Layer for the table TBL_SONG. Every statement is parameterized.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Returns the whole catalog of songs with the artists and the album
        /// resolved from TBL_PLAYER, TBL_ARTIST and TBL_TRACKLIST.
        /// </summary>
        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            string sentence =
                "SELECT S.[ID_SONG], S.[SONG_NAME], S.[SONG_PATH], ISNULL(S.[PLAYS], 0) AS [PLAYS], " +
                "ISNULL(STUFF((SELECT ', ' + A.[ARTIST_NAME] + ' ' + ISNULL(A.[ARTIST_LASTNAME], '') " +
                "              FROM [TBL_PLAYER] P " +
                "              INNER JOIN [TBL_ARTIST] A ON A.[ID_ARTIST] = P.[ID_ARTIST] " +
                "              WHERE P.[ID_SONG] = S.[ID_SONG] " +
                "              FOR XML PATH('')), 1, 2, ''), '') AS [ARTIST], " +
                "ISNULL((SELECT TOP 1 AL.[TITLE_ALBUM] " +
                "        FROM [TBL_TRACKLIST] T " +
                "        INNER JOIN [TBL_ALBUM] AL ON AL.[ID_ALBUM] = T.[ID_ALBUM] " +
                "        WHERE T.[ID_SONG] = S.[ID_SONG]), '') AS [ALBUM] " +
                "FROM [TBL_SONG] S " +
                "ORDER BY S.[ID_SONG]";
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sentence, con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Returns one single song by its identifier.
        /// </summary>
        public DataTable Read(int idSong)
        {
            DataTable dtSong = new DataTable();
            string sentence =
                "SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], ISNULL([PLAYS], 0) AS [PLAYS] " +
                "FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sentence, con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public int Save(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG]([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                        "VALUES(@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.Name);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.Path);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public int Update(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                        "[SONG_NAME] = @SONG_NAME, [SONG_PATH] = @SONG_PATH, [PLAYS] = @PLAYS " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.Name);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.Path);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "DELETE [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Adds one play to the counter of the song.
        /// </summary>
        public int IncrementPlays(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [PLAYS] = ISNULL([PLAYS], 0) + 1 " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
