<?php
$host = "localhost";
$user = "root";
$password = "";
$database = "student_feedback_system";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}

/*
|--------------------------------------------------------------------------
| Audit Log Function
|--------------------------------------------------------------------------
| Used to record important user/admin/security actions.
|--------------------------------------------------------------------------
*/
function logEvent($conn, $user_id, $action, $details) {
    $stmt = $conn->prepare("INSERT INTO audit_logs (user_id, action, details) VALUES (?, ?, ?)");

    if (!$stmt) {
        return false;
    }

    $db_user_id = (!empty($user_id)) ? intval($user_id) : null;

    $stmt->bind_param("iss", $db_user_id, $action, $details);
    $result = $stmt->execute();
    $stmt->close();

    return $result;
}

/*
|--------------------------------------------------------------------------
| CSRF Token Helpers
|--------------------------------------------------------------------------
| Protects forms from Cross-Site Request Forgery attacks.
|--------------------------------------------------------------------------
*/
function generateCsrfToken() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }

    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }

    return $_SESSION['csrf_token'];
}

function validateCsrfToken($token) {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }

    return isset($_SESSION['csrf_token']) &&
           is_string($token) &&
           hash_equals($_SESSION['csrf_token'], $token);
}

/*
|--------------------------------------------------------------------------
| Field-Level Encryption Helpers
|--------------------------------------------------------------------------
| Used to protect sensitive database fields such as:
| - feedback.description
| - feedback.admin_response
|
| Note:
| For local assignment testing, the key is stored here for simplicity.
| In production, store the key outside the web root or in environment variables.
|--------------------------------------------------------------------------
*/
define('APP_ENCRYPTION_KEY', 'student_feedback_system_local_demo_key_2026_change_in_production');

function getEncryptionKey() {
    return hash('sha256', APP_ENCRYPTION_KEY, true);
}

function encryptSensitiveData($plainText) {
    if ($plainText === null || $plainText === '') {
        return $plainText;
    }

    // Prevent double encryption
    if (is_string($plainText) && strpos($plainText, 'ENC::') === 0) {
        return $plainText;
    }

    $method = 'AES-256-CBC';
    $key = getEncryptionKey();
    $ivLength = openssl_cipher_iv_length($method);
    $iv = random_bytes($ivLength);

    $cipherText = openssl_encrypt($plainText, $method, $key, OPENSSL_RAW_DATA, $iv);

    if ($cipherText === false) {
        return $plainText;
    }

    return 'ENC::' . base64_encode($iv . $cipherText);
}

function decryptSensitiveData($storedValue) {
    if ($storedValue === null || $storedValue === '') {
        return $storedValue;
    }

    // Old plaintext data still displays normally
    if (!is_string($storedValue) || strpos($storedValue, 'ENC::') !== 0) {
        return $storedValue;
    }

    $method = 'AES-256-CBC';
    $key = getEncryptionKey();

    $encoded = substr($storedValue, 5);
    $combined = base64_decode($encoded, true);

    if ($combined === false) {
        return '[Unable to decrypt data]';
    }

    $ivLength = openssl_cipher_iv_length($method);

    if (strlen($combined) <= $ivLength) {
        return '[Unable to decrypt data]';
    }

    $iv = substr($combined, 0, $ivLength);
    $cipherText = substr($combined, $ivLength);

    $plainText = openssl_decrypt($cipherText, $method, $key, OPENSSL_RAW_DATA, $iv);

    if ($plainText === false) {
        return '[Unable to decrypt data]';
    }

    return $plainText;
}

/*
|--------------------------------------------------------------------------
| Dynamic Data Masking Helper
|--------------------------------------------------------------------------
| Used to mask email addresses before displaying them in pages such as audit logs.
|
| Example:
| student123@gmail.com → s********3@gmail.com
|--------------------------------------------------------------------------
*/
function maskEmail($email) {
    if (empty($email) || $email === 'System / Guest') {
        return $email;
    }

    $parts = explode("@", $email);

    if (count($parts) !== 2) {
        return $email;
    }

    $name = $parts[0];
    $domain = $parts[1];
    $length = strlen($name);

    if ($length <= 1) {
        $maskedName = $name;
    } elseif ($length == 2) {
        $maskedName = substr($name, 0, 1) . "*";
    } else {
        $maskedName = substr($name, 0, 1) . str_repeat("*", $length - 2) . substr($name, -1);
    }

    return $maskedName . "@" . $domain;
}
?>