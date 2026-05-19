<?php
session_start();
include 'db.php';

$maxAttempts = 5;
$lockoutMinutes = 5;

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = trim($_POST['email']);
    $password = $_POST['password'];
    $csrf_token = $_POST['csrf_token'] ?? '';

    if (!validateCsrfToken($csrf_token)) {
        logEvent($conn, null, 'CSRF_FAILED', "Invalid CSRF token during login attempt for: {$email}");
        echo "<script>alert('Invalid request. Please refresh the page and try again.');</script>";
    } else {
        $stmt = $conn->prepare("SELECT user_id, full_name, email, password_hash, role, failed_login_attempts, locked_until FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $stmt->bind_result($user_id, $full_name, $db_email, $password_hash, $role, $failed_attempts, $locked_until);

        if ($stmt->fetch()) {
            $stmt->close();

            if (!empty($locked_until) && strtotime($locked_until) > time()) {
                logEvent($conn, $user_id, 'LOGIN_LOCKED', "Blocked login attempt because account is locked for: {$email}");
                echo "<script>alert('Account temporarily locked. Please try again later.');</script>";
            } elseif (password_verify($password, $password_hash)) {
                $resetStmt = $conn->prepare("UPDATE users SET failed_login_attempts = 0, locked_until = NULL WHERE user_id = ?");
                $resetStmt->bind_param("i", $user_id);
                $resetStmt->execute();
                $resetStmt->close();

                session_regenerate_id(true);
                $_SESSION['user_id'] = $user_id;
                $_SESSION['role'] = $role;

                logEvent($conn, $user_id, 'USER_LOGIN', "Successful login event for user identity: {$email}");

                if ($role == 'admin') {
                    header("Location: admin_dashboard.php");
                } else {
                    header("Location: student_dashboard.php");
                }
                exit();
            } else {
                $failed_attempts++;
                $new_locked_until = null;

                if ($failed_attempts >= $maxAttempts) {
                    $new_locked_until = date("Y-m-d H:i:s", strtotime("+{$lockoutMinutes} minutes"));

                    $updateStmt = $conn->prepare("UPDATE users SET failed_login_attempts = ?, locked_until = ? WHERE user_id = ?");
                    $updateStmt->bind_param("isi", $failed_attempts, $new_locked_until, $user_id);
                    $updateStmt->execute();
                    $updateStmt->close();

                    logEvent($conn, $user_id, 'ACCOUNT_LOCKED', "Account locked after {$failed_attempts} failed login attempts for: {$email}");
                    echo "<script>alert('Too many failed login attempts. Account locked for {$lockoutMinutes} minutes.');</script>";
                } else {
                    $updateStmt = $conn->prepare("UPDATE users SET failed_login_attempts = ? WHERE user_id = ?");
                    $updateStmt->bind_param("ii", $failed_attempts, $user_id);
                    $updateStmt->execute();
                    $updateStmt->close();

                    $remaining = $maxAttempts - $failed_attempts;
                    logEvent($conn, $user_id, 'LOGIN_FAILED', "Incorrect password for account: {$email}. Remaining attempts: {$remaining}");
                    echo "<script>alert('Invalid password. Remaining attempts: {$remaining}');</script>";
                }
            }
        } else {
            $stmt->close();

            logEvent($conn, null, 'LOGIN_FAILED', "Failed login attempt. Account does not exist: {$email}");
            echo "<script>alert('User not found');</script>";
        }
    }
}

$csrfToken = generateCsrfToken();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Student Feedback System</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            min-height: 100vh;
            background: linear-gradient(135deg, #4facfe, #00f2fe);
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .auth-card {
            width: 90%;
            max-width: 420px;
            background: white;
            padding: 38px;
            border-radius: 22px;
            box-shadow: 0 20px 45px rgba(0, 0, 0, 0.22);
        }

        .logo {
            text-align: center;
            margin-bottom: 25px;
        }

        .logo span {
            display: inline-block;
            background: #e3f2fd;
            color: #1565c0;
            padding: 8px 14px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: bold;
        }

        h2 {
            margin: 0;
            text-align: center;
            color: #1f2937;
            font-size: 30px;
        }

        .subtitle {
            text-align: center;
            color: #64748b;
            font-size: 14px;
            margin: 12px 0 28px;
            line-height: 1.5;
        }

        label {
            display: block;
            margin-bottom: 7px;
            color: #374151;
            font-weight: bold;
            font-size: 14px;
        }

        input {
            width: 100%;
            padding: 13px;
            margin-bottom: 18px;
            border-radius: 12px;
            border: 1px solid #cbd5e1;
            font-size: 14px;
            background: #f8fafc;
            transition: 0.2s;
        }

        input:focus {
            outline: none;
            border-color: #38bdf8;
            background: white;
            box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.18);
        }

        .btn {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 12px;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.25s;
        }

        .login-btn {
            background: #0f172a;
            color: white;
        }

        .login-btn:hover {
            background: #1e293b;
            transform: translateY(-2px);
        }

        .links {
            margin-top: 20px;
            text-align: center;
            font-size: 14px;
            color: #64748b;
        }

        .links a {
            color: #0284c7;
            text-decoration: none;
            font-weight: bold;
        }

        .links a:hover {
            text-decoration: underline;
        }

        .security-note {
            margin-top: 22px;
            padding: 13px;
            border-radius: 12px;
            background: #f1f5f9;
            color: #64748b;
            font-size: 12px;
            line-height: 1.5;
            text-align: center;
        }
    </style>
</head>

<body>

<div class="auth-card">
    <div class="logo">
        <span>Secure Access</span>
    </div>

    <h2>Login</h2>
    <p class="subtitle">
        Access your dashboard to manage student feedback securely.
    </p>

    <form method="POST">
        <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($csrfToken); ?>">

        <label>Email Address</label>
        <input type="email" name="email" placeholder="Enter your email" required>

        <label>Password</label>
        <input type="password" name="password" placeholder="Enter your password" required>

        <button type="submit" class="btn login-btn">Login</button>
    </form>

    <div class="links">
        <p>New student? <a href="register.php">Create an account</a></p>
        <p><a href="index.php">← Back to Homepage</a></p>
    </div>

    <div class="security-note">
        Protected with CSRF token validation, password hashing, account lockout,
        and audit logging.
    </div>
</div>

</body>
</html>