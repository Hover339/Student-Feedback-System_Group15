#!/bin/bash
set -e

apt update -y
apt install -y apache2 php libapache2-mod-php

systemctl enable apache2
systemctl start apache2

cd /var/www/html
rm -f index.html

mkdir -p demo_data
echo "[]" > demo_data/feedbacks.json
echo "[]" > demo_data/audit_logs.json
echo "[]" > demo_data/users.json

cat > demo_lib.php <<'PHP'
<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

define('FEEDBACK_FILE', __DIR__ . '/demo_data/feedbacks.json');
define('AUDIT_FILE', __DIR__ . '/demo_data/audit_logs.json');
define('USERS_FILE', __DIR__ . '/demo_data/users.json');

function h($value) {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function readJsonFile($file) {
    if (!file_exists($file)) {
        file_put_contents($file, json_encode([]));
    }

    $data = json_decode(file_get_contents($file), true);
    return is_array($data) ? $data : [];
}

function writeJsonFile($file, $data) {
    file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT));
}

function readFeedbacks() {
    return readJsonFile(FEEDBACK_FILE);
}

function saveFeedbacks($feedbacks) {
    writeJsonFile(FEEDBACK_FILE, $feedbacks);
}

function readAuditLogs() {
    return readJsonFile(AUDIT_FILE);
}

function readUsers() {
    return readJsonFile(USERS_FILE);
}

function saveUsers($users) {
    writeJsonFile(USERS_FILE, $users);
}

function findUserByEmail($email) {
    $email = strtolower(trim($email));
    $users = readUsers();

    foreach ($users as $user) {
        if (strtolower($user['email'] ?? '') === $email) {
            return $user;
        }
    }

    return null;
}

function registerStudent($name, $email, $password) {
    $users = readUsers();

    $name = trim($name);
    $email = strtolower(trim($email));

    foreach ($users as $user) {
        if (strtolower($user['email'] ?? '') === $email) {
            return false;
        }
    }

    $users[] = [
        'id' => count($users) + 1,
        'name' => $name,
        'email' => $email,
        'password_hash' => password_hash($password, PASSWORD_DEFAULT),
        'role' => 'student',
        'created_at' => date('Y-m-d H:i:s')
    ];

    saveUsers($users);
    return true;
}

function logDemoEvent($user, $action, $details) {
    $logs = readAuditLogs();

    $logs[] = [
        'id' => count($logs) + 1,
        'user' => $user,
        'action' => $action,
        'details' => $details,
        'time' => date('Y-m-d H:i:s')
    ];

    writeJsonFile(AUDIT_FILE, $logs);
}

function requireLogin() {
    if (!isset($_SESSION['user_email']) || !isset($_SESSION['role'])) {
        header("Location: login.php");
        exit();
    }
}

function requireStudent() {
    requireLogin();

    if ($_SESSION['role'] !== 'student') {
        header("Location: admin_dashboard.php");
        exit();
    }
}

function requireAdmin() {
    requireLogin();

    if ($_SESSION['role'] !== 'admin') {
        header("Location: student_dashboard.php");
        exit();
    }
}

function currentUserEmail() {
    return $_SESSION['user_email'] ?? 'guest@example.com';
}

function currentUserName() {
    return $_SESSION['user_name'] ?? currentUserEmail();
}

function statusClass($status) {
    switch ($status) {
        case 'Pending':
            return 'status-pending';
        case 'In Progress':
            return 'status-progress';
        case 'Resolved':
            return 'status-resolved';
        case 'Rejected':
            return 'status-rejected';
        default:
            return 'status-pending';
    }
}

function actionClass($action) {
    switch ($action) {
        case 'LOGIN':
            return 'action-login';
        case 'LOGOUT':
            return 'action-logout';
        case 'REGISTER':
            return 'action-register';
        case 'FEEDBACK_SUBMITTED':
            return 'action-submitted';
        case 'FEEDBACK_UPDATED':
            return 'action-updated';
        case 'FEEDBACK_EDITED':
            return 'action-edited';
        case 'FEEDBACK_DELETED':
            return 'action-deleted';
        default:
            return 'action-default';
    }
}

function formatAction($action) {
    return str_replace('_', ' ', $action);
}
?>
PHP

cat > cloud-demo.css <<'CSS'
* { box-sizing: border-box; }
body { margin: 0; font-family: Arial, sans-serif; min-height: 100vh; color: #333; }
body.login-theme, body.student-theme { background: linear-gradient(to right, #4facfe, #00f2fe); }
body.admin-theme { background: linear-gradient(to right, #dc2626, #991b1b); }
.navbar { background: white; padding: 15px 30px; box-shadow: 0 3px 10px rgba(0,0,0,0.15); display: flex; justify-content: space-between; align-items: center; }
.navbar h2 { margin: 0; color: #333; }
.navbar a { text-decoration: none; background: #e74c3c; color: white; padding: 10px 18px; border-radius: 5px; }
.navbar a:hover { background: #c0392b; }
.container { width: 88%; max-width: 1100px; margin: 45px auto; background: white; padding: 35px; border-radius: 14px; box-shadow: 0 5px 16px rgba(0,0,0,0.22); }
.login-box { width: 360px; margin: 90px auto; background: white; padding: 34px; border-radius: 14px; text-align: center; box-shadow: 0 5px 16px rgba(0,0,0,0.22); }
h1 { margin-top: 0; color: #333; text-align: center; }
.subtitle { text-align: center; color: #666; margin-bottom: 30px; }
.card-container { display: flex; gap: 20px; justify-content: center; flex-wrap: wrap; }
.card { background: #f7f9fc; padding: 22px; border-radius: 12px; box-shadow: 0 3px 8px rgba(0,0,0,0.1); margin-bottom: 20px; }
.card-link { width: 250px; text-decoration: none; color: #333; transition: 0.3s; }
.card-link:hover { transform: translateY(-5px); background: #eef6ff; }
.card h3 { margin-top: 0; color: #2196F3; }
.admin-theme .card h3 { color: #dc2626; }
.stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 18px; margin-bottom: 28px; }
.stat-card { background: #f8fafc; border-left: 5px solid #2196F3; padding: 18px; border-radius: 12px; box-shadow: 0 3px 8px rgba(0,0,0,0.08); }
.admin-theme .stat-card { border-left-color: #dc2626; }
.stat-card h3 { margin: 0; font-size: 14px; color: #666; }
.stat-card p { margin: 8px 0 0; font-size: 28px; font-weight: bold; color: #222; }
input, select, textarea { width: 100%; padding: 11px; margin: 8px 0 15px; border-radius: 6px; border: 1px solid #ccc; font-family: Arial, sans-serif; }
textarea { min-height: 120px; resize: vertical; }
.btn { display: inline-block; border: none; border-radius: 6px; padding: 10px 16px; color: white; background: #2196F3; text-decoration: none; cursor: pointer; font-size: 14px; }
.btn:hover { background: #1e87db; }
.btn-green { background: #4CAF50; }
.btn-green:hover { background: #45a049; }
.btn-red { background: #dc2626; }
.btn-red:hover { background: #b91c1c; }
.btn-orange { background: #f59e0b; }
.btn-orange:hover { background: #d97706; }
.btn-grey { background: #777; }
.btn-grey:hover { background: #555; }
.btn-small { padding: 7px 11px; font-size: 12px; margin: 2px; }
.table-wrapper { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; background: white; margin-top: 15px; }
th { background: #2196F3; color: white; }
.admin-theme th { background: #dc2626; }
th, td { border: 1px solid #ddd; padding: 12px; text-align: left; vertical-align: top; }
tr:nth-child(even) { background: #f7f9fc; }
.badge, .status-badge, .action-badge { display: inline-block; padding: 6px 10px; border-radius: 999px; font-size: 12px; font-weight: bold; white-space: nowrap; }
.status-pending { background: #fef3c7; color: #92400e; }
.status-progress { background: #dbeafe; color: #1d4ed8; }
.status-resolved { background: #dcfce7; color: #166534; }
.status-rejected { background: #fee2e2; color: #991b1b; }
.action-badge { color: white; letter-spacing: 0.3px; }
.action-login { background: #2563eb; }
.action-logout { background: #6b7280; }
.action-submitted { background: #16a34a; }
.action-updated { background: #dc2626; }
.action-register { background: #7c3aed; }
.action-deleted { background: #111827; }
.action-edited { background: #f59e0b; }
.action-default { background: #475569; }
.filter-bar { display: flex; gap: 12px; align-items: end; flex-wrap: wrap; background: #f8fafc; padding: 16px; border-radius: 12px; margin-bottom: 20px; }
.filter-group { min-width: 190px; flex: 1; }
.filter-group label { display: block; font-size: 13px; font-weight: bold; color: #555; margin-bottom: 4px; }
.filter-group select, .filter-group input { margin: 0; }
.actions { margin-top: 25px; text-align: center; }
.inline-actions { display: flex; gap: 6px; flex-wrap: wrap; }
.error { color: red; }
.success { color: green; }
.warning-text { color: #92400e; font-size: 13px; }
.empty-state { text-align: center; padding: 35px; color: #666; }
CSS

cat > index.php <<'PHP'
<!DOCTYPE html>
<html>
<head>
    <title>Student Feedback System</title>
    <link rel="stylesheet" href="cloud-demo.css">
</head>
<body class="login-theme">
<div class="login-box">
    <h2>Student Feedback System</h2>
    <p style="color:#666;">Secure feedback management portal</p>
    <a class="btn btn-green" style="width:100%;margin-bottom:12px;" href="login.php">Login</a>
    <a class="btn" style="width:100%;" href="register.php">Register</a>
</div>
</body>
</html>
PHP

cat > login.php <<'PHP'
<?php
require_once 'demo_lib.php';

$error = '';

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $email = strtolower(trim($_POST['email'] ?? ''));
    $password = trim($_POST['password'] ?? '');

    if ($email === '' || $password === '') {
        $error = "Please enter email and password.";
    } elseif ($email === 'admin@example.com') {
        if ($password === 'admin123') {
            $_SESSION['user_id'] = 99;
            $_SESSION['user_email'] = $email;
            $_SESSION['user_name'] = 'Administrator';
            $_SESSION['role'] = 'admin';
            logDemoEvent($email, 'LOGIN', 'Admin logged in.');
            header("Location: admin_dashboard.php");
            exit();
        } else {
            $error = "Invalid email or password.";
        }
    } else {
        $user = findUserByEmail($email);

        if (!$user) {
            $error = "Invalid email or password.";
        } elseif (($user['role'] ?? '') !== 'student') {
            $error = "Invalid email or password.";
        } elseif (!password_verify($password, $user['password_hash'] ?? '')) {
            $error = "Invalid email or password.";
        } else {
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['user_email'] = $user['email'];
            $_SESSION['user_name'] = $user['name'];
            $_SESSION['role'] = 'student';
            logDemoEvent($email, 'LOGIN', 'Student logged in.');
            header("Location: student_dashboard.php");
            exit();
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="cloud-demo.css">
</head>
<body class="login-theme">
<div class="login-box">
    <h2>Login</h2>
    <?php if ($error): ?><p class="error"><?php echo h($error); ?></p><?php endif; ?>
    <form method="POST" autocomplete="off">
        <input type="email" name="email" placeholder="Email" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit" class="btn btn-green" style="width:100%;">Login</button>
    </form>
    <br>
    <a class="btn btn-grey" href="index.php">Back</a>
</div>
</body>
</html>
PHP

cat > register.php <<'PHP'
<?php
require_once 'demo_lib.php';

$message = '';
$error = '';

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $name = trim($_POST['name'] ?? '');
    $email = strtolower(trim($_POST['email'] ?? ''));
    $password = trim($_POST['password'] ?? '');

    if ($name === '' || $email === '' || $password === '') {
        $error = "Please fill in all fields.";
    } elseif ($email === 'admin@example.com') {
        $error = "This email cannot be registered.";
    } elseif (strlen($password) < 4) {
        $error = "Password must be at least 4 characters.";
    } elseif (findUserByEmail($email)) {
        $error = "This email is already registered.";
    } else {
        registerStudent($name, $email, $password);
        logDemoEvent($email, 'REGISTER', 'New student account registered.');
        $message = "Registration successful. You may now login.";
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    <link rel="stylesheet" href="cloud-demo.css">
</head>
<body class="login-theme">
<div class="login-box">
    <h2>Register</h2>
    <?php if ($message): ?><p class="success"><?php echo h($message); ?></p><?php endif; ?>
    <?php if ($error): ?><p class="error"><?php echo h($error); ?></p><?php endif; ?>
    <form method="POST" autocomplete="off">
        <input type="text" name="name" placeholder="Full Name" required>
        <input type="email" name="email" placeholder="Email" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit" class="btn btn-green" style="width:100%;">Register</button>
    </form>
    <br>
    <a class="btn btn-grey" href="index.php">Back</a>
</div>
</body>
</html>
PHP

cat > logout.php <<'PHP'
<?php
require_once 'demo_lib.php';
if (isset($_SESSION['user_email'])) {
    logDemoEvent($_SESSION['user_email'], 'LOGOUT', 'User logged out.');
}
session_unset();
session_destroy();
header("Location: login.php");
exit();
?>
PHP

cat > student_dashboard.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireStudent();
$allFeedbacks = readFeedbacks();
$myFeedbacks = array_filter($allFeedbacks, function($fb) {
    return ($fb['student_email'] ?? '') === currentUserEmail();
});
$total = count($myFeedbacks);
$pending = count(array_filter($myFeedbacks, fn($fb) => ($fb['status'] ?? '') === 'Pending'));
$progress = count(array_filter($myFeedbacks, fn($fb) => ($fb['status'] ?? '') === 'In Progress'));
$resolved = count(array_filter($myFeedbacks, fn($fb) => ($fb['status'] ?? '') === 'Resolved'));
?>
<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard</title>
    <link rel="stylesheet" href="cloud-demo.css">
</head>
<body class="student-theme">
<div class="navbar"><h2>Student Feedback System</h2><a href="logout.php">Logout</a></div>
<div class="container">
    <h1>Student Dashboard</h1>
    <p class="subtitle">Welcome, <?php echo h(currentUserName()); ?>.</p>
    <div class="stat-grid">
        <div class="stat-card"><h3>Total Feedback</h3><p><?php echo h($total); ?></p></div>
        <div class="stat-card"><h3>Pending</h3><p><?php echo h($pending); ?></p></div>
        <div class="stat-card"><h3>In Progress</h3><p><?php echo h($progress); ?></p></div>
        <div class="stat-card"><h3>Resolved</h3><p><?php echo h($resolved); ?></p></div>
    </div>
    <div class="card-container">
        <a href="submit_feedback.php" class="card card-link"><h3>Submit Feedback</h3><p>Create a new complaint, suggestion, or feedback report.</p></a>
        <a href="my_feedback.php" class="card card-link"><h3>My Feedback</h3><p>View, edit, delete, and track your submitted feedback.</p></a>
    </div>
</div>
</body>
</html>
PHP

cat > submit_feedback.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireStudent();

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $feedbacks = readFeedbacks();
    $title = trim($_POST['title'] ?? '');
    $category = trim($_POST['category'] ?? '');
    $type = trim($_POST['type'] ?? '');
    $description = trim($_POST['description'] ?? '');

    if ($title !== '' && $description !== '') {
        $feedbacks[] = [
            'id' => count($feedbacks) + 1,
            'student_email' => currentUserEmail(),
            'title' => $title,
            'category' => $category,
            'type' => $type,
            'description' => $description,
            'status' => 'Pending',
            'admin_response' => 'No admin response yet.',
            'created_at' => date('Y-m-d H:i:s')
        ];
        saveFeedbacks($feedbacks);
        logDemoEvent(currentUserEmail(), 'FEEDBACK_SUBMITTED', 'Submitted feedback: ' . $title);
        header("Location: my_feedback.php");
        exit();
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Submit Feedback</title>
    <link rel="stylesheet" href="cloud-demo.css">
</head>
<body class="student-theme">
<div class="navbar"><h2>Student Feedback System</h2><a href="logout.php">Logout</a></div>
<div class="container">
    <h1>Submit Feedback</h1>
    <p class="subtitle">Create a new complaint, suggestion, or feedback report.</p>
    <div class="card">
        <form method="POST">
            <label>Feedback Title</label>
            <input type="text" name="title" placeholder="Enter feedback title" required>
            <label>Category</label>
            <select name="category"><option>Facility</option><option>Academic</option><option>IT Service</option><option>General</option></select>
            <label>Feedback Type</label>
            <select name="type"><option>Complaint</option><option>Suggestion</option><option>Feedback</option></select>
            <label>Description</label>
            <textarea name="description" placeholder="Describe your feedback here..." required></textarea>
            <button class="btn btn-green" type="submit">Submit Feedback</button>
        </form>
    </div>
    <div class="actions"><a class="btn btn-grey" href="student_dashboard.php">Back to Dashboard</a></div>
</div>
</body>
</html>
PHP

cat > my_feedback.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireStudent();
$statusFilter = $_GET['status'] ?? 'All';
$allFeedbacks = readFeedbacks();
$myFeedbacks = array_filter($allFeedbacks, function($fb) use ($statusFilter) {
    $isOwner = ($fb['student_email'] ?? '') === currentUserEmail();
    $statusMatch = $statusFilter === 'All' || ($fb['status'] ?? '') === $statusFilter;
    return $isOwner && $statusMatch;
});
?>
<!DOCTYPE html>
<html>
<head><title>My Feedback</title><link rel="stylesheet" href="cloud-demo.css"></head>
<body class="student-theme">
<div class="navbar"><h2>Student Feedback System</h2><a href="logout.php">Logout</a></div>
<div class="container">
    <h1>My Feedback</h1>
    <p class="subtitle">View, edit, delete, and track your feedback records.</p>
    <form method="GET" class="filter-bar">
        <div class="filter-group"><label>Status Filter</label><select name="status"><option <?php if ($statusFilter === 'All') echo 'selected'; ?>>All</option><option <?php if ($statusFilter === 'Pending') echo 'selected'; ?>>Pending</option><option <?php if ($statusFilter === 'In Progress') echo 'selected'; ?>>In Progress</option><option <?php if ($statusFilter === 'Resolved') echo 'selected'; ?>>Resolved</option><option <?php if ($statusFilter === 'Rejected') echo 'selected'; ?>>Rejected</option></select></div>
        <button class="btn btn-green" type="submit">Apply Filter</button><a class="btn btn-grey" href="my_feedback.php">Reset</a>
    </form>
    <?php if (empty($myFeedbacks)): ?>
        <div class="card empty-state"><h3>No feedback found</h3><p>No feedback records match the selected filter.</p><a class="btn btn-green" href="submit_feedback.php">Submit Feedback</a></div>
    <?php else: ?>
        <div class="table-wrapper"><table><tr><th>ID</th><th>Title</th><th>Category</th><th>Type</th><th>Status</th><th>Admin Response</th><th>Action</th></tr>
        <?php foreach ($myFeedbacks as $fb): ?>
            <tr>
                <td><?php echo h($fb['id']); ?></td><td><?php echo h($fb['title']); ?></td><td><?php echo h($fb['category']); ?></td><td><?php echo h($fb['type']); ?></td>
                <td><span class="status-badge <?php echo h(statusClass($fb['status'])); ?>"><?php echo h($fb['status']); ?></span></td>
                <td><?php echo h($fb['admin_response']); ?></td>
                <td><div class="inline-actions"><?php if (($fb['status'] ?? '') === 'Pending'): ?><a class="btn btn-orange btn-small" href="edit_feedback.php?id=<?php echo h($fb['id']); ?>">Edit</a><a class="btn btn-red btn-small" href="delete_feedback.php?id=<?php echo h($fb['id']); ?>" onclick="return confirm('Are you sure you want to delete this feedback?');">Delete</a><?php else: ?><span class="warning-text">Locked</span><?php endif; ?></div></td>
            </tr>
        <?php endforeach; ?></table></div>
    <?php endif; ?>
    <div class="actions"><a class="btn btn-green" href="submit_feedback.php">Submit New Feedback</a> <a class="btn btn-grey" href="student_dashboard.php">Back to Dashboard</a></div>
</div>
</body>
</html>
PHP

cat > edit_feedback.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireStudent();
$id = intval($_GET['id'] ?? 0);
$feedbacks = readFeedbacks();
$selectedIndex = null;
foreach ($feedbacks as $index => $fb) {
    if (($fb['id'] ?? 0) == $id && ($fb['student_email'] ?? '') === currentUserEmail()) { $selectedIndex = $index; break; }
}
if ($selectedIndex === null) { die("Feedback not found. <a href='my_feedback.php'>Back</a>"); }
if (($feedbacks[$selectedIndex]['status'] ?? '') !== 'Pending') { die("Only pending feedback can be edited. <a href='my_feedback.php'>Back</a>"); }
$error = '';
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $title = trim($_POST['title'] ?? ''); $category = trim($_POST['category'] ?? ''); $type = trim($_POST['type'] ?? ''); $description = trim($_POST['description'] ?? '');
    if ($title === '' || $description === '') { $error = "Title and description are required."; }
    else { $feedbacks[$selectedIndex]['title'] = $title; $feedbacks[$selectedIndex]['category'] = $category; $feedbacks[$selectedIndex]['type'] = $type; $feedbacks[$selectedIndex]['description'] = $description; $feedbacks[$selectedIndex]['updated_at'] = date('Y-m-d H:i:s'); saveFeedbacks($feedbacks); logDemoEvent(currentUserEmail(), 'FEEDBACK_EDITED', 'Edited feedback ID ' . $id); header("Location: my_feedback.php"); exit(); }
}
$fb = $feedbacks[$selectedIndex];
?>
<!DOCTYPE html>
<html>
<head><title>Edit Feedback</title><link rel="stylesheet" href="cloud-demo.css"></head>
<body class="student-theme">
<div class="navbar"><h2>Student Feedback System</h2><a href="logout.php">Logout</a></div>
<div class="container">
<h1>Edit Feedback</h1><p class="subtitle">Modify your pending feedback submission.</p>
<?php if ($error): ?><p class="error"><?php echo h($error); ?></p><?php endif; ?>
<div class="card"><form method="POST">
<label>Feedback Title</label><input type="text" name="title" value="<?php echo h($fb['title']); ?>" required>
<label>Category</label><select name="category"><?php foreach (['Facility', 'Academic', 'IT Service', 'General'] as $cat): ?><option <?php if (($fb['category'] ?? '') === $cat) echo 'selected'; ?>><?php echo h($cat); ?></option><?php endforeach; ?></select>
<label>Feedback Type</label><select name="type"><?php foreach (['Complaint', 'Suggestion', 'Feedback'] as $type): ?><option <?php if (($fb['type'] ?? '') === $type) echo 'selected'; ?>><?php echo h($type); ?></option><?php endforeach; ?></select>
<label>Description</label><textarea name="description" required><?php echo h($fb['description']); ?></textarea>
<button class="btn btn-green" type="submit">Save Changes</button> <a class="btn btn-grey" href="my_feedback.php">Cancel</a>
</form></div></div></body></html>
PHP

cat > delete_feedback.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireStudent();
$id = intval($_GET['id'] ?? 0);
$feedbacks = readFeedbacks();
$newFeedbacks = [];
$deleted = false;
foreach ($feedbacks as $fb) {
    if (($fb['id'] ?? 0) == $id && ($fb['student_email'] ?? '') === currentUserEmail() && ($fb['status'] ?? '') === 'Pending') { $deleted = true; continue; }
    $newFeedbacks[] = $fb;
}
if ($deleted) { saveFeedbacks(array_values($newFeedbacks)); logDemoEvent(currentUserEmail(), 'FEEDBACK_DELETED', 'Deleted feedback ID ' . $id); }
header("Location: my_feedback.php");
exit();
?>
PHP

cat > admin_dashboard.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireAdmin();
$feedbacks = readFeedbacks();
$total = count($feedbacks);
$pending = count(array_filter($feedbacks, fn($fb) => ($fb['status'] ?? '') === 'Pending'));
$progress = count(array_filter($feedbacks, fn($fb) => ($fb['status'] ?? '') === 'In Progress'));
$resolved = count(array_filter($feedbacks, fn($fb) => ($fb['status'] ?? '') === 'Resolved'));
?>
<!DOCTYPE html>
<html><head><title>Admin Dashboard</title><link rel="stylesheet" href="cloud-demo.css"></head><body class="admin-theme">
<div class="navbar"><h2>Admin Panel</h2><a href="logout.php">Logout</a></div>
<div class="container"><h1>Administrator Dashboard</h1><p class="subtitle">Welcome, <?php echo h(currentUserName()); ?>.</p>
<div class="stat-grid"><div class="stat-card"><h3>Total Feedback</h3><p><?php echo h($total); ?></p></div><div class="stat-card"><h3>Pending</h3><p><?php echo h($pending); ?></p></div><div class="stat-card"><h3>In Progress</h3><p><?php echo h($progress); ?></p></div><div class="stat-card"><h3>Resolved</h3><p><?php echo h($resolved); ?></p></div></div>
<div class="card-container"><a href="update_feedback.php" class="card card-link"><h3>Manage Feedback</h3><p>Review feedback records and update their status.</p></a><a href="view_reports.php" class="card card-link"><h3>View Reports</h3><p>Analyze feedback trends and summary statistics.</p></a><a href="audit_logs.php" class="card card-link"><h3>Audit Logs</h3><p>Monitor user and administrative activities.</p></a></div>
</div></body></html>
PHP

cat > update_feedback.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireAdmin();
$statusFilter = $_GET['status'] ?? 'All';
$search = strtolower(trim($_GET['search'] ?? ''));
$feedbacks = readFeedbacks();
$filteredFeedbacks = array_filter($feedbacks, function($fb) use ($statusFilter, $search) {
    $statusMatch = $statusFilter === 'All' || ($fb['status'] ?? '') === $statusFilter;
    $haystack = strtolower(($fb['title'] ?? '') . ' ' . ($fb['category'] ?? '') . ' ' . ($fb['type'] ?? '') . ' ' . ($fb['student_email'] ?? ''));
    $searchMatch = $search === '' || strpos($haystack, $search) !== false;
    return $statusMatch && $searchMatch;
});
?>
<!DOCTYPE html>
<html><head><title>Manage Feedback</title><link rel="stylesheet" href="cloud-demo.css"></head><body class="admin-theme">
<div class="navbar"><h2>Admin Panel</h2><a href="logout.php">Logout</a></div>
<div class="container"><h1>Manage Feedback</h1><p class="subtitle">Review feedback submissions and update their status.</p>
<form method="GET" class="filter-bar"><div class="filter-group"><label>Status</label><select name="status"><option <?php if ($statusFilter === 'All') echo 'selected'; ?>>All</option><option <?php if ($statusFilter === 'Pending') echo 'selected'; ?>>Pending</option><option <?php if ($statusFilter === 'In Progress') echo 'selected'; ?>>In Progress</option><option <?php if ($statusFilter === 'Resolved') echo 'selected'; ?>>Resolved</option><option <?php if ($statusFilter === 'Rejected') echo 'selected'; ?>>Rejected</option></select></div><div class="filter-group"><label>Search</label><input type="text" name="search" value="<?php echo h($search); ?>" placeholder="Search title, category, student"></div><button class="btn btn-red" type="submit">Apply Filter</button><a class="btn btn-grey" href="update_feedback.php">Reset</a></form>
<?php if (empty($filteredFeedbacks)): ?><div class="card empty-state"><h3>No feedback found</h3><p>No feedback records match the selected filter.</p></div><?php else: ?><div class="table-wrapper"><table><tr><th>ID</th><th>Student</th><th>Title</th><th>Category</th><th>Type</th><th>Status</th><th>Action</th></tr><?php foreach ($filteredFeedbacks as $fb): ?><tr><td><?php echo h($fb['id']); ?></td><td><?php echo h($fb['student_email']); ?></td><td><?php echo h($fb['title']); ?></td><td><?php echo h($fb['category']); ?></td><td><?php echo h($fb['type']); ?></td><td><span class="status-badge <?php echo h(statusClass($fb['status'])); ?>"><?php echo h($fb['status']); ?></span></td><td><a class="btn btn-red btn-small" href="view_details.php?id=<?php echo h($fb['id']); ?>">View Details</a></td></tr><?php endforeach; ?></table></div><?php endif; ?>
<div class="actions"><a class="btn btn-grey" href="admin_dashboard.php">Back to Admin Dashboard</a></div></div></body></html>
PHP

cat > view_details.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireAdmin();
$id = intval($_GET['id'] ?? 0);
$feedbacks = readFeedbacks();
$selectedIndex = null;
foreach ($feedbacks as $index => $fb) { if (($fb['id'] ?? 0) == $id) { $selectedIndex = $index; break; } }
if ($selectedIndex === null) { die("Feedback not found. <a href='update_feedback.php'>Back</a>"); }
if ($_SERVER["REQUEST_METHOD"] === "POST") { $feedbacks[$selectedIndex]['status'] = $_POST['status'] ?? 'Pending'; $feedbacks[$selectedIndex]['admin_response'] = trim($_POST['admin_response'] ?? ''); saveFeedbacks($feedbacks); logDemoEvent(currentUserEmail(), 'FEEDBACK_UPDATED', 'Updated feedback ID ' . $id); header("Location: update_feedback.php"); exit(); }
$fb = $feedbacks[$selectedIndex];
?>
<!DOCTYPE html>
<html><head><title>Feedback Details</title><link rel="stylesheet" href="cloud-demo.css"></head><body class="admin-theme">
<div class="navbar"><h2>Admin Panel</h2><a href="logout.php">Logout</a></div>
<div class="container"><h1>Feedback Details</h1><p class="subtitle">Detailed view of a selected feedback record.</p>
<div class="card"><h3><?php echo h($fb['title']); ?></h3><p><strong>Student:</strong> <?php echo h($fb['student_email']); ?></p><p><strong>Category:</strong> <?php echo h($fb['category']); ?></p><p><strong>Type:</strong> <?php echo h($fb['type']); ?></p><p><strong>Status:</strong> <span class="status-badge <?php echo h(statusClass($fb['status'])); ?>"><?php echo h($fb['status']); ?></span></p><p><strong>Description:</strong> <?php echo h($fb['description']); ?></p><p><strong>Created At:</strong> <?php echo h($fb['created_at']); ?></p></div>
<div class="card"><h3>Admin Update</h3><form method="POST"><label>Status</label><select name="status"><option <?php if (($fb['status'] ?? '') === 'Pending') echo 'selected'; ?>>Pending</option><option <?php if (($fb['status'] ?? '') === 'In Progress') echo 'selected'; ?>>In Progress</option><option <?php if (($fb['status'] ?? '') === 'Resolved') echo 'selected'; ?>>Resolved</option><option <?php if (($fb['status'] ?? '') === 'Rejected') echo 'selected'; ?>>Rejected</option></select><label>Admin Response</label><textarea name="admin_response"><?php echo h($fb['admin_response']); ?></textarea><button class="btn btn-red" type="submit">Save Update</button></form></div>
<div class="actions"><a class="btn btn-grey" href="update_feedback.php">Back to Manage Feedback</a></div></div></body></html>
PHP

cat > view_reports.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireAdmin();
$feedbacks = readFeedbacks();
$total = count($feedbacks);
$pending = count(array_filter($feedbacks, fn($fb) => ($fb['status'] ?? '') === 'Pending'));
$progress = count(array_filter($feedbacks, fn($fb) => ($fb['status'] ?? '') === 'In Progress'));
$resolved = count(array_filter($feedbacks, fn($fb) => ($fb['status'] ?? '') === 'Resolved'));
$rejected = count(array_filter($feedbacks, fn($fb) => ($fb['status'] ?? '') === 'Rejected'));
$categoryCounts = []; $typeCounts = [];
foreach ($feedbacks as $fb) { $category = $fb['category'] ?? 'Unknown'; $type = $fb['type'] ?? 'Unknown'; $categoryCounts[$category] = ($categoryCounts[$category] ?? 0) + 1; $typeCounts[$type] = ($typeCounts[$type] ?? 0) + 1; }
?>
<!DOCTYPE html>
<html><head><title>View Reports</title><link rel="stylesheet" href="cloud-demo.css"></head><body class="admin-theme">
<div class="navbar"><h2>Admin Panel</h2><a href="logout.php">Logout</a></div>
<div class="container"><h1>Feedback Reports</h1><p class="subtitle">Summary of feedback activity and system trends.</p>
<div class="stat-grid"><div class="stat-card"><h3>Total Feedback</h3><p><?php echo h($total); ?></p></div><div class="stat-card"><h3>Pending</h3><p><?php echo h($pending); ?></p></div><div class="stat-card"><h3>In Progress</h3><p><?php echo h($progress); ?></p></div><div class="stat-card"><h3>Resolved</h3><p><?php echo h($resolved); ?></p></div><div class="stat-card"><h3>Rejected</h3><p><?php echo h($rejected); ?></p></div></div>
<div class="card"><h3>Feedback by Category</h3><table><tr><th>Category</th><th>Count</th></tr><?php if (empty($categoryCounts)): ?><tr><td colspan="2">No data available</td></tr><?php else: ?><?php foreach ($categoryCounts as $category => $count): ?><tr><td><?php echo h($category); ?></td><td><?php echo h($count); ?></td></tr><?php endforeach; ?><?php endif; ?></table></div>
<div class="card"><h3>Feedback by Type</h3><table><tr><th>Type</th><th>Count</th></tr><?php if (empty($typeCounts)): ?><tr><td colspan="2">No data available</td></tr><?php else: ?><?php foreach ($typeCounts as $type => $count): ?><tr><td><?php echo h($type); ?></td><td><?php echo h($count); ?></td></tr><?php endforeach; ?><?php endif; ?></table></div>
<div class="actions"><a class="btn btn-grey" href="admin_dashboard.php">Back to Admin Dashboard</a></div></div></body></html>
PHP

cat > audit_logs.php <<'PHP'
<?php
require_once 'demo_lib.php';
requireAdmin();
$actionFilter = $_GET['action'] ?? 'All';
$userSearch = strtolower(trim($_GET['user'] ?? ''));
$logs = array_reverse(readAuditLogs());
$filteredLogs = array_filter($logs, function($log) use ($actionFilter, $userSearch) {
    $actionMatch = $actionFilter === 'All' || ($log['action'] ?? '') === $actionFilter;
    $userMatch = $userSearch === '' || strpos(strtolower($log['user'] ?? ''), $userSearch) !== false;
    return $actionMatch && $userMatch;
});
$actions = ['LOGIN', 'LOGOUT', 'REGISTER', 'FEEDBACK_SUBMITTED', 'FEEDBACK_EDITED', 'FEEDBACK_DELETED', 'FEEDBACK_UPDATED'];
?>
<!DOCTYPE html>
<html><head><title>Audit Logs</title><link rel="stylesheet" href="cloud-demo.css"></head><body class="admin-theme">
<div class="navbar"><h2>Admin Panel</h2><a href="logout.php">Logout</a></div>
<div class="container"><h1>Audit Logs</h1><p class="subtitle">Monitor user activity and administrative actions.</p>
<form method="GET" class="filter-bar"><div class="filter-group"><label>Action</label><select name="action"><option <?php if ($actionFilter === 'All') echo 'selected'; ?>>All</option><?php foreach ($actions as $action): ?><option value="<?php echo h($action); ?>" <?php if ($actionFilter === $action) echo 'selected'; ?>><?php echo h(formatAction($action)); ?></option><?php endforeach; ?></select></div><div class="filter-group"><label>User Email</label><input type="text" name="user" value="<?php echo h($userSearch); ?>" placeholder="Search by user email"></div><button class="btn btn-red" type="submit">Apply Filter</button><a class="btn btn-grey" href="audit_logs.php">Reset</a></form>
<?php if (empty($filteredLogs)): ?><div class="card empty-state"><h3>No audit logs found</h3><p>No audit records match the selected filter.</p></div><?php else: ?><div class="table-wrapper"><table><tr><th>Log ID</th><th>User</th><th>Action</th><th>Details</th><th>Time</th></tr><?php foreach ($filteredLogs as $log): ?><?php $action = $log['action'] ?? 'UNKNOWN'; ?><tr><td><?php echo h($log['id']); ?></td><td><?php echo h($log['user']); ?></td><td><span class="action-badge <?php echo h(actionClass($action)); ?>"><?php echo h(formatAction($action)); ?></span></td><td><?php echo h($log['details']); ?></td><td><?php echo h($log['time']); ?></td></tr><?php endforeach; ?></table></div><?php endif; ?>
<div class="actions"><a class="btn btn-grey" href="admin_dashboard.php">Back to Admin Dashboard</a></div></div></body></html>
PHP

chown -R www-data:www-data /var/www/html/demo_data
chmod -R 775 /var/www/html/demo_data
rm -f /var/lib/php/sessions/sess_* 2>/dev/null || true
systemctl restart apache2
