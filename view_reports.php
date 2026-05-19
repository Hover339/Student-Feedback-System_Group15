<?php
session_start();
include 'db.php';

if (!isset($_SESSION['role']) || $_SESSION['role'] !== 'admin') {
    header('Location: login.php');
    exit();
}

$totalSubmissions = 0;
$statusCounts = [
    'Pending' => 0,
    'In Progress' => 0,
    'Resolved' => 0,
    'Rejected' => 0,
];
$categoryCounts = [];
$typeCounts = [
    'Complaint' => 0,
    'Suggestion' => 0,
    'Feedback' => 0,
];

$totalSql = "SELECT COUNT(*) AS total FROM feedback";
$totalResult = $conn->query($totalSql);
if ($totalResult && $row = $totalResult->fetch_assoc()) {
    $totalSubmissions = (int) $row['total'];
}

$statusSql = "SELECT status, COUNT(*) AS count FROM feedback GROUP BY status";
$statusResult = $conn->query($statusSql);
if ($statusResult) {
    while ($row = $statusResult->fetch_assoc()) {
        $status = $row['status'];
        if (isset($statusCounts[$status])) {
            $statusCounts[$status] = (int) $row['count'];
        }
    }
}

$categorySql = "SELECT category, COUNT(*) AS count FROM feedback GROUP BY category";
$categoryResult = $conn->query($categorySql);
if ($categoryResult) {
    while ($row = $categoryResult->fetch_assoc()) {
        $categoryCounts[$row['category']] = (int) $row['count'];
    }
}

$typeSql = "SELECT type, COUNT(*) AS count FROM feedback GROUP BY type";
$typeResult = $conn->query($typeSql);
if ($typeResult) {
    while ($row = $typeResult->fetch_assoc()) {
        $type = $row['type'];
        if (isset($typeCounts[$type])) {
            $typeCounts[$type] = (int) $row['count'];
        }
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Reports</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(to right, #4facfe, #00f2fe);
            min-height: 100vh;
            color: #333;
        }

        .navbar {
            background: white;
            padding: 16px 32px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.15);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar h2 {
            margin: 0;
            color: #333;
        }

        .navbar .nav-links {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        .nav-link,
        .logout {
            text-decoration: none;
            color: #333;
            padding: 10px 16px;
            border-radius: 8px;
            transition: background 0.2s ease;
        }

        .nav-link:hover,
        .logout:hover {
            background: rgba(0, 0, 0, 0.05);
        }

        .logout {
            background: #ff4757;
            color: white;
        }

        .logout:hover {
            background: #e03e4f;
        }

        .page-wrapper {
            width: 90%;
            max-width: 1200px;
            margin: 40px auto 60px;
        }

        .report-card {
            background: white;
            padding: 32px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
        }

        .report-card h1,
        .report-card h2,
        .report-card h3 {
            margin: 0;
            color: #222;
        }

        .report-card p {
            margin: 10px 0 24px;
            color: #555;
            line-height: 1.6;
        }

        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .kpi-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 150px;
        }

        .kpi-card .label {
            font-size: 14px;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: #888;
            margin-bottom: 12px;
        }

        .kpi-card .value {
            font-size: 44px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 6px;
        }

        .kpi-card .detail {
            font-size: 14px;
            color: #666;
        }

        .summary-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }

        .summary-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
        }

        .summary-table th,
        .summary-table td {
            padding: 16px 18px;
            text-align: left;
            border-bottom: 1px solid #f0f0f0;
        }

        .summary-table th {
            background: #f7fbff;
            color: #333;
            font-weight: 700;
        }

        .summary-table tr:last-child td {
            border-bottom: none;
        }

        .summary-label {
            font-size: 18px;
            margin-bottom: 14px;
            color: #333;
        }

        @media (max-width: 900px) {
            .summary-section {
                grid-template-columns: 1fr;
            }
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

    </style>
</head>
<body>
    <div class="navbar">
        <h2>Admin Reports</h2>
        <div class="nav-links">
            <a class="nav-link" href="admin_dashboard.php">Dashboard</a>
            <a class="logout" href="logout.php">Logout</a>
        </div>
    </div>

    <div class="page-wrapper">
        <div class="report-card">
            <a href="admin_dashboard.php" class="back-link">← Back to Dashboard</a>

            <h1>Feedback Summary</h1>
            <p>Review total submission volume, status performance, and category/type distributions for feedback received through the student feedback system.</p>

            <div class="kpi-grid">
                <div class="kpi-card">
                    <span class="label">Total Submissions</span>
                    <span class="value"><?php echo $totalSubmissions; ?></span>
                    <span class="detail">Overall number of feedback records.</span>
                </div>
                <div class="kpi-card">
                    <span class="label">Pending</span>
                    <span class="value"><?php echo $statusCounts['Pending']; ?></span>
                    <span class="detail">Feedback entries awaiting review.</span>
                </div>
                <div class="kpi-card">
                    <span class="label">In Progress</span>
                    <span class="value"><?php echo $statusCounts['In Progress']; ?></span>
                    <span class="detail">Submissions currently being addressed.</span>
                </div>
                <div class="kpi-card">
                    <span class="label">Resolved</span>
                    <span class="value"><?php echo $statusCounts['Resolved']; ?></span>
                    <span class="detail">Resolved feedback items.</span>
                </div>
                <div class="kpi-card">
                    <span class="label">Rejected</span>
                    <span class="value"><?php echo $statusCounts['Rejected']; ?></span>
                    <span class="detail">Feedback marked as rejected.</span>
                </div>
            </div>

            <div class="summary-section">
                <div>
                    <div class="summary-label">Category Breakdown</div>
                    <table class="summary-table">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Count</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (count($categoryCounts) === 0): ?>
                                <tr><td colspan="2">No category data available.</td></tr>
                            <?php else: ?>
                                <?php foreach ($categoryCounts as $category => $count): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($category, ENT_QUOTES, 'UTF-8'); ?></td>
                                        <td><?php echo $count; ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>

                <div>
                    <div class="summary-label">Type Breakdown</div>
                    <table class="summary-table">
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Count</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($typeCounts as $type => $count): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($type, ENT_QUOTES, 'UTF-8'); ?></td>
                                    <td><?php echo $count; ?></td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
