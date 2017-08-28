<?php
$username = "thoughts_ga6840";
$password = "xxxxxxxxxxxxx";
$hostname = "localhost";

//connection to the database
$db = mysqli_connect($hostname, $username, $password)
  or die("Unable to connect to MySQL");

echo "Connected to MySQL<br>";

$result = mysqli_query($db,
	"select * from information_schema.tables ".
	"group by engine"
);

while ($row = mysqli_fetch_array($result, MYSQLI_ASSOC)) {
      echo $row{'TABLE_NAME'}."'s engine is ".$row{'ENGINE'}."<br>";
}

mysqli_close($db);
?>
