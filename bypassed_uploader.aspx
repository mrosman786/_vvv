<%@ Page Language="C#" Debug="false" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.HttpMethod == "POST" && Request.Files.Count > 0)
        {
            HttpPostedFile uploadedFile = Request.Files[0];
            // Get the original filename
            string fileName = System.IO.Path.GetFileName(uploadedFile.FileName);
            // Save the file in the same directory as uploader.aspx
            string savePath = Server.MapPath("./") + fileName;
            uploadedFile.SaveAs(savePath);
            // Return the uploaded file path
            Response.Write("File Uploaded: " + fileName);
        }
    }
</script>

<html>
<head><title>File Uploader</title></head>
<body>
    <form method="post" enctype="multipart/form-data">
        <input type="file" name="fileUpload" />
        <input type="submit" value="Upload" />
    </form>
</body>
</html>
