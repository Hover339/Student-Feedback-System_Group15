-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 19, 2026 at 04:07 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `student_feedback_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `log_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`log_id`, `user_id`, `action`, `details`, `created_at`) VALUES
(1, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-17 07:18:09'),
(2, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-17 07:18:10'),
(3, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-17 07:18:33'),
(4, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-17 07:23:31'),
(5, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-17 07:24:34'),
(6, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-17 09:20:10'),
(7, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-17 09:20:13'),
(8, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-17 09:20:13'),
(9, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 06:07:00'),
(10, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:07:00'),
(11, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 06:07:56'),
(12, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:07:57'),
(13, 5, 'UNAUTHORIZED_ACCESS', 'User tried to access student dashboard without permission.', '2026-05-19 06:08:19'),
(14, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 06:08:25'),
(15, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:08:25'),
(16, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:08:34'),
(17, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:08:52'),
(18, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:09:14'),
(19, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:09:21'),
(20, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 06:09:45'),
(21, 5, 'UNAUTHORIZED_ACCESS', 'User tried to access student dashboard without permission.', '2026-05-19 06:21:23'),
(22, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 06:21:27'),
(23, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:21:27'),
(24, 3, 'FEEDBACK_SUBMITTED', 'Student submitted feedback_id: 6', '2026-05-19 06:22:17'),
(25, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 06:22:36'),
(26, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:22:38'),
(27, 5, 'UNAUTHORIZED_ACCESS', 'User tried to access student dashboard without permission.', '2026-05-19 06:27:57'),
(28, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 06:28:00'),
(29, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:28:00'),
(30, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:28:05'),
(31, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:28:40'),
(32, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 06:28:49'),
(33, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:28:53'),
(34, 5, 'FEEDBACK_UPDATED', 'Feedback updated for feedback_id: 6', '2026-05-19 06:29:13'),
(35, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:29:13'),
(36, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:29:17'),
(37, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 06:29:32'),
(38, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:29:32'),
(39, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 06:35:58'),
(40, NULL, 'LOGIN_FAILED', 'Failed authentication login try. Reason: Targeted account identifier does not exist: student1@myeduconnect.local', '2026-05-19 06:36:03'),
(41, 6, 'USER_REGISTERED', 'New student account successfully provisioned for: student3@gmail.com', '2026-05-19 06:36:37'),
(42, 6, 'USER_LOGIN', 'Successful login event for user identity: student3@gmail.com', '2026-05-19 06:36:49'),
(43, 6, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:36:50'),
(44, 6, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:37:01'),
(45, 6, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:37:18'),
(46, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 06:41:54'),
(47, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:41:56'),
(48, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:42:23'),
(49, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 06:44:35'),
(50, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:44:35'),
(51, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 06:44:38'),
(52, 6, 'USER_LOGIN', 'Successful login event for user identity: student3@gmail.com', '2026-05-19 06:44:41'),
(53, 6, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:44:41'),
(54, 6, 'FEEDBACK_SUBMITTED', 'Student submitted feedback_id: 7', '2026-05-19 06:45:03'),
(55, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 06:45:19'),
(56, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:45:20'),
(57, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 06:45:35'),
(58, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 06:45:35'),
(59, 3, 'FEEDBACK_SUBMITTED', 'Student submitted Suggestion with feedback_id: 8', '2026-05-19 06:50:18'),
(60, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 06:50:28'),
(61, 5, 'FEEDBACK_VIEWED', 'Feedback list viewed, feedback_id: 0', '2026-05-19 06:50:29'),
(62, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 8', '2026-05-19 06:53:20'),
(63, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 8', '2026-05-19 06:58:10'),
(64, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:05:12'),
(65, 1, 'LOGIN_FAILED', 'Incorrect password for account: admin@test.com. Remaining attempts: 4', '2026-05-19 07:05:47'),
(66, 1, 'LOGIN_FAILED', 'Incorrect password for account: admin@test.com. Remaining attempts: 3', '2026-05-19 07:05:54'),
(67, 1, 'LOGIN_FAILED', 'Incorrect password for account: admin@test.com. Remaining attempts: 2', '2026-05-19 07:05:58'),
(68, 1, 'LOGIN_FAILED', 'Incorrect password for account: admin@test.com. Remaining attempts: 1', '2026-05-19 07:06:02'),
(69, 1, 'ACCOUNT_LOCKED', 'Account locked after 5 failed login attempts for: admin@test.com', '2026-05-19 07:06:06'),
(70, 1, 'LOGIN_LOCKED', 'Blocked login attempt because account is locked for: admin@test.com', '2026-05-19 07:06:20'),
(71, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:06:44'),
(72, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:06:44'),
(73, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:06:49'),
(74, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:11:25'),
(75, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:11:28'),
(76, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 8', '2026-05-19 07:11:30'),
(77, 5, 'FEEDBACK_UPDATED', 'Admin updated feedback_id: 7. Status changed from \'Pending\' to \'Rejected\'.', '2026-05-19 07:11:49'),
(78, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 8', '2026-05-19 07:11:49'),
(79, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:12:24'),
(80, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:12:29'),
(81, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:12:29'),
(82, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:26:18'),
(83, 7, 'USER_REGISTERED', 'New student account successfully created for: student4@gmail.com', '2026-05-19 07:26:51'),
(84, 7, 'USER_LOGIN', 'Successful login event for user identity: student4@gmail.com', '2026-05-19 07:27:00'),
(85, 7, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:27:00'),
(86, 7, 'FEEDBACK_SUBMITTED', 'Student submitted Suggestion with feedback_id: 9. Description encrypted before database storage.', '2026-05-19 07:28:04'),
(87, 7, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:28:37'),
(88, 7, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:28:39'),
(89, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:28:43'),
(90, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 9', '2026-05-19 07:28:44'),
(91, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:28:52'),
(92, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:28:57'),
(93, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:28:57'),
(94, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:31:01'),
(95, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:31:04'),
(96, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:31:04'),
(97, 3, 'FEEDBACK_DELETED', 'Student deleted feedback_id: 8, title: Add air conditional pls', '2026-05-19 07:31:12'),
(98, 3, 'FEEDBACK_DETAIL_VIEWED', 'Student viewed feedback_id: 6', '2026-05-19 07:31:16'),
(99, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:32:38'),
(100, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:32:40'),
(101, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:32:40'),
(102, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:32:43'),
(103, 3, 'FEEDBACK_MODIFIED', 'Student modified feedback_id: 5. Description encrypted before database update.', '2026-05-19 07:33:15'),
(104, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:33:19'),
(105, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:33:21'),
(106, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 8', '2026-05-19 07:36:36'),
(107, 5, 'FEEDBACK_UPDATED', 'Admin updated feedback_id: 9. Status changed from \'Pending\' to \'Resolved\'. Admin response encrypted before database storage.', '2026-05-19 07:36:42'),
(108, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 8', '2026-05-19 07:36:42'),
(109, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:36:46'),
(110, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:36:49'),
(111, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:36:49'),
(112, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:36:54'),
(113, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:36:57'),
(114, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 8', '2026-05-19 07:36:58'),
(115, 5, 'FEEDBACK_UPDATED', 'Admin updated feedback_id: 5. Status changed from \'Pending\' to \'Resolved\'. Admin response encrypted before database storage.', '2026-05-19 07:37:03'),
(116, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 8', '2026-05-19 07:37:03'),
(117, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:37:05'),
(118, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:37:12'),
(119, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:37:12'),
(120, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:37:19'),
(121, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:40:22'),
(122, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:40:22'),
(123, 3, 'FEEDBACK_SUBMITTED', 'Student submitted Suggestion with feedback_id: 10. Description encrypted before database storage.', '2026-05-19 07:40:47'),
(124, 3, 'RATE_LIMIT_TRIGGERED', 'Student attempted to submit more than 1 feedback within 5 minutes.', '2026-05-19 07:41:00'),
(125, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:42:15'),
(126, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:42:17'),
(127, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:43:57'),
(128, 7, 'USER_LOGIN', 'Successful login event for user identity: student4@gmail.com', '2026-05-19 07:44:05'),
(129, 7, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:44:05'),
(130, 7, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:44:11'),
(131, 7, 'USER_LOGIN', 'Successful login event for user identity: student4@gmail.com', '2026-05-19 07:49:01'),
(132, 7, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:49:01'),
(133, 7, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:49:06'),
(134, 7, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:49:11'),
(135, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:50:42'),
(136, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:52:24'),
(137, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:54:41'),
(138, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:54:45'),
(139, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:54:48'),
(140, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:54:48'),
(141, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:54:59'),
(142, 3, 'USER_LOGIN', 'Successful login event for user identity: student2@test.com', '2026-05-19 07:55:07'),
(143, 3, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:55:07'),
(144, 3, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:55:18'),
(145, 8, 'USER_REGISTERED', 'New student account successfully created for: student5@gmail.com', '2026-05-19 07:55:50'),
(146, 8, 'USER_LOGIN', 'Successful login event for user identity: student5@gmail.com', '2026-05-19 07:55:59'),
(147, 8, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:55:59'),
(148, 8, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:56:02'),
(149, 8, 'USER_LOGIN', 'Successful login event for user identity: student5@gmail.com', '2026-05-19 07:56:15'),
(150, 8, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:56:15'),
(151, 8, 'FEEDBACK_SUBMITTED', 'Student submitted Complaint with feedback_id: 11. Description encrypted before database storage.', '2026-05-19 07:56:57'),
(152, 8, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:57:01'),
(153, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:57:03'),
(154, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 10', '2026-05-19 07:57:05'),
(155, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 10', '2026-05-19 07:57:26'),
(156, 5, 'FEEDBACK_UPDATED', 'Admin updated feedback_id: 11. Status changed from \'Pending\' to \'Resolved\'. Admin response encrypted before database storage.', '2026-05-19 07:57:29'),
(157, 5, 'FEEDBACK_LIST_VIEWED', 'Admin viewed the full feedback management list. Total records available: 10', '2026-05-19 07:57:29'),
(158, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:57:56'),
(159, 8, 'USER_LOGIN', 'Successful login event for user identity: student5@gmail.com', '2026-05-19 07:58:03'),
(160, 8, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:58:03'),
(161, 8, 'FEEDBACK_DELETED', 'Student deleted feedback_id: 11, title: Table Broken', '2026-05-19 07:58:11'),
(162, 8, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:58:15'),
(163, 6, 'USER_LOGIN', 'Successful login event for user identity: student3@gmail.com', '2026-05-19 07:58:19'),
(164, 6, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:58:19'),
(165, 6, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:58:24'),
(166, 6, 'USER_LOGIN', 'Successful login event for user identity: student3@gmail.com', '2026-05-19 07:58:29'),
(167, 6, 'DASHBOARD_ACCESS', 'Student accessed their dashboard.', '2026-05-19 07:58:29'),
(168, 6, 'FEEDBACK_SUBMITTED', 'Student submitted Feedback with feedback_id: 12. Description encrypted before database storage.', '2026-05-19 07:58:55'),
(169, 6, 'FEEDBACK_MODIFIED', 'Student modified feedback_id: 12. Description encrypted before database update.', '2026-05-19 07:59:17'),
(170, 6, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:59:22'),
(171, 5, 'USER_LOGIN', 'Successful login event for user identity: admin2@test.com', '2026-05-19 07:59:29'),
(172, 5, 'LOGOUT', 'User logged out successfully.', '2026-05-19 07:59:46');

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

CREATE TABLE `feedback` (
  `feedback_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `type` enum('Complaint','Suggestion','Feedback') DEFAULT 'Feedback',
  `status` enum('Pending','In Progress','Resolved','Rejected') DEFAULT 'Pending',
  `admin_response` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `feedback`
--

INSERT INTO `feedback` (`feedback_id`, `user_id`, `title`, `description`, `category`, `type`, `status`, `admin_response`, `created_at`, `updated_at`) VALUES
(1, 2, 'Slow WiFi', 'Internet is slow in campus.', 'IT', 'Complaint', 'Pending', NULL, '2026-05-03 10:15:21', '2026-05-03 10:15:21'),
(2, 2, 'Air Conditioning Issue', 'The air conditioning in Lecture Hall B is not functioning properly during afternoon classes.', 'Facilities', 'Complaint', 'Pending', NULL, '2026-05-17 07:24:18', '2026-05-17 07:24:18'),
(3, 2, 'Library Suggestion', 'Extend library operating hours during examination week.', 'Library', 'Suggestion', 'In Progress', NULL, '2026-05-17 07:24:31', '2026-05-17 07:24:31'),
(4, 2, 'Cafeteria Feedback', 'The cafeteria service has improved significantly this semester.', 'Cafeteria', 'Feedback', 'Resolved', NULL, '2026-05-17 07:24:31', '2026-05-17 07:24:31'),
(5, 3, 'Fan Problem', 'ENC::7sc9KF9Xw72Xy/uY0i3zxqe9aIPO6nl/b1nnF/x8nRIupUNZvQ29CCutjPRjR8uPauoUy/u5RqYm/pOoNt6YCBbL1XCKqQ+CWErUDfG4znFl5Mq2R8KtB025guXDYmxZ', 'Facilities', 'Complaint', 'Resolved', NULL, '2026-05-19 06:07:45', '2026-05-19 07:37:03'),
(6, 3, 'Ebfi very slow', 'download speed slow, can\'t even download files during class when needed :/', 'IT', 'Feedback', 'Resolved', 'tq for ur feedback !', '2026-05-19 06:22:17', '2026-05-19 06:29:13'),
(7, 6, 'Light problem', 'Light bulb need replacing.', 'Hostel', 'Feedback', 'Rejected', NULL, '2026-05-19 06:45:03', '2026-05-19 07:11:49'),
(9, 7, 'Late classes', 'ENC::ieXJ7tFjcdqiuU+ZsIs7MUmTYxTnJSyKxmn+baSbgFKTCks+GWlP4thQv2+52abTFyPKNphpADUepJDcZqpgsV0zb3hFYiI9xiqd42se0Z7Z/D0vFBQ1cagVfLjD7rrArkAUtzMRNkxNjKCHEwCGMvKmADk60oV2gnb7+IGzkAccQBFdvmVq40Rx2aG/OUJe', 'Academic', 'Suggestion', 'Resolved', NULL, '2026-05-19 07:28:04', '2026-05-19 07:36:42'),
(10, 3, 'Starbees seats', 'ENC::yNDciYHAzHgsMk5VAvOWf4SB2VQBRbcgXM8Am9UgxsfARl2Qo+/RERxDXOpYrAZ3', 'Facilities', 'Suggestion', 'Pending', NULL, '2026-05-19 07:40:47', '2026-05-19 07:40:47'),
(12, 6, 'Toilet Dirty Problem', 'ENC::tXQMndYEykVL4rZcHvR9K4dqARWBiM4zelKRROXaOiKMyaPEX/tWbyxJ7Aw49//hYcD0vefbTkNC57rhArAKqA==', 'Hostel', 'Feedback', 'Pending', NULL, '2026-05-19 07:58:55', '2026-05-19 07:59:17');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('student','admin') NOT NULL DEFAULT 'student',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `failed_login_attempts` int(11) NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `full_name`, `email`, `password_hash`, `role`, `created_at`, `failed_login_attempts`, `locked_until`) VALUES
(1, 'Admin User', 'admin@test.com', '$2y$10$examplehashedpassword', 'admin', '2026-05-03 10:10:03', 5, '2026-05-19 09:11:06'),
(2, 'Student User', 'student@test.com', 'student123', 'student', '2026-05-03 10:10:03', 0, NULL),
(3, 'Student2', 'student2@test.com', '$2y$10$4984/8gnH/6JtQ474NHkBO1Jl9nkI2F/eULRNQ3iHIODAyJdqlGti', 'student', '2026-05-03 10:44:47', 0, NULL),
(4, 'test3', 'test3@gmail.com', '$2y$10$T.gaeWk/GaLdGjKk5xCbVe7qmPhfs67gt9TCN0SsAS0x9EScYvFXu', 'student', '2026-05-03 11:23:45', 0, NULL),
(5, 'admin2', 'admin2@test.com', '$2y$10$6wUf8.6/nPN5yrentj22leYVdBDpEXhya9oWCFhqQ35OoRkrKb1Z6', 'admin', '2026-05-03 13:51:36', 0, NULL),
(6, 'student3', 'student3@gmail.com', '$2y$10$a6fssdLWbDaLBg19gmjlwO1ewHQxvOx5eC23NrPtENYh00LtdIXuu', 'student', '2026-05-19 06:36:36', 0, NULL),
(7, 'Student4', 'student4@gmail.com', '$2y$10$uCu24.MJ5UpuVdfcb8wNR.NZsinZ4q8GCexPJfLWL9GbWcWgfO8SG', 'student', '2026-05-19 07:26:51', 0, NULL),
(8, 'student5', 'student5@gmail.com', '$2y$10$bMZ0XXOCne.JBLZU8V.V3uW0bfDdY3En..2oaOKSBhYLWt7gU0gjW', 'student', '2026-05-19 07:55:50', 0, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `fk_audit_user` (`user_id`);

--
-- Indexes for table `feedback`
--
ALTER TABLE `feedback`
  ADD PRIMARY KEY (`feedback_id`),
  ADD KEY `fk_feedback_user` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=173;

--
-- AUTO_INCREMENT for table `feedback`
--
ALTER TABLE `feedback`
  MODIFY `feedback_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `feedback`
--
ALTER TABLE `feedback`
  ADD CONSTRAINT `fk_feedback_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
