<?php
$serverName = "localhost";

$connectionOptions = [
    "Database" => "StudentFeedbackSystem",
    "TrustServerCertificate" => true
];

$conn = sqlsrv_connect($serverName, $connectionOptions);

if ($conn) {
    echo "SQL Server connected to StudentFeedbackSystem successfully!";
} else {
    echo "Connection failed:<br>";
    die(print_r(sqlsrv_errors(), true));
}
?>