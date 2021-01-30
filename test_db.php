<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "nts";

$conn = new mysqli($servername, $username, $password, $dbname);
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$sql = "select table_schema,0x3a,table_name,0x3a,column_name from information_schema.columns";

$result = mysqli_query($conn, $sql);

while($row = mysqli_fetch_array($result))
		{
			print_r($row);
		}


?>
