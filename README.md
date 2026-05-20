# Student Feedback System

A secure PHP and Microsoft SQL Server-based Student Feedback System developed for a Database & Cloud Security assignment.

## Project Overview

The Student Feedback System is a web-based platform that allows students to submit complaints, feedback, and suggestions. Administrators can review submissions, update feedback status, provide responses, view reports, and monitor system activity through audit logs.

The system focuses not only on basic web application functionality, but also on database security controls, privacy protection, and secure access management.

## Technology Stack

- Frontend: HTML, CSS, JavaScript
- Backend: PHP
- Web Server: Apache using XAMPP
- Database: Microsoft SQL Server Developer Edition
- Database Management Tool: SQL Server Management Studio (SSMS)
- PHP Database Driver: Microsoft SQL Server PHP Driver (`sqlsrv` / `pdo_sqlsrv`)

## Features

- Student registration and login
- Student dashboard
- Submit complaint, feedback, or suggestion
- View submitted feedback
- Modify pending feedback
- Delete feedback
- Admin dashboard
- Admin feedback management
- Admin response and status update
- Reports page
- Audit logs with action filtering
- Feedback submission rate limiting

## Security Features

- Password hashing using PHP `password_hash()`
- Prepared statements using SQL Server parameterized queries
- Role-based access control for student and admin users
- Session-based authentication
- Session ID regeneration after login
- CSRF token protection for forms
- Account lockout after multiple failed login attempts
- Audit logging for important system and security events
- Feedback submission rate limiting
- Field-level encryption for sensitive feedback descriptions and admin responses
- Dynamic email masking
- Student ownership checks to prevent unauthorized access to other users' feedback
- SQL Server database constraints and foreign keys
- SQL Server Dynamic Data Masking for user email column

## Database Security Controls

The system uses Microsoft SQL Server Developer Edition as the database backend. The database includes:

- Primary keys
- Foreign key relationships
- CHECK constraints for valid roles, feedback types, categories, and statuses
- Dynamic Data Masking for user email addresses
- Encrypted sensitive feedback data stored in the database
- Audit log table for accountability and traceability

## Setup Instructions

### 1. Install Required Software

Install the following:

- XAMPP
- Microsoft SQL Server Developer Edition
- SQL Server Management Studio (SSMS)
- Microsoft ODBC Driver for SQL Server
- Microsoft PHP SQL Server Drivers (`sqlsrv` and `pdo_sqlsrv`)

### 2. Configure PHP SQL Server Driver

Copy the SQL Server PHP driver DLL files into:

```text
C:\xampp\php\ext