<?php
session_start();
include 'db.php';

// Student-only access check
if (!isset($_SESSION['user_id']) || !isset($_SESSION['role']) || $_SESSION['role'] !== 'student') {
    header("Location: login.php");
    exit();
}

$csrfToken = generateCsrfToken();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Submit Feedback</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(to right, #4facfe, #00f2fe);
            min-height: 100vh;
        }

        .navbar {
            background: white;
            padding: 15px 30px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.15);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar h2 {
            margin: 0;
            color: #333;
        }

        .logout {
            text-decoration: none;
            background: #e74c3c;
            color: white;
            padding: 10px 18px;
            border-radius: 5px;
        }

        .logout:hover {
            background: #c0392b;
        }

        .container {
            width: 80%;
            max-width: 650px;
            margin: 40px auto;
            background: white;
            padding: 35px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .container h1 {
            margin-bottom: 5px;
            color: #333;
            text-align: left;
        }

        .container p.subtitle {
            color: #666;
            margin-bottom: 25px;
            text-align: left;
            font-size: 14px;
        }

        .back-link {
            display: block;
            text-align: left;
            margin-bottom: 20px;
            color: #2196F3;
            text-decoration: none;
            font-weight: bold;
            font-size: 14px;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #444;
            font-size: 14px;
        }

        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
            font-size: 14px;
            background: #f7f9fc;
        }

        .form-control:focus {
            border-color: #2196F3;
            outline: none;
            background: #ffffff;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            margin-top: 30px;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }

        .btn-submit {
            background: #2196F3;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 15px;
            font-weight: bold;
            transition: 0.2s;
        }

        .btn-submit:hover {
            background: #1976D2;
        }

        .cancel-container {
            text-align: center;
            margin-top: 20px;
        }

        .btn-cancel {
            color: #888;
            text-decoration: none;
            font-size: 14px;
            transition: 0.2s;
        }

        .btn-cancel:hover {
            color: #333;
            text-decoration: underline;
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>Student Feedback System</h2>
    <a class="logout" href="logout.php">Logout</a>
</div>

<div class="container">
    <a href="student_dashboard.php" class="back-link">← Back to Dashboard</a>

    <h1>Submit New Feedback</h1>
    <p class="subtitle">Please provide detailed information to help us review your submission effectively.</p>

    <form id="feedbackForm" method="POST" action="process_feedback.php" onsubmit="handleSubmit(event)">
        <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($csrfToken); ?>">

        <div class="form-group">
            <label for="type">Feedback Type</label>
            <select id="type" name="type" class="form-control" required>
                <option value="" disabled selected>Select feedback type...</option>
                <option value="Complaint">Complaint</option>
                <option value="Feedback">Feedback</option>
                <option value="Suggestion">Suggestion</option>
            </select>
        </div>

        <div class="form-group">
            <label for="category">Category</label>
            <select id="category" name="category" class="form-control" required>
                <option value="" disabled selected>Select a category...</option>
                <option value="Academic">Academic</option>
                <option value="Facilities">Campus Facilities</option>
                <option value="Hostel">Hostel</option>
                <option value="IT">IT Services / Wi-Fi</option>
                <option value="Student Affairs">Student Affairs</option>
                <option value="Others">Others</option>
            </select>
        </div>

        <div class="form-group">
            <label for="subject">Subject / Title</label>
            <input type="text" id="subject" name="subject" class="form-control" placeholder="Brief summary of your feedback" required>
        </div>

        <div class="form-group">
            <label for="description">Detailed Description</label>
            <textarea id="description" name="description" class="form-control" rows="6" placeholder="Provide as much context as possible..." required></textarea>
        </div>

        <div class="form-actions">
            <button type="submit" id="submitBtn" class="btn-submit">Submit Feedback</button>
        </div>
    </form>

    <div class="cancel-container">
        <a href="student_dashboard.php" class="btn-cancel">Cancel and Go Back</a>
    </div>
</div>

<script>
function handleSubmit(event) {
    event.preventDefault();

    const form = document.getElementById('feedbackForm');
    const submitBtn = document.getElementById('submitBtn');
    const formData = new FormData(form);

    submitBtn.innerText = "Submitting...";
    submitBtn.style.background = "#4caf50";
    submitBtn.disabled = true;

    fetch(form.action, {
        method: 'POST',
        body: formData
    })
    .then(response => response.text())
    .then(data => {
        if (data.trim() === "Success") {
            alert("Your feedback has been submitted successfully.");
            window.location.href = "my_feedback.php";
        } else {
            alert(data);
            submitBtn.innerText = "Submit Feedback";
            submitBtn.style.background = "#2196F3";
            submitBtn.disabled = false;
        }
    })
    .catch(error => {
        console.error('Error submitting form:', error);
        alert("An error occurred while submitting your feedback. Please try again.");

        submitBtn.innerText = "Submit Feedback";
        submitBtn.style.background = "#2196F3";
        submitBtn.disabled = false;
    });
}
</script>

</body>
</html>