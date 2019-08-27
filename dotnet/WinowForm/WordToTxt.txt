using NPOI.XWPF.UserModel;
using System;
using System.IO;
using System.Windows.Forms;
using Microsoft.Office.Interop.Word;
using System.Text.RegularExpressions;

namespace DemoWindowsFormsApp
{
    //一般 I/O 工作
    //https://docs.microsoft.com/zh-tw/dotnet/standard/io/common-i-o-tasks


    //using NPOI
    //https://www.nuget.org/packages/NPOI/
    //VS 的Nuget下載，VS2010工具外部擴充套件器Nuget package manager下載->安裝->重啟
    //完成此任务应该准备的DLL：NPOI.DLL ，官网下载链接：http://npoi.codeplex.com/
    public partial class FormNPOI : Form
    {
        public FormNPOI()
        {
            InitializeComponent();
        }

        private void btnWordToTxt_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.InitialDirectory = "";
            ofd.Filter = "Word檔案|*.docx;*.doc";
            ofd.Multiselect = true;
            string[] WordUrl;//資料來源路徑集合
            DialogResult r = ofd.ShowDialog();
            if (r == DialogResult.OK)
            {
                WordUrl = ofd.FileNames;
            }
            else
            {
                return;
            }
            for (int i = 0; i < WordUrl.Length; i++)
            {
                string wordFile = "";
                wordFile = WordUrl[i];
                Stream stream = File.OpenRead(wordFile);
                if (wordFile.EndsWith(".docx_"))
                {
                    //using NPOI.XWPF.UserModel;
                    XWPFDocument doc = new XWPFDocument(stream);
                    foreach (var para in doc.Paragraphs)
                    {
                        string text = para.ParagraphText;
                        //獲得文字                     
                        if (text.Trim() != "")
                        {
                            Console.WriteLine(text);
                        }
                    }
                }
                else
                {
                    string extension = Path.GetExtension(wordFile);
                    string newFile = wordFile.Replace(extension, ".txt");

                    //本文使用的程式碼僅適合 已安裝 Word 的環境
                    // Open a doc file.
                    Microsoft.Office.Interop.Word.Application appWord = new Microsoft.Office.Interop.Word.Application();
                    Microsoft.Office.Interop.Word.Document docWord = appWord.Documents.Open(wordFile);
                    StreamWriter sw = new StreamWriter(newFile, false, encoding: System.Text.Encoding.UTF8);
                    // Loop through all words in the document.
                    int count = docWord.Words.Count;
                    System.Text.StringBuilder sb = new System.Text.StringBuilder();
                    for (int iline = 1; iline <= count; iline++)
                    {
                        // Write the word.
                        sb.Append(docWord.Words[iline].Text);
                        if (iline % 100 == 0 || iline == count)
                        {
                            //sw.Write(sb.ToString().Replace(@"\r", System.Environment.NewLine));
                            //System.Environment.NewLine = "/r/n" = CRLF
                            sw.Write(Regex.Replace(sb.ToString(), @"\r", System.Environment.NewLine));
                            sb.Clear();
                        }
                    }
                    sw.Close();
                    // Close word.
                    docWord.Close();
                    appWord.Quit();
                }

            }
            Console.ReadLine();

        }


        /// <summary>
        /// 本文使用的程式碼僅適合 已安裝 Word 的環境
        /// https://blog.yowko.com/c-sharp-word-to-pdf/
        /// </summary>
        public void WordToPdf()
        {
            // word 檔案位置
            string sourcedocx = @"C:\sample.docx";
            // PDF 儲存位置
            string targetpdf = @"C:\output.pdf";

            //建立 word application instance
            Microsoft.Office.Interop.Word.Application appWord = new Microsoft.Office.Interop.Word.Application();
            //開啟 word 檔案
            var wordDocument = appWord.Documents.Open(sourcedocx);
            //匯出為 pdf
            wordDocument.ExportAsFixedFormat(targetpdf, WdExportFormat.wdExportFormatPDF);

            //關閉 word 檔
            wordDocument.Close();
            //結束 word
            appWord.Quit();
        }
    }
}
