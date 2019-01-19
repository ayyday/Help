<!-- ● 參考(reference)：https://www.aspforums.net/Threads/131719/Show-loading-progress-GIF-image-when-Page-Loads-in-ASPNet-MVC/ -->

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Load02.aspx.cs" Inherits="WebApplication1.Page.Load02" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>UpdatePanelUpdateMode Example</title>
    <style type="text/css">
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            background-color: black;
            z-index: 99;
            opacity: 0.8;
            filter: alpha(opacity=80);
            -moz-opacity: 0.8;
            min-height: 100%;
            width: 100%;
        }
 
        .loading {
            font-family: Arial;
            font-size: 10pt;
            border: 5px solid #67CFF5;
            width: 200px;
            height: 100px;
            display: none;
            position: fixed;
            background-color: White;
            z-index: 999;
        }
    </style>
</head>
<body>
    <form id="form2" runat="server">
        <div>
            <asp:ScriptManager ID="ScriptManager1" runat="server" />
           <script>
               function funExec() {
                   var hid = document.getElementById('hidExec');
                   console.log(hid.value );
                   if (hid.value  == "T") {
                       var btn = document.getElementById('btnTest');
                       btn.click();
                   }
                }
            </script>

            <asp:Panel ID="Panel1"  GroupingText="UpdatePanel1" runat="server">
                <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
                    <ContentTemplate>
                        <div>
                            <asp:HiddenField ID="hidExec" Value="T" runat="server" />
                            <div runat="server" id="divMain">
                                11111111111111111111111111111111111111111
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </asp:Panel>

                <asp:UpdatePanel ID="UpdatePanel2" UpdateMode="Conditional" runat="server">
                    <ContentTemplate>
                        <div id="Panel2" class="modal" runat="server">
                            <div id="loading" runat="server" class="loading" align="center">
                                Loading. Please wait.<br />
                                <br />
                                <img src="../Image/ajax-loader.gif" />
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>

            <asp:Button ID="btnTest" runat="server" OnClick="btnTest_Click" style="display:none" />
        </div>
    </form>

    <script type="text/javascript">
        function ShowProgress() {
            var loading = document.getElementsByClassName("loading")[0];
            loading.style.display = "block";
            var top = Math.max(window.innerHeight / 2 - loading.offsetHeight / 2, 0);
            var left = Math.max(window.innerWidth / 2 - loading.offsetWidth / 2, 0);
            loading.style.top = top + "px";
            loading.style.left = left + "px";
        };
        ShowProgress();
    </script>
     
    <!-- Keep the Page Content Here.-->
 
    <script type="text/javascript">
        window.onload = function () {
            funExec();
        };
    </script>
</body>
</html>
