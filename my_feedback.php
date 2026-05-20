<?php
session_start();
include 'db.php';

// Student-only access check
if (!isset($_SESSION['user_id']) || !isset($_SESSION['role']) || $_SESSION['role'] !== 'student') {
    header("Location: login.php");
    exit();
}

$user_id = intval($_SESSION['user_id']);
$message = "";

// Generate CSRF token
$csrfToken = generateCsrfToken();

$allowedTypes = ['Complaint', 'Feedback', 'Suggestion'];
$allowedCategories = ['Academic', 'Facilities', 'Hostel', 'IT', 'Student Affairs', 'Others'];

/*
|--------------------------------------------------------------------------
| Handle Delete Feedback
|--------------------------------------------------------------------------
*/
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['delete_feedback_id'])) {
    $feedback_id = intval($_POST['delete_feedback_id']);
    $csrf_token = $_POST['csrf_token'] ?? '';

    if (!validateCsrfToken($csrf_token)) {
        logEvent($conn, $user_id, 'CSRF_FAILED', 'Invalid CSRF token during feedback deletion.');
        $message = "Invalid request. Please refresh the page and try again.";
    } else {
        $checkSql = "SELECT title FROM feedback WHERE feedback_id = ? AND user_id = ?";
        $checkStmt = sqlsrv_query($conn, $checkSql, [$feedback_id, $user_id]);

        $feedback = null;

        if ($checkStmt) {
            $feedback = sqlsrv_fetch_array($checkStmt, SQLSRV_FETCH_ASSOC);
        }

        if ($feedback) {
            $feedbackTitle = $feedback['title'];

            $deleteSql = "DELETE FROM feedback WHERE feedback_id = ? AND user_id = ?";
            $deleteStmt = sqlsrv_query($conn, $deleteSql, [$feedback_id, $user_id]);

            if ($deleteStmt) {
                logEvent(
                    $conn,
                    $user_id,
                    'FEEDBACK_DELETED',
                    "Student deleted feedback_id: {$feedback_id}, title: {$feedbackTitle}"
                );

                $message = "Feedback deleted successfully.";
            } else {
                $message = "Unable to delete feedback. Please try again.";
            }
        } else {
            logEvent(
                $conn,
                $user_id,
                'UNAUTHORIZED_DELETE_ATTEMPT',
                "Student attempted to delete feedback_id: {$feedback_id} without ownership."
            );

            $message = "Invalid feedback record or permission denied.";
        }
    }
}

/*
|--------------------------------------------------------------------------
| Handle Modify Feedback
|--------------------------------------------------------------------------
| Only Pending feedback can be modified.
|--------------------------------------------------------------------------
*/
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['modify_feedback_id'])) {
    $feedback_id = intval($_POST['modify_feedback_id']);
    $csrf_token = $_POST['csrf_token'] ?? '';

    $new_type = isset($_POST['type']) ? trim($_POST['type']) : '';
    $new_category = isset($_POST['category']) ? trim($_POST['category']) : '';
    $new_title = isset($_POST['title']) ? trim($_POST['title']) : '';
    $new_description = isset($_POST['description']) ? trim($_POST['description']) : '';

    if (!validateCsrfToken($csrf_token)) {
        logEvent($conn, $user_id, 'CSRF_FAILED', 'Invalid CSRF token during feedback modification.');
        $message = "Invalid request. Please refresh the page and try again.";
    } elseif (!in_array($new_type, $allowedTypes, true)) {
        $message = "Invalid feedback type.";
    } elseif (!in_array($new_category, $allowedCategories, true)) {
        $message = "Invalid feedback category.";
    } elseif ($new_title === '' || $new_description === '') {
        $message = "Title and description cannot be empty.";
    } else {
        // Check ownership and status before modifying
        $checkSql = "SELECT title, status FROM feedback WHERE feedback_id = ? AND user_id = ?";
        $checkStmt = sqlsrv_query($conn, $checkSql, [$feedback_id, $user_id]);

        $feedback = null;

        if ($checkStmt) {
            $feedback = sqlsrv_fetch_array($checkStmt, SQLSRV_FETCH_ASSOC);
        }

        if (!$feedback) {
            logEvent(
                $conn,
                $user_id,
                'UNAUTHORIZED_MODIFY_ATTEMPT',
                "Student attempted to modify feedback_id: {$feedback_id} without ownership."
            );

            $message = "Invalid feedback record or permission denied.";
        } elseif ($feedback['status'] !== 'Pending') {
            $message = "Only feedback with Pending status can be modified.";
        } else {
            $encryptedDescription = encryptSensitiveData($new_description);

            $updateSql = "UPDATE feedback
                          SET type = ?, 
                              category = ?, 
                              title = ?, 
                              description = ?, 
                              updated_at = GETDATE()
                          WHERE feedback_id = ? 
                          AND user_id = ? 
                          AND status = 'Pending'";

            $updateParams = [
                $new_type,
                $new_category,
                $new_title,
                $encryptedDescription,
                $feedback_id,
                $user_id
            ];

            $updateStmt = sqlsrv_query($conn, $updateSql, $updateParams);

            if ($updateStmt) {
                logEvent(
                    $conn,
                    $user_id,
                    'FEEDBACK_MODIFIED',
                    "Student modified feedback_id: {$feedback_id}. Description encrypted before database update."
                );

                $message = "Feedback modified successfully.";
            } else {
                $message = "Unable to modify feedback. Please try again.";
            }
        }
    }
}

/*
|--------------------------------------------------------------------------
| Fetch Student Feedback
|--------------------------------------------------------------------------
*/
$query = "SELECT feedback_id, created_at, category, type, title, description, status
          FROM feedback
          WHERE user_id = ?
          ORDER BY created_at DESC";

$stmt = sqlsrv_query($conn, $query, [$user_id]);

$feedbackRows = [];

if ($stmt) {
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        $feedbackRows[] = $row;
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Feedback - Student Feedback System</title>

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
            width: 95%;
            max-width: 1200px;
            margin: 40px auto;
            background: white;
            padding: 35px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #2196F3;
            text-decoration: none;
            font-weight: bold;
            font-size: 14px;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        h1 {
            margin-top: 0;
            color: #333;
        }

        .message {
            margin-bottom: 20px;
            padding: 14px 18px;
            border-radius: 8px;
            background: #f0f8ff;
            color: #1a6fb3;
            border: 1px solid #d3e6f7;
        }

        .top-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .submit-btn {
            text-decoration: none;
            background: #2196F3;
            color: white;
            padding: 10px 18px;
            border-radius: 6px;
            font-weight: bold;
        }

        .submit-btn:hover {
            background: #1976D2;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        th, td {
            padding: 13px 12px;
            text-align: left;
            border-bottom: 1px solid #e0e7ef;
            font-size: 14px;
            vertical-align: top;
        }

        th {
            background: #f5f8fb;
            color: #333;
            font-weight: bold;
        }

        tr:hover {
            background: #fbfcff;
        }

        .badge {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 5px;
            font-size: 12px;
            font-weight: bold;
        }

        .status-Pending {
            background: #fff3cd;
            color: #856404;
        }

        .status-In-Progress {
            background: #cce5ff;
            color: #004085;
        }

        .status-Resolved {
            background: #d4edda;
            color: #155724;
        }

        .status-Rejected {
            background: #f8d7da;
            color: #721c24;
        }

        .action-group {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }

        .view-btn {
            text-decoration: none;
            background: #4CAF50;
            color: white;
            padding: 8px 12px;
            border-radius: 5px;
            font-size: 13px;
            border: none;
            cursor: pointer;
        }

        .view-btn:hover {
            background: #45a049;
        }

        .modify-btn {
            background: #ff9800;
            color: white;
            padding: 8px 12px;
            border-radius: 5px;
            font-size: 13px;
            border: none;
            cursor: pointer;
        }

        .modify-btn:hover {
            background: #e68900;
        }

        .delete-btn {
            background: #e74c3c;
            color: white;
            padding: 8px 12px;
            border-radius: 5px;
            font-size: 13px;
            border: none;
            cursor: pointer;
        }

        .delete-btn:hover {
            background: #c0392b;
        }

        .empty-box {
            text-align: center;
            padding: 35px;
            color: #666;
            background: #f7f9fc;
            border-radius: 10px;
            margin-top: 20px;
        }

        .edit-box {
            margin-top: 12px;
            padding: 15px;
            background: #f7f9fc;
            border: 1px solid #e0e7ef;
            border-radius: 8px;
            display: none;
        }

        .edit-box input,
        .edit-box select,
        .edit-box textarea {
            width: 100%;
            padding: 9px;
            margin: 7px 0 12px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        .save-btn {
            background: #2196F3;
            color: white;
            padding: 9px 14px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .save-btn:hover {
            background: #1976D2;
        }

        .cancel-edit-btn {
            background: #777;
            color: white;
            padding: 9px 14px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-left: 8px;
        }

        .cancel-edit-btn:hover {
            background: #555;
        }

        .note {
            font-size: 12px;
            color: #777;
            margin-top: 6px;
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>Student Feedback System</h2>
    <a class="logout" href="logout.php">Logout</a>
</div>

<div class="container">
    <a href="student_dashboard.php" class="back-link">← Back to Dashboard</a>

    <div class="top-actions">
        <div>
            <h1>My Feedback</h1>
            <p>View, modify, track, or delete your submitted feedback records.</p>
            <p class="note">Note: Feedback can only be modified while its status is Pending.</p>
        </div>

        <a href="submit_feedback.php" class="submit-btn">Submit New Feedback</a>
    </div>

    <?php if (!empty($message)): ?>
        <div class="message"><?php echo htmlspecialchars($message); ?></div>
    <?php endif; ?>

    <?php if (!empty($feedbackRows)): ?>
        <table>
            <thead>
                <tr>
                    <th>Date Submitted</th>
                    <th>Type</th>
                    <th>Category</th>
                    <th>Subject</th>
                    <th>Status</th>
                    <th style="width: 250px;">Action</th>
                </tr>
            </thead>

            <tbody>
                <?php foreach ($feedbackRows as $row): ?>
                    <?php
                        $decryptedDescription = decryptSensitiveData($row['description']);
                        $editBoxId = "edit-box-" . intval($row['feedback_id']);
                    ?>

                    <tr>
                        <td>
                            <?php echo htmlspecialchars(date("M d, Y", strtotime($row['created_at']))); ?>
                        </td>

                        <td>
                            <?php echo htmlspecialchars($row['type']); ?>
                        </td>

                        <td>
                            <?php echo htmlspecialchars($row['category']); ?>
                        </td>

                        <td>
                            <strong><?php echo htmlspecialchars($row['title']); ?></strong>
                        </td>

                        <td>
                            <?php
                            $statusClass = "status-" . str_replace(" ", "-", $row['status']);
                            ?>
                            <span class="badge <?php echo htmlspecialchars($statusClass); ?>">
                                <?php echo htmlspecialchars($row['status']); ?>
                            </span>
                        </td>

                        <td>
                            <div class="action-group">
                                <a 
                                    href="view_details.php?id=<?php echo urlencode($row['feedback_id']); ?>" 
                                    class="view-btn"
                                >
                                    View
                                </a>

                                <?php if ($row['status'] === 'Pending'): ?>
                                    <button 
                                        type="button" 
                                        class="modify-btn"
                                        onclick="toggleEditBox('<?php echo $editBoxId; ?>')"
                                    >
                                        Modify
                                    </button>
                                <?php endif; ?>

                                <form method="POST" action="my_feedback.php" onsubmit="return confirm('Are you sure you want to delete this feedback?');">
                                    <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($csrfToken); ?>">
                                    <input type="hidden" name="delete_feedback_id" value="<?php echo htmlspecialchars($row['feedback_id']); ?>">
                                    <button type="submit" class="delete-btn">Delete</button>
                                </form>
                            </div>

                            <?php if ($row['status'] === 'Pending'): ?>
                                <div id="<?php echo $editBoxId; ?>" class="edit-box">
                                    <form method="POST" action="my_feedback.php">
                                        <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($csrfToken); ?>">
                                        <input type="hidden" name="modify_feedback_id" value="<?php echo htmlspecialchars($row['feedback_id']); ?>">

                                        <label>Feedback Type</label>
                                        <select name="type" required>
                                            <?php foreach ($allowedTypes as $typeOption): ?>
                                                <option value="<?php echo htmlspecialchars($typeOption); ?>" 
                                                    <?php echo $row['type'] === $typeOption ? 'selected' : ''; ?>>
                                                    <?php echo htmlspecialchars($typeOption); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>

                                        <label>Category</label>
                                        <select name="category" required>
                                            <?php foreach ($allowedCategories as $categoryOption): ?>
                                                <option value="<?php echo htmlspecialchars($categoryOption); ?>" 
                                                    <?php echo $row['category'] === $categoryOption ? 'selected' : ''; ?>>
                                                    <?php echo htmlspecialchars($categoryOption); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>

                                        <label>Title</label>
                                        <input 
                                            type="text" 
                                            name="title" 
                                            value="<?php echo htmlspecialchars($row['title']); ?>" 
                                            required
                                        >

                                        <label>Description</label>
                                        <textarea name="description" rows="4" required><?php echo htmlspecialchars($decryptedDescription); ?></textarea>

                                        <button type="submit" class="save-btn">Save Changes</button>
                                        <button type="button" class="cancel-edit-btn" onclick="toggleEditBox('<?php echo $editBoxId; ?>')">Cancel</button>
                                    </form>
                                </div>
                            <?php endif; ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php else: ?>
        <div class="empty-box">
            <h3>No feedback found</h3>
            <p>You have not submitted any feedback yet.</p>
            <a href="submit_feedback.php" class="submit-btn">Submit Your First Feedback</a>
        </div>
    <?php endif; ?>
</div>

<script>
function toggleEditBox(id) {
    const box = document.getElementById(id);

    if (box.style.display === "block") {
        box.style.display = "none";
    } else {
        box.style.display = "block";
    }
}
</script>

</body>
</html>

<?php
sqlsrv_close($conn);
?>