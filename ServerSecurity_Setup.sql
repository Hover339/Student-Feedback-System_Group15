/* ============================================================
   SERVER-LEVEL SECURITY SETUP
   Student Feedback System
   Run this AFTER importing StudentFeedbackSystem_FullDatabase.sql
   using Windows Authentication / SQL Server admin account.
============================================================ */

USE master;
GO

/* ============================================================
   1. SQL LOGIN FOR PHP APPLICATION
============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'student_feedback_app')
BEGIN
    CREATE LOGIN student_feedback_app
    WITH PASSWORD = 'StudentApp@12345',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
END
GO

USE StudentFeedbackSystem;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals
    WHERE name = 'student_feedback_app'
)
BEGIN
    CREATE USER student_feedback_app FOR LOGIN student_feedback_app;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals
    WHERE name = 'app_role'
)
BEGIN
    CREATE ROLE app_role AUTHORIZATION dbo;
END
GO

ALTER ROLE app_role ADD MEMBER student_feedback_app;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::app TO app_role;
GRANT SELECT, INSERT ON SCHEMA::security TO app_role;
GO


/* ============================================================
   2. SECURITY REVIEWER LOGIN + CUSTOM SERVER ROLE
============================================================ */

USE master;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.server_principals
    WHERE name = 'feedback_security_reviewer'
)
BEGIN
    CREATE SERVER ROLE feedback_security_reviewer AUTHORIZATION sa;
END
GO

GRANT VIEW SERVER STATE TO feedback_security_reviewer;
GRANT VIEW ANY DEFINITION TO feedback_security_reviewer;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.sql_logins
    WHERE name = 'feedback_security_user'
)
BEGIN
    CREATE LOGIN feedback_security_user
    WITH PASSWORD = 'SecurityUser@12345',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;
END
GO

ALTER SERVER ROLE feedback_security_reviewer
ADD MEMBER feedback_security_user;
GO

USE StudentFeedbackSystem;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals
    WHERE name = 'feedback_security_user'
)
BEGIN
    CREATE USER feedback_security_user FOR LOGIN feedback_security_user;
END
GO

GRANT VIEW DEFINITION TO feedback_security_user;
GO


/* ============================================================
   3. RESTRICT METADATA VISIBILITY FOR APPLICATION LOGIN
============================================================ */

USE master;
GO

DENY VIEW ANY DEFINITION TO student_feedback_app;
GO

USE StudentFeedbackSystem;
GO

DENY VIEW DEFINITION TO student_feedback_app;
GO


/* ============================================================
   4. SQL SERVER AUDIT OBJECT
   Make sure C:\SQLAudit\ exists before running this.
============================================================ */

USE master;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.server_file_audits
    WHERE name = 'StudentFeedback_Audit'
)
BEGIN
    CREATE SERVER AUDIT StudentFeedback_Audit
    TO FILE
    (
        FILEPATH = 'C:\SQLAudit\',
        MAXSIZE = 10 MB,
        MAX_ROLLOVER_FILES = 5
    );
END
GO

ALTER SERVER AUDIT StudentFeedback_Audit
WITH (STATE = ON);
GO


/* ============================================================
   5. DATABASE AUDIT SPECIFICATION
============================================================ */

USE StudentFeedbackSystem;
GO

IF EXISTS (
    SELECT 1 FROM sys.database_audit_specifications
    WHERE name = 'StudentFeedback_DB_Audit'
)
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION StudentFeedback_DB_Audit
    WITH (STATE = OFF);

    DROP DATABASE AUDIT SPECIFICATION StudentFeedback_DB_Audit;
END
GO

CREATE DATABASE AUDIT SPECIFICATION StudentFeedback_DB_Audit
FOR SERVER AUDIT StudentFeedback_Audit
ADD (INSERT, UPDATE, DELETE ON OBJECT::app.users BY public),
ADD (INSERT, UPDATE, DELETE ON OBJECT::app.feedback BY public),
ADD (INSERT ON OBJECT::security.audit_logs BY public),
ADD (INSERT ON OBJECT::security.db_audit_logs BY public)
WITH (STATE = ON);
GO


/* ============================================================
   6. SQL SERVER LOGIN AUDIT
============================================================ */

USE master;
GO

IF EXISTS (
    SELECT 1 FROM sys.server_audit_specifications
    WHERE name = 'StudentFeedback_Login_Audit'
)
BEGIN
    ALTER SERVER AUDIT SPECIFICATION StudentFeedback_Login_Audit
    WITH (STATE = OFF);

    DROP SERVER AUDIT SPECIFICATION StudentFeedback_Login_Audit;
END
GO

CREATE SERVER AUDIT SPECIFICATION StudentFeedback_Login_Audit
FOR SERVER AUDIT StudentFeedback_Audit
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (LOGOUT_GROUP)
WITH (STATE = ON);
GO


/* ============================================================
   7. DANGEROUS FEATURE LOCKDOWN
============================================================ */

USE master;
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
GO

EXEC sp_configure 'Ole Automation Procedures', 0;
RECONFIGURE;
GO

EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO


/* ============================================================
   8. SQL AGENT JOB AUDIT IN MSDB
============================================================ */

USE msdb;
GO

IF EXISTS (
    SELECT 1 FROM sys.database_audit_specifications
    WHERE name = 'Audit_SQL_Agent_Job_Changes'
)
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION Audit_SQL_Agent_Job_Changes
    WITH (STATE = OFF);

    DROP DATABASE AUDIT SPECIFICATION Audit_SQL_Agent_Job_Changes;
END
GO

CREATE DATABASE AUDIT SPECIFICATION Audit_SQL_Agent_Job_Changes
FOR SERVER AUDIT StudentFeedback_Audit
ADD (EXECUTE ON OBJECT::dbo.sp_add_job BY public),
ADD (EXECUTE ON OBJECT::dbo.sp_update_job BY public),
ADD (EXECUTE ON OBJECT::dbo.sp_delete_job BY public),
ADD (EXECUTE ON OBJECT::dbo.sp_add_jobstep BY public),
ADD (EXECUTE ON OBJECT::dbo.sp_update_jobstep BY public),
ADD (EXECUTE ON OBJECT::dbo.sp_delete_jobstep BY public),
ADD (EXECUTE ON OBJECT::dbo.sp_add_jobschedule BY public),
ADD (EXECUTE ON OBJECT::dbo.sp_update_schedule BY public),
ADD (EXECUTE ON OBJECT::dbo.sp_delete_schedule BY public)
WITH (STATE = ON);
GO


/* ============================================================
   9. TDE NOTE
   TDE certificate/private key files must be backed up separately.
   Do not upload .cer/.pvk files to public GitHub.
============================================================ */

/*
TDE was configured manually using:
- master key
- TdeSystemCertificate
- database encryption key
- ALTER DATABASE StudentFeedbackSystem SET ENCRYPTION ON

Certificate backup files:
C:\SQLKeys\TdeSystemCertificate.cer
C:\SQLKeys\TdeSystemCertificate_PrivateKey.pvk
*/


/* ============================================================
   10. NETWORK HARDENING NOTE
   These are configured in SQL Server Configuration Manager / Services.
============================================================ */

/*
Manual settings:
- TCP/IP enabled
- TCP Dynamic Ports cleared
- TCP Port set to 1433
- Named Pipes disabled
- SQL Server Browser disabled/stopped
*/