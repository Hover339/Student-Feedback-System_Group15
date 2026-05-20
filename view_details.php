<?php
session_start();
include 'db.php';

// Student-only access check
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'student') {
    header("Location: login.php");
    exit();
}

$user_id = intval($_SESSION['user_id']);
$feedback_id = isset($_GET['id']) ? intval($_GET['id']) : 0;

if ($feedback_id <= 0) {
    header("Location: my_feedback.php");
    exit();
}

/*
|--------------------------------------------------------------------------
| Fetch feedback details
|--------------------------------------------------------------------------
| Security:
| - Uses prepared query with parameters
| - Checks feedback_id AND user_id
| - Prevents students from viewing other students' feedback
|--------------------------------------------------------------------------
*/
$sql = "SELECT title, description, category, type, status, admin_response, created_at, updated_at
        FROM feedback
        WHERE feedback_id = ? AND user_id = ?";

$params = [$feedback_id, $user_id];

$stmt = sqlsrv_query($conn, $sql, $params);

$feedback = null;

if ($stmt) {
    $feedback = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
}

if (!$feedback) {
    logEvent(
        $conn,
        $user_id,
        'UNAUTHORIZED_ACCESS',
        "Student attempted to view feedback_id: {$feedback_id}"
    );

    header("Location: my_feedback.php");
    exit();
}

// Decrypt sensitive fields only after ownership has been verified
$feedback['description'] = decryptSensitiveData($feedback['description']);
$feedback['admin_response'] = decryptSensitiveData($feedback['admin_response']);

logEvent(
    $conn,
    $user_id,
    'FEEDBACK_DETAIL_VIEWED',
    "Student viewed feedback_id: {$feedback_id}"
);
?>

<!DOCTYPE html>
<html>
<head>
    <title>Feedback Details</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
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
            max-width: 800px;
            margin: 40px auto;
            background: white;
            padding: 35px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .back-link {
            color: #2196F3;
            text-decoration: none;
            font-weight: bold;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        h1 {
            color: #333;
            margin-top: 25px;
        }

        .row {
            margin: 18px 0;
        }

        .label {
            font-weight: bold;
            color: #444;
            margin-bottom: 6px;
        }

        .value {
            background: #f7f9fc;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #e0e7ef;
            line-height: 1.5;
        }

        .badge {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 5px;
            font-weight: bold;
            font-size: 13px;
        }

        .Pending {
            background: #fff3cd;
            color: #856404;
        }

        .InProgress {
            background: #cce5ff;
            color: #004085;
        }

        .Resolved {
            background: #d4edda;
            color: #155724;
        }

        .Rejected {
            background: #f8d7da;
            color: #721c24;
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>Student Feedback System</h2>
    <a class="logout" href="logout.php">Logout</a>
</div>

<div class="container">
    <a href="my_feedback.php" class="back-link">← Back to My Feedback</a>

    <h1>Feedback Details</h1>

    <div class="row">
        <div class="label">Title</div>
        <div class="value"><?php echo htmlspecialchars($feedback['title']); ?></div>
    </div>

    <div class="row">
        <div class="label">Category</div>
        <div class="value"><?php echo htmlspecialchars($feedback['category']); ?></div>
    </div>

    <div class="row">
        <div class="label">Type</div>
        <div class="value"><?php echo htmlspecialchars($feedback['type']); ?></div>
    </div>

    <div class="row">
        <div class="label">Status</div>
        <?php $badgeClass = str_replace(' ', '', $feedback['status']); ?>
        <span class="badge <?php echo htmlspecialchars($badgeClass); ?>">
            <?php echo htmlspecialchars($feedback['status']); ?>
        </span>
    </div>

    <div class="row">
        <div class="label">Description</div>
        <div class="value"><?php echo nl2br(htmlspecialchars($feedback['description'])); ?></div>
    </div>

    <div class="row">
        <div class="label">Admin Response</div>
        <div class="value">
            <?php
            if (!empty($feedback['admin_response'])) {
                echo nl2br(htmlspecialchars($feedback['admin_response']));
            } else {
                echo "No admin response yet.";
            }
            ?>
        </div>
    </div>

    <div class="row">
        <div class="label">Created At</div>
        <div class="value"><?php echo htmlspecialchars($feedback['created_at']); ?></div>
    </div>

    <div class="row">
        <div class="label">Updated At</div>
        <div class="value"><?php echo htmlspecialchars($feedback['updated_at']); ?></div>
    </div>
</div>

</body>
</html>

<?php
sqlsrv_close($conn);
?>