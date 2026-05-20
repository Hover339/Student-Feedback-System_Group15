# Import Guide — Student Feedback System

This guide explains how to import and run the **Student Feedback System** on another device.

## 1. Required Software

Install these first:

1. **XAMPP** with PHP 8.2
2. **Microsoft SQL Server Developer Edition**
3. **SQL Server Management Studio (SSMS)**
4. **Microsoft ODBC Driver for SQL Server**
5. **Microsoft Drivers for PHP for SQL Server** matching PHP 8.2 Thread Safe x64

The PHP SQL Server driver files should be copied into the PHP extension folder, for example:

```text
C:\xampp\php\ext
```

Then enable these two extensions in `php.ini`:

```ini
extension=php_sqlsrv_82_ts_x64.dll
extension=php_pdo_sqlsrv_82_ts_x64.dll
```

After editing `php.ini`, restart Apache in XAMPP.

---

## 2. Clone the Project

Open PowerShell or Command Prompt and run:

```powershell
cd C:\xampp\htdocs

git clone https://github.com/Hover339/Student-Feedback-System.git student_feedback_system
```

The project should be located at:

```text
C:\xampp\htdocs\student_feedback_system
```

---

## 3. Create Required SQL Server Folders

Create these folders manually in File Explorer:

```text
C:\SQLAudit
C:\SQLBackups
C:\SQLKeys
```

These folders are used for audit files, backups, and SQL Server key/certificate storage.

Do **not** upload `.bak`, `.cer`, `.pvk`, or `.sqlaudit` files to public GitHub.

---

## 4. Connect to SQL Server in SSMS

Open SSMS and connect using:

```text
Server name: localhost
Authentication: Windows Authentication
Trust Server Certificate: ticked
```

If `localhost` does not work, try:

```text
tcp:localhost,1433
```

---

## 5. Enable Mixed Mode Authentication

The PHP application uses a dedicated SQL Server login named:

```text
student_feedback_app
```

So SQL Server must allow SQL Server Authentication.

In SSMS:

```text
Right-click localhost server
→ Properties
→ Security
→ Select "SQL Server and Windows Authentication mode"
→ OK
```

Then restart SQL Server:

```text
SQL Server Configuration Manager
→ SQL Server Services
→ SQL Server (MSSQLSERVER)
→ Restart
```

---

## 6. Import the Main Database

In SSMS, open the file:

```text
StudentFeedbackSystem_FullDatabase.sql
```

Run the full script.

This imports:

```text
StudentFeedbackSystem database
app.users
app.feedback
security.audit_logs
security.db_audit_logs
database schemas
constraints
triggers
Row-Level Security function and policy
sample data
```

If the database already exists, the script may drop and recreate objects depending on the export settings.

---

## 7. Run the Server Security Setup Script

After the main database script finishes, open and run:

```text
ServerSecurity_Setup.sql
```

Run it using Windows Authentication / administrator access.

This script sets up server-level and database-level security, including:

```text
student_feedback_app SQL login
app_role database role
feedback_security_user login
feedback_security_reviewer server role
SQL Server Audit
SQL login audit
SQL Agent job audit
xp_cmdshell and OLE Automation lockdown
metadata visibility restrictions
database permissions
```

If the script fails because of `C:\SQLAudit\`, make sure the folder exists.

---

## 8. Optional: Configure Static TCP Port 1433

Open SQL Server Configuration Manager:

```text
SQL Server Network Configuration
→ Protocols for MSSQLSERVER
```

Set:

```text
TCP/IP = Enabled
Named Pipes = Disabled
Shared Memory = Enabled
```

Then open:

```text
TCP/IP → Properties → IP Addresses → IPAll
```

Set:

```text
TCP Dynamic Ports = blank
TCP Port = 1433
```

Restart SQL Server.

To test TCP connection in SSMS, connect using:

```text
tcp:localhost,1433
```

Then run:

```sql
SELECT 
    session_id,
    net_transport,
    local_tcp_port,
    client_net_address
FROM sys.dm_exec_connections
WHERE session_id = @@SPID;
```

Expected:

```text
net_transport = TCP
local_tcp_port = 1433
```

---

## 9. Optional: Disable SQL Server Browser

Since the system uses a static port, SQL Server Browser is not required.

Open:

```text
SQL Server Configuration Manager
→ SQL Server Services
```

Find:

```text
SQL Server Browser
```

Set:

```text
Start Mode = Disabled
Status = Stopped
```

This reduces SQL Server instance discovery exposure.

---

## 10. Test the PHP Application

Open in browser:

```text
http://localhost/student_feedback_system/login.php
```

Test these functions:

```text
1. Register a new student
2. Login as student
3. Submit feedback
4. View My Feedback
5. View Feedback Details
6. Modify pending feedback
7. Delete feedback
8. Login as admin
9. Manage Feedback
10. View Reports
11. View Audit Logs
```

If PHP cannot connect to SQL Server, open `db.php` and change:

```php
$serverName = "localhost";
```

to:

```php
$serverName = "localhost,1433";
```

Then refresh the website.

---

## 11. TDE Note

Transparent Data Encryption (TDE) is server-specific because it depends on a SQL Server certificate and private key.

For normal testing, the app can run without restoring the original TDE certificate.

If TDE must be enabled on the new device, run a new TDE setup using that machine’s own certificate:

```sql
USE master;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM sys.symmetric_keys 
    WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterServerPassword99!!';
END
GO

IF NOT EXISTS (
    SELECT 1 
    FROM sys.certificates 
    WHERE name = 'TdeSystemCertificate'
)
BEGIN
    CREATE CERTIFICATE TdeSystemCertificate
    WITH SUBJECT = 'Feedback System TDE Cert';
END
GO

USE StudentFeedbackSystem;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.dm_database_encryption_keys
    WHERE database_id = DB_ID('StudentFeedbackSystem')
)
BEGIN
    CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE TdeSystemCertificate;
END
GO

ALTER DATABASE StudentFeedbackSystem
SET ENCRYPTION ON;
GO
```

Verify TDE:

```sql
SELECT 
    DB_NAME(database_id) AS database_name,
    encryption_state,
    CASE encryption_state
        WHEN 3 THEN 'Encrypted'
        ELSE 'Other State'
    END AS encryption_state_desc,
    key_algorithm,
    key_length
FROM sys.dm_database_encryption_keys
WHERE database_id = DB_ID('StudentFeedbackSystem');
```

Expected:

```text
encryption_state_desc = Encrypted
key_algorithm = AES
key_length = 256
```

---

## 12. Common Issues

### SQL Server connection failed for `student_feedback_app`

Check:

```text
1. Mixed Mode Authentication is enabled
2. SQL Server was restarted after enabling Mixed Mode
3. ServerSecurity_Setup.sql was executed successfully
4. student_feedback_app login exists
5. app_role permissions exist
```

Verify login:

```sql
USE master;
GO

SELECT name, is_disabled
FROM sys.sql_logins
WHERE name = 'student_feedback_app';
```

### PHP SQLSRV extension not loaded

Open:

```text
http://localhost/dashboard/phpinfo.php
```

Search for:

```text
sqlsrv
pdo_sqlsrv
```

If missing, check:

```text
php.ini extension lines
DLL files in C:\xampp\php\ext
Apache restarted
PHP version matches the SQLSRV driver version
```

### RLS shows no feedback for admin

Make sure `db.php` sets SQL Server session context after connection:

```php
EXEC sys.sp_set_session_context N'ActiveUserID', ?
EXEC sys.sp_set_session_context N'ActiveUserRole', ?
```

Admin role must be stored in session as:

```text
admin
```

### SQL Audit fails

Make sure this folder exists:

```text
C:\SQLAudit
```

Then rerun `ServerSecurity_Setup.sql`.

---

## 13. Recommended Import Order Summary

Use this order:

```text
1. Install XAMPP, SQL Server, SSMS, ODBC Driver, PHP SQLSRV driver
2. Clone project into C:\xampp\htdocs\student_feedback_system
3. Create C:\SQLAudit, C:\SQLBackups, C:\SQLKeys
4. Enable SQL Server Mixed Mode Authentication
5. Restart SQL Server
6. Run StudentFeedbackSystem_FullDatabase.sql
7. Run ServerSecurity_Setup.sql
8. Optional: configure TCP/IP static port 1433
9. Optional: disable SQL Server Browser
10. Restart Apache and SQL Server if needed
11. Open http://localhost/student_feedback_system/login.php
12. Test student and admin functions
```
