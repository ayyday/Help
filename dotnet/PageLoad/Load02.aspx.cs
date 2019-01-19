// ● 參考(reference)：https://www.aspforums.net/Threads/131719/Show-loading-progress-GIF-image-when-Page-Loads-in-ASPNet-MVC/ 
using System;
using System.Threading;
using System.Web.UI.WebControls;

namespace WebApplication1.Page
{
    public partial class Load02 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            ScriptManager1.RegisterAsyncPostBackControl(btnTest);
        }

        protected void btnTest_Click(object sender, EventArgs e)
        {
            setData();
        }

        private void setData()
        {
            hidExec.Value = "F";
            string txt = "";
            for (int i = 0; i < 15; i++)
            {
                Thread.Sleep(500);
                txt += i.ToString();
            }
            divMain.InnerText = txt;
            TextBox txtAdd = new TextBox();
            txtAdd.Text = "abcdef";
            divMain.Controls.Add(txtAdd);
            UpdatePanel1.Update();

            Panel2.Visible = false;
            UpdatePanel2.Update();
        }
    }
}
