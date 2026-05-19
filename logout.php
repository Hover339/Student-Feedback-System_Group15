<?php
session_start();
include 'db.php';

if (isset($_SESSION['user_id'])) {
    // ADDed LOGOUT event to audit logs
    logEvent($conn, $_SESSION['user_id'], 'LOGOUT', "User logged out successfully.");
}

session_unset();
session_destroy();
header("Location: login.php");
exit();
?>