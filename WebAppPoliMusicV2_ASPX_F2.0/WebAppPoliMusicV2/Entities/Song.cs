using System;

namespace WebAppPoliMusicV2.Entities
{
    /// <summary>
    /// Entity that represents a row of the table TBL_SONG together with the
    /// information resolved from TBL_PLAYER, TBL_ARTIST and TBL_TRACKLIST.
    /// </summary>
    public class Song
    {
        public Song()
        {
        }

        public Song(int id, string name, string path, int plays)
        {
            ID = id;
            Name = name;
            Path = path;
            Plays = plays;
        }

        public int ID { get; set; }
        public string Name { get; set; }
        public string Path { get; set; }
        public int Plays { get; set; }
        public string Artist { get; set; }
        public string Album { get; set; }
    }
}
