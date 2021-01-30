<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "nts";

$conn = mysqli_connect($servername, $username, $password, $dbname);
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
if($conn){
	echo "yes";
}

$result = mysqli_query($conn,"show tables"); // run the query and assign the result to $result
while($table = mysqli_fetch_array($result)) { // go through each row that was returned in $result
    echo($table[0] . "<BR>");    // print the table that was returned on that row.
}


?>
