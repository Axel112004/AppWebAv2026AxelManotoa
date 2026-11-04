using System;
using System.Data;
using System.Configuration;
using System.Web.Security;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV3
{
    public partial class Login : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
#if DEBUG
                // Datos del estudiante: Axel Manotoa
                // (aqui se reemplaza "nombre.apellidoestudiante" por los datos propios)
                txtLogin.Text = "Axel.Manotoa";
                txtPassword.Text = "12345678";
                txtPassword.Attributes.Add("value", txtPassword.Text);
                txtPassword.TextMode = TextBoxMode.Password;
#endif
                lblMessage.Text = string.Empty;
            }
        }

        protected void BtnLogin_Click(object sender, EventArgs e)
        {
            string login = txtLogin.Text;
            string password = txtPassword.Text;

            if (string.IsNullOrEmpty(login) || string.IsNullOrEmpty(password))
            {
                lblMessage.Text = "Please, write a login/password.";
                return;
            }
            password = EntityLayer.PoliMusicV3.Util.Hash.GeneratePasswordHash(password);
            DataTable dtUser = new BLL.PoliMusicV3.User(strConnString).AuthenticateUser(login, password);

            if (dtUser != null && dtUser.Rows.Count > 0)
            {
                EntityLayer.PoliMusicV3.User user = new EntityLayer.PoliMusicV3.User();
                user.ID = Convert.ToInt32(dtUser.Rows[0]["ID_USER"]);
                user.UserName = login;
                user.Photo = dtUser.Rows[0]["USER_PHOTO"].ToString();
                user.Email = dtUser.Rows[0]["EMAIL"].ToString();
                user.Birthday = dtUser.Rows[0]["BIRTHDAY"].ToString();
                user.UserType = Convert.ToInt32(dtUser.Rows[0]["USER_TYPE"]);
                if (user.UserType == EntityLayer.PoliMusicV3.Util.Constants.ID_USER_NORMAL)
                {
                    Session[EntityLayer.PoliMusicV3.Util.Constants.USER] = user;
                    FormsAuthentication.RedirectFromLoginPage(login, true);
                    //Response.Redirect("~/Default.aspx", true);
                }
                else if (user.UserType == EntityLayer.PoliMusicV3.Util.Constants.ID_USER_ADMIN)
                {
                    Session[EntityLayer.PoliMusicV3.Util.Constants.USER] = user;
                    FormsAuthentication.RedirectFromLoginPage(login, true);
                    // El laboratorio no define DesktopAdmin; ambos roles acceden al inicio.
                }
                else
                {
                    lblMessage.Text = "Login/password incorrect, try again.";
                    return;
                }
            }
            else
            {
                lblMessage.Text = "Login/password incorrect, try again.";
                return;
            }
            //#endif
            lblMessage.Text = string.Empty;
        }

        protected void LinkButtonNewUser_Click(object sender, EventArgs e)
        {
            Response.Redirect("SignUp.aspx", true);
        }
    }
}
