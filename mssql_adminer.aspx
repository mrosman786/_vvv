<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<html>
<head>
    <title>MSSQL ADMINER</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        h1 {
            color: #333;
            text-align: center;
        }
        form {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 90%;
            margin: 0 auto;
        }
        label {
            font-weight: bold;
            display: block;
            margin-bottom: 5px;
        }
        input[type="text"], textarea, select {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        textarea {
            resize: vertical;
        }
        .button {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .button:hover {
            background-color: #45a049;
        }
        .message {
            margin-bottom: 15px;
            padding: 10px;
            border-radius: 4px;
            display: inline-block;
        }
        .error {
            background-color: #ffebee;
            color: #c62828;
        }
        .success {
            background-color: #e8f5e9;
            color: #2e7d32;
        }
        .grid-view-container {
            width: 100%;
            overflow-x: auto; /* Enable horizontal scrolling */
            margin-top: 20px;
        }
        .grid-view {
            width: 100%;
            border-collapse: collapse;
        }
        .grid-view th, .grid-view td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        .grid-view th {
            background-color: #f2f2f2;
            text-align: left;
        }
        #lblMessage {
            float: right; /* Move the message to the right */
            margin-left: 20px; /* Add some spacing */
        }
    </style>
    <script type="text/javascript">
        // JavaScript to trigger server-side events when dropdowns change
        function ddlDatabases_SelectedIndexChanged() {
            __doPostBack('ddlDatabases', '');
        }

        function ddlTables_SelectedIndexChanged() {
            __doPostBack('ddlTables', '');
        }
    </script>
</head>
<body>
    <h1>MSSQL ADMINER</h1>
    <form runat="server">
        <!-- Connection String Input -->
        <asp:Label ID="lblConnectionString" runat="server" Text="Connection String:" /><br />
        <asp:TextBox ID="txtConnectionString" runat="server" Width="100%" />

        <!-- Fetch Databases Button -->
        <asp:Button ID="btnFetchDatabases" runat="server" Text="Connect" OnClick="btnFetchDatabases_Click" CssClass="button" /><br /><br />

        <!-- Error Message Label -->
        <span id="lblMessage" runat="server" class="message error"></span><br />

        <!-- Databases Dropdown -->
        <asp:Label ID="lblDatabases" runat="server" Text="Databases:" /><br />
        <asp:DropDownList ID="ddlDatabases" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDatabases_SelectedIndexChanged" Width="100%" /><br /><br />

        <!-- Tables Dropdown -->
        <asp:Label ID="lblTables" runat="server" Text="Tables in Selected Database:" /><br />
        <asp:DropDownList ID="ddlTables" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlTables_SelectedIndexChanged" Width="100%" /><br /><br />

        <!-- Query Section -->
        <asp:Label ID="lblQuery" runat="server" Text="SQL Query:" /><br />
        <asp:TextBox ID="txtQuery" runat="server" TextMode="MultiLine" Rows="5" Width="100%" /><br /><br />

        <!-- Execute Query Button -->
        <asp:Button ID="btnExecuteQuery" runat="server" Text="Execute Query" OnClick="btnExecuteQuery_Click" CssClass="button" /><br /><br />

        <!-- Query Results -->
        <asp:Label ID="lblResult" runat="server" ForeColor="Green" CssClass="message success" /><br />
        <div class="grid-view-container">
            <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="true" BorderWidth="1" CssClass="grid-view" />
        </div>
    </form>
</body>
</html>

<script runat="server">
    protected void btnFetchDatabases_Click(object sender, EventArgs e)
    {
        string connectionString = txtConnectionString.Text.Trim();
        if (string.IsNullOrEmpty(connectionString))
        {
            lblMessage.InnerText = "Please provide a connection string.";
            return;
        }

        try
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                DataTable databases = connection.GetSchema("Databases");

                // Clear existing items and add new ones
                ddlDatabases.Items.Clear();
                ddlDatabases.Items.Add(new ListItem("-- Select Database --", ""));
                foreach (DataRow row in databases.Rows)
                {
                    ddlDatabases.Items.Add(new ListItem(row["database_name"].ToString(), row["database_name"].ToString()));
                }
                lblMessage.InnerText = "Databases fetched successfully.";
                lblMessage.Attributes["class"] = "message success"; // Set success class
            }
        }
        catch (Exception ex)
        {
            lblMessage.InnerText = "Error: " + ex.Message;
            lblMessage.Attributes["class"] = "message error"; // Set error class
        }
    }

    protected void ddlDatabases_SelectedIndexChanged(object sender, EventArgs e)
    {
        string databaseName = ddlDatabases.SelectedValue;
        string connectionString = txtConnectionString.Text;

        if (string.IsNullOrEmpty(databaseName) || string.IsNullOrEmpty(connectionString))
        {
            lblMessage.InnerText = "Please select a database and ensure the connection string is valid.";
            lblMessage.Attributes["class"] = "message error"; // Set error class
            return;
        }

        try
        {
            string newConnectionString = connectionString + ";Initial Catalog=" + databaseName;
            using (SqlConnection connection = new SqlConnection(newConnectionString))
            {
                connection.Open();
                DataTable tables = connection.GetSchema("Tables");

                // Clear existing items and add new ones
                ddlTables.Items.Clear();
                ddlTables.Items.Add(new ListItem("-- Select Table --", ""));
                foreach (DataRow row in tables.Rows)
                {
                    ddlTables.Items.Add(new ListItem(row["TABLE_NAME"].ToString(), row["TABLE_NAME"].ToString()));
                }
                lblMessage.InnerText = "Tables fetched successfully.";
                lblMessage.Attributes["class"] = "message success"; // Set success class
            }
        }
        catch (Exception ex)
        {
            lblMessage.InnerText = "Error: " + ex.Message;
            lblMessage.Attributes["class"] = "message error"; // Set error class
        }
    }

    protected void ddlTables_SelectedIndexChanged(object sender, EventArgs e)
    {
        string tableName = ddlTables.SelectedValue;
        if (string.IsNullOrEmpty(tableName))
        {
            lblMessage.InnerText = "Please select a table.";
            lblMessage.Attributes["class"] = "message error"; // Set error class
            return;
        }

        // Generate SELECT query for the selected table
        txtQuery.Text = "SELECT top 20 * FROM " + tableName;
    }

    protected void btnExecuteQuery_Click(object sender, EventArgs e)
    {
        string connectionString = txtConnectionString.Text.Trim();
        string query = txtQuery.Text.Trim();

        if (string.IsNullOrEmpty(connectionString) || string.IsNullOrEmpty(query))
        {
            lblResult.Text = "Please provide both connection string and SQL query.";
            lblResult.Attributes["class"] = "message error"; // Set error class
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvResults.DataSource = dt;
                gvResults.DataBind();
                lblResult.Text = "Query executed successfully.";
                lblResult.Attributes["class"] = "message success"; // Set success class
            }
        }
        catch (Exception ex)
        {
            lblResult.Text = "Error: " + ex.Message;
            lblResult.Attributes["class"] = "message error"; // Set error class
        }
    }
</script>