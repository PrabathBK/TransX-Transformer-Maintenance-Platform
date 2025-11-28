-- MySQL dump 10.13  Distrib 8.0.43, for macos15 (arm64)
--
-- Host: localhost    Database: en3350_db
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `annotation_history`
--

DROP TABLE IF EXISTS `annotation_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `annotation_history` (
  `id` binary(16) NOT NULL,
  `annotation_id` binary(16) NOT NULL,
  `inspection_id` binary(16) NOT NULL,
  `action_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `snapshot_data` json DEFAULT NULL,
  `user_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_annotation_id` (`annotation_id`),
  KEY `idx_inspection_id` (`inspection_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `annotation_history_ibfk_1` FOREIGN KEY (`annotation_id`) REFERENCES `annotations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `annotation_history_ibfk_2` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `annotation_history`
--

LOCK TABLES `annotation_history` WRITE;
/*!40000 ALTER TABLE `annotation_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `annotation_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `annotations`
--

DROP TABLE IF EXISTS `annotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `annotations` (
  `id` binary(16) NOT NULL,
  `inspection_id` binary(16) NOT NULL,
  `version` int DEFAULT '1',
  `bbox_x1` int NOT NULL,
  `bbox_y1` int NOT NULL,
  `bbox_x2` int NOT NULL,
  `bbox_y2` int NOT NULL,
  `class_id` int DEFAULT NULL,
  `class_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `box_number` int DEFAULT NULL,
  `confidence` decimal(5,3) DEFAULT NULL,
  `source` enum('ai','human') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_type` enum('created','edited','deleted','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'created',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_inspector` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `modified_at` timestamp NULL DEFAULT NULL,
  `parent_annotation_id` binary(16) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `parent_annotation_id` (`parent_annotation_id`),
  KEY `idx_inspection_id` (`inspection_id`),
  KEY `idx_inspection_active` (`inspection_id`,`is_active`),
  KEY `idx_source` (`source`),
  KEY `idx_version` (`inspection_id`,`version`),
  KEY `idx_box_number` (`inspection_id`,`box_number`),
  CONSTRAINT `annotations_ibfk_1` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `annotations_ibfk_2` FOREIGN KEY (`parent_annotation_id`) REFERENCES `annotations` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `annotations`
--

LOCK TABLES `annotations` WRITE;
/*!40000 ALTER TABLE `annotations` DISABLE KEYS */;
INSERT INTO `annotations` VALUES (_binary 'G[I\‚\◊B{∏Å\Àrºw˜R',_binary 'oeˇ6\◊L»§ü\‹~8d',1,258,131,335,205,3,'potential_faulty',1,0.935,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:55:42','current-user@example.com','2025-11-28 10:55:46',NULL,1,NULL),(_binary '\È=¥UÒN;ÅS@d¿Ö \Œ',_binary '\Ô˜\n\ @ë¶äCvçU\›\Î',1,273,79,471,244,1,'faulty_loose_joint',1,0.698,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:57:04','current-user@example.com','2025-11-28 10:57:07',NULL,1,NULL),(_binary 'à\¬j.\ÃB$ì\ÌXæ\\CL´',_binary '3 tú\€K@j¶:¸◊Ö{™',1,294,157,383,294,3,'potential_faulty',1,0.973,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:58:00','current-user@example.com','2025-11-28 10:58:02',NULL,1,NULL),(_binary '©¡a^Nãà4\ﬂ<j2¿o',_binary '«ø†\rÀ∫M\‚∏\Ãl˝A!\œ',1,380,403,457,514,0,'faulty',2,0.765,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:54:29','current-user@example.com','2025-11-28 10:54:34',NULL,1,NULL),(_binary '∞LRõî©B;âGÀ¨\ÏE;Ú',_binary '\…\Ï\ﬁ\÷G\‚ùS\ƒHf7ù',1,36,78,83,169,0,'faulty',1,0.957,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 11:04:29','current-user@example.com','2025-11-28 11:04:36',NULL,1,NULL),(_binary 'π≠hJ\ÀÚB•æ\«ÚQPuH∂',_binary 'oeˇ6\◊L»§ü\‹~8d',1,120,127,156,203,3,'potential_faulty',3,0.920,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:55:42','current-user@example.com','2025-11-28 10:55:48',NULL,1,NULL),(_binary '¿P		\Z≠HòäN§sˇ†Ù\‚',_binary '3 tú\€K@j¶:¸◊Ö{™',1,195,161,287,300,3,'potential_faulty',2,0.969,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:58:00','current-user@example.com','2025-11-28 10:58:04',NULL,1,NULL),(_binary '»ÜSØl!N©í9XÅéí',_binary '«ø†\rÀ∫M\‚∏\Ãl˝A!\œ',1,60,260,287,603,0,'faulty',1,0.850,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:54:29','current-user@example.com','2025-11-28 10:54:36',NULL,1,NULL),(_binary '\Ÿ…ù\—XàL\Â¥\ﬁvvÒÖt',_binary 'oeˇ6\◊L»§ü\‹~8d',1,166,133,245,205,3,'potential_faulty',2,0.929,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:55:42','current-user@example.com','2025-11-28 10:55:49',NULL,1,NULL),(_binary '˜y\–≥åN}íB3t¸“è',_binary '3 tú\€K@j¶:¸◊Ö{™',1,98,169,188,306,3,'potential_faulty',3,0.962,'ai','approved','AI-YOLOv8','AI-System','2025-11-28 10:58:00','current-user@example.com','2025-11-28 10:58:06',NULL,1,NULL);
/*!40000 ALTER TABLE `annotations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `box_numbering_sequence`
--

DROP TABLE IF EXISTS `box_numbering_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `box_numbering_sequence` (
  `inspection_id` binary(16) NOT NULL,
  `next_box_number` int NOT NULL DEFAULT '1',
  `last_updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inspection_id`),
  CONSTRAINT `box_numbering_sequence_ibfk_1` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `box_numbering_sequence`
--

LOCK TABLES `box_numbering_sequence` WRITE;
/*!40000 ALTER TABLE `box_numbering_sequence` DISABLE KEYS */;
INSERT INTO `box_numbering_sequence` VALUES (_binary '\…\Ï\ﬁ\÷G\‚ùS\ƒHf7ù',2,'2025-11-28 16:34:29'),(_binary '3 tú\€K@j¶:¸◊Ö{™',4,'2025-11-28 16:28:00'),(_binary 'oeˇ6\◊L»§ü\‹~8d',4,'2025-11-28 16:25:42'),(_binary '«ø†\rÀ∫M\‚∏\Ãl˝A!\œ',3,'2025-11-28 16:24:28'),(_binary '\Ô˜\n\ @ë¶äCvçU\›\Î',2,'2025-11-28 16:27:04');
/*!40000 ALTER TABLE `box_numbering_sequence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_code` varchar(20) NOT NULL,
  `course_name` varchar(100) NOT NULL,
  `credits` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `course_code` (`course_code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (1,'EN3350','Software Engineering Project',3),(2,'EN1234','Database Systems',3);
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollments`
--

DROP TABLE IF EXISTS `enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enrollments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `enrolled_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `enrollments_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollments`
--

LOCK TABLES `enrollments` WRITE;
/*!40000 ALTER TABLE `enrollments` DISABLE KEYS */;
/*!40000 ALTER TABLE `enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspection_access_log`
--

DROP TABLE IF EXISTS `inspection_access_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspection_access_log` (
  `id` binary(16) NOT NULL,
  `inspection_id` binary(16) NOT NULL,
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_type` enum('VIEW','EDIT','CREATE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_start` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `session_end` timestamp NULL DEFAULT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_access_log_inspection_id` (`inspection_id`),
  KEY `idx_access_log_user` (`user_name`),
  KEY `idx_access_log_session_start` (`session_start`),
  CONSTRAINT `inspection_access_log_ibfk_1` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_access_log`
--

LOCK TABLES `inspection_access_log` WRITE;
/*!40000 ALTER TABLE `inspection_access_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `inspection_access_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `inspection_boxes_current`
--

DROP TABLE IF EXISTS `inspection_boxes_current`;
/*!50001 DROP VIEW IF EXISTS `inspection_boxes_current`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `inspection_boxes_current` AS SELECT 
 1 AS `inspection_id`,
 1 AS `inspection_id_hex`,
 1 AS `inspection_number`,
 1 AS `box_number`,
 1 AS `class_name`,
 1 AS `class_id`,
 1 AS `confidence`,
 1 AS `source`,
 1 AS `action_type`,
 1 AS `created_by`,
 1 AS `current_inspector`,
 1 AS `created_at`,
 1 AS `bbox_x1`,
 1 AS `bbox_y1`,
 1 AS `bbox_x2`,
 1 AS `bbox_y2`,
 1 AS `inspection_status`,
 1 AS `inspection_current_inspector`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inspection_comments`
--

DROP TABLE IF EXISTS `inspection_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspection_comments` (
  `id` binary(16) NOT NULL,
  `inspection_id` binary(16) NOT NULL,
  `comment_text` varchar(2048) NOT NULL,
  `author` varchar(255) NOT NULL,
  `created_at` timestamp(6) NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` timestamp(6) NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_inspection_comments_inspection_id` (`inspection_id`),
  KEY `idx_inspection_comments_created_at` (`created_at`),
  CONSTRAINT `inspection_comments_ibfk_1` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_comments`
--

LOCK TABLES `inspection_comments` WRITE;
/*!40000 ALTER TABLE `inspection_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `inspection_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspection_history`
--

DROP TABLE IF EXISTS `inspection_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspection_history` (
  `id` binary(16) NOT NULL,
  `inspection_id` binary(16) NOT NULL,
  `box_number` int DEFAULT NULL,
  `action_type` enum('INSPECTION_CREATED','INSPECTOR_CHANGED','AI_DETECTION_RUN','BOX_CREATED','BOX_EDITED','BOX_MOVED','BOX_RESIZED','BOX_APPROVED','BOX_REJECTED','BOX_DELETED','CLASS_CHANGED','CONFIDENCE_UPDATED','STATUS_CHANGED','INSPECTION_COMPLETED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `previous_data` json DEFAULT NULL,
  `new_data` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_inspection_history_inspection_id` (`inspection_id`),
  KEY `idx_inspection_history_box_number` (`inspection_id`,`box_number`),
  KEY `idx_inspection_history_created_at` (`created_at`),
  KEY `idx_inspection_history_user` (`user_name`),
  KEY `idx_inspection_history_action_type` (`action_type`),
  CONSTRAINT `inspection_history_ibfk_1` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_history`
--

LOCK TABLES `inspection_history` WRITE;
/*!40000 ALTER TABLE `inspection_history` DISABLE KEYS */;
INSERT INTO `inspection_history` VALUES (_binary ',+æ\Ãw∑Ωs\ŒI',_binary '\Ô˜\n\ @ë¶äCvçU\›\Î',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 273, \"x2\": 471, \"y1\": 79, \"y2\": 244}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.698}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-11-28 16:27:04'),(_binary 'h5\Ê\Ãx∑Ωs\ŒI',_binary '\…\Ï\ﬁ\÷G\‚ùS\ƒHf7ù',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 36, \"x2\": 83, \"y1\": 78, \"y2\": 169}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.957}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-11-28 16:34:29'),(_binary '4ô\¬\Ãw∑Ωs\ŒI',_binary '3 tú\€K@j¶:¸◊Ö{™',NULL,'AI_DETECTION_RUN','AI detected 3 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 294, \"x2\": 383, \"y1\": 157, \"y2\": 294}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 1, \"class_name\": \"potential_faulty\", \"confidence\": 0.973}, {\"bbox\": {\"x1\": 195, \"x2\": 287, \"y1\": 161, \"y2\": 300}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 2, \"class_name\": \"potential_faulty\", \"confidence\": 0.969}, {\"bbox\": {\"x1\": 98, \"x2\": 188, \"y1\": 169, \"y2\": 306}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 3, \"class_name\": \"potential_faulty\", \"confidence\": 0.962}], \"total_detections\": 3, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 3, \"confidence_threshold\": \"user_specified\"}}','2025-11-28 16:28:00'),(_binary '∂m\√~\Ãv∑Ωs\ŒI',_binary '«ø†\rÀ∫M\‚∏\Ãl˝A!\œ',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 60, \"x2\": 287, \"y1\": 260, \"y2\": 603}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.85}, {\"bbox\": {\"x1\": 380, \"x2\": 457, \"y1\": 403, \"y2\": 514}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.765}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-11-28 16:24:28'),(_binary '\‚)\»\Ê\Ãv∑Ωs\ŒI',_binary 'oeˇ6\◊L»§ü\‹~8d',NULL,'AI_DETECTION_RUN','AI detected 3 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 258, \"x2\": 335, \"y1\": 131, \"y2\": 205}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 1, \"class_name\": \"potential_faulty\", \"confidence\": 0.935}, {\"bbox\": {\"x1\": 166, \"x2\": 245, \"y1\": 133, \"y2\": 205}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 2, \"class_name\": \"potential_faulty\", \"confidence\": 0.929}, {\"bbox\": {\"x1\": 120, \"x2\": 156, \"y1\": 127, \"y2\": 203}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 3, \"class_name\": \"potential_faulty\", \"confidence\": 0.92}], \"total_detections\": 3, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 3, \"confidence_threshold\": \"user_specified\"}}','2025-11-28 16:25:42');
/*!40000 ALTER TABLE `inspection_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `inspection_history_view`
--

DROP TABLE IF EXISTS `inspection_history_view`;
/*!50001 DROP VIEW IF EXISTS `inspection_history_view`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `inspection_history_view` AS SELECT 
 1 AS `id`,
 1 AS `inspection_id`,
 1 AS `inspection_id_hex`,
 1 AS `inspection_number`,
 1 AS `box_number`,
 1 AS `action_type`,
 1 AS `action_description`,
 1 AS `user_name`,
 1 AS `previous_data`,
 1 AS `new_data`,
 1 AS `created_at`,
 1 AS `inspection_status`,
 1 AS `current_inspector`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inspections`
--

DROP TABLE IF EXISTS `inspections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspections` (
  `id` binary(16) NOT NULL,
  `inspection_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `transformer_id` binary(16) NOT NULL,
  `baseline_image_id` binary(16) DEFAULT NULL,
  `inspection_image_id` binary(16) DEFAULT NULL,
  `branch` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weather_condition` enum('SUNNY','CLOUDY','RAINY') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('DRAFT','IN_PROGRESS','UNDER_REVIEW','COMPLETED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
  `notes` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_inspector` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_at` timestamp NULL DEFAULT NULL,
  `maintenance_date` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `completed_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `original_inspection_image_id` binary(16) DEFAULT NULL,
  `has_maintenance_record` tinyint(1) DEFAULT '0' COMMENT 'Flag indicating if maintenance record exists for this inspection',
  PRIMARY KEY (`id`),
  UNIQUE KEY `inspection_number` (`inspection_number`),
  KEY `baseline_image_id` (`baseline_image_id`),
  KEY `inspection_image_id` (`inspection_image_id`),
  KEY `idx_inspection_number` (`inspection_number`),
  KEY `idx_transformer_id` (`transformer_id`),
  KEY `idx_status` (`status`),
  KEY `idx_inspected_at` (`inspected_at`),
  KEY `idx_inspections_original_inspection_image_id` (`original_inspection_image_id`),
  CONSTRAINT `fk_inspection_original_image` FOREIGN KEY (`original_inspection_image_id`) REFERENCES `thermal_images` (`id`) ON DELETE SET NULL,
  CONSTRAINT `inspections_ibfk_1` FOREIGN KEY (`transformer_id`) REFERENCES `transformers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `inspections_ibfk_2` FOREIGN KEY (`baseline_image_id`) REFERENCES `thermal_images` (`id`) ON DELETE SET NULL,
  CONSTRAINT `inspections_ibfk_3` FOREIGN KEY (`inspection_image_id`) REFERENCES `thermal_images` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspections`
--

LOCK TABLES `inspections` WRITE;
/*!40000 ALTER TABLE `inspections` DISABLE KEYS */;
INSERT INTO `inspections` VALUES (_binary '\…\Ï\ﬁ\÷G\‚ùS\ƒHf7ù','INS-008',_binary 'q?≤≠qCó®l@)ìFÉ',NULL,_binary 'Æ∑\nzíKH±Ajô6Cˆb',NULL,'RAINY','IN_PROGRESS',NULL,'Jaliya',NULL,'2025-11-28 11:04:03',NULL,NULL,NULL,'2025-11-28 11:04:03','2025-11-28 11:04:32',_binary 'bı€∞Aˆëe\Z\ÏÃÅCÄ',0),(_binary '3 tú\€K@j¶:¸◊Ö{™','INS-003',_binary '\›b\Œ¿CUØî\ÓZpP',NULL,_binary '?IèmAL9òJé_BòàB',NULL,'CLOUDY','IN_PROGRESS',NULL,'Jaliya',NULL,'2025-11-28 10:57:31',NULL,NULL,NULL,'2025-11-28 10:57:31','2025-11-28 10:58:17',_binary '©Y\0Y\ZE+πTØãw\—«ï',0),(_binary 'oeˇ6\◊L»§ü\‹~8d','INS-002',_binary 'Px™\œe¸O\ÈÇ¡^\‚/jE[',NULL,_binary '¢)ÜV\»9B2øsBxÅ\Z>\¬',NULL,'CLOUDY','COMPLETED',NULL,'Jaliya',NULL,'2025-11-28 10:55:11',NULL,NULL,NULL,'2025-11-28 10:55:11','2025-11-28 10:56:01',_binary '0\’\ZKﬁã\»ı\‹>Ú?f',0),(_binary '«ø†\rÀ∫M\‚∏\Ãl˝A!\œ','INS-001',_binary 'º™OˆHÖò\◊Oo[è',NULL,_binary 'åŸÖIL∂∫w\¬Rß˜\…!',NULL,'CLOUDY','COMPLETED',NULL,'Jaliya',NULL,'2025-11-28 10:54:15',NULL,NULL,NULL,'2025-11-28 10:54:15','2025-11-28 10:54:48',_binary 'jùV•éO˙òˆ\\\\P;c',0),(_binary '\Ô˜\n\ @ë¶äCvçU\›\Î','INS-004',_binary '§ªD|k\ÂGÅ\”SjåîI3',NULL,_binary 'ÆåΩ7~æK´\Á]˚ã1dö',NULL,'RAINY','IN_PROGRESS',NULL,'Jaliya',NULL,'2025-11-28 10:56:17',NULL,NULL,NULL,'2025-11-28 10:56:17','2025-11-28 10:57:11',_binary '_éFí8˛A|¢_+LU≈∑',0);
/*!40000 ALTER TABLE `inspections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_record_anomalies`
--

DROP TABLE IF EXISTS `maintenance_record_anomalies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_record_anomalies` (
  `id` binary(16) NOT NULL,
  `maintenance_record_id` binary(16) NOT NULL,
  `box_number` int DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  `class_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confidence` decimal(5,3) DEFAULT NULL,
  `bbox_x1` int NOT NULL,
  `bbox_y1` int NOT NULL,
  `bbox_x2` int NOT NULL,
  `bbox_y2` int NOT NULL,
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_maintenance_record_id` (`maintenance_record_id`),
  KEY `idx_box_number` (`maintenance_record_id`,`box_number`),
  CONSTRAINT `fk_mra_maintenance_record` FOREIGN KEY (`maintenance_record_id`) REFERENCES `maintenance_records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historical snapshot of anomalies for each maintenance record';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_record_anomalies`
--

LOCK TABLES `maintenance_record_anomalies` WRITE;
/*!40000 ALTER TABLE `maintenance_record_anomalies` DISABLE KEYS */;
INSERT INTO `maintenance_record_anomalies` VALUES (_binary '\nNÒZë\–L6£§ìß*±x',_binary '§íS˝xB∆öò¡\‡XH\Â\€',3,3,'potential_faulty',0.920,120,127,156,203,'ai',NULL,NULL,NULL,'2025-11-28 11:05:42'),(_binary '¨\Á&\Ë,Oy§ûZ/',_binary '§íS˝xB∆öò¡\‡XH\Â\€',1,3,'potential_faulty',0.935,258,131,335,205,'ai',NULL,NULL,NULL,'2025-11-28 11:05:42'),(_binary 'Û;å]\ÍB9ØÒ∫d<ıu',_binary '§íS˝xB∆öò¡\‡XH\Â\€',2,3,'potential_faulty',0.929,166,133,245,205,'ai',NULL,NULL,NULL,'2025-11-28 11:05:42');
/*!40000 ALTER TABLE `maintenance_record_anomalies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_records`
--

DROP TABLE IF EXISTS `maintenance_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_records` (
  `id` binary(16) NOT NULL,
  `record_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `transformer_id` binary(16) NOT NULL,
  `inspection_id` binary(16) NOT NULL,
  `inspection_date` date DEFAULT NULL,
  `weather_condition` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thermal_image_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `anomaly_count` int DEFAULT '0',
  `start_time` time DEFAULT NULL,
  `completion_time` time DEFAULT NULL,
  `supervised_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gang_tech_1` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Technician I',
  `gang_tech_2` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Technician II',
  `gang_tech_3` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Technician III',
  `gang_helpers` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_date` date DEFAULT NULL,
  `rectified_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rectified_date` date DEFAULT NULL,
  `re_inspected_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `re_inspected_date` date DEFAULT NULL,
  `css_inspector` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `css_date` date DEFAULT NULL,
  `all_spotted_spots_corrected` tinyint(1) DEFAULT '0',
  `css_inspector_2` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `css_date_2` date DEFAULT NULL,
  `branch` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transformer_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pole_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location_details` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_inspection` date DEFAULT NULL,
  `inspection_time` time DEFAULT NULL,
  `baseline_right` decimal(5,2) DEFAULT NULL,
  `baseline_left` decimal(5,2) DEFAULT NULL,
  `baseline_front` decimal(5,2) DEFAULT NULL,
  `load_growth_kva` decimal(10,2) DEFAULT NULL,
  `current_month_date` date DEFAULT NULL,
  `current_month_kva` decimal(10,2) DEFAULT NULL,
  `baseline_condition` enum('GOOD','FAIR','POOR') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transformer_type` enum('BULK','DISTRIBUTION','POLE_MOUNTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meter_serial` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meter_maker_ct_ratio` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meter_make` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `work_content` json DEFAULT NULL COMMENT 'Stores selected work items as {"Mo": true, "C": false, ...}',
  `after_inspection_ok` tinyint(1) DEFAULT '0',
  `after_inspection_not_ok` tinyint(1) DEFAULT '0',
  `after_inspection_rf_nos` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `after_inspection_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `first_inspection_v_x` decimal(10,2) DEFAULT NULL,
  `first_inspection_v_y` decimal(10,2) DEFAULT NULL,
  `first_inspection_v_z` decimal(10,2) DEFAULT NULL,
  `first_inspection_i_r` decimal(10,2) DEFAULT NULL,
  `first_inspection_i_y` decimal(10,2) DEFAULT NULL,
  `first_inspection_i_b` decimal(10,2) DEFAULT NULL,
  `second_inspection_v_x` decimal(10,2) DEFAULT NULL,
  `second_inspection_v_y` decimal(10,2) DEFAULT NULL,
  `second_inspection_v_z` decimal(10,2) DEFAULT NULL,
  `second_inspection_i_r` decimal(10,2) DEFAULT NULL,
  `second_inspection_i_y` decimal(10,2) DEFAULT NULL,
  `second_inspection_i_b` decimal(10,2) DEFAULT NULL,
  `status` enum('DRAFT','FINALIZED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
  `version` int DEFAULT '1',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finalized_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `css_inspector_date` date DEFAULT NULL,
  `engineer_remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `finalized_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_current_b` decimal(7,2) DEFAULT NULL,
  `first_current_r` decimal(7,2) DEFAULT NULL,
  `first_current_y` decimal(7,2) DEFAULT NULL,
  `first_kw_b` decimal(7,2) DEFAULT NULL,
  `first_kw_r` decimal(7,2) DEFAULT NULL,
  `first_kw_y` decimal(7,2) DEFAULT NULL,
  `first_power_factor_b` decimal(4,3) DEFAULT NULL,
  `first_power_factor_r` decimal(4,3) DEFAULT NULL,
  `first_power_factor_y` decimal(4,3) DEFAULT NULL,
  `first_voltage_b` decimal(7,2) DEFAULT NULL,
  `first_voltage_r` decimal(7,2) DEFAULT NULL,
  `first_voltage_y` decimal(7,2) DEFAULT NULL,
  `meter_maker` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meter_serial_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `second_current_b` decimal(7,2) DEFAULT NULL,
  `second_current_r` decimal(7,2) DEFAULT NULL,
  `second_current_y` decimal(7,2) DEFAULT NULL,
  `second_inspection_date` date DEFAULT NULL,
  `second_kw_b` decimal(7,2) DEFAULT NULL,
  `second_kw_r` decimal(7,2) DEFAULT NULL,
  `second_kw_y` decimal(7,2) DEFAULT NULL,
  `second_power_factor_b` decimal(4,3) DEFAULT NULL,
  `second_power_factor_r` decimal(4,3) DEFAULT NULL,
  `second_power_factor_y` decimal(4,3) DEFAULT NULL,
  `second_voltage_b` decimal(7,2) DEFAULT NULL,
  `second_voltage_r` decimal(7,2) DEFAULT NULL,
  `second_voltage_y` decimal(7,2) DEFAULT NULL,
  `transformer_status` enum('NOT_WORKING','PARTIALLY_WORKING','WORKING') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `record_number` (`record_number`),
  UNIQUE KEY `uk_record_number` (`record_number`),
  KEY `idx_transformer_id` (`transformer_id`),
  KEY `idx_inspection_id` (`inspection_id`),
  KEY `idx_status` (`status`),
  KEY `idx_date_of_inspection` (`date_of_inspection`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_transformer_date` (`transformer_id`,`date_of_inspection`),
  KEY `idx_transformer_status` (`transformer_id`,`status`),
  KEY `idx_finalized_records` (`status`,`finalized_at`),
  CONSTRAINT `fk_maintenance_inspection` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_maintenance_transformer` FOREIGN KEY (`transformer_id`) REFERENCES `transformers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Digital maintenance records with inspection data and engineer inputs';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_records`
--

LOCK TABLES `maintenance_records` WRITE;
/*!40000 ALTER TABLE `maintenance_records` DISABLE KEYS */;
INSERT INTO `maintenance_records` VALUES (_binary '§íS˝xB∆öò¡\‡XH\Â\€','MR-TX-002-001',_binary 'Px™\œe¸O\ÈÇ¡^\‚/jE[',_binary 'oeˇ6\◊L»§ü\‹~8d','2025-11-28','CLOUDY','http://localhost:8080/files/5078aacf-65fc-4fe9-82c1-5ee22f6a455b/inspection/43b90d9d-ca75-4082-b40a-430f516b6318_annotated_INS-002_1764347151877.png',3,'22:05:00','22:05:00','JALIYA','KAMAL','SUNIL','NIMA','Gamage,Nihal','Jaliya','2025-11-28','Kamal','2025-11-28',NULL,NULL,'Nimali',NULL,0,NULL,NULL,'Gampaha','TX-002','EN-122-B',NULL,'2025-11-28',NULL,45.00,50.00,45.00,1000.00,NULL,NULL,'FAIR','DISTRIBUTION',NULL,NULL,'None',NULL,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'DRAFT',2,'engineer','engineer','2025-11-28 11:05:42','2025-11-28 11:07:37',NULL,0,'2025-11-28','None',NULL,67.00,56.00,67.00,100.00,100.00,100.00,0.004,0.004,0.005,70.00,50.00,78.00,'None','33-67','None',56.00,12.00,34.00,'2025-11-28',78.00,344.00,679.00,0.007,0.003,0.010,344.00,10.00,34.00,'NOT_WORKING');
/*!40000 ALTER TABLE `maintenance_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thermal_images`
--

DROP TABLE IF EXISTS `thermal_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thermal_images` (
  `id` binary(16) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `env_condition` enum('CLOUDY','RAINY','SUNNY') DEFAULT NULL,
  `original_filename` varchar(255) DEFAULT NULL,
  `public_url` varchar(255) DEFAULT NULL,
  `size_bytes` bigint DEFAULT NULL,
  `stored_filename` varchar(255) DEFAULT NULL,
  `type` enum('BASELINE','MAINTENANCE','INSPECTION') NOT NULL,
  `uploaded_at` datetime(6) DEFAULT NULL,
  `uploader` varchar(255) DEFAULT NULL,
  `transformer_id` binary(16) NOT NULL,
  `inspection_id` binary(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKnsq63y0cepal10a8rt4twhq2e` (`transformer_id`),
  KEY `FK5w6vpcnvpiar8kculwo4nvuqp` (`inspection_id`),
  CONSTRAINT `FK5w6vpcnvpiar8kculwo4nvuqp` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`),
  CONSTRAINT `FKnsq63y0cepal10a8rt4twhq2e` FOREIGN KEY (`transformer_id`) REFERENCES `transformers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thermal_images`
--

LOCK TABLES `thermal_images` WRITE;
/*!40000 ALTER TABLE `thermal_images` DISABLE KEYS */;
INSERT INTO `thermal_images` VALUES (_binary '0\’\ZKﬁã\»ı\‹>Ú?f','image/jpeg',NULL,'WhatsApp Image 2025-11-28 at 21.46.03.jpeg','http://localhost:8080/files/5078aacf-65fc-4fe9-82c1-5ee22f6a455b/inspection/d694494e-a664-4c9a-bb34-74902c971e64_WhatsApp Image 2025-11-28 at 21.46.03.jpeg',19466,'d694494e-a664-4c9a-bb34-74902c971e64_WhatsApp Image 2025-11-28 at 21.46.03.jpeg','INSPECTION','2025-11-28 16:25:39.047721','Jaliya',_binary 'Px™\œe¸O\ÈÇ¡^\‚/jE[',_binary 'oeˇ6\◊L»§ü\‹~8d'),(_binary 'ôV\“˙˝KÄä\‚\Ëh?S\Ï*','image/jpeg','SUNNY','WhatsApp Image 2025-11-28 at 21.47.08.jpeg','http://localhost:8080/files/dd62ce1c-c00c-4355-af0b-94ee195a7050/baseline/9a3a68ab-d73e-4710-83b1-5209b9ba617a_WhatsApp Image 2025-11-28 at 21.47.08.jpeg',25421,'9a3a68ab-d73e-4710-83b1-5209b9ba617a_WhatsApp Image 2025-11-28 at 21.47.08.jpeg','BASELINE','2025-11-28 16:20:23.944090','admin',_binary '\›b\Œ¿CUØî\ÓZpP',NULL),(_binary '?IèmAL9òJé_BòàB','image/png',NULL,'annotated_INS-003_1764347297225.png','http://localhost:8080/files/dd62ce1c-c00c-4355-af0b-94ee195a7050/inspection/8eee620b-de21-4c01-b97e-79342c552446_annotated_INS-003_1764347297225.png',420889,'8eee620b-de21-4c01-b97e-79342c552446_annotated_INS-003_1764347297225.png','INSPECTION','2025-11-28 16:28:17.243818','Jaliya',_binary '\›b\Œ¿CUØî\ÓZpP',_binary '3 tú\€K@j¶:¸◊Ö{™'),(_binary '@\‚\◊TÉuE•ªcÇ8J2','image/jpeg','SUNNY','WhatsApp Image 2025-11-28 at 21.45.48.jpeg','http://localhost:8080/files/dd62ce1c-c00c-4355-af0b-94ee195a7050/baseline/aa99785f-702c-4b7c-b820-4a4950698ac8_WhatsApp Image 2025-11-28 at 21.45.48.jpeg',26893,'aa99785f-702c-4b7c-b820-4a4950698ac8_WhatsApp Image 2025-11-28 at 21.45.48.jpeg','BASELINE','2025-11-28 16:20:11.818249','admin',_binary '\›b\Œ¿CUØî\ÓZpP',NULL),(_binary 'T.M\ÍÅEJ¡ôvÓºª_íó','image/jpeg','RAINY','WhatsApp Image 2025-11-28 at 21.46.37.jpeg','http://localhost:8080/files/71043fb2-ad71-4397-a86c-174029934683/baseline/fa9127b3-3b44-4652-9add-fb14504172c5_WhatsApp Image 2025-11-28 at 21.46.37.jpeg',10990,'fa9127b3-3b44-4652-9add-fb14504172c5_WhatsApp Image 2025-11-28 at 21.46.37.jpeg','BASELINE','2025-11-28 16:33:30.242254','admin',_binary 'q?≤≠qCó®l@)ìFÉ',NULL),(_binary '_éFí8˛A|¢_+LU≈∑','image/jpeg',NULL,'WhatsApp Image 2025-11-28 at 21.47.36.jpeg','http://localhost:8080/files/a4bb447c-6be5-4701-81d3-536a8c944933/inspection/afb58f71-8c6d-4621-9365-aa7f39e5822d_WhatsApp Image 2025-11-28 at 21.47.36.jpeg',115798,'afb58f71-8c6d-4621-9365-aa7f39e5822d_WhatsApp Image 2025-11-28 at 21.47.36.jpeg','INSPECTION','2025-11-28 16:27:00.840298','Jaliya',_binary '§ªD|k\ÂGÅ\”SjåîI3',_binary '\Ô˜\n\ @ë¶äCvçU\›\Î'),(_binary 'bı€∞Aˆëe\Z\ÏÃÅCÄ','image/jpeg',NULL,'WhatsApp Image 2025-11-28 at 21.46.26.jpeg','http://localhost:8080/files/71043fb2-ad71-4397-a86c-174029934683/inspection/c0991b7b-d44e-4be2-97fb-d32e23e7b5b9_WhatsApp Image 2025-11-28 at 21.46.26.jpeg',12260,'c0991b7b-d44e-4be2-97fb-d32e23e7b5b9_WhatsApp Image 2025-11-28 at 21.46.26.jpeg','INSPECTION','2025-11-28 16:34:26.031375','Jaliya',_binary 'q?≤≠qCó®l@)ìFÉ',_binary '\…\Ï\ﬁ\÷G\‚ùS\ƒHf7ù'),(_binary 'jùV•éO˙òˆ\\\\P;c','image/jpeg',NULL,'WhatsApp Image 2025-11-28 at 21.45.38.jpeg','http://localhost:8080/files/bcaa4ff6-1f1d-481e-8598-d74f6f085b8f/inspection/69e09fb6-3364-4faa-8a3a-27719e6feed5_WhatsApp Image 2025-11-28 at 21.45.38.jpeg',36307,'69e09fb6-3364-4faa-8a3a-27719e6feed5_WhatsApp Image 2025-11-28 at 21.45.38.jpeg','INSPECTION','2025-11-28 16:24:24.077195','Jaliya',_binary 'º™OˆHÖò\◊Oo[è',_binary '«ø†\rÀ∫M\‚∏\Ãl˝A!\œ'),(_binary 'åŸÖIL∂∫w\¬Rß˜\…!','image/png',NULL,'annotated_INS-001_1764347079330.png','http://localhost:8080/files/bcaa4ff6-1f1d-481e-8598-d74f6f085b8f/inspection/76de2179-5a96-4edc-9e73-c4eae73d63b4_annotated_INS-001_1764347079330.png',479531,'76de2179-5a96-4edc-9e73-c4eae73d63b4_annotated_INS-001_1764347079330.png','INSPECTION','2025-11-28 16:24:39.351219','Jaliya',_binary 'º™OˆHÖò\◊Oo[è',_binary '«ø†\rÀ∫M\‚∏\Ãl˝A!\œ'),(_binary '¢)ÜV\»9B2øsBxÅ\Z>\¬','image/png',NULL,'annotated_INS-002_1764347151877.png','http://localhost:8080/files/5078aacf-65fc-4fe9-82c1-5ee22f6a455b/inspection/43b90d9d-ca75-4082-b40a-430f516b6318_annotated_INS-002_1764347151877.png',127524,'43b90d9d-ca75-4082-b40a-430f516b6318_annotated_INS-002_1764347151877.png','INSPECTION','2025-11-28 16:25:51.897277','Jaliya',_binary 'Px™\œe¸O\ÈÇ¡^\‚/jE[',_binary 'oeˇ6\◊L»§ü\‹~8d'),(_binary '©Y\0Y\ZE+πTØãw\—«ï','image/jpeg',NULL,'WhatsApp Image 2025-11-28 at 21.46.55.jpeg','http://localhost:8080/files/dd62ce1c-c00c-4355-af0b-94ee195a7050/inspection/304082ca-c048-40f0-aef7-b9e97623802c_WhatsApp Image 2025-11-28 at 21.46.55.jpeg',45306,'304082ca-c048-40f0-aef7-b9e97623802c_WhatsApp Image 2025-11-28 at 21.46.55.jpeg','INSPECTION','2025-11-28 16:27:52.411564','Jaliya',_binary '\›b\Œ¿CUØî\ÓZpP',_binary '3 tú\€K@j¶:¸◊Ö{™'),(_binary '™\∆ÛÆÄL´\‹u:$+8É','image/jpeg','CLOUDY','WhatsApp Image 2025-11-28 at 21.47.54.jpeg','http://localhost:8080/files/a4bb447c-6be5-4701-81d3-536a8c944933/baseline/dd4691e2-3c45-4e6c-ab01-d79a30ed6326_WhatsApp Image 2025-11-28 at 21.47.54.jpeg',89830,'dd4691e2-3c45-4e6c-ab01-d79a30ed6326_WhatsApp Image 2025-11-28 at 21.47.54.jpeg','BASELINE','2025-11-28 16:21:10.728481','admin',_binary '§ªD|k\ÂGÅ\”SjåîI3',NULL),(_binary 'Æ∑\nzíKH±Ajô6Cˆb','image/png',NULL,'annotated_INS-008_1764347672277.png','http://localhost:8080/files/71043fb2-ad71-4397-a86c-174029934683/inspection/687ee8e7-8c5e-4e51-b437-7435354725f1_annotated_INS-008_1764347672277.png',85156,'687ee8e7-8c5e-4e51-b437-7435354725f1_annotated_INS-008_1764347672277.png','INSPECTION','2025-11-28 16:34:32.297523','Jaliya',_binary 'q?≤≠qCó®l@)ìFÉ',_binary '\…\Ï\ﬁ\÷G\‚ùS\ƒHf7ù'),(_binary 'ÆåΩ7~æK´\Á]˚ã1dö','image/png',NULL,'annotated_INS-004_1764347230865.png','http://localhost:8080/files/a4bb447c-6be5-4701-81d3-536a8c944933/inspection/9fda4c7a-c999-4a1e-9b2c-26a0bf8cfa31_annotated_INS-004_1764347230865.png',485560,'9fda4c7a-c999-4a1e-9b2c-26a0bf8cfa31_annotated_INS-004_1764347230865.png','INSPECTION','2025-11-28 16:27:10.885738','Jaliya',_binary '§ªD|k\ÂGÅ\”SjåîI3',_binary '\Ô˜\n\ @ë¶äCvçU\›\Î'),(_binary '¯Àü7\–A‹ÆLô-L\ŸPÄ','image/jpeg','CLOUDY','WhatsApp Image 2025-11-28 at 21.45.48.jpeg','http://localhost:8080/files/bcaa4ff6-1f1d-481e-8598-d74f6f085b8f/baseline/93cbf96e-2b04-4962-bc15-77034cacf15e_WhatsApp Image 2025-11-28 at 21.45.48.jpeg',26893,'93cbf96e-2b04-4962-bc15-77034cacf15e_WhatsApp Image 2025-11-28 at 21.45.48.jpeg','BASELINE','2025-11-28 16:16:49.457189','admin',_binary 'º™OˆHÖò\◊Oo[è',NULL),(_binary '˘hÖ\È<Bäò\Ï—ñ∑∫˚k','image/jpeg','CLOUDY','WhatsApp Image 2025-11-28 at 21.46.14.jpeg','http://localhost:8080/files/5078aacf-65fc-4fe9-82c1-5ee22f6a455b/baseline/f105d123-9d44-49e0-bb37-ba9ea22ef4c7_WhatsApp Image 2025-11-28 at 21.46.14.jpeg',14663,'f105d123-9d44-49e0-bb37-ba9ea22ef4c7_WhatsApp Image 2025-11-28 at 21.46.14.jpeg','BASELINE','2025-11-28 16:18:33.876956','admin',_binary 'Px™\œe¸O\ÈÇ¡^\‚/jE[',NULL);
/*!40000 ALTER TABLE `thermal_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transformers`
--

DROP TABLE IF EXISTS `transformers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transformers` (
  `id` binary(16) NOT NULL,
  `capacitykva` int DEFAULT NULL,
  `code` varchar(255) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `location` varchar(255) NOT NULL,
  `location_details` varchar(2048) DEFAULT NULL,
  `pole_no` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `maintenance_record_count` int DEFAULT '0' COMMENT 'Cached count of maintenance records for this transformer',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKrf31hajpol0ljs9b1kjwthqax` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transformers`
--

LOCK TABLES `transformers` WRITE;
/*!40000 ALTER TABLE `transformers` DISABLE KEYS */;
INSERT INTO `transformers` VALUES (_binary 'Px™\œe¸O\ÈÇ¡^\‚/jE[',1500,'TX-002','2025-11-28 16:18:18.293499','Udugampola',NULL,'EN-122-B','Gampaha','Bulk','2025-11-28 16:18:18.293501',0),(_binary 'q?≤≠qCó®l@)ìFÉ',1000,'TX-005','2025-11-28 16:31:57.620480','New Town',NULL,'EN-134-HA','Anuradhapura','Distribution','2025-11-28 16:31:57.620482',0),(_binary '§ªD|k\ÂGÅ\”SjåîI3',780,'TX-004','2025-11-28 16:20:57.692861','Peradeniya',NULL,'EN-115-B','Kandy','Distribution','2025-11-28 16:20:57.692864',0),(_binary 'º™OˆHÖò\◊Oo[è',1000,'TX-001','2025-11-28 16:12:16.649335','Kollupitiya',NULL,'EN-122-A','Colombo','Bulk','2025-11-28 16:12:16.649337',0),(_binary '\›b\Œ¿CUØî\ÓZpP',1200,'TX-006','2025-11-28 16:19:06.303360','Malkaduwawa',NULL,'EN-550-X','Kurunegala','Distribution','2025-11-28 16:19:06.303364',0);
/*!40000 ALTER TABLE `transformers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transx_user_activity_log`
--

DROP TABLE IF EXISTS `transx_user_activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transx_user_activity_log` (
  `id` binary(16) NOT NULL,
  `user_id` binary(16) NOT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` binary(16) DEFAULT NULL,
  `details` json DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_activity_user` (`user_id`),
  KEY `idx_activity_action` (`action`),
  KEY `idx_activity_created` (`created_at`),
  CONSTRAINT `fk_transx_activity_user` FOREIGN KEY (`user_id`) REFERENCES `transx_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transx_user_activity_log`
--

LOCK TABLES `transx_user_activity_log` WRITE;
/*!40000 ALTER TABLE `transx_user_activity_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `transx_user_activity_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transx_users`
--

DROP TABLE IF EXISTS `transx_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transx_users` (
  `id` binary(16) NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('ADMIN','INSPECTOR','VIEWER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'INSPECTOR',
  `provider` enum('EMAIL','GOOGLE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EMAIL',
  `google_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `theme_preference` enum('LIGHT','DARK','SYSTEM') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SYSTEM',
  `notifications_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `email_notifications_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `language_preference` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timezone_preference` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `google_id` (`google_id`),
  KEY `idx_transx_users_email` (`email`),
  KEY `idx_transx_users_google_id` (`google_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transx_users`
--

LOCK TABLES `transx_users` WRITE;
/*!40000 ALTER TABLE `transx_users` DISABLE KEYS */;
INSERT INTO `transx_users` VALUES (_binary 'Ü<˚DK~ò\"\Ó~s\‡z\»','Jaliya','jaliyanimantha071@gmail.con','$2a$10$ji1pGICvaRhTFBkzsYcx9OwliAMj6T/MnDRfUQBRTy7mNhQwTWnTq',NULL,'INSPECTOR','EMAIL',NULL,'SYSTEM',1,1,'en','UTC','2025-11-27 05:32:27','2025-11-28 10:59:57','2025-11-28 10:59:57',1),(_binary 'V®ñ\n\–A\Ô≤©\Ê¡Ö@-','Prabath Wijethilaka','rajans50prabath@gmail.com',NULL,'https://lh3.googleusercontent.com/a/ACg8ocIX6KfzPL3vvkDWkJmxuIwEk86rsCCXEdmPcpSJ9ufiWLwERpxS=s96-c','INSPECTOR','GOOGLE','108455024764383207884','SYSTEM',1,1,'en','UTC','2025-11-26 04:04:13','2025-11-26 12:32:30','2025-11-26 12:32:30',1),(_binary 'UF™\‚\0îA∫ôı˜w)ë','Bk Cloud5','bkcloudspace5@gmail.com',NULL,'https://lh3.googleusercontent.com/a/ACg8ocLJKKvDxrV5bAw83fbchIGXfPwLM8GRhECBIcaEIdxXZ_0dJw=s96-c','INSPECTOR','GOOGLE','106316183403819249754','SYSTEM',1,1,'en','UTC','2025-11-26 03:10:59','2025-11-26 06:05:54','2025-11-26 06:05:54',1),(_binary 's2:(\ﬂ˚MÄ§IØ\‡\Î˝j','kasun','kasun@gmail.com','$2a$10$YQWJCCS/.IBgxmfsLGFWi.3Rx5xfRhKjJsHPkD/j/n8fIYoOrJzTW',NULL,'INSPECTOR','EMAIL',NULL,'SYSTEM',1,1,'en','UTC','2025-11-26 02:20:32','2025-11-26 10:57:50','2025-11-26 10:57:50',1),(_binary 'àÆU  õÉ‘ì¬ÉK\Î','Admin User','admin@transx.com','$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG',NULL,'ADMIN','EMAIL',NULL,'SYSTEM',1,1,'en','UTC','2025-11-26 07:43:01','2025-11-26 07:43:01',NULL,1),(_binary 'ä\r\Áa¨\–MÅâ#`Ÿó\’\€','Jaliya Nimantha','jaliyanimantha071@gmail.com',NULL,'https://lh3.googleusercontent.com/a/ACg8ocKzfUNE-WeOgCa7NG1OcnCzUJ56aZr4kQDuSPYwQZbJg3itpQ=s96-c','INSPECTOR','GOOGLE','109869673278673616875','SYSTEM',1,1,'en','UTC','2025-11-27 05:26:48','2025-11-27 07:37:29','2025-11-27 07:37:29',1),(_binary '¶ƒ¥\"†Ho∏W•·πåp˘','Kasun','Kasun123@gmail.com','$2a$10$LDDU2zOuXrooZ1GXsilU3OBnMAOB.cwDsm1Kp1cx990BusbPUN1XO',NULL,'INSPECTOR','EMAIL',NULL,'SYSTEM',1,1,'en','UTC','2025-11-26 10:58:38','2025-11-26 11:11:41','2025-11-26 11:11:41',1),(_binary 'æLW\“Mó¥ˆΩCñc\€','Prabath Wijethilaka','prabathwijethilaka50@gmail.com',NULL,'https://lh3.googleusercontent.com/a/ACg8ocJEFsDNJD9hjUjyFlOwD278_UDScqpgRfw88xGItx60_-rD7TQf=s96-c','INSPECTOR','GOOGLE','115527804369620187207','SYSTEM',1,1,'en','UTC','2025-11-26 03:10:25','2025-11-26 03:10:25',NULL,1);
/*!40000 ALTER TABLE `transx_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` enum('student','lecturer','admin') NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'student1','pass123','student','student1@uni.com'),(2,'lecturer1','pass456','lecturer','lecturer1@uni.com'),(3,'admin1','adminpass','admin','admin@uni.com');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `inspection_boxes_current`
--

/*!50001 DROP VIEW IF EXISTS `inspection_boxes_current`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `inspection_boxes_current` AS select `a`.`inspection_id` AS `inspection_id`,hex(`a`.`inspection_id`) AS `inspection_id_hex`,`i`.`inspection_number` AS `inspection_number`,`a`.`box_number` AS `box_number`,`a`.`class_name` AS `class_name`,`a`.`class_id` AS `class_id`,`a`.`confidence` AS `confidence`,`a`.`source` AS `source`,`a`.`action_type` AS `action_type`,`a`.`created_by` AS `created_by`,`a`.`current_inspector` AS `current_inspector`,`a`.`created_at` AS `created_at`,`a`.`bbox_x1` AS `bbox_x1`,`a`.`bbox_y1` AS `bbox_y1`,`a`.`bbox_x2` AS `bbox_x2`,`a`.`bbox_y2` AS `bbox_y2`,`i`.`status` AS `inspection_status`,`i`.`current_inspector` AS `inspection_current_inspector` from (`annotations` `a` join `inspections` `i` on((`a`.`inspection_id` = `i`.`id`))) where (`a`.`is_active` = 1) order by `a`.`inspection_id`,`a`.`box_number` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `inspection_history_view`
--

/*!50001 DROP VIEW IF EXISTS `inspection_history_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `inspection_history_view` AS select `h`.`id` AS `id`,`h`.`inspection_id` AS `inspection_id`,hex(`h`.`inspection_id`) AS `inspection_id_hex`,`i`.`inspection_number` AS `inspection_number`,`h`.`box_number` AS `box_number`,`h`.`action_type` AS `action_type`,`h`.`action_description` AS `action_description`,`h`.`user_name` AS `user_name`,`h`.`previous_data` AS `previous_data`,`h`.`new_data` AS `new_data`,`h`.`created_at` AS `created_at`,`i`.`status` AS `inspection_status`,`i`.`current_inspector` AS `current_inspector` from (`inspection_history` `h` join `inspections` `i` on((`h`.`inspection_id` = `i`.`id`))) order by `h`.`created_at` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-28 22:14:14
