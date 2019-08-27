using Dapper;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Windows.Forms;

namespace DemoWindowsFormsApp
{
    //測試DB逾時
    public partial class FormDb : Form
    {
        StringBuilder sb = new StringBuilder();

        public FormDb()
        {
            InitializeComponent();
        }

        /// <summary>動態SQL執行</summary>
        /// <returns></returns>
        private DataTable ExecSqlcommand()
        {
            /* 解決AP call DB查詢等待回應時間(30秒) 過短，產生 Exception :
             * https://docs.microsoft.com/zh-tw/dotnet/api/system.data.sqlclient.sqlcommand.commandtimeout?redirectedfrom=MSDN&view=netframework-4.8#System_Data_SqlClient_SqlCommand_CommandTimeout
             * 
                ExecSqlcommand ConnectionTimeout = 15
                ExecSqlcommand start Exception = 執行逾時到期。在作業完成之前超過逾時等待的時間，或是伺服器未回應。
                    於 System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
                    於 System.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
                    於 System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
                    於 System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
                    於 System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
                    於 System.Data.SqlClient.SqlDataReader.get_MetaData()
                    於 System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
                    於 System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
                    於 System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
                    於 System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
                    於 System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
                    於 System.Data.SqlClient.SqlCommand.ExecuteDbDataReader(CommandBehavior behavior)
                    於 System.Data.Common.DbCommand.System.Data.IDbCommand.ExecuteReader(CommandBehavior behavior)
                    於 Dapper.SqlMapper.ExecuteReaderWithFlagsFallback(IDbCommand cmd, Boolean wasClosed, CommandBehavior behavior)
                    於 Dapper.SqlMapper.ExecuteReaderImpl(IDbConnection cnn, CommandDefinition& command, CommandBehavior commandBehavior, IDbCommand& cmd)
                    於 Dapper.SqlMapper.ExecuteReader(IDbConnection cnn, String sql, Object param, IDbTransaction transaction, Nullable`1 commandTimeout, Nullable`1 commandType)
                    於 WindowsFormsApp1.FormDb.ExecSqlcommand() 於 D:\Angel\git_demo\DemoWindowsFormsApp\WindowsFormsApp1\FormDb.cs: 行 106
                ExecSqlcommand end Exception
                Exec Start = 2019/07/26 11:40:43.819
                Exec End = 2019/07/26 11:41:13.945
                Exec diff = 30.1260123秒
            */
            DateTime startDateTime = DateTime.MinValue;
            DateTime endDateTime = DateTime.MinValue;
            try
            {
                //ex  txtSqlCommand.Text = "WAITFOR DELAY '00:00:30' select GETDATE()";
                //    commandTimeoutSec.Text = "60";
                //建立新的DataTable Columns
                DataTable returnDT = new DataTable();
                Util.AppConfig appConfig = new Util.AppConfig();
                using (SqlConnection conn = new SqlConnection(appConfig.DbConnection))
                {
                    sb.AppendLine("ExecSqlcommand ConnectionTimeout = " + conn.ConnectionTimeout);
                    startDateTime = DateTime.Now;
                    System.Data.IDataReader dr;
                    if (txtCommandTimeoutSec.Text == "")
                    {
                        sb.AppendLine("ExecSqlcommand CommandTimeout = Default 30 sec");
                        dr = conn.ExecuteReader(txtSqlCommand.Text);
                    }
                    else
                    {
                        int commandTimeoutSec = int.Parse(txtCommandTimeoutSec.Text);
                        sb.AppendLine($"ExecSqlcommand CommandTimeout = {commandTimeoutSec} sec");
                        dr = conn.ExecuteReader(txtSqlCommand.Text, commandTimeout: commandTimeoutSec);
                    }
                    endDateTime = DateTime.Now;
                    returnDT.Load(dr);
                }
                return returnDT;
            }
            catch (Exception ex)
            {
                endDateTime = DateTime.Now;
                sb.AppendLine("ExecSqlcommand start Exception = " + ex.Message);
                sb.AppendLine(ex.StackTrace);
                sb.AppendLine("ExecSqlcommand end Exception");
                return null;
            }
            finally
            {
                sb.AppendLine("Exec Start = " + startDateTime.ToString("yyyy/MM/dd HH:mm:ss.fff"));
                sb.AppendLine("Exec End = " + endDateTime.ToString("yyyy/MM/dd HH:mm:ss.fff"));

                //C#的日期型態可直接相減並傳回TimeSpan物件
                TimeSpan ts = endDateTime - startDateTime;
                //時間差換算成秒 String s1 = ts.TotalSeconds.ToString();
                //時間差換算成分 String s2 = ts.TotalMinutes.ToString();
                sb.AppendLine($"Exec diff = {ts.TotalSeconds.ToString()}秒");
            }
        }


        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                sb.Clear();
                DataTable dt = ExecSqlcommand();
                sb.AppendLine("Result = ");
                if (dt != null)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        sb.AppendLine(string.Join(",", dr.ItemArray));
                    }
                }
                txtResult.Text = sb.ToString();
            }
            catch (Exception ex)
            {
                txtResult.Text = ex.ToString() + "\r\n" + ex.StackTrace;
            }
        }
    }
}
