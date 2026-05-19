# Student Feedback System

A secure PHP and MySQL-based Student Feedback System developed for a Database & Cloud Security assignment.

## Features
- Student registration and login
- Student dashboard
- Submit, view, modify, and delete feedback
- Admin dashboard
- Admin feedback management
- Reports page
- Audit logs

## Security Features
- Password hashing
- Prepared statements
- Role-based access control
- Session protection
- CSRF protection
- Account lockout
- Audit logging
- Feedback rate limiting
- Field-level encryption
- Dynamic email masking
- Student ownership checks

## Setup Instructions
1. Install XAMPP.
2. Start Apache and MySQL.
3. Copy this project folder into:
   `C:\xampp\htdocs\`
4. Open phpMyAdmin.
5. Create a database named:
   `student_feedback_system`
6. Import:
   `student_feedback_system.sql`
7. Run the system at:
   `http://localhost/student_feedback_system/`

## Default Notes
Register a new student account through the register page.  
Admin accounts can be created by updating the user role in the database.