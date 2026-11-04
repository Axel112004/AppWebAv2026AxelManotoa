using System.Web.Optimization;
namespace WebAppPoliMusicV3
{
    public static class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include("~/Scripts/jquery-3.7.0.js"));
            // Bootstrap 5 uses modern JavaScript; the legacy WebGrease minifier cannot parse it.
            bundles.Add(new Bundle("~/bundles/bootstrap").Include("~/Scripts/bootstrap.bundle.js"));
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include("~/Scripts/modernizr-2.8.3.js"));
            bundles.Add(new ScriptBundle("~/bundles/polimusic").Include("~/Scripts/polimusic.js"));
            // Preserve the CSS variables used by Bootstrap and the PoliMusic design.
            bundles.Add(new Bundle("~/Content/css").Include("~/Content/bootstrap.css", "~/Content/polimusic.css"));
        }
    }
}
