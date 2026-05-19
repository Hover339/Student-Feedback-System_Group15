<?php
session_start();
include 'db.php';

// Show errors during development/testing
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Student-only access check
if (!isset($_SESSION['user_id']) || !isset($_SESSION['role']) || $_SESSION['role'] !== 'student') {
    http_response_code(403);
    echo "Error: Only students are allowed to submit feedback.";
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $csrf_token = $_POST['csrf_token'] ?? '';

    if (!validateCsrfToken($csrf_token)) {
        logEvent($conn, $_SESSION['user_id'], 'CSRF_FAILED', 'Invalid CSRF token during feedback submission.');
        http_response_code(403);
        echo "Invalid request. Please refresh the page and try again.";
        exit();
    }

    $user_id = intval($_SESSION['user_id']);

    /*
    |--------------------------------------------------------------------------
    | Rate Limit Check
    |--------------------------------------------------------------------------
    | Student can only submit 1 feedback within 5 minutes.
    | This helps reduce spam submissions and basic DoS-style abuse.
    |--------------------------------------------------------------------------
    */
    $rateLimitStmt = $conn->prepare(
        "SELECT COUNT(*) 
         FROM feedback 
         WHERE user_id = ? 
         AND created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)"
    );

    if (!$rateLimitStmt) {
        http_response_code(500);
        echo "Database Error: Failed to prepare rate limit check.";
        exit();
    }

    $rateLimitStmt->bind_param("i", $user_id);
    $rateLimitStmt->execute();
    $rateLimitStmt->bind_result($recentSubmissionCount);
    $rateLimitStmt->fetch();
    $rateLimitStmt->close();

    if ($recentSubmissionCount >= 1) {
        logEvent(
            $conn,
            $user_id,
            'RATE_LIMIT_TRIGGERED',
            'Student attempted to submit more than 1 feedback within 5 minutes.'
        );

        http_response_code(429);
        echo "Rate limit reached. You can only submit 1 feedback every 5 minutes.";
        exit();
    }

    $type = isset($_POST['type']) ? trim($_POST['type']) : '';
    $category = isset($_POST['category']) ? trim($_POST['category']) : '';
    $title = isset($_POST['subject']) ? trim($_POST['subject']) : '';
    $description = isset($_POST['description']) ? trim($_POST['description']) : '';

    $allowedTypes = ['Complaint', 'Feedback', 'Suggestion'];
    $allowedCategories = ['Academic', 'Facilities', 'Hostel', 'IT', 'Student Affairs', 'Others'];

    if (!in_array($type, $allowedTypes, true)) {
        http_response_code(400);
        echo "Invalid feedback type.";
        exit();
    }

    if (!in_array($category, $allowedCategories, true)) {
        http_response_code(400);
        echo "Invalid category.";
        exit();
    }

    if ($title === '' || $description === '') {
        http_response_code(400);
        echo "Title and description are required.";
        exit();
    }

    $status = 'Pending';

    // Encrypt sensitive feedback description before saving into database
    $encryptedDescription = encryptSensitiveData($description);

    $query = "INSERT INTO feedback 
              (user_id, title, description, category, type, status, created_at, updated_at) 
              VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";

    $stmt = $conn->prepare($query);

    if (!$stmt) {
        http_response_code(500);
        echo "Database Error: Failed to prepare statement. " . $conn->error;
        exit();
    }

    $stmt->bind_param("isssss", $user_id, $title, $encryptedDescription, $category, $type, $status);

    if ($stmt->execute()) {
        $new_feedback_id = $conn->insert_id;

        logEvent(
            $conn,
            $user_id,
            'FEEDBACK_SUBMITTED',
            "Student submitted {$type} with feedback_id: {$new_feedback_id}. Description encrypted before database storage."
        );

        echo "Success";
    } else {
        http_response_code(500);
        echo "Database Error: Failed to submit feedback. " . $stmt->error;
    }

    $stmt->close();
} else {
    http_response_code(405);
    echo "Method Not Allowed";
}

$conn->close();
?>