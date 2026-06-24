#!/bin/bash
set -e

cd /var/www/html

cat >> cloud-demo.css <<'CSS'

/* ===== Polished Landing/Login/Register Pages ===== */

.auth-page {
    min-height: 100vh;
    background:
        radial-gradient(circle at 15% 20%, rgba(255,255,255,0.28), transparent 28%),
        radial-gradient(circle at 85% 10%, rgba(255,255,255,0.18), transparent 25%),
        linear-gradient(135deg, #0f172a 0%, #1e3a8a 45%, #06b6d4 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 35px;
}

.auth-shell {
    width: 100%;
    max-width: 1050px;
    min-height: 620px;
    display: grid;
    grid-template-columns: 1.1fr 0.9fr;
    background: rgba(255,255,255,0.12);
    border: 1px solid rgba(255,255,255,0.22);
    border-radius: 28px;
    overflow: hidden;
    box-shadow: 0 30px 80px rgba(0,0,0,0.35);
    backdrop-filter: blur(16px);
}

.auth-hero {
    padding: 60px;
    color: white;
    position: relative;
    overflow: hidden;
}

.auth-hero::after {
    content: "";
    position: absolute;
    width: 330px;
    height: 330px;
    right: -120px;
    bottom: -100px;
    background: rgba(255,255,255,0.12);
    border-radius: 50%;
}

.auth-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: rgba(255,255,255,0.16);
    border: 1px solid rgba(255,255,255,0.2);
    padding: 9px 14px;
    border-radius: 999px;
    font-size: 13px;
    font-weight: bold;
    margin-bottom: 24px;
}

.auth-hero h1 {
    color: white;
    text-align: left;
    font-size: 46px;
    line-height: 1.05;
    margin: 0 0 18px;
    letter-spacing: -1px;
}

.auth-hero p {
    color: rgba(255,255,255,0.82);
    font-size: 16px;
    line-height: 1.7;
    max-width: 520px;
}

.auth-feature-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 14px;
    margin-top: 34px;
    max-width: 520px;
}

.auth-feature {
    background: rgba(255,255,255,0.13);
    border: 1px solid rgba(255,255,255,0.18);
    border-radius: 18px;
    padding: 16px;
}

.auth-feature strong {
    display: block;
    font-size: 14px;
    margin-bottom: 5px;
}

.auth-feature span {
    display: block;
    font-size: 12px;
    color: rgba(255,255,255,0.72);
    line-height: 1.45;
}

.auth-panel {
    background: rgba(255,255,255,0.96);
    padding: 54px 46px;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.auth-panel h2 {
    margin: 0 0 8px;
    color: #0f172a;
    font-size: 30px;
}

.auth-panel .auth-subtitle {
    margin: 0 0 28px;
    color: #64748b;
    line-height: 1.55;
}

.auth-form label {
    display: block;
    font-size: 13px;
    color: #334155;
    font-weight: bold;
    margin-bottom: 7px;
}

.auth-input {
    width: 100%;
    margin: 0 0 16px;
    padding: 14px 14px;
    border: 1px solid #cbd5e1;
    border-radius: 14px;
    background: #f8fafc;
    outline: none;
    transition: 0.2s;
}

.auth-input:focus {
    border-color: #2563eb;
    background: white;
    box-shadow: 0 0 0 4px rgba(37,99,235,0.12);
}

.auth-primary-btn,
.auth-secondary-btn {
    width: 100%;
    border: none;
    border-radius: 14px;
    padding: 14px 16px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    text-align: center;
    display: inline-block;
    transition: 0.25s;
}

.auth-primary-btn {
    background: linear-gradient(135deg, #2563eb, #06b6d4);
    color: white;
    box-shadow: 0 12px 24px rgba(37,99,235,0.25);
}

.auth-primary-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 16px 30px rgba(37,99,235,0.32);
}

.auth-secondary-btn {
    background: #e2e8f0;
    color: #0f172a;
}

.auth-secondary-btn:hover {
    background: #cbd5e1;
}

.auth-link-row {
    margin-top: 18px;
    text-align: center;
    font-size: 14px;
    color: #64748b;
}

.auth-link-row a {
    color: #2563eb;
    font-weight: bold;
    text-decoration: none;
}

.auth-alert {
    padding: 12px 14px;
    border-radius: 14px;
    margin-bottom: 18px;
    font-size: 14px;
    text-align: left;
}

.auth-alert.error {
    background: #fee2e2;
    color: #991b1b;
}

.auth-alert.success {
    background: #dcfce7;
    color: #166534;
}

.auth-info-note {
    margin-top: 18px;
    padding: 14px;
    border-radius: 14px;
    background: #f1f5f9;
    color: #475569;
    font-size: 13px;
    line-height: 1.55;
}

.auth-info-note strong {
    color: #0f172a;
}

@media (max-width: 850px) {
    .auth-shell {
        grid-template-columns: 1fr;
    }

    .auth-hero {
        padding: 38px;
    }

    .auth-hero h1 {
        font-size: 34px;
    }

    .auth-feature-grid {
        grid-template-columns: 1fr;
    }

    .auth-panel {
        padding: 38px;
    }
}
CSS

cat > index.php <<'PHP'
<!DOCTYPE html>
<html>
<head>
    <title>Student Feedback System</title>
    <link rel="stylesheet" href="cloud-demo.css">
</head>
<body class="auth-page">

<div class="auth-shell">
    <section class="auth-hero">
        <div class="auth-badge">AWS Cloud Migration Demo</div>

        <h1>Student Feedback System</h1>

        <p>
            A secure cloud-based portal for students to submit feedback and for administrators
            to monitor, respond, and manage feedback records with audit visibility.
        </p>

        <div class="auth-feature-grid">
            <div class="auth-feature">
                <strong>Student Portal</strong>
                <span>Submit feedback, track status, edit pending records, and view responses.</span>
            </div>

            <div class="auth-feature">
                <strong>Admin Dashboard</strong>
                <span>Review feedback, update status, view reports, and monitor audit logs.</span>
            </div>

            <div class="auth-feature">
                <strong>Cloud Security</strong>
                <span>Hosted on AWS EC2 with Terraform-managed infrastructure and logging.</span>
            </div>

            <div class="auth-feature">
                <strong>Audit Trail</strong>
                <span>Login, registration, feedback changes, and admin actions are recorded.</span>
            </div>
        </div>
    </section>

    <section class="auth-panel">
        <h2>Welcome</h2>
        <p class="auth-subtitle">
            Login to continue, or create a student account to submit and track feedback.
        </p>

        <a class="auth-primary-btn" href="login.php">Login to Portal</a>

        <div style="height:12px;"></div>

        <a class="auth-secondary-btn" href="register.php">Create Student Account</a>

        <div class="auth-info-note">
            <strong>Role-based access enabled:</strong><br>
            Student and administrator dashboards are separated based on authenticated account role.
        </div>
    </section>
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
    <title>Login - Student Feedback System</title>
    <link rel="stylesheet" href="cloud-demo.css">
</head>
<body class="auth-page">

<div class="auth-shell">
    <section class="auth-hero">
        <div class="auth-badge">Secure Access</div>

        <h1>Login to your feedback portal</h1>

        <p>
            Students can submit and track feedback, while administrators can manage
            feedback records, reports, and audit logs.
        </p>

        <div class="auth-feature-grid">
            <div class="auth-feature">
                <strong>No role dropdown</strong>
                <span>The portal determines access based on authenticated account details.</span>
            </div>

            <div class="auth-feature">
                <strong>Protected dashboard</strong>
                <span>Student and admin pages are separated using session-based access control.</span>
            </div>

            <div class="auth-feature">
                <strong>Audit logging</strong>
                <span>Successful login and logout actions are recorded for monitoring.</span>
            </div>

            <div class="auth-feature">
                <strong>Cloud hosted</strong>
                <span>The application is deployed on AWS infrastructure using Terraform automation.</span>
            </div>
        </div>
    </section>

    <section class="auth-panel">
        <h2>Sign In</h2>
        <p class="auth-subtitle">Enter your account details to continue.</p>

        <?php if ($error): ?>
            <div class="auth-alert error"><?php echo h($error); ?></div>
        <?php endif; ?>

        <form method="POST" class="auth-form" autocomplete="off">
            <label>Email Address</label>
            <input class="auth-input" type="email" name="email" placeholder="student@example.com" required>

            <label>Password</label>
            <input class="auth-input" type="password" name="password" placeholder="Enter password" required>

            <button type="submit" class="auth-primary-btn">Login</button>
        </form>

        <div class="auth-link-row">
            New student? <a href="register.php">Create an account</a>
        </div>

        <div class="auth-link-row">
            <a href="index.php">Back to home</a>
        </div>

        <div class="auth-info-note">
            <strong>Access notice:</strong><br>
            Students must register before logging in. Administrator access is restricted to authorized accounts only.
        </div>
    </section>
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
    <title>Register - Student Feedback System</title>
    <link rel="stylesheet" href="cloud-demo.css">
</head>
<body class="auth-page">

<div class="auth-shell">
    <section class="auth-hero">
        <div class="auth-badge">Student Registration</div>

        <h1>Create your student account</h1>

        <p>
            Register a student account to submit feedback, manage pending submissions,
            and track the response from administrators.
        </p>

        <div class="auth-feature-grid">
            <div class="auth-feature">
                <strong>Submit feedback</strong>
                <span>Create complaints, suggestions, and general feedback records.</span>
            </div>

            <div class="auth-feature">
                <strong>Track progress</strong>
                <span>View pending, in-progress, resolved, and rejected feedback status.</span>
            </div>

            <div class="auth-feature">
                <strong>Edit pending items</strong>
                <span>Modify or delete your feedback before an admin starts processing it.</span>
            </div>

            <div class="auth-feature">
                <strong>Audit visibility</strong>
                <span>Important actions are logged for accountability and monitoring.</span>
            </div>
        </div>
    </section>

    <section class="auth-panel">
        <h2>Register</h2>
        <p class="auth-subtitle">Create a student account for the cloud feedback portal.</p>

        <?php if ($message): ?>
            <div class="auth-alert success"><?php echo h($message); ?></div>
        <?php endif; ?>

        <?php if ($error): ?>
            <div class="auth-alert error"><?php echo h($error); ?></div>
        <?php endif; ?>

        <form method="POST" class="auth-form" autocomplete="off">
            <label>Full Name</label>
            <input class="auth-input" type="text" name="name" placeholder="Enter full name" required>

            <label>Email Address</label>
            <input class="auth-input" type="email" name="email" placeholder="student@example.com" required>

            <label>Password</label>
            <input class="auth-input" type="password" name="password" placeholder="Minimum 4 characters" required>

            <button type="submit" class="auth-primary-btn">Create Account</button>
        </form>

        <div class="auth-link-row">
            Already registered? <a href="login.php">Login here</a>
        </div>

        <div class="auth-link-row">
            <a href="index.php">Back to home</a>
        </div>
    </section>
</div>

</body>
</html>
PHP

sudo chown www-data:www-data /var/www/html/index.php /var/www/html/login.php /var/www/html/register.php /var/www/html/cloud-demo.css || true
sudo systemctl restart apache2 || sudo service apache2 restart || true