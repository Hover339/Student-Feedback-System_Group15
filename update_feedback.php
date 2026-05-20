<?php
session_start();
include 'db.php';

// Admin-only access check
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header('Location: login.php');
    exit();
}

$message = '';
$allowedStatuses = ['Pending', 'In Progress', 'Resolved', 'Rejected'];

/*
|--------------------------------------------------------------------------
| Handle feedback status/response update
|--------------------------------------------------------------------------
*/
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['feedback_id'], $_POST['status'])) {
    $csrf_token = $_POST['csrf_token'] ?? '';

    if (!validateCsrfToken($csrf_token)) {
        logEvent($conn, $_SESSION['user_id'], 'CSRF_FAILED', 'Invalid CSRF token during feedback update.');
        $message = 'Invalid request. Please refresh the page and try again.';
    } else {
        $feedback_id = intval($_POST['feedback_id']);
        $new_status = $_POST['status'];
        $new_response_plain = isset($_POST['admin_response']) ? trim($_POST['admin_response']) : '';

        if ($feedback_id > 0 && in_array($new_status, $allowedStatuses, true)) {
            $selectSql = "SELECT status, admin_response 
                          FROM feedback 
                          WHERE feedback_id = ?";

            $selectStmt = sqlsrv_query($conn, $selectSql, [$feedback_id]);

            $current = null;

            if ($selectStmt) {
                $current = sqlsrv_fetch_array($selectStmt, SQLSRV_FETCH_ASSOC);
            }

            if ($current) {
                $current_status = $current['status'];
                $current_response_plain = decryptSensitiveData($current['admin_response']);

                $needsUpdate = ($current_status !== $new_status) || (($current_response_plain ?? '') !== $new_response_plain);

                if ($needsUpdate) {
                    $db_response = ($new_response_plain === '') ? null : encryptSensitiveData($new_response_plain);

                    $updateSql = "UPDATE feedback
                                  SET status = ?, 
                                      admin_response = ?, 
                                      updated_at = GETDATE()
                                  WHERE feedback_id = ?";

                    $updateStmt = sqlsrv_query($conn, $updateSql, [
                        $new_status,
                        $db_response,
                        $feedback_id
                    ]);

                    if ($updateStmt) {
                        logEvent(
                            $conn,
                            $_SESSION['user_id'],
                            'FEEDBACK_UPDATED',
                            "Admin updated feedback_id: {$feedback_id}. Status changed from '{$current_status}' to '{$new_status}'. Admin response encrypted before database storage."
                        );

                        $message = 'Feedback updated successfully.';
                    } else {
                        $message = 'Unable to update feedback at this time.';
                    }
                } else {
                    $message = 'No changes were made because status and response are unchanged.';
                }
            } else {
                $message = 'Feedback entry not found.';
            }
        } else {
            $message = 'Invalid feedback ID or status provided.';
        }
    }
}

/*
|--------------------------------------------------------------------------
| Log admin viewing full feedback management list
|--------------------------------------------------------------------------
*/
$countSql = "SELECT COUNT(*) AS total FROM feedback";
$countStmt = sqlsrv_query($conn, $countSql);

$totalFeedback = 0;

if ($countStmt) {
    $countRow = sqlsrv_fetch_array($countStmt, SQLSRV_FETCH_ASSOC);
    if ($countRow) {
        $totalFeedback = intval($countRow['total']);
    }
}

logEvent(
    $conn,
    $_SESSION['user_id'],
    'FEEDBACK_LIST_VIEWED',
    "Admin viewed the full feedback management list. Total records available: {$totalFeedback}"
);

/*
|--------------------------------------------------------------------------
| Fetch all feedback records for admin table
|--------------------------------------------------------------------------
*/
$feedbackItems = [];

$feedbackSql = "SELECT feedback_id, user_id, title, description, category, type, status, admin_response, created_at, updated_at
                FROM feedback
                ORDER BY created_at DESC";

$feedbackStmt = sqlsrv_query($conn, $feedbackSql);

if ($feedbackStmt) {
    while ($row = sqlsrv_fetch_array($feedbackStmt, SQLSRV_FETCH_ASSOC)) {
        $row['description'] = decryptSensitiveData($row['description']);
        $row['admin_response'] = decryptSensitiveData($row['admin_response']);

        $feedbackItems[] = $row;
    }
}

$csrfToken = generateCsrfToken();
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Feedback</title>

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

        .nav-links {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .nav-link {
            text-decoration: none;
            color: #333;
            padding: 10px 16px;
            border-radius: 8px;
            transition: background 0.2s ease;
        }

        .nav-link:hover {
            background: rgba(0, 0, 0, 0.05);
        }

        .logout {
            text-decoration: none;
            background: #e74c3c;
            color: white;
            padding: 10px 18px;
            border-radius: 5px;
            font-weight: bold;
        }

        .logout:hover {
            background: #c0392b;
        }

        .container {
            width: 95%;
            max-width: 1400px;
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

        .container h1 {
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

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            padding: 12px 10px;
            text-align: left;
            border-bottom: 1px solid #e0e7ef;
            vertical-align: middle;
            font-size: 14px;
        }

        th {
            background: #f5f8fb;
            color: #333;
            font-weight: 600;
        }

        tr:hover {
            background: #fbfcff;
        }

        select {
            width: 100%;
            padding: 8px 10px;
            border: 1px solid #ccd6df;
            border-radius: 6px;
            background: #fff;
            color: #333;
        }

        textarea {
            width: 100%;
            height: 60px;
            padding: 8px;
            border: 1px solid #ccd6df;
            border-radius: 6px;
            resize: vertical;
            font-family: Arial, sans-serif;
            box-sizing: border-box;
        }

        .update-button {
            padding: 10px 16px;
            border: none;
            border-radius: 8px;
            background: #4facfe;
            color: white;
            cursor: pointer;
            font-weight: bold;
            transition: background 0.2s ease;
            width: 100%;
        }

        .update-button:hover {
            background: #0e94f6;
        }

        .small-text {
            font-size: 13px;
            color: #666;
        }

        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 11px;
            margin-top: 4px;
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
    </style>
</head>

<body>

<div class="navbar">
    <h2>Admin Panel</h2>

    <div class="nav-links">
        <a class="nav-link" href="admin_dashboard.php">Dashboard</a>
        <a class="nav-link" href="view_reports.php">View Reports</a>
        <a class="nav-link" href="audit_logs.php">Audit Logs</a>
        <a class="logout" href="logout.php">Logout</a>
    </div>
</div>

<div class="container">
    <a href="admin_dashboard.php" class="back-link">← Back to Dashboard</a>

    <h1>Manage Feedback</h1>
    <p class="small-text">Review submitted feedback and update the status for each entry.</p>

    <?php if ($message): ?>
        <div class="message"><?php echo htmlspecialchars($message); ?></div>
    <?php endif; ?>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>User ID</th>
                <th>Title</th>
                <th>Description</th>
                <th>Category</th>
                <th>Type</th>
                <th>Status Control</th>
                <th>Admin Response</th>
                <th>Timestamps</th>
                <th>Action</th>
            </tr>
        </thead>

        <tbody>
            <?php if (empty($feedbackItems)): ?>
                <tr>
                    <td colspan="10" style="padding: 24px; text-align: center; color: #555;">
                        No feedback entries found.
                    </td>
                </tr>
            <?php else: ?>
                <?php foreach ($feedbackItems as $item): ?>
                    <tr>
                        <td style="display:none;">
                            <form id="form-<?php echo htmlspecialchars($item['feedback_id']); ?>" method="post" action="update_feedback.php">
                                <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($csrfToken); ?>">
                                <input type="hidden" name="feedback_id" value="<?php echo htmlspecialchars($item['feedback_id']); ?>">
                            </form>
                        </td>

                        <td><?php echo htmlspecialchars($item['feedback_id']); ?></td>

                        <td><?php echo htmlspecialchars($item['user_id']); ?></td>

                        <td>
                            <strong><?php echo htmlspecialchars($item['title']); ?></strong>
                        </td>

                        <td>
                            <small><?php echo nl2br(htmlspecialchars($item['description'])); ?></small>
                        </td>

                        <td><?php echo htmlspecialchars($item['category'] ?? 'N/A'); ?></td>

                        <td><?php echo htmlspecialchars($item['type']); ?></td>

                        <td>
                            <select name="status" form="form-<?php echo htmlspecialchars($item['feedback_id']); ?>">
                                <?php foreach ($allowedStatuses as $statusOption): ?>
                                    <option value="<?php echo htmlspecialchars($statusOption); ?>"
                                        <?php echo $item['status'] === $statusOption ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($statusOption); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>

                            <span class="badge status-<?php echo str_replace(' ', '-', htmlspecialchars($item['status'])); ?>">
                                <?php echo htmlspecialchars($item['status']); ?>
                            </span>
                        </td>

                        <td>
                            <textarea 
                                name="admin_response" 
                                form="form-<?php echo htmlspecialchars($item['feedback_id']); ?>" 
                                placeholder="Enter official response..."
                            ><?php echo htmlspecialchars($item['admin_response'] ?? ''); ?></textarea>
                        </td>

                        <td style="font-size:11px; color:#666; line-height:1.3;">
                            Created: <?php echo htmlspecialchars($item['created_at']); ?><br>
                            Updated: <?php echo htmlspecialchars($item['updated_at']); ?>
                        </td>

                        <td>
                            <button 
                                type="submit" 
                                form="form-<?php echo htmlspecialchars($item['feedback_id']); ?>" 
                                class="update-button"
                            >
                                Update
                            </button>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>

</body>
</html>

<?php
sqlsrv_close($conn);
?>