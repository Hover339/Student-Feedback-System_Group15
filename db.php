<?php
/*
|--------------------------------------------------------------------------
| Start Session
|--------------------------------------------------------------------------
| db.php may be included by pages that already called session_start().
| This prevents duplicate session warnings.
|--------------------------------------------------------------------------
*/
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/*
|--------------------------------------------------------------------------
| SQL Server Database Connection
|--------------------------------------------------------------------------
| This connection uses a dedicated least-privilege SQL Server login:
| student_feedback_app
|
| The login should be mapped to app_role in SQL Server.
|--------------------------------------------------------------------------
*/

$serverName = "localhost";

$connectionOptions = [
    "Database" => "StudentFeedbackSystem",
    "Uid" => "student_feedback_app",
    "PWD" => "StudentApp@12345",
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
| SQL Server Session Context for Row-Level Security
|--------------------------------------------------------------------------
| If user is not logged in yet, ActiveUserID is set to 0.
| This avoids NULL issues and makes guest users see no feedback rows.
|--------------------------------------------------------------------------
*/

$activeUserId = isset($_SESSION['user_id']) ? intval($_SESSION['user_id']) : 0;
$activeUserRole = isset($_SESSION['role']) ? $_SESSION['role'] : 'guest';

$setUserContextStmt = sqlsrv_query(
    $conn,
    "EXEC sys.sp_set_session_context N'ActiveUserID', ?",
    [$activeUserId]
);

if ($setUserContextStmt === false) {
    die("Failed to set SQL Server ActiveUserID session context:<br>" . print_r(sqlsrv_errors(), true));
}

$setRoleContextStmt = sqlsrv_query(
    $conn,
    "EXEC sys.sp_set_session_context N'ActiveUserRole', ?",
    [$activeUserRole]
);

if ($setRoleContextStmt === false) {
    die("Failed to set SQL Server ActiveUserRole session context:<br>" . print_r(sqlsrv_errors(), true));
}
/*
|--------------------------------------------------------------------------
| Audit Log Function
|--------------------------------------------------------------------------
| Application-level audit logs are stored in:
| security.audit_logs
|--------------------------------------------------------------------------
*/
function logEvent($conn, $user_id, $action, $details) {
    $sql = "INSERT INTO security.audit_logs (user_id, action, details) VALUES (?, ?, ?)";

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
| - app.feedback.description
| - app.feedback.admin_response
|
| Note:
| For assignment/local testing, the key is stored here for simplicity.
| In production, store this key in environment variables or outside web root.
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

    $cipherText = openssl_encrypt(
        $plainText,
        $method,
        $key,
        OPENSSL_RAW_DATA,
        $iv
    );

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

    $plainText = openssl_decrypt(
        $cipherText,
        $method,
        $key,
        OPENSSL_RAW_DATA,
        $iv
    );

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
| SQL Server Dynamic Data Masking is also applied at database level.
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