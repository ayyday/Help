using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace DemoWindowsFormsApp
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void btnExec_Click(object sender, EventArgs e)
        {
            FolderBrowserDialog folderBrowserDialog1 = new FolderBrowserDialog();
            if(folderBrowserDialog1.ShowDialog() == DialogResult.OK)
            {
                StringBuilder sb = new StringBuilder();
                DirectoryInfo dirRoot = new DirectoryInfo(folderBrowserDialog1.SelectedPath);
                
                foreach (DirectoryInfo dirSub in dirRoot.GetDirectories())
                {
                    foreach(FileInfo file in  dirSub.GetFiles())
                    {
                        if(file.FullName.IndexOf(".htm") >= 0)
                        {
                            sb.AppendLine(file.FullName);
                            using (StreamReader streamReader = new StreamReader(file.FullName))
                            {
                                using (StreamWriter streamWriter = new StreamWriter(Path.Combine(file.DirectoryName, "new_" + file.Name)))
                                {
                                    string line;
                                    while ((line = streamReader.ReadLine()) != null)
                                    {
                                        streamWriter.WriteLine(
                                            line
                                        );
                                    }
                                }
                            }
                        }
                    }
                }
                MessageBox.Show("Html File= \r\n" + sb.ToString());
            }


            /*
            [Select Directory]
            FolderBrowserDialog folderBrowserDialog1 = new FolderBrowserDialog();
            if(folderBrowserDialog1.ShowDialog() == DialogResult.OK)
            {
                //MessageBox.Show("Open FullPahtDir=" + folderBrowserDialog1.SelectedPath.ToString());
            }
            [Select File]
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                MessageBox.Show("Open FullPahtFileName=" + openFileDialog1.FileName.ToString());
            }*/
        }
    }
}
