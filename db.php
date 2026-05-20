<?php
$serverName = "localhost";

$connectionOptions = [
    "Database" => "StudentFeedbackSystem",
    "TrustServerCertificate" => true,
    "CharacterSet" => "UTF-8",
    "ReturnDatesAsStrings" => true
];

$conn = sqlsrv_connect($serverName, $connectionOptions);

if (!$conn) {
    die("SQL Server connection failed:<br>" . print_r(sqlsrv_errors(), true));
}

/*
|--------------------------------------------------------------------------
| Audit Log Function
|--------------------------------------------------------------------------
*/
function logEvent($conn, $user_id, $action, $details) {
    $sql = "INSERT INTO audit_logs (user_id, action, details) VALUES (?, ?, ?)";

    $params = [
        !empty($user_id) ? intval($user_id) : null,
        $action,
        $details
    ];

    $stmt = sqlsrv_query($conn, $sql, $params);

    return $stmt !== false;
}

/*
|--------------------------------------------------------------------------
| CSRF Token Helpers
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
| Used to protect sensitive database fields:
| - feedback.description
| - feedback.admin_response
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
| Masks email addresses before displaying them in PHP pages.
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