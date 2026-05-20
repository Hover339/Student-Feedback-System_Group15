<?php
session_start();
include 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = trim($_POST['name']);
    $email = trim($_POST['email']);
    $plain_password = $_POST['password'];
    $csrf_token = $_POST['csrf_token'] ?? '';

    if (!validateCsrfToken($csrf_token)) {
        logEvent($conn, null, 'CSRF_FAILED', "Invalid CSRF token during registration attempt for: {$email}");
        echo "<script>alert('Invalid request. Please refresh the page and try again.');</script>";
    } elseif (strlen($plain_password) < 6) {
        echo "<script>alert('Password must be at least 6 characters.');</script>";
    } else {
        $password = password_hash($plain_password, PASSWORD_DEFAULT);

        $sql = "INSERT INTO users (full_name, email, password_hash, role)
                OUTPUT INSERTED.user_id
                VALUES (?, ?, ?, 'student')";

        $params = [$name, $email, $password];

        $stmt = sqlsrv_query($conn, $sql, $params);

        if ($stmt && ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_NUMERIC))) {
            $new_user_id = intval($row[0]);

            logEvent(
                $conn,
                $new_user_id,
                'USER_REGISTERED',
                "New student account successfully created for: {$email}"
            );

            echo "<script>alert('Registration successful!'); window.location='login.php';</script>";
        } else {
            echo "<script>alert('Error: Email may already exist.');</script>";
        }
    }
}

$csrfToken = generateCsrfToken();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Register - Student Feedback System</title>
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
            max-width: 430px;
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

        .note {
            margin-top: -10px;
            margin-bottom: 18px;
            font-size: 12px;
            color: #64748b;
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

        .register-btn {
            background: #0f172a;
            color: white;
        }

        .register-btn:hover {
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
        <span>Student Registration</span>
    </div>

    <h2>Create Account</h2>
    <p class="subtitle">
        Register as a student to submit and track feedback securely.
    </p>

    <form method="POST">
        <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($csrfToken); ?>">

        <label>Full Name</label>
        <input type="text" name="name" placeholder="Enter your full name" required>

        <label>Email Address</label>
        <input type="email" name="email" placeholder="Enter your email" required>

        <label>Password</label>
        <input type="password" name="password" placeholder="Create a password" required>
        <div class="note">Password must be at least 6 characters.</div>

        <button type="submit" class="btn register-btn">Register</button>
    </form>

    <div class="links">
        <p>Already have an account? <a href="login.php">Login here</a></p>
        <p><a href="index.php">← Back to Homepage</a></p>
    </div>

    <div class="security-note">
        Passwords are securely hashed before storage and registration events are recorded in audit logs.
    </div>
</div>

</body>
</html>