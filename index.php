<!DOCTYPE html>
<html>
<head>
    <title>Student Feedback System</title>
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
            color: #222;
        }

        .page-wrapper {
            width: 90%;
            max-width: 1000px;
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 20px 45px rgba(0, 0, 0, 0.22);
        }

        .hero {
            padding: 55px;
            background: linear-gradient(160deg, #ffffff, #eef8ff);
        }

        .badge {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 999px;
            background: #e3f2fd;
            color: #1565c0;
            font-size: 13px;
            font-weight: bold;
            margin-bottom: 20px;
        }

        .hero h1 {
            font-size: 42px;
            margin: 0 0 18px;
            color: #1f2937;
            line-height: 1.15;
        }

        .hero p {
            font-size: 16px;
            line-height: 1.7;
            color: #5f6b7a;
            margin-bottom: 30px;
        }

        .feature-list {
            display: grid;
            gap: 14px;
            margin-top: 25px;
        }

        .feature {
            background: white;
            padding: 14px 16px;
            border-radius: 14px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.06);
            color: #374151;
            font-size: 14px;
        }

        .action-panel {
            padding: 55px 40px;
            background: #0f172a;
            color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .action-panel h2 {
            margin: 0 0 10px;
            font-size: 28px;
        }

        .action-panel p {
            color: #cbd5e1;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .btn {
            width: 100%;
            display: block;
            text-align: center;
            text-decoration: none;
            padding: 14px 18px;
            border-radius: 12px;
            font-weight: bold;
            margin-bottom: 14px;
            transition: 0.25s;
        }

        .btn-primary {
            background: #38bdf8;
            color: #0f172a;
        }

        .btn-primary:hover {
            background: #0ea5e9;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: transparent;
            color: white;
            border: 1px solid #64748b;
        }

        .btn-secondary:hover {
            background: #1e293b;
            transform: translateY(-2px);
        }

        .footer-note {
            margin-top: 20px;
            font-size: 12px;
            color: #94a3b8;
            line-height: 1.5;
        }

        @media (max-width: 800px) {
            .page-wrapper {
                grid-template-columns: 1fr;
            }

            .hero, .action-panel {
                padding: 35px;
            }

            .hero h1 {
                font-size: 32px;
            }
        }
    </style>
</head>

<body>

<div class="page-wrapper">
    <div class="hero">
        <span class="badge">Secure Web-Based Feedback Platform</span>

        <h1>Student Feedback System</h1>

        <p>
            A secure platform for students to submit complaints, suggestions, and feedback,
            while allowing administrators to review, respond, and manage submissions responsibly.
        </p>

        <div class="feature-list">
            <div class="feature">🔐 Secure login with password hashing and account protection</div>
            <div class="feature">🛡️ Role-based access for students and administrators</div>
            <div class="feature">📋 Audit logging for accountability and traceability</div>
            <div class="feature">🔒 Encrypted feedback content for better data protection</div>
        </div>
    </div>

    <div class="action-panel">
        <h2>Get Started</h2>
        <p>
            Login to continue, or register a student account to submit new feedback.
        </p>

        <a href="login.php" class="btn btn-primary">Login</a>
        <a href="register.php" class="btn btn-secondary">Register as Student</a>

        <div class="footer-note">
            This system is designed with database security controls such as prepared statements,
            CSRF protection, audit logs, and data encryption.
        </div>
    </div>
</div>

</body>
</html>