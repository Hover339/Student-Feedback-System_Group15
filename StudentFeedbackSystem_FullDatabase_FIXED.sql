USE [master]
GO

/* Portable setup wrapper added for teammate import.
   This avoids fixed .mdf/.ldf paths and creates required SQL logins
   before database users are created.
*/

IF DB_ID(N'StudentFeedbackSystem') IS NOT NULL
BEGIN
    ALTER DATABASE [StudentFeedbackSystem] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [StudentFeedbackSystem];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'student_feedback_app')
BEGIN
    CREATE LOGIN [student_feedback_app]
    WITH PASSWORD = 'StudentApp@12345',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
END
ELSE
BEGIN
    ALTER LOGIN [student_feedback_app]
    WITH PASSWORD = 'StudentApp@12345',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'feedback_security_user')
BEGIN
    CREATE LOGIN [feedback_security_user]
    WITH PASSWORD = 'SecurityUser@12345',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;
END
ELSE
BEGIN
    ALTER LOGIN [feedback_security_user]
    WITH PASSWORD = 'SecurityUser@12345',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;
END
GO

CREATE DATABASE [StudentFeedbackSystem];
GO

USE [StudentFeedbackSystem]
GO
/****** Object:  User [student_feedback_app]    Script Date: 20/5/2026 7:35:29 PM ******/
CREATE USER [student_feedback_app] FOR LOGIN [student_feedback_app] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [feedback_security_user]    Script Date: 20/5/2026 7:35:29 PM ******/
CREATE USER [feedback_security_user] FOR LOGIN [feedback_security_user] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [app_role]    Script Date: 20/5/2026 7:35:29 PM ******/
CREATE ROLE [app_role]
GO
ALTER ROLE [app_role] ADD MEMBER [student_feedback_app]
GO
GRANT CONNECT TO [feedback_security_user] AS [dbo]
GO
GRANT VIEW DEFINITION TO [feedback_security_user] AS [dbo]
GO
GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [public] AS [dbo]
GO
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [public] AS [dbo]
GO
DENY VIEW DEFINITION TO [student_feedback_app] AS [dbo]
GO
GRANT CONNECT TO [student_feedback_app] AS [dbo]
GO
/****** Object:  Schema [app]    Script Date: 20/5/2026 7:35:29 PM ******/
CREATE SCHEMA [app]
GO
GRANT DELETE ON SCHEMA::[app] TO [app_role] AS [dbo]
GO
GRANT INSERT ON SCHEMA::[app] TO [app_role] AS [dbo]
GO
GRANT SELECT ON SCHEMA::[app] TO [app_role] AS [dbo]
GO
GRANT UPDATE ON SCHEMA::[app] TO [app_role] AS [dbo]
GO
GRANT VIEW DEFINITION ON SCHEMA::[app] TO [feedback_security_user] AS [dbo]
GO
/****** Object:  Schema [security]    Script Date: 20/5/2026 7:35:29 PM ******/
CREATE SCHEMA [security]
GO
GRANT INSERT ON SCHEMA::[security] TO [app_role] AS [dbo]
GO
GRANT SELECT ON SCHEMA::[security] TO [app_role] AS [dbo]
GO
GRANT VIEW DEFINITION ON SCHEMA::[security] TO [feedback_security_user] AS [dbo]
GO
/****** Object:  UserDefinedFunction [security].[fn_feedback_rls]    Script Date: 20/5/2026 7:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [security].[fn_feedback_rls]
(
    @user_id INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_security_predicate_result
    WHERE
        @user_id = CAST(SESSION_CONTEXT(N'ActiveUserID') AS INT)
        OR CAST(SESSION_CONTEXT(N'ActiveUserRole') AS NVARCHAR(20)) = N'admin'
);
GO
/****** Object:  Table [app].[feedback]    Script Date: 20/5/2026 7:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[feedback](
	[feedback_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[title] [varchar](150) NOT NULL,
	[description] [nvarchar](max) NOT NULL,
	[category] [varchar](50) NOT NULL,
	[type] [varchar](20) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[admin_response] [nvarchar](max) NULL,
	[created_at] [datetime] NOT NULL,
	[updated_at] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[feedback_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [app].[users]    Script Date: 20/5/2026 7:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[users](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[full_name] [varchar](100) NOT NULL,
	[email] [varchar](100) MASKED WITH (FUNCTION = 'email()') NOT NULL,
	[password_hash] [varchar](255) NOT NULL,
	[role] [varchar](20) NOT NULL,
	[failed_login_attempts] [int] NOT NULL,
	[locked_until] [datetime] NULL,
	[created_at] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [security].[audit_logs]    Script Date: 20/5/2026 7:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [security].[audit_logs](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[action] [varchar](100) NOT NULL,
	[details] [nvarchar](max) NULL,
	[created_at] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [security].[db_audit_logs]    Script Date: 20/5/2026 7:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [security].[db_audit_logs](
	[db_log_id] [int] IDENTITY(1,1) NOT NULL,
	[table_name] [varchar](100) NOT NULL,
	[action_type] [varchar](20) NOT NULL,
	[record_id] [int] NULL,
	[performed_by] [varchar](200) NOT NULL,
	[details] [nvarchar](max) NULL,
	[created_at] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[db_log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  SecurityPolicy [security].[FeedbackRLS]    Script Date: 20/5/2026 7:35:29 PM ******/
CREATE SECURITY POLICY [security].[FeedbackRLS] 
ADD FILTER PREDICATE [security].[fn_feedback_rls]([user_id]) ON [app].[feedback]
WITH (STATE = ON, SCHEMABINDING = ON)
GO
SET IDENTITY_INSERT [app].[users] ON 

INSERT [app].[users] ([user_id], [full_name], [email], [password_hash], [role], [failed_login_attempts], [locked_until], [created_at]) VALUES (1, N'Student2', N'student2@gmail.com', N'$2y$10$8QroVVf/3Ctms/2NrLXvSekbVTrWjNAihvk31AwyIwjH2rS4Vgqe.', N'student', 0, NULL, CAST(N'2026-05-20T12:32:39.177' AS DateTime))
INSERT [app].[users] ([user_id], [full_name], [email], [password_hash], [role], [failed_login_attempts], [locked_until], [created_at]) VALUES (2, N'admin1', N'admin1@gmail.com', N'$2y$10$LIfAzwLv0OXWzYfoynCawOhpqJ0EoGpw3gx2cs9Roym1IiZixaJ6S', N'admin', 0, NULL, CAST(N'2026-05-20T12:43:12.830' AS DateTime))
INSERT [app].[users] ([user_id], [full_name], [email], [password_hash], [role], [failed_login_attempts], [locked_until], [created_at]) VALUES (5, N'student3', N'student3@gmail.com', N'$2y$10$DyctE9cj2tjvLaxLjtwy1edE1xaqIphPfSIC6GE/ckrZhqU1W/hgS', N'student', 0, NULL, CAST(N'2026-05-20T16:51:05.480' AS DateTime))
INSERT [app].[users] ([user_id], [full_name], [email], [password_hash], [role], [failed_login_attempts], [locked_until], [created_at]) VALUES (6, N'Student4', N'student4@gmail.com', N'$2y$10$h9OgFgX3eVnRvSepKjzmL.nnU4rJ.nP4VyAld1LRaqTM7kycMRJWm', N'student', 0, NULL, CAST(N'2026-05-20T18:40:11.820' AS DateTime))
SET IDENTITY_INSERT [app].[users] OFF
GO
SET IDENTITY_INSERT [security].[audit_logs] ON 

INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (1, 1, N'USER_REGISTERED', N'New student account successfully created for: student2@gmail.com', CAST(N'2026-05-20T12:32:39.187' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (2, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T12:34:07.940' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (3, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T12:34:07.947' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (4, 1, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T12:35:30.070' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (5, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T12:35:33.147' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (6, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T12:35:33.150' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (7, 1, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T12:36:54.890' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (8, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T12:36:58.017' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (9, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T12:36:58.020' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (10, 1, N'FEEDBACK_SUBMITTED', N'Student submitted Feedback with feedback_id: 1. Description encrypted before database storage.', CAST(N'2026-05-20T12:37:38.223' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (11, 1, N'FEEDBACK_MODIFIED', N'Student modified feedback_id: 1. Description encrypted before database update.', CAST(N'2026-05-20T12:39:19.820' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (12, 1, N'FEEDBACK_DETAIL_VIEWED', N'Student viewed feedback_id: 1', CAST(N'2026-05-20T12:40:20.633' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (13, 1, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T12:42:18.547' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (14, 2, N'USER_REGISTERED', N'New student account successfully created for: admin1@gmail.com', CAST(N'2026-05-20T12:43:12.833' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (15, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T12:44:23.747' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (16, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 1', CAST(N'2026-05-20T12:45:57.110' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (17, 2, N'FEEDBACK_UPDATED', N'Admin updated feedback_id: 1. Status changed from ''Pending'' to ''Resolved''. Admin response encrypted before database storage.', CAST(N'2026-05-20T12:46:17.277' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (18, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 1', CAST(N'2026-05-20T12:46:17.280' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (19, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T12:46:40.520' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (20, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T12:46:46.960' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (21, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T12:46:46.963' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (22, 1, N'FEEDBACK_DETAIL_VIEWED', N'Student viewed feedback_id: 1', CAST(N'2026-05-20T12:46:52.293' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (23, 1, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T12:48:20.550' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (24, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T12:48:23.860' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (25, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T13:52:36.270' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (26, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T14:56:56.487' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (27, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 1', CAST(N'2026-05-20T14:56:57.993' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (28, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T14:57:08.500' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (29, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T14:57:15.580' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (30, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T14:57:15.587' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (31, 1, N'FEEDBACK_SUBMITTED', N'Student submitted Suggestion with feedback_id: 2. Description encrypted before database storage.', CAST(N'2026-05-20T14:57:41.507' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (32, 1, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T14:57:44.623' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (33, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T14:57:48.597' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (34, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 2', CAST(N'2026-05-20T14:57:49.373' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (35, 2, N'FEEDBACK_UPDATED', N'Admin updated feedback_id: 2. Status changed from ''Pending'' to ''In Progress''. Admin response encrypted before database storage.', CAST(N'2026-05-20T14:57:53.600' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (36, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 2', CAST(N'2026-05-20T14:57:53.600' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (37, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T15:07:32.533' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (38, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 2', CAST(N'2026-05-20T15:07:33.560' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (39, 2, N'FEEDBACK_UPDATED', N'Admin updated feedback_id: 2. Status changed from ''In Progress'' to ''Pending''. Admin response encrypted before database storage.', CAST(N'2026-05-20T15:07:37.803' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (40, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 2', CAST(N'2026-05-20T15:07:37.803' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (41, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T15:07:43.740' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (42, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T15:07:51.577' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (43, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T15:07:51.580' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (44, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T15:07:55.517' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (45, NULL, N'PRIVILEGE_TEST', N'Testing least privilege INSERT permission.', CAST(N'2026-05-20T15:18:12.210' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (46, 1, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T16:14:56.100' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (47, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T16:14:59.583' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (48, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 2', CAST(N'2026-05-20T16:15:00.633' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (49, 2, N'FEEDBACK_UPDATED', N'Admin updated feedback_id: 2. Status changed from ''Pending'' to ''Resolved''. Admin response encrypted before database storage.', CAST(N'2026-05-20T16:15:04.410' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (50, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 2', CAST(N'2026-05-20T16:15:04.413' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (51, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T16:15:05.650' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (52, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T16:19:35.453' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (53, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T16:19:35.463' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (54, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T16:26:55.463' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (55, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T16:26:55.470' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (56, 5, N'USER_REGISTERED', N'New student account successfully created for: student3@gmail.com', CAST(N'2026-05-20T16:51:05.507' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (57, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T16:52:29.200' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (58, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T16:52:29.210' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (59, 1, N'FEEDBACK_SUBMITTED', N'Student submitted Feedback with feedback_id: 3. Description encrypted before database storage.', CAST(N'2026-05-20T16:54:51.503' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (60, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T16:57:03.703' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (61, 1, N'FEEDBACK_DETAIL_VIEWED', N'Student viewed feedback_id: 3', CAST(N'2026-05-20T16:58:35.273' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (62, 1, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T17:00:31.060' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (63, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T17:00:34.290' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (64, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 3', CAST(N'2026-05-20T17:00:35.743' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (65, 2, N'FEEDBACK_UPDATED', N'Admin updated feedback_id: 3. Status changed from ''Pending'' to ''In Progress''. Admin response encrypted before database storage.', CAST(N'2026-05-20T17:00:40.013' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (66, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 3', CAST(N'2026-05-20T17:00:40.013' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (67, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T17:27:00.927' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (68, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T17:29:19.117' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (69, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T17:29:19.123' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (70, 1, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T17:39:19.087' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (71, 5, N'LOGIN_FAILED', N'Incorrect password for account: student3@gmail.com. Remaining attempts: 4', CAST(N'2026-05-20T17:39:24.930' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (72, 5, N'USER_LOGIN', N'Successful login event for user identity: student3@gmail.com', CAST(N'2026-05-20T17:39:33.160' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (73, 5, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T17:39:33.167' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (74, 5, N'FEEDBACK_SUBMITTED', N'Student submitted Complaint with feedback_id: 4. Description encrypted before database storage.', CAST(N'2026-05-20T17:39:51.583' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (75, 5, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T18:29:20.987' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (76, 6, N'USER_REGISTERED', N'New student account successfully created for: student4@gmail.com', CAST(N'2026-05-20T18:40:11.833' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (77, 6, N'USER_LOGIN', N'Successful login event for user identity: student4@gmail.com', CAST(N'2026-05-20T18:40:19.037' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (78, 6, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T18:40:19.043' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (79, 6, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T18:40:23.997' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (80, 6, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T18:40:26.007' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (81, 6, N'FEEDBACK_SUBMITTED', N'Student submitted Complaint with feedback_id: 5. Description encrypted before database storage.', CAST(N'2026-05-20T18:40:34.650' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (82, 6, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T18:40:38.513' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (83, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T18:40:40.890' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (84, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 5', CAST(N'2026-05-20T18:40:41.757' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (85, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T19:01:21.863' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (86, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T19:02:18.747' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (87, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T19:02:20.387' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (88, 5, N'USER_LOGIN', N'Successful login event for user identity: student3@gmail.com', CAST(N'2026-05-20T19:02:29.497' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (89, 5, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T19:02:29.503' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (90, 5, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T19:17:54.827' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (91, 5, N'USER_LOGIN', N'Successful login event for user identity: student3@gmail.com', CAST(N'2026-05-20T19:24:15.967' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (92, 5, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T19:24:15.973' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (93, 5, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T19:24:17.297' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (94, 2, N'USER_LOGIN', N'Successful login event for user identity: admin1@gmail.com', CAST(N'2026-05-20T19:24:20.190' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (95, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 5', CAST(N'2026-05-20T19:24:21.403' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (96, 2, N'FEEDBACK_UPDATED', N'Admin updated feedback_id: 5. Status changed from ''Pending'' to ''In Progress''. Admin response encrypted before database storage.', CAST(N'2026-05-20T19:24:24.177' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (97, 2, N'FEEDBACK_LIST_VIEWED', N'Admin viewed the full feedback management list. Total records available: 5', CAST(N'2026-05-20T19:24:24.177' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (98, 2, N'LOGOUT', N'User logged out successfully.', CAST(N'2026-05-20T19:24:26.583' AS DateTime))
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (99, 1, N'USER_LOGIN', N'Successful login event for user identity: student2@gmail.com', CAST(N'2026-05-20T19:24:30.510' AS DateTime))
GO
INSERT [security].[audit_logs] ([log_id], [user_id], [action], [details], [created_at]) VALUES (100, 1, N'DASHBOARD_ACCESS', N'Student accessed their dashboard.', CAST(N'2026-05-20T19:24:30.520' AS DateTime))
SET IDENTITY_INSERT [security].[audit_logs] OFF
GO
SET IDENTITY_INSERT [security].[db_audit_logs] ON 

INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (1, N'feedback', N'UPDATE', 1, N'MSI\User', N'Feedback record updated. Old status: Resolved, New status: Resolved, Title: Slow wifi', CAST(N'2026-05-20T16:14:37.733' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (2, N'audit_logs', N'INSERT', 46, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T16:14:56.103' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (3, N'users', N'UPDATE', 2, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T16:14:59.583' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (4, N'audit_logs', N'INSERT', 47, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T16:14:59.583' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (5, N'audit_logs', N'INSERT', 48, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_LIST_VIEWED', CAST(N'2026-05-20T16:15:00.633' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (6, N'feedback', N'UPDATE', 2, N'student_feedback_app', N'Feedback record updated. Old status: Pending, New status: Resolved, Title: More charger', CAST(N'2026-05-20T16:15:04.407' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (7, N'audit_logs', N'INSERT', 49, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_UPDATED', CAST(N'2026-05-20T16:15:04.410' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (8, N'audit_logs', N'INSERT', 50, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_LIST_VIEWED', CAST(N'2026-05-20T16:15:04.413' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (9, N'audit_logs', N'INSERT', 51, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T16:15:05.653' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (10, N'users', N'UPDATE', 1, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T16:19:35.450' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (11, N'audit_logs', N'INSERT', 52, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T16:19:35.457' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (12, N'audit_logs', N'INSERT', 53, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T16:19:35.467' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (13, N'users', N'UPDATE', 1, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T16:26:55.460' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (14, N'audit_logs', N'INSERT', 54, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T16:26:55.463' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (15, N'audit_logs', N'INSERT', 55, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T16:26:55.470' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (16, N'app.users', N'INSERT', 5, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T16:51:05.503' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (17, N'security.audit_logs', N'INSERT', 56, N'student_feedback_app', N'Application audit log inserted. Action: USER_REGISTERED', CAST(N'2026-05-20T16:51:05.510' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (18, N'app.users', N'UPDATE', 1, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T16:52:29.197' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (19, N'security.audit_logs', N'INSERT', 57, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T16:52:29.203' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (20, N'security.audit_logs', N'INSERT', 58, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T16:52:29.210' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (21, N'app.feedback', N'INSERT', 3, N'student_feedback_app', N'New feedback record inserted. Title: More timeslot, Status: Pending', CAST(N'2026-05-20T16:54:51.500' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (22, N'security.audit_logs', N'INSERT', 59, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_SUBMITTED', CAST(N'2026-05-20T16:54:51.507' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (23, N'security.audit_logs', N'INSERT', 60, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T16:57:03.710' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (24, N'security.audit_logs', N'INSERT', 61, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_DETAIL_VIEWED', CAST(N'2026-05-20T16:58:35.277' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (25, N'security.audit_logs', N'INSERT', 62, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T17:00:31.063' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (26, N'app.users', N'UPDATE', 2, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T17:00:34.290' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (27, N'security.audit_logs', N'INSERT', 63, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T17:00:34.290' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (28, N'security.audit_logs', N'INSERT', 64, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_LIST_VIEWED', CAST(N'2026-05-20T17:00:35.743' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (29, N'app.feedback', N'UPDATE', 3, N'student_feedback_app', N'Feedback record updated. Old status: Pending, New status: In Progress, Title: More timeslot', CAST(N'2026-05-20T17:00:40.010' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (30, N'security.audit_logs', N'INSERT', 65, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_UPDATED', CAST(N'2026-05-20T17:00:40.013' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (31, N'security.audit_logs', N'INSERT', 66, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_LIST_VIEWED', CAST(N'2026-05-20T17:00:40.013' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (32, N'security.audit_logs', N'INSERT', 67, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T17:27:00.930' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (33, N'app.users', N'UPDATE', 1, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T17:29:19.110' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (34, N'security.audit_logs', N'INSERT', 68, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T17:29:19.117' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (35, N'security.audit_logs', N'INSERT', 69, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T17:29:19.123' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (36, N'security.audit_logs', N'INSERT', 70, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T17:39:19.093' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (37, N'app.users', N'UPDATE', 5, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T17:39:24.927' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (38, N'security.audit_logs', N'INSERT', 71, N'student_feedback_app', N'Application audit log inserted. Action: LOGIN_FAILED', CAST(N'2026-05-20T17:39:24.930' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (39, N'app.users', N'UPDATE', 5, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T17:39:33.160' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (40, N'security.audit_logs', N'INSERT', 72, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T17:39:33.160' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (41, N'security.audit_logs', N'INSERT', 73, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T17:39:33.170' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (42, N'app.feedback', N'INSERT', 4, N'student_feedback_app', N'New feedback record inserted. Title: Toilet Dirty, Status: Pending', CAST(N'2026-05-20T17:39:51.580' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (43, N'security.audit_logs', N'INSERT', 74, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_SUBMITTED', CAST(N'2026-05-20T17:39:51.587' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (44, N'security.audit_logs', N'INSERT', 75, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T18:29:20.990' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (45, N'app.users', N'INSERT', 6, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T18:40:11.830' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (46, N'security.audit_logs', N'INSERT', 76, N'student_feedback_app', N'Application audit log inserted. Action: USER_REGISTERED', CAST(N'2026-05-20T18:40:11.837' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (47, N'app.users', N'UPDATE', 6, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T18:40:19.037' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (48, N'security.audit_logs', N'INSERT', 77, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T18:40:19.037' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (49, N'security.audit_logs', N'INSERT', 78, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T18:40:19.047' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (50, N'security.audit_logs', N'INSERT', 79, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T18:40:23.997' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (51, N'security.audit_logs', N'INSERT', 80, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T18:40:26.010' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (52, N'app.feedback', N'INSERT', 5, N'student_feedback_app', N'New feedback record inserted. Title: WAD, Status: Pending', CAST(N'2026-05-20T18:40:34.650' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (53, N'security.audit_logs', N'INSERT', 81, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_SUBMITTED', CAST(N'2026-05-20T18:40:34.650' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (54, N'security.audit_logs', N'INSERT', 82, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T18:40:38.513' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (55, N'app.users', N'UPDATE', 2, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T18:40:40.890' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (56, N'security.audit_logs', N'INSERT', 83, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T18:40:40.890' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (57, N'security.audit_logs', N'INSERT', 84, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_LIST_VIEWED', CAST(N'2026-05-20T18:40:41.757' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (58, N'security.audit_logs', N'INSERT', 85, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T19:01:21.867' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (59, N'app.users', N'UPDATE', 2, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T19:02:18.743' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (60, N'security.audit_logs', N'INSERT', 86, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T19:02:18.747' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (61, N'security.audit_logs', N'INSERT', 87, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T19:02:20.387' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (62, N'app.users', N'UPDATE', 5, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T19:02:29.497' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (63, N'security.audit_logs', N'INSERT', 88, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T19:02:29.497' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (64, N'security.audit_logs', N'INSERT', 89, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T19:02:29.503' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (65, N'security.audit_logs', N'INSERT', 90, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T19:17:54.827' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (66, N'app.users', N'UPDATE', 5, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T19:24:15.967' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (67, N'security.audit_logs', N'INSERT', 91, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T19:24:15.967' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (68, N'security.audit_logs', N'INSERT', 92, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T19:24:15.973' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (69, N'security.audit_logs', N'INSERT', 93, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T19:24:17.297' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (70, N'app.users', N'UPDATE', 2, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T19:24:20.190' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (71, N'security.audit_logs', N'INSERT', 94, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T19:24:20.190' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (72, N'security.audit_logs', N'INSERT', 95, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_LIST_VIEWED', CAST(N'2026-05-20T19:24:21.403' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (73, N'app.feedback', N'UPDATE', 5, N'student_feedback_app', N'Feedback record updated. Old status: Pending, New status: In Progress, Title: WAD', CAST(N'2026-05-20T19:24:24.173' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (74, N'security.audit_logs', N'INSERT', 96, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_UPDATED', CAST(N'2026-05-20T19:24:24.177' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (75, N'security.audit_logs', N'INSERT', 97, N'student_feedback_app', N'Application audit log inserted. Action: FEEDBACK_LIST_VIEWED', CAST(N'2026-05-20T19:24:24.177' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (76, N'security.audit_logs', N'INSERT', 98, N'student_feedback_app', N'Application audit log inserted. Action: LOGOUT', CAST(N'2026-05-20T19:24:26.583' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (77, N'app.users', N'UPDATE', 1, N'student_feedback_app', N'xxxx', CAST(N'2026-05-20T19:24:30.510' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (78, N'security.audit_logs', N'INSERT', 99, N'student_feedback_app', N'Application audit log inserted. Action: USER_LOGIN', CAST(N'2026-05-20T19:24:30.510' AS DateTime))
INSERT [security].[db_audit_logs] ([db_log_id], [table_name], [action_type], [record_id], [performed_by], [details], [created_at]) VALUES (79, N'security.audit_logs', N'INSERT', 100, N'student_feedback_app', N'Application audit log inserted. Action: DASHBOARD_ACCESS', CAST(N'2026-05-20T19:24:30.520' AS DateTime))
SET IDENTITY_INSERT [security].[db_audit_logs] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__users__AB6E61641B22CF92]    Script Date: 20/5/2026 7:35:29 PM ******/
ALTER TABLE [app].[users] ADD UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [app].[feedback] ADD  DEFAULT ('Feedback') FOR [type]
GO
ALTER TABLE [app].[feedback] ADD  DEFAULT ('Pending') FOR [status]
GO
ALTER TABLE [app].[feedback] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [app].[feedback] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [app].[users] ADD  DEFAULT ('student') FOR [role]
GO
ALTER TABLE [app].[users] ADD  DEFAULT ((0)) FOR [failed_login_attempts]
GO
ALTER TABLE [app].[users] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [security].[audit_logs] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [security].[db_audit_logs] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [app].[feedback]  WITH CHECK ADD  CONSTRAINT [fk_feedback_user] FOREIGN KEY([user_id])
REFERENCES [app].[users] ([user_id])
ON DELETE CASCADE
GO
ALTER TABLE [app].[feedback] CHECK CONSTRAINT [fk_feedback_user]
GO
ALTER TABLE [security].[audit_logs]  WITH CHECK ADD  CONSTRAINT [fk_audit_user] FOREIGN KEY([user_id])
REFERENCES [app].[users] ([user_id])
ON DELETE SET NULL
GO
ALTER TABLE [security].[audit_logs] CHECK CONSTRAINT [fk_audit_user]
GO
ALTER TABLE [app].[feedback]  WITH CHECK ADD  CONSTRAINT [chk_feedback_category] CHECK  (([category]='Others' OR [category]='Student Affairs' OR [category]='IT' OR [category]='Hostel' OR [category]='Facilities' OR [category]='Academic'))
GO
ALTER TABLE [app].[feedback] CHECK CONSTRAINT [chk_feedback_category]
GO
ALTER TABLE [app].[feedback]  WITH CHECK ADD  CONSTRAINT [chk_feedback_status] CHECK  (([status]='Rejected' OR [status]='Resolved' OR [status]='In Progress' OR [status]='Pending'))
GO
ALTER TABLE [app].[feedback] CHECK CONSTRAINT [chk_feedback_status]
GO
ALTER TABLE [app].[feedback]  WITH CHECK ADD  CONSTRAINT [chk_feedback_type] CHECK  (([type]='Suggestion' OR [type]='Feedback' OR [type]='Complaint'))
GO
ALTER TABLE [app].[feedback] CHECK CONSTRAINT [chk_feedback_type]
GO
ALTER TABLE [app].[users]  WITH CHECK ADD  CONSTRAINT [chk_users_role] CHECK  (([role]='admin' OR [role]='student'))
GO
ALTER TABLE [app].[users] CHECK CONSTRAINT [chk_users_role]
GO
/****** Object:  Trigger [app].[trg_db_audit_feedback]    Script Date: 20/5/2026 7:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER [app].[trg_db_audit_feedback]
ON [app].[feedback]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO security.db_audit_logs
        (table_name, action_type, record_id, performed_by, details, created_at)
        SELECT
            'app.feedback',
            'INSERT',
            i.feedback_id,
            SYSTEM_USER,
            CONCAT('New feedback record inserted. Title: ', i.title, ', Status: ', i.status),
            GETDATE()
        FROM inserted i;
    END

    -- UPDATE
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO security.db_audit_logs
        (table_name, action_type, record_id, performed_by, details, created_at)
        SELECT
            'app.feedback',
            'UPDATE',
            i.feedback_id,
            SYSTEM_USER,
            CONCAT(
                'Feedback record updated. Old status: ',
                d.status,
                ', New status: ',
                i.status,
                ', Title: ',
                i.title
            ),
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d
            ON i.feedback_id = d.feedback_id;
    END

    -- DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO security.db_audit_logs
        (table_name, action_type, record_id, performed_by, details, created_at)
        SELECT
            'app.feedback',
            'DELETE',
            d.feedback_id,
            SYSTEM_USER,
            CONCAT('Feedback record deleted. Title: ', d.title, ', Status: ', d.status),
            GETDATE()
        FROM deleted d;
    END
END;
GO
ALTER TABLE [app].[feedback] ENABLE TRIGGER [trg_db_audit_feedback]
GO
/****** Object:  Trigger [app].[trg_db_audit_users]    Script Date: 20/5/2026 7:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER [app].[trg_db_audit_users]
ON [app].[users]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO security.db_audit_logs
        (table_name, action_type, record_id, performed_by, details, created_at)
        SELECT
            'app.users',
            'INSERT',
            i.user_id,
            SYSTEM_USER,
            CONCAT('New user inserted. Email: ', i.email, ', Role: ', i.role),
            GETDATE()
        FROM inserted i;
    END

    -- UPDATE
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO security.db_audit_logs
        (table_name, action_type, record_id, performed_by, details, created_at)
        SELECT
            'app.users',
            'UPDATE',
            i.user_id,
            SYSTEM_USER,
            CONCAT(
                'User record updated. Email: ',
                i.email,
                ', Old role: ',
                d.role,
                ', New role: ',
                i.role
            ),
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d
            ON i.user_id = d.user_id;
    END

    -- DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO security.db_audit_logs
        (table_name, action_type, record_id, performed_by, details, created_at)
        SELECT
            'app.users',
            'DELETE',
            d.user_id,
            SYSTEM_USER,
            CONCAT('User deleted. Email: ', d.email, ', Role: ', d.role),
            GETDATE()
        FROM deleted d;
    END
END;
GO
ALTER TABLE [app].[users] ENABLE TRIGGER [trg_db_audit_users]
GO
/****** Object:  Trigger [security].[trg_db_audit_audit_logs]    Script Date: 20/5/2026 7:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER [security].[trg_db_audit_audit_logs]
ON [security].[audit_logs]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO security.db_audit_logs
    (table_name, action_type, record_id, performed_by, details, created_at)
    SELECT
        'security.audit_logs',
        'INSERT',
        i.log_id,
        SYSTEM_USER,
        CONCAT('Application audit log inserted. Action: ', i.action),
        GETDATE()
    FROM inserted i;
END;
GO
ALTER TABLE [security].[audit_logs] ENABLE TRIGGER [trg_db_audit_audit_logs]
GO
USE [master]
GO
ALTER DATABASE [StudentFeedbackSystem] SET  READ_WRITE 
GO
