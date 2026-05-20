<?php
session_start();
include 'db.php';

// Authenticated Admin Session Guard
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}

// Time filter
$filter = isset($_POST['filter']) ? $_POST['filter'] : 'all';

// Action flag filter
$actionFilter = isset($_POST['action_filter']) ? $_POST['action_filter'] : 'all';

// Allowed action flags
$allowedActions = [
    'all',
    'USER_LOGIN',
    'LOGIN_FAILED',
    'ACCOUNT_LOCKED',
    'LOGIN_LOCKED',
    'LOGOUT',
    'USER_REGISTERED',
    'DASHBOARD_ACCESS',
    'FEEDBACK_SUBMITTED',
    'FEEDBACK_LIST_VIEWED',
    'FEEDBACK_DETAIL_VIEWED',
    'FEEDBACK_UPDATED',
    'FEEDBACK_MODIFIED',
    'FEEDBACK_DELETED',
    'RATE_LIMIT_TRIGGERED',
    'CSRF_FAILED',
    'UNAUTHORIZED_ACCESS',
    'UNAUTHORIZED_DELETE_ATTEMPT',
    'UNAUTHORIZED_MODIFY_ATTEMPT'
];

if (!in_array($actionFilter, $allowedActions, true)) {
    $actionFilter = 'all';
}

// Build SQL Server query safely
$query = "SELECT a.log_id, u.email, a.action, a.details, a.created_at
          FROM security.audit_logs a
          LEFT JOIN app.users u ON a.user_id = u.user_id";

$conditions = [];
$params = [];

// Time filter condition
if ($filter === 'today') {
    $conditions[] = "a.created_at >= CAST(GETDATE() AS DATE)";
} elseif ($filter === 'week') {
    $conditions[] = "a.created_at >= DATEADD(DAY, -7, GETDATE())";
} elseif ($filter === 'month') {
    $conditions[] = "a.created_at >= DATEADD(MONTH, -1, GETDATE())";
}

// Action filter condition
if ($actionFilter !== 'all') {
    $conditions[] = "a.action = ?";
    $params[] = $actionFilter;
}

// Add WHERE if needed
if (!empty($conditions)) {
    $query .= " WHERE " . implode(" AND ", $conditions);
}

$query .= " ORDER BY a.created_at DESC";

// Execute query
$logs = [];
$stmt = sqlsrv_query($conn, $query, $params);

if ($stmt) {
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        $logs[] = [
            'log_id'     => $row['log_id'],
            'email'      => $row['email'] ?? 'System / Guest',
            'action'     => $row['action'],
            'details'    => $row['details'],
            'created_at' => $row['created_at']
        ];
    }
} else {
    echo "<h3>SQL Server Error while loading audit logs:</h3>";
    echo "<pre>";
    print_r(sqlsrv_errors());
    echo "</pre>";
    exit();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Platform Audit Logs</title>

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
            width: 90%;
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

        .container h1 {
            margin-top: 0;
            margin-bottom: 10px;
            color: #333;
            text-align: center;
        }

        .subtitle {
            text-align: center;
            color: #666;
            font-size: 14px;
            margin-bottom: 30px;
        }

        .filter-form {
            margin-bottom: 25px;
            background: #f8fba8;
            padding: 18px;
            border-radius: 8px;
            border: 1px solid #e6db55;
            width: 100%;
            box-sizing: border-box;
        }

        .filter-row {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .filter-form label {
            font-weight: bold;
            color: #555;
            font-size: 14px;
        }

        .filter-form select {
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            background: white;
        }

        .filter-form button {
            padding: 8px 20px;
            background: #4facfe;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            transition: background 0.2s;
        }

        .filter-form button:hover {
            background: #0e94f6;
        }

        .reset-link {
            text-decoration: none;
            padding: 8px 16px;
            background: #777;
            color: white;
            border-radius: 6px;
            font-size: 14px;
            font-weight: bold;
        }

        .reset-link:hover {
            background: #555;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        th, td {
            padding: 14px;
            text-align: left;
            border-bottom: 1px solid #e0e7ef;
            font-size: 14px;
        }

        th {
            background-color: #f5f8fb;
            color: #333;
            font-weight: 600;
        }

        tr:hover {
            background-color: #fbfcff;
        }

        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
        }

        .badge-default {
            background: #e2e3e5;
            color: #383d41;
        }

        .badge-view {
            background: #d1ecf1;
            color: #0c5460;
        }

        .badge-update {
            background: #fff3cd;
            color: #856404;
        }

        .badge-success {
            background: #d4edda;
            color: #155724;
        }

        .badge-delete {
            background: #f8d7da;
            color: #721c24;
        }

        .sensitive {
            background: #f8d7da;
            color: #721c24;
        }

        .rate-limit {
            background: #ffe8cc;
            color: #8a4b00;
        }

        .filter-summary {
            margin-bottom: 15px;
            color: #555;
            font-size: 14px;
        }

        code {
            font-size: 13px;
            color: #444;
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>Admin Panel</h2>

    <div class="nav-links">
        <a class="nav-link" href="admin_dashboard.php">Dashboard</a>
        <a class="nav-link" href="view_reports.php">View Reports</a>
        <a class="nav-link" href="update_feedback.php">Manage Feedback</a>
        <a class="logout" href="logout.php">Logout</a>
    </div>
</div>

<div class="container">
    <a href="admin_dashboard.php" class="back-link">← Back to Dashboard</a>

    <h1>Platform Audit Logs</h1>
    <div class="subtitle">Application-level audit logs stored in the security schema.</div>

    <form method="post" class="filter-form">
        <div class="filter-row">

            <div class="filter-group">
                <label for="filter">Timeframe:</label>
                <select name="filter" id="filter">
                    <option value="all" <?php if ($filter == 'all') echo 'selected'; ?>>All History Logs</option>
                    <option value="today" <?php if ($filter == 'today') echo 'selected'; ?>>Today's Activity</option>
                    <option value="week" <?php if ($filter == 'week') echo 'selected'; ?>>Past 7 Days</option>
                    <option value="month" <?php if ($filter == 'month') echo 'selected'; ?>>Past 30 Days</option>
                </select>
            </div>

            <div class="filter-group">
                <label for="action_filter">Action Flag:</label>
                <select name="action_filter" id="action_filter">
                    <option value="all" <?php if ($actionFilter == 'all') echo 'selected'; ?>>All Actions</option>

                    <?php foreach ($allowedActions as $actionOption): ?>
                        <?php if ($actionOption !== 'all'): ?>
                            <option value="<?php echo htmlspecialchars($actionOption); ?>" 
                                <?php if ($actionFilter == $actionOption) echo 'selected'; ?>>
                                <?php echo htmlspecialchars($actionOption); ?>
                            </option>
                        <?php endif; ?>
                    <?php endforeach; ?>
                </select>
            </div>

            <button type="submit">Apply Filter</button>
            <a href="audit_logs.php" class="reset-link">Reset</a>
        </div>
    </form>

    <div class="filter-summary">
        Showing:
        <strong><?php echo htmlspecialchars($filter); ?></strong>
        timeframe |
        Action:
        <strong><?php echo htmlspecialchars($actionFilter); ?></strong>
    </div>

    <table>
        <thead>
            <tr>
                <th style="width: 8%;">Log ID</th>
                <th style="width: 22%;">Account / Operator</th>
                <th style="width: 18%;">Action Flag</th>
                <th>Detailed Log Context</th>
                <th style="width: 18%;">Timestamp</th>
            </tr>
        </thead>

        <tbody>
            <?php if (empty($logs)): ?>
                <tr>
                    <td colspan="5" style="text-align: center; padding: 30px; color: #777;">
                        No transaction activity recorded for this filter.
                    </td>
                </tr>
            <?php else: ?>
                <?php foreach ($logs as $log): ?>
                    <tr>
                        <td>#<?php echo htmlspecialchars($log['log_id']); ?></td>

                        <td>
                            <strong><?php echo htmlspecialchars(maskEmail($log['email'])); ?></strong>
                        </td>

                        <td>
                            <?php
                            $badgeType = 'badge-default';

                            if (strpos($log['action'], 'VIEW') !== false) {
                                $badgeType = 'badge-view';
                            }

                            if (strpos($log['action'], 'UPDATE') !== false || strpos($log['action'], 'MODIFIED') !== false) {
                                $badgeType = 'badge-update';
                            }

                            if (strpos($log['action'], 'SUBMITTED') !== false || strpos($log['action'], 'REGISTERED') !== false || $log['action'] === 'USER_LOGIN') {
                                $badgeType = 'badge-success';
                            }

                            if (strpos($log['action'], 'DELETE') !== false || strpos($log['action'], 'DELETED') !== false) {
                                $badgeType = 'badge-delete';
                            }

                            if ($log['action'] === 'RATE_LIMIT_TRIGGERED') {
                                $badgeType = 'rate-limit';
                            }

                            if (
                                $log['action'] === 'LOGIN_FAILED' ||
                                $log['action'] === 'ACCOUNT_LOCKED' ||
                                $log['action'] === 'LOGIN_LOCKED' ||
                                $log['action'] === 'CSRF_FAILED' ||
                                strpos($log['action'], 'UNAUTHORIZED') !== false
                            ) {
                                $badgeType = 'sensitive';
                            }
                            ?>

                            <span class="badge <?php echo htmlspecialchars($badgeType); ?>">
                                <?php echo htmlspecialchars($log['action']); ?>
                            </span>
                        </td>

                        <td>
                            <code><?php echo htmlspecialchars($log['details']); ?></code>
                        </td>

                        <td style="color: #666; font-size: 13px;">
                            <?php echo htmlspecialchars($log['created_at']); ?>
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