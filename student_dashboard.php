<?php
session_start();
include 'db.php';

if (!isset($_SESSION['user_id']) || $_SESSION['role'] != 'student') {
    if (isset($_SESSION['user_id'])) {
        logEvent(
            $conn,
            $_SESSION['user_id'],
            'UNAUTHORIZED_ACCESS',
            "User tried to access student dashboard without permission."
        );
    }

    header("Location: login.php");
    exit();
}

logEvent(
    $conn,
    $_SESSION['user_id'],
    'DASHBOARD_ACCESS',
    "Student accessed their dashboard."
);
?>

<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard</title>

    <style>
        body {
            margin: 0;
            font-family: Arial;
            background: linear-gradient(to right, #4facfe, #00f2fe);
            min-height: 100vh;
        }

        .navbar {
            background: white;
            padding: 15px 30px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.15);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar h2 {
            margin: 0;
            color: #333;
        }

        .logout {
            text-decoration: none;
            background: #e74c3c;
            color: white;
            padding: 10px 18px;
            border-radius: 5px;
        }

        .logout:hover {
            background: #c0392b;
        }

        .container {
            width: 80%;
            max-width: 900px;
            margin: 60px auto;
            background: white;
            padding: 35px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
            text-align: center;
        }

        .container h1 {
            margin-bottom: 10px;
            color: #333;
        }

        .container p {
            color: #666;
            margin-bottom: 35px;
        }

        .card-container {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .card {
            width: 230px;
            padding: 25px;
            border-radius: 10px;
            background: #f7f9fc;
            box-shadow: 0 3px 8px rgba(0,0,0,0.1);
            text-decoration: none;
            color: #333;
            transition: 0.3s;
        }

        .card:hover {
            transform: translateY(-5px);
            background: #eef6ff;
        }

        .card h3 {
            margin-bottom: 10px;
            color: #2196F3;
        }

        .card p {
            font-size: 14px;
            margin: 0;
            color: #555;
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>Student Feedback System</h2>
    <a class="logout" href="logout.php">Logout</a>
</div>

<div class="container">
    <h1>Student Dashboard</h1>
    <p>Welcome to the Student Feedback System. Please select one of the options below to proceed.</p>

    <div class="card-container">
        <a href="submit_feedback.php" class="card">
            <h3>Submit Feedback</h3>
            <p>Create a new complaint, suggestion, or feedback report.</p>
        </a>

        <a href="my_feedback.php" class="card">
            <h3>My Feedback</h3>
            <p>View your submitted feedback and check status updates.</p>
        </a>
    </div>
</div>

</body>
</html>