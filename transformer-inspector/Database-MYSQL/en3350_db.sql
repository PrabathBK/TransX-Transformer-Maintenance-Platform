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
  `current_inspector` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
INSERT INTO `annotations` VALUES (_binary 'Ç5±\n0H[ã=QT≤∏Ñ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',1,251,149,371,279,3,'potential_faulty',10,0.968,'ai','approved','AI-YOLOv8','AI-System','2025-10-22 03:12:05','current-user@example.com','2025-10-22 03:12:13',NULL,1,NULL),(_binary '\0\⁄\≈\ÂLAkÑ\·˛j—ú>ï',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',1,380,403,457,514,0,'faulty',2,0.765,'ai','approved','AI-YOLOv8','AI-System','2025-11-10 09:17:19','current-user@example.com','2025-11-10 09:17:25',NULL,1,NULL),(_binary '&7\Ó®:\ÈFˇÑ2ÜtÆl',_binary '´òç†\ÕpAEçˇh\Êp\‚-',1,118,156,230,265,4,'potential_faulty',12,1.000,'human','created','current-user@example.com',NULL,'2025-10-22 03:12:23',NULL,NULL,NULL,1,NULL),(_binary '&ö ë,¡O™òyé±\ÍA\Ã',_binary 'Ñ\·R`ö@∫Sfûv°ùt',1,1043,875,1586,1325,1,'Faulty',2,1.000,'human','deleted','current-user@example.com',NULL,'2025-10-22 00:17:07','current-user@example.com','2025-10-22 00:18:14',NULL,0,NULL),(_binary '(ì\ƒ\≈q=DN©í\ÿ\€¬Æ}',_binary '´òç†\ÕpAEçˇh\Êp\‚-',1,189,283,233,314,4,'potential_faulty',13,1.000,'human','created','current-user@example.com',NULL,'2025-10-22 03:12:25',NULL,NULL,NULL,1,NULL),(_binary '?≥∞p¥ÉB∂¢íL2ÉˇÇY',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,143,409,216,572,0,'faulty',4,0.846,'ai','approved','AI-YOLOv8','AI-System','2025-10-22 03:13:59','current-user@example.com','2025-10-22 03:14:14',NULL,1,NULL),(_binary 'S¯rHﬁ¶A[£tΩLÖ-z',_binary 'Ñ\·R`ö@∫Sfûv°ùt',2,659,189,1132,587,2,'faulty_loose_joint',1,0.665,'ai','edited',NULL,'AI-System','2025-10-22 00:18:35','current-user@example.com','2025-10-22 00:18:35',_binary '°®π˛\Î@NΩ\·pÖúf\"',1,'fine'),(_binary 'j¬å\ÕïIˆì\ﬂl\ƒU:@',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',1,298,289,365,471,1,'Faulty',3,1.000,'human','created','current-user@example.com',NULL,'2025-11-10 09:17:40',NULL,NULL,NULL,1,NULL),(_binary 'ì\Œ\ŒJ(LGÆeÚ\¬\«\‘,k',_binary '´òç†\ÕpAEçˇh\Êp\‚-',1,388,151,503,279,3,'potential_faulty',11,0.960,'ai','approved','AI-YOLOv8','AI-System','2025-10-22 03:12:05','current-user@example.com','2025-10-22 03:12:15',NULL,1,NULL),(_binary '°®π˛\Î@NΩ\·pÖúf\"',_binary 'Ñ\·R`ö@∫Sfûv°ùt',1,659,189,1132,587,1,'faulty_loose_joint',1,0.665,'ai','approved','AI-YOLOv8','AI-System','2025-10-22 00:16:46','current-user@example.com','2025-10-22 00:16:50',NULL,0,NULL),(_binary '≥Çú0¢AÛìÑ\Ã\"›ßú',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,284,400,357,541,0,'faulty',5,0.831,'ai','approved','AI-YOLOv8','AI-System','2025-10-22 03:13:59','current-user@example.com','2025-10-22 03:14:13',NULL,1,NULL),(_binary '\‡koˆn¡D©Ä3u^™ä',_binary '´òç†\ÕpAEçˇh\Êp\‚-',1,120,152,236,276,3,'potential_faulty',12,0.905,'ai','rejected','AI-YOLOv8','AI-System','2025-10-22 03:12:05','current-user@example.com','2025-10-22 03:12:21',NULL,0,'User rejected this annotation'),(_binary '\ÊBZ\∆\›Cﬁì‹ò≠td',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,417,365,602,602,0,'faulty',3,0.883,'ai','approved','AI-YOLOv8','AI-System','2025-10-22 03:13:59','current-user@example.com','2025-10-22 03:14:16',NULL,1,NULL),(_binary '\ÍJ∏ñQ˚M~±I\ŒUì\⁄\‹d',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',1,60,260,287,603,0,'faulty',1,0.850,'ai','approved','AI-YOLOv8','AI-System','2025-11-10 09:17:18','current-user@example.com','2025-11-10 09:17:27',NULL,1,NULL),(_binary '˜4Ii˝IÑı⁄æë≤a\Á',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,135,207,245,291,4,'potential_faulty',6,1.000,'human','created','current-user@example.com',NULL,'2025-10-22 03:14:10',NULL,NULL,NULL,1,NULL),(_binary '˝´n¨ºuGMû±¨±≠°92',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',1,1248,783,1317,870,1,'faulty_loose_joint',1,0.712,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 00:55:46','current-user@example.com','2025-10-05 00:55:54',NULL,1,NULL);
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
INSERT INTO `box_numbering_sequence` VALUES (_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',3,'2025-11-10 14:47:18'),(_binary 'Ñ\·R`ö@∫Sfûv°ùt',2,'2025-10-22 05:46:45'),(_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',2,'2025-10-05 06:25:46'),(_binary '´òç†\ÕpAEçˇh\Êp\‚-',13,'2025-10-22 08:42:05'),(_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',6,'2025-10-22 08:43:58');
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
  `user_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_type` enum('VIEW','EDIT','CREATE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_start` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `session_end` timestamp NULL DEFAULT NULL,
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
INSERT INTO `inspection_comments` VALUES (_binary '÷æ\Ô∏:E÷ÆK6≠∑a4~',_binary '´òç†\ÕpAEçˇh\Êp\‚-','add comments','admin','2025-10-22 02:58:58.296323','2025-10-22 02:58:58.296333');
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
  `action_type` enum('INSPECTION_CREATED','INSPECTOR_CHANGED','AI_DETECTION_RUN','BOX_CREATED','BOX_EDITED','BOX_MOVED','BOX_RESIZED','BOX_APPROVED','BOX_REJECTED','BOX_DELETED','CLASS_CHANGED','CONFIDENCE_UPDATED','STATUS_CHANGED','INSPECTION_COMPLETED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_description` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
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
INSERT INTO `inspection_history` VALUES (_binary '_†T°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','PRABATH','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 12:44:17'),(_binary 'éw*Ø#≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',10,'BOX_APPROVED','Box #10 approved','AI-System','{\"bbox\": {\"x1\": 251, \"x2\": 371, \"y1\": 149, \"y2\": 279}, \"class_id\": 3, \"box_number\": 10, \"class_name\": \"potential_faulty\", \"confidence\": 0.968, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 251, \"x2\": 371, \"y1\": 149, \"y2\": 279}, \"class_id\": 3, \"box_number\": 10, \"class_name\": \"potential_faulty\", \"confidence\": 0.968, \"action_type\": \"approved\"}','2025-10-22 08:42:13'),(_binary 'zè\\Ø#≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',11,'BOX_APPROVED','Box #11 approved','AI-System','{\"bbox\": {\"x1\": 388, \"x2\": 503, \"y1\": 151, \"y2\": 279}, \"class_id\": 3, \"box_number\": 11, \"class_name\": \"potential_faulty\", \"confidence\": 0.960, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 388, \"x2\": 503, \"y1\": 151, \"y2\": 279}, \"class_id\": 3, \"box_number\": 11, \"class_name\": \"potential_faulty\", \"confidence\": 0.960, \"action_type\": \"approved\"}','2025-10-22 08:42:14'),(_binary 'Ú	$°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.817}, {\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.804}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 12:44:21'),(_binary 'Û	ñ°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,'AI_DETECTION_RUN','AI detected box #1 - Faulty (confidence: 0.817)','AI-System',NULL,'{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"created\"}','2025-10-05 12:44:21'),(_binary 'Ûf°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',2,'AI_DETECTION_RUN','AI detected box #2 - Faulty (confidence: 0.804)','AI-System',NULL,'{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"created\"}','2025-10-05 12:44:21'),(_binary 'Pp°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"approved\"}','2025-10-05 12:44:23'),(_binary '≠G°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',2,'BOX_APPROVED','Box #2 approved','AI-System','{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"approved\"}','2025-10-05 12:44:24'),(_binary '\ËàØ#≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',12,'BOX_REJECTED','Box #12 rejected','AI-System','{\"bbox\": {\"x1\": 120, \"x2\": 236, \"y1\": 152, \"y2\": 276}, \"class_id\": 3, \"box_number\": 12, \"class_name\": \"potential_faulty\", \"confidence\": 0.905, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 120, \"x2\": 236, \"y1\": 152, \"y2\": 276}, \"class_id\": 3, \"box_number\": 12, \"class_name\": \"potential_faulty\", \"confidence\": 0.905, \"action_type\": \"rejected\"}','2025-10-22 08:42:20'),(_binary 'F°\ÏØ#≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',12,'BOX_CREATED','User created box #12 - potential_faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 118, \"x2\": 230, \"y1\": 156, \"y2\": 265}, \"source\": \"human\", \"class_id\": 4, \"box_number\": 12, \"class_name\": \"potential_faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-22 08:42:22'),(_binary 'a¿RØ#≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',13,'BOX_CREATED','User created box #13 - potential_faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 189, \"x2\": 233, \"y1\": 283, \"y2\": 314}, \"source\": \"human\", \"class_id\": 4, \"box_number\": 13, \"class_name\": \"potential_faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-22 08:42:24'),(_binary '\›\‡å°¥Ç\Œ\Ìøˆëı\Z',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 06:25:39'),(_binary ' Ü°¥Ç\Œ\Ìøˆëı\Z',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 06:25:46'),(_binary ' á\‡ò°¥Ç\Œ\Ìøˆëı\Z',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',1,'AI_DETECTION_RUN','AI detected box #1 - faulty_loose_joint (confidence: 0.712)','AI-System',NULL,'{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','2025-10-05 06:25:46'),(_binary '$\\ıDæDªj=ıö∏\À',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-11-10 14:47:12'),(_binary '%3î°¥Ç\Œ\Ìøˆëı\Z',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"approved\"}','2025-10-05 06:25:53'),(_binary '\'\Â\Î\ÓæDªj=ıö∏\À',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 60, \"x2\": 287, \"y1\": 260, \"y2\": 603}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.85}, {\"bbox\": {\"x1\": 380, \"x2\": 457, \"y1\": 403, \"y2\": 514}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.765}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-11-10 14:47:18'),(_binary '\'\ÁH6æDªj=ıö∏\À',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',1,'AI_DETECTION_RUN','AI detected box #1 - faulty (confidence: 0.850)','AI-System',NULL,'{\"bbox\": {\"x1\": 60, \"x2\": 287, \"y1\": 260, \"y2\": 603}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.850, \"action_type\": \"created\"}','2025-11-10 14:47:18'),(_binary '\'\Á{ÄæDªj=ıö∏\À',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',2,'AI_DETECTION_RUN','AI detected box #2 - faulty (confidence: 0.765)','AI-System',NULL,'{\"bbox\": {\"x1\": 380, \"x2\": 457, \"y1\": 403, \"y2\": 514}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.765, \"action_type\": \"created\"}','2025-11-10 14:47:18'),(_binary '+£7æDªj=ıö∏\À',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',2,'BOX_APPROVED','Box #2 approved','AI-System','{\"bbox\": {\"x1\": 380, \"x2\": 457, \"y1\": 403, \"y2\": 514}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.765, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 380, \"x2\": 457, \"y1\": 403, \"y2\": 514}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.765, \"action_type\": \"approved\"}','2025-11-10 14:47:24'),(_binary ',¿\ZöæDªj=ıö∏\À',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 60, \"x2\": 287, \"y1\": 260, \"y2\": 603}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.850, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 60, \"x2\": 287, \"y1\": 260, \"y2\": 603}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.850, \"action_type\": \"approved\"}','2025-11-10 14:47:26'),(_binary '4§sæDªj=ıö∏\À',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 298, \"x2\": 365, \"y1\": 289, \"y2\": 471}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-11-10 14:47:39'),(_binary ':\‡8Ø#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','PRABATH','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-22 08:43:49'),(_binary '@p;ÃØ#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'AI_DETECTION_RUN','AI detected 3 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 417, \"x2\": 602, \"y1\": 365, \"y2\": 602}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"faulty\", \"confidence\": 0.883}, {\"bbox\": {\"x1\": 143, \"x2\": 216, \"y1\": 409, \"y2\": 572}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 4, \"class_name\": \"faulty\", \"confidence\": 0.846}, {\"bbox\": {\"x1\": 284, \"x2\": 357, \"y1\": 400, \"y2\": 541}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 5, \"class_name\": \"faulty\", \"confidence\": 0.831}], \"total_detections\": 3, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 3, \"confidence_threshold\": \"user_specified\"}}','2025-10-22 08:43:58'),(_binary '@qı\\Ø#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'AI_DETECTION_RUN','AI detected box #3 - faulty (confidence: 0.883)','AI-System',NULL,'{\"bbox\": {\"x1\": 417, \"x2\": 602, \"y1\": 365, \"y2\": 602}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"faulty\", \"confidence\": 0.883, \"action_type\": \"created\"}','2025-10-22 08:43:58'),(_binary '@rFˆØ#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',4,'AI_DETECTION_RUN','AI detected box #4 - faulty (confidence: 0.846)','AI-System',NULL,'{\"bbox\": {\"x1\": 143, \"x2\": 216, \"y1\": 409, \"y2\": 572}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 4, \"class_name\": \"faulty\", \"confidence\": 0.846, \"action_type\": \"created\"}','2025-10-22 08:43:58'),(_binary '@ráÿØ#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',5,'AI_DETECTION_RUN','AI detected box #5 - faulty (confidence: 0.831)','AI-System',NULL,'{\"bbox\": {\"x1\": 284, \"x2\": 357, \"y1\": 400, \"y2\": 541}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 5, \"class_name\": \"faulty\", \"confidence\": 0.831, \"action_type\": \"created\"}','2025-10-22 08:43:58'),(_binary 'BV\ÓÓÆ¨≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to COMPLETED','PRABATH','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"COMPLETED\", \"current_inspector\": null}','2025-10-21 18:32:11'),(_binary 'F\Êƒ≤Ø#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',6,'BOX_CREATED','User created box #6 - potential_faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 135, \"x2\": 245, \"y1\": 207, \"y2\": 291}, \"source\": \"human\", \"class_id\": 4, \"box_number\": 6, \"class_name\": \"potential_faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-22 08:44:09'),(_binary 'H\⁄”ÄØ#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',5,'BOX_APPROVED','Box #5 approved','AI-System','{\"bbox\": {\"x1\": 284, \"x2\": 357, \"y1\": 400, \"y2\": 541}, \"class_id\": 0, \"box_number\": 5, \"class_name\": \"faulty\", \"confidence\": 0.831, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 284, \"x2\": 357, \"y1\": 400, \"y2\": 541}, \"class_id\": 0, \"box_number\": 5, \"class_name\": \"faulty\", \"confidence\": 0.831, \"action_type\": \"approved\"}','2025-10-22 08:44:12'),(_binary 'Iw\'XØ#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',4,'BOX_APPROVED','Box #4 approved','AI-System','{\"bbox\": {\"x1\": 143, \"x2\": 216, \"y1\": 409, \"y2\": 572}, \"class_id\": 0, \"box_number\": 4, \"class_name\": \"faulty\", \"confidence\": 0.846, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 143, \"x2\": 216, \"y1\": 409, \"y2\": 572}, \"class_id\": 0, \"box_number\": 4, \"class_name\": \"faulty\", \"confidence\": 0.846, \"action_type\": \"approved\"}','2025-10-22 08:44:13'),(_binary 'IÒb~Æ¨≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 238, \"x2\": 350, \"y1\": 241, \"y2\": 304}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-21 18:32:24'),(_binary 'Jç‘Ø#≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_APPROVED','Box #3 approved','AI-System','{\"bbox\": {\"x1\": 417, \"x2\": 602, \"y1\": 365, \"y2\": 602}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"faulty\", \"confidence\": 0.883, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 417, \"x2\": 602, \"y1\": 365, \"y2\": 602}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"faulty\", \"confidence\": 0.883, \"action_type\": \"approved\"}','2025-10-22 08:44:15'),(_binary 'J•tíØ!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to DRAFT','Dinethra','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"DRAFT\", \"current_inspector\": null}','2025-10-22 08:29:56'),(_binary 'J´%¬Ø!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_EDITED','Box #3 modified','current-user@example.com','{\"bbox\": {\"x1\": 131, \"x2\": 391, \"y1\": 34, \"y2\": 97}, \"class_id\": 3, \"box_number\": 3, \"class_name\": \"faulty_point_overload\", \"confidence\": 1.000, \"action_type\": \"deleted\"}','{\"bbox\": {\"x1\": 131, \"x2\": 391, \"y1\": 34, \"y2\": 97}, \"class_id\": 3, \"box_number\": 3, \"class_name\": \"faulty_point_overload\", \"confidence\": 1.000, \"action_type\": \"deleted\"}','2025-10-22 08:29:56'),(_binary 'J´l\ÓØ!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_EDITED','Box #3 modified','current-user@example.com','{\"bbox\": {\"x1\": 118, \"x2\": 235, \"y1\": 138, \"y2\": 282}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 118, \"x2\": 235, \"y1\": 138, \"y2\": 282}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-22 08:29:57'),(_binary 'MK\–HØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Dinethra','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-22 08:22:51'),(_binary 'PÛè˙Ø!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Dinethra','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-22 08:30:07'),(_binary 'Qm7îÆ¨≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_DELETED','Box #3 deleted','current-user@example.com','{\"bbox\": {\"x1\": 238, \"x2\": 350, \"y1\": 241, \"y2\": 304}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 238, \"x2\": 350, \"y1\": 241, \"y2\": 304}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"deleted\"}','2025-10-21 18:32:37'),(_binary 'TK†DØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'AI_DETECTION_RUN','AI detected 3 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 249, \"x2\": 377, \"y1\": 144, \"y2\": 288}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.917}, {\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.905}, {\"bbox\": {\"x1\": 115, \"x2\": 241, \"y1\": 153, \"y2\": 292}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"faulty\", \"confidence\": 0.862}], \"total_detections\": 3, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 3, \"confidence_threshold\": \"user_specified\"}}','2025-10-22 08:23:03'),(_binary 'TO§2Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',1,'AI_DETECTION_RUN','AI detected box #1 - faulty (confidence: 0.917)','AI-System',NULL,'{\"bbox\": {\"x1\": 249, \"x2\": 377, \"y1\": 144, \"y2\": 288}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.917, \"action_type\": \"created\"}','2025-10-22 08:23:03'),(_binary 'TP\Z>Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',2,'AI_DETECTION_RUN','AI detected box #2 - faulty (confidence: 0.905)','AI-System',NULL,'{\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.905, \"action_type\": \"created\"}','2025-10-22 08:23:03'),(_binary 'TPÜ6Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'AI_DETECTION_RUN','AI detected box #3 - faulty (confidence: 0.862)','AI-System',NULL,'{\"bbox\": {\"x1\": 115, \"x2\": 241, \"y1\": 153, \"y2\": 292}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"faulty\", \"confidence\": 0.862, \"action_type\": \"created\"}','2025-10-22 08:23:03'),(_binary 'T\∆x÷Ø!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'AI_DETECTION_RUN','AI detected 3 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 251, \"x2\": 371, \"y1\": 149, \"y2\": 279}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 4, \"class_name\": \"potential_faulty\", \"confidence\": 0.968}, {\"bbox\": {\"x1\": 388, \"x2\": 503, \"y1\": 151, \"y2\": 279}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 5, \"class_name\": \"potential_faulty\", \"confidence\": 0.96}, {\"bbox\": {\"x1\": 120, \"x2\": 236, \"y1\": 152, \"y2\": 276}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 6, \"class_name\": \"potential_faulty\", \"confidence\": 0.905}], \"total_detections\": 3, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 3, \"confidence_threshold\": \"user_specified\"}}','2025-10-22 08:30:13'),(_binary 'T\«F¯Ø!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',4,'AI_DETECTION_RUN','AI detected box #4 - potential_faulty (confidence: 0.968)','AI-System',NULL,'{\"bbox\": {\"x1\": 251, \"x2\": 371, \"y1\": 149, \"y2\": 279}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 4, \"class_name\": \"potential_faulty\", \"confidence\": 0.968, \"action_type\": \"created\"}','2025-10-22 08:30:13'),(_binary 'T\«pjØ!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',5,'AI_DETECTION_RUN','AI detected box #5 - potential_faulty (confidence: 0.960)','AI-System',NULL,'{\"bbox\": {\"x1\": 388, \"x2\": 503, \"y1\": 151, \"y2\": 279}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 5, \"class_name\": \"potential_faulty\", \"confidence\": 0.960, \"action_type\": \"created\"}','2025-10-22 08:30:13'),(_binary 'T\«\ÕXØ!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',6,'AI_DETECTION_RUN','AI detected box #6 - potential_faulty (confidence: 0.905)','AI-System',NULL,'{\"bbox\": {\"x1\": 120, \"x2\": 236, \"y1\": 152, \"y2\": 276}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 6, \"class_name\": \"potential_faulty\", \"confidence\": 0.905, \"action_type\": \"created\"}','2025-10-22 08:30:13'),(_binary 'Z˝˘êØ!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to DRAFT','Dinethra','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"DRAFT\", \"current_inspector\": null}','2025-10-22 08:30:24'),(_binary '\\q{\ÍØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_REJECTED','Box #3 rejected','AI-System','{\"bbox\": {\"x1\": 115, \"x2\": 241, \"y1\": 153, \"y2\": 292}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"faulty\", \"confidence\": 0.862, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 115, \"x2\": 241, \"y1\": 153, \"y2\": 292}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"faulty\", \"confidence\": 0.862, \"action_type\": \"rejected\"}','2025-10-22 08:23:17'),(_binary ']Ù\ÌØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 249, \"x2\": 377, \"y1\": 144, \"y2\": 288}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.917, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 249, \"x2\": 377, \"y1\": 144, \"y2\": 288}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"faulty\", \"confidence\": 0.917, \"action_type\": \"approved\"}','2025-10-22 08:23:19'),(_binary '_\0≤Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',2,'BOX_APPROVED','Box #2 approved','AI-System','{\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.905, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.905, \"action_type\": \"approved\"}','2025-10-22 08:23:21'),(_binary '`#0RØ!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Dinethra','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-22 08:30:33'),(_binary 'c\ÂA≤Ø!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'AI_DETECTION_RUN','AI detected 3 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 249, \"x2\": 377, \"y1\": 144, \"y2\": 288}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 7, \"class_name\": \"faulty\", \"confidence\": 0.917}, {\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 8, \"class_name\": \"faulty\", \"confidence\": 0.905}, {\"bbox\": {\"x1\": 115, \"x2\": 241, \"y1\": 153, \"y2\": 292}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 9, \"class_name\": \"faulty\", \"confidence\": 0.862}], \"total_detections\": 3, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 3, \"confidence_threshold\": \"user_specified\"}}','2025-10-22 08:30:39'),(_binary 'c\Ê˙Ø!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',7,'AI_DETECTION_RUN','AI detected box #7 - faulty (confidence: 0.917)','AI-System',NULL,'{\"bbox\": {\"x1\": 249, \"x2\": 377, \"y1\": 144, \"y2\": 288}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 7, \"class_name\": \"faulty\", \"confidence\": 0.917, \"action_type\": \"created\"}','2025-10-22 08:30:39'),(_binary 'c\Ê*Ø!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',8,'AI_DETECTION_RUN','AI detected box #8 - faulty (confidence: 0.905)','AI-System',NULL,'{\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 8, \"class_name\": \"faulty\", \"confidence\": 0.905, \"action_type\": \"created\"}','2025-10-22 08:30:39'),(_binary 'c\ÊM\ÊØ!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',9,'AI_DETECTION_RUN','AI detected box #9 - faulty (confidence: 0.862)','AI-System',NULL,'{\"bbox\": {\"x1\": 115, \"x2\": 241, \"y1\": 153, \"y2\": 292}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 9, \"class_name\": \"faulty\", \"confidence\": 0.862, \"action_type\": \"created\"}','2025-10-22 08:30:39'),(_binary 'g\\πÚØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',2,'AI_DETECTION_RUN','AI detected box #2 - faulty (confidence: 0.905)','AI-System',NULL,'{\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.905, \"action_type\": \"edited\"}','2025-10-22 08:23:35'),(_binary 'g]†LØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',2,'BOX_EDITED','Box #2 modified','AI-System','{\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.905, \"action_type\": \"approved\"}','{\"bbox\": {\"x1\": 388, \"x2\": 510, \"y1\": 149, \"y2\": 286}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"faulty\", \"confidence\": 0.905, \"action_type\": \"approved\"}','2025-10-22 08:23:35'),(_binary 'u\”\ÎXØ!≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to COMPLETED','Dinethra','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"COMPLETED\", \"current_inspector\": null}','2025-10-22 08:31:09'),(_binary 'v/OnØ\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-22 05:46:31'),(_binary 'y©“Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_CREATED','User created box #3 - faulty_point_overload (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 131, \"x2\": 391, \"y1\": 34, \"y2\": 97}, \"source\": \"human\", \"class_id\": 3, \"box_number\": 3, \"class_name\": \"faulty_point_overload\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-22 08:24:06'),(_binary '~9ÄBØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_CREATED','User created box #3 - faulty_point_overload (confidence: 1.000)','system',NULL,'{\"bbox\": {\"x1\": 131, \"x2\": 391, \"y1\": 34, \"y2\": 97}, \"source\": \"human\", \"class_id\": 3, \"box_number\": 3, \"class_name\": \"faulty_point_overload\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-22 08:24:13'),(_binary '~9\·|Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_EDITED','Box #3 modified','current-user@example.com','{\"bbox\": {\"x1\": 131, \"x2\": 391, \"y1\": 34, \"y2\": 97}, \"class_id\": 3, \"box_number\": 3, \"class_name\": \"faulty_point_overload\", \"confidence\": 1.000, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 131, \"x2\": 391, \"y1\": 34, \"y2\": 97}, \"class_id\": 3, \"box_number\": 3, \"class_name\": \"faulty_point_overload\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-22 08:24:14'),(_binary '~ï™Ø\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 659, \"x2\": 1132, \"y1\": 189, \"y2\": 587}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.665}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-10-22 05:46:45'),(_binary '~ñ–™Ø\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',1,'AI_DETECTION_RUN','AI detected box #1 - faulty_loose_joint (confidence: 0.665)','AI-System',NULL,'{\"bbox\": {\"x1\": 659, \"x2\": 1132, \"y1\": 189, \"y2\": 587}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.665, \"action_type\": \"created\"}','2025-10-22 05:46:45'),(_binary 'Ä\Ó{(Ø\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 659, \"x2\": 1132, \"y1\": 189, \"y2\": 587}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.665, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 659, \"x2\": 1132, \"y1\": 189, \"y2\": 587}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.665, \"action_type\": \"approved\"}','2025-10-22 05:46:49'),(_binary 'É#	¿Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_DELETED','Box #3 deleted','current-user@example.com','{\"bbox\": {\"x1\": 131, \"x2\": 391, \"y1\": 34, \"y2\": 97}, \"class_id\": 3, \"box_number\": 3, \"class_name\": \"faulty_point_overload\", \"confidence\": 1.000, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 131, \"x2\": 391, \"y1\": 34, \"y2\": 97}, \"class_id\": 3, \"box_number\": 3, \"class_name\": \"faulty_point_overload\", \"confidence\": 1.000, \"action_type\": \"deleted\"}','2025-10-22 08:24:22'),(_binary 'ãVDØ\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',2,'BOX_CREATED','User created box #2 - Faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 1043, \"x2\": 1586, \"y1\": 875, \"y2\": 1325}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-22 05:47:06'),(_binary 'ëñRØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 118, \"x2\": 236, \"y1\": 152, \"y2\": 283}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-22 08:24:46'),(_binary 'î¢JØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','system',NULL,'{\"bbox\": {\"x1\": 118, \"x2\": 235, \"y1\": 138, \"y2\": 282}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-22 08:24:51'),(_binary 'î¢\«⁄Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_EDITED','Box #3 modified','current-user@example.com','{\"bbox\": {\"x1\": 118, \"x2\": 236, \"y1\": 152, \"y2\": 283}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 118, \"x2\": 236, \"y1\": 152, \"y2\": 283}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-22 08:24:51'),(_binary 'ó	£¬Ø ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','system',NULL,'{\"bbox\": {\"x1\": 117, \"x2\": 234, \"y1\": 152, \"y2\": 282}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-22 08:24:55'),(_binary 'ó\nvØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_EDITED','Box #3 modified','current-user@example.com','{\"bbox\": {\"x1\": 118, \"x2\": 235, \"y1\": 138, \"y2\": 282}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 118, \"x2\": 235, \"y1\": 138, \"y2\": 282}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-22 08:24:55'),(_binary 'ò\È\È\ÍØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','system',NULL,'{\"bbox\": {\"x1\": 118, \"x2\": 234, \"y1\": 153, \"y2\": 282}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-22 08:24:58'),(_binary 'ò\ÍNäØ ≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',3,'BOX_EDITED','Box #3 modified','current-user@example.com','{\"bbox\": {\"x1\": 117, \"x2\": 234, \"y1\": 152, \"y2\": 282}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 117, \"x2\": 234, \"y1\": 152, \"y2\": 282}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-22 08:24:58'),(_binary 'Æ\√rƒÆ´≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 318, \"x2\": 467, \"y1\": 214, \"y2\": 298}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-21 18:28:04'),(_binary '≥EM^Ø\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',2,'BOX_DELETED','Box #2 deleted','current-user@example.com','{\"bbox\": {\"x1\": 1043, \"x2\": 1586, \"y1\": 875, \"y2\": 1325}, \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 1043, \"x2\": 1586, \"y1\": 875, \"y2\": 1325}, \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"deleted\"}','2025-10-22 05:48:14'),(_binary 'æ“§Æ´≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','system',NULL,'{\"bbox\": {\"x1\": 319, \"x2\": 468, \"y1\": 184, \"y2\": 268}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-21 18:28:31'),(_binary 'æ\‘X÷Æ´≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_EDITED','Box #3 modified','current-user@example.com','{\"bbox\": {\"x1\": 318, \"x2\": 467, \"y1\": 214, \"y2\": 298}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 318, \"x2\": 467, \"y1\": 214, \"y2\": 298}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-21 18:28:31'),(_binary 'ø§ZTØ\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',1,'AI_DETECTION_RUN','AI detected box #1 - faulty_loose_joint (confidence: 0.665)','AI-System',NULL,'{\"bbox\": {\"x1\": 659, \"x2\": 1132, \"y1\": 189, \"y2\": 587}, \"source\": \"ai\", \"class_id\": 2, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.665, \"action_type\": \"edited\"}','2025-10-22 05:48:34'),(_binary 'ø§≤\ÏØ\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',1,'BOX_EDITED','Box #1 modified','AI-System','{\"bbox\": {\"x1\": 659, \"x2\": 1132, \"y1\": 189, \"y2\": 587}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.665, \"action_type\": \"approved\"}','{\"bbox\": {\"x1\": 659, \"x2\": 1132, \"y1\": 189, \"y2\": 587}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.665, \"action_type\": \"approved\"}','2025-10-22 05:48:34'),(_binary '\¬§ÄÆ´≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_DELETED','Box #3 deleted','current-user@example.com','{\"bbox\": {\"x1\": 319, \"x2\": 468, \"y1\": 184, \"y2\": 268}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 319, \"x2\": 468, \"y1\": 184, \"y2\": 268}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"deleted\"}','2025-10-21 18:28:36'),(_binary '\»\◊ZrØ\n≤7£\‡|ÀÜ',_binary 'Ñ\·R`ö@∫Sfûv°ùt',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to COMPLETED','Prabath','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"COMPLETED\", \"current_inspector\": null}','2025-10-22 05:48:50'),(_binary '\ﬂÙ&Ø\"≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'STATUS_CHANGED','Inspection status changed from COMPLETED to DRAFT','Dinethra','{\"status\": \"COMPLETED\", \"current_inspector\": null}','{\"status\": \"DRAFT\", \"current_inspector\": null}','2025-10-22 08:41:45'),(_binary 'ˆﬂÇ8Ø\"≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Dinethra','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-22 08:41:55'),(_binary '˜øö†Ø≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'STATUS_CHANGED','Inspection status changed from COMPLETED to DRAFT','PRABATH','{\"status\": \"COMPLETED\", \"current_inspector\": null}','{\"status\": \"DRAFT\", \"current_inspector\": null}','2025-10-22 06:04:27'),(_binary '¸\ `\0Ø\"≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',NULL,'AI_DETECTION_RUN','AI detected 3 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 251, \"x2\": 371, \"y1\": 149, \"y2\": 279}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 10, \"class_name\": \"potential_faulty\", \"confidence\": 0.968}, {\"bbox\": {\"x1\": 388, \"x2\": 503, \"y1\": 151, \"y2\": 279}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 11, \"class_name\": \"potential_faulty\", \"confidence\": 0.96}, {\"bbox\": {\"x1\": 120, \"x2\": 236, \"y1\": 152, \"y2\": 276}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 12, \"class_name\": \"potential_faulty\", \"confidence\": 0.905}], \"total_detections\": 3, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 3, \"confidence_threshold\": \"user_specified\"}}','2025-10-22 08:42:05'),(_binary '¸\À\‘∆Ø\"≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',10,'AI_DETECTION_RUN','AI detected box #10 - potential_faulty (confidence: 0.968)','AI-System',NULL,'{\"bbox\": {\"x1\": 251, \"x2\": 371, \"y1\": 149, \"y2\": 279}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 10, \"class_name\": \"potential_faulty\", \"confidence\": 0.968, \"action_type\": \"created\"}','2025-10-22 08:42:05'),(_binary '¸\ÃD\ZØ\"≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',11,'AI_DETECTION_RUN','AI detected box #11 - potential_faulty (confidence: 0.960)','AI-System',NULL,'{\"bbox\": {\"x1\": 388, \"x2\": 503, \"y1\": 151, \"y2\": 279}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 11, \"class_name\": \"potential_faulty\", \"confidence\": 0.960, \"action_type\": \"created\"}','2025-10-22 08:42:05'),(_binary '¸ÃÖ$Ø\"≤7£\‡|ÀÜ',_binary '´òç†\ÕpAEçˇh\Êp\‚-',12,'AI_DETECTION_RUN','AI detected box #12 - potential_faulty (confidence: 0.905)','AI-System',NULL,'{\"bbox\": {\"x1\": 120, \"x2\": 236, \"y1\": 152, \"y2\": 276}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 12, \"class_name\": \"potential_faulty\", \"confidence\": 0.905, \"action_type\": \"created\"}','2025-10-22 08:42:05');
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
  `status` enum('DRAFT','IN_PROGRESS','UNDER_REVIEW','COMPLETED','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
  `notes` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_inspector` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_at` timestamp NULL DEFAULT NULL,
  `maintenance_date` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `completed_by` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
INSERT INTO `inspections` VALUES (_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>','INS-001',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',NULL,_binary 'dÕ¥OkñBÇùYÚÜh\–V¿',NULL,'SUNNY','IN_PROGRESS',NULL,'Prabath',NULL,'2025-11-10 09:16:44',NULL,NULL,NULL,'2025-11-10 09:16:44','2025-11-10 09:17:49',_binary '\È=JæBtî.∑G¡Ö>',0),(_binary 'Ñ\·R`ö@∫Sfûv°ùt','INS-010',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',NULL,_binary 'cúü¸Hv≤¬ãv≤p/2',NULL,'SUNNY','COMPLETED',NULL,'Prabath',NULL,'2025-10-22 00:16:22',NULL,NULL,NULL,'2025-10-22 00:16:22','2025-10-22 00:18:50',_binary 'çqáh\—}NC∞ùØΩ$~3',0),(_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶','INS-003',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',NULL,_binary '\€¡Bˇ§E,£X_N~â',NULL,'CLOUDY','IN_PROGRESS',NULL,'Prabath',NULL,'2025-10-05 00:55:02',NULL,NULL,NULL,'2025-10-05 00:55:02','2025-10-05 00:56:06',_binary '\”\ÀÙ√ïI«∏òm\Zá#S\Ô',0),(_binary '´òç†\ÕpAEçˇh\Êp\‚-','INS-004',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',NULL,_binary ' \”‘õ\ËE≈ë\…e|b€∫ñ',NULL,'CLOUDY','IN_PROGRESS','test','Dinethra',NULL,'2025-10-22 02:52:36',NULL,NULL,NULL,'2025-10-22 02:52:36','2025-10-22 03:12:28',_binary 'Ü…òr@VÅ®\ÿod\„F;',0),(_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ','INS-007',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',NULL,_binary 'x%ˇS≠O@í◊õzZµY',NULL,'RAINY','IN_PROGRESS',NULL,'PRABATH',NULL,'2025-10-05 07:14:09',NULL,NULL,NULL,'2025-10-05 07:14:09','2025-10-22 03:14:18',_binary '\r:ä∂º≠E°â\ËíM≤',0);
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
  `class_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confidence` decimal(5,3) DEFAULT NULL,
  `bbox_x1` int NOT NULL,
  `bbox_y1` int NOT NULL,
  `bbox_x2` int NOT NULL,
  `bbox_y2` int NOT NULL,
  `source` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
INSERT INTO `maintenance_record_anomalies` VALUES (_binary '}Fàò-F°ºYÙ\”\…X\Ï',_binary '¢k\Œ\ÕZO]∏\Ê$¥4ıp',3,1,'Faulty',1.000,298,289,365,471,'human',NULL,NULL,'2025-11-10 09:18:18'),(_binary '\„J\"A\≈L.Æ\È°9Rä\‘\ﬁ',_binary '¢k\Œ\ÕZO]∏\Ê$¥4ıp',1,0,'faulty',0.850,60,260,287,603,'ai',NULL,NULL,'2025-11-10 09:18:18'),(_binary '\Ê{°;ÅF‰ø¨1d˝\ÎBT',_binary '¢k\Œ\ÕZO]∏\Ê$¥4ıp',2,0,'faulty',0.765,380,403,457,514,'ai',NULL,NULL,'2025-11-10 09:18:18');
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
  `record_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transformer_id` binary(16) NOT NULL,
  `inspection_id` binary(16) NOT NULL,
  `inspection_date` date DEFAULT NULL,
  `weather_condition` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thermal_image_url` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `anomaly_count` int DEFAULT '0',
  `start_time` time DEFAULT NULL,
  `completion_time` time DEFAULT NULL,
  `supervised_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gang_tech_1` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Technician I',
  `gang_tech_2` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Technician II',
  `gang_tech_3` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Technician III',
  `gang_helpers` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_date` date DEFAULT NULL,
  `rectified_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rectified_date` date DEFAULT NULL,
  `re_inspected_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `re_inspected_date` date DEFAULT NULL,
  `css_inspector` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `css_date` date DEFAULT NULL,
  `all_spotted_spots_corrected` tinyint(1) DEFAULT '0',
  `css_inspector_2` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `css_date_2` date DEFAULT NULL,
  `branch` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transformer_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pole_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location_details` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_inspection` date DEFAULT NULL,
  `inspection_time` time DEFAULT NULL,
  `baseline_right` decimal(5,2) DEFAULT NULL,
  `baseline_left` decimal(5,2) DEFAULT NULL,
  `baseline_front` decimal(5,2) DEFAULT NULL,
  `load_growth_kva` decimal(10,2) DEFAULT NULL,
  `current_month_date` date DEFAULT NULL,
  `current_month_kva` decimal(10,2) DEFAULT NULL,
  `baseline_condition` enum('GOOD','FAIR','POOR') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transformer_type` enum('BULK','DISTRIBUTION','POLE_MOUNTED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meter_serial` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meter_maker_ct_ratio` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meter_make` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `work_content` json DEFAULT NULL COMMENT 'Stores selected work items as {"Mo": true, "C": false, ...}',
  `after_inspection_ok` tinyint(1) DEFAULT '0',
  `after_inspection_not_ok` tinyint(1) DEFAULT '0',
  `after_inspection_rf_nos` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `after_inspection_notes` text COLLATE utf8mb4_unicode_ci,
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
  `status` enum('DRAFT','FINALIZED') COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
  `version` int DEFAULT '1',
  `created_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finalized_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `css_inspector_date` date DEFAULT NULL,
  `engineer_remarks` text COLLATE utf8mb4_unicode_ci,
  `finalized_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `meter_maker` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meter_serial_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
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
  `transformer_status` enum('NOT_WORKING','PARTIALLY_WORKING','WORKING') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
INSERT INTO `maintenance_records` VALUES (_binary '¢k\Œ\ÕZO]∏\Ê$¥4ıp','MR-TX-002-001',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>','2025-11-10','SUNNY','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/893525b3-4fdb-47c2-8e5c-9e8a9c16cf3e_annotated_INS-001_1762786069033.png',3,'20:36:00','20:36:00','Prabath','Kasun',NULL,NULL,NULL,'Prabath','2025-11-10',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2','TX-002','23',NULL,'2025-11-10',NULL,45.00,54.00,33.00,44.00,NULL,NULL,'GOOD','DISTRIBUTION',NULL,NULL,NULL,'{}',0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'DRAFT',12,'engineer','engineer','2025-11-10 09:18:18','2025-11-10 10:18:24',NULL,0,NULL,'good',NULL,6.00,4.00,5.00,67.00,45.00,56.00,0.450,0.560,0.780,77.00,45.00,676.00,NULL,NULL,'test',NULL,NULL,NULL,'2025-11-11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WORKING');
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
INSERT INTO `thermal_images` VALUES (_binary '\0’øm¡∑Gäö9Å\">â0˘','image/png',NULL,'T4_faulty_002.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/180eb642-becb-41ea-9c44-c0b150785ecd_T4_faulty_002.png',260572,'180eb642-becb-41ea-9c44-c0b150785ecd_T4_faulty_002.png','INSPECTION','2025-10-22 08:30:32.992058','Dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary '´òç†\ÕpAEçˇh\Êp\‚-'),(_binary '˚$T\≈H3≤6\Œ1ø\√\Á','image/jpeg','SUNNY','T1_normal_003.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/baseline/c17cd32a-49ca-4b74-8165-2bcfa02bde9e_T1_normal_003.jpg',27630,'c17cd32a-49ca-4b74-8165-2bcfa02bde9e_T1_normal_003.jpg','BASELINE','2025-10-02 05:06:53.377655','seed',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',NULL),(_binary '\r:ä∂º≠E°â\ËíM≤','image/jpeg',NULL,'T1_faulty_006.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/2a11bbf7-3783-4b25-8de6-179369b796fc_T1_faulty_006.jpg',38887,'2a11bbf7-3783-4b25-8de6-179369b796fc_T1_faulty_006.jpg','INSPECTION','2025-10-22 08:43:49.441490','PRABATH',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ'),(_binary ' \”‘õ\ËE≈ë\…e|b€∫ñ','image/png',NULL,'annotated_INS-004_1761122547780.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/ad90daf3-aa66-46d8-a36a-b59816440e23_annotated_INS-004_1761122547780.png',93522,'ad90daf3-aa66-46d8-a36a-b59816440e23_annotated_INS-004_1761122547780.png','INSPECTION','2025-10-22 08:42:27.805828','Dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary '´òç†\ÕpAEçˇh\Êp\‚-'),(_binary '\È=JæBtî.∑G¡Ö>','image/jpeg',NULL,'T1_faulty_001.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/ac8c94a2-9760-46a3-afb8-b9250a53d81d_T1_faulty_001.jpg',36307,'ac8c94a2-9760-46a3-afb8-b9250a53d81d_T1_faulty_001.jpg','INSPECTION','2025-11-10 14:47:12.519480','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>'),(_binary 'cúü¸Hv≤¬ãv≤p/2','image/png',NULL,'annotated_INS-010_1761112097893.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/1a553383-50b3-4401-b08a-fb3f887eae8c_annotated_INS-010_1761112097893.png',471920,'1a553383-50b3-4401-b08a-fb3f887eae8c_annotated_INS-010_1761112097893.png','INSPECTION','2025-10-22 05:48:17.928549','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'Ñ\·R`ö@∫Sfûv°ùt'),(_binary '\€¡Bˇ§E,£X_N~â','image/png',NULL,'annotated_INS-003_1759645566246.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/68ecee6d-b8ea-4742-ac9c-bcddb4303e25_annotated_INS-003_1759645566246.png',260465,'68ecee6d-b8ea-4742-ac9c-bcddb4303e25_annotated_INS-003_1759645566246.png','INSPECTION','2025-10-05 06:26:06.271825','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶'),(_binary '%’£1åKmÜa\”<\ÁGâI','image/jpeg','SUNNY','T7_normal_001.jpg','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/baseline/2275d00e-b2a3-482f-89a8-f80c2fe43d21_T7_normal_001.jpg',398693,'2275d00e-b2a3-482f-89a8-f80c2fe43d21_T7_normal_001.jpg','BASELINE','2025-10-02 05:06:53.391896','seed',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',NULL),(_binary 'dÕ¥OkñBÇùYÚÜh\–V¿','image/png',NULL,'annotated_INS-001_1762786069033.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/893525b3-4fdb-47c2-8e5c-9e8a9c16cf3e_annotated_INS-001_1762786069033.png',478960,'893525b3-4fdb-47c2-8e5c-9e8a9c16cf3e_annotated_INS-001_1762786069033.png','INSPECTION','2025-11-10 14:47:49.079784','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary 'Klc]qF\Ïß.\Ë3Ω\Ê\Â>'),(_binary 'fkæ\Á ˝Lú8Ü\Âà','image/jpeg',NULL,'T1_faulty_015 - 2.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/778191ce-9870-4d21-9b4f-91a13560a8e4_T1_faulty_015 - 2.jpg',31721,'778191ce-9870-4d21-9b4f-91a13560a8e4_T1_faulty_015 - 2.jpg','INSPECTION','2025-10-05 12:44:17.082663','PRABATH',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ'),(_binary 'x%ˇS≠O@í◊õzZµY','image/png',NULL,'annotated_INS-007_1761122658282.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/f99da2cd-21b6-40fa-8322-0a7c30b180ee_annotated_INS-007_1761122658282.png',499026,'f99da2cd-21b6-40fa-8322-0a7c30b180ee_annotated_INS-007_1761122658282.png','INSPECTION','2025-10-22 08:44:18.309946','PRABATH',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ'),(_binary 'Ü…òr@VÅ®\ÿod\„F;','image/png',NULL,'T5_faulty_001.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/2dd8cea2-acb0-4860-9348-721692b096d5_T5_faulty_001.png',249741,'2dd8cea2-acb0-4860-9348-721692b096d5_T5_faulty_001.png','INSPECTION','2025-10-22 08:41:55.376526','Dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary '´òç†\ÕpAEçˇh\Êp\‚-'),(_binary 'çqáh\—}NC∞ùØΩ$~3','image/jpeg',NULL,'T6_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/59565811-1035-4898-afce-f845bfacba57_T6_faulty_001.jpg',381827,'59565811-1035-4898-afce-f845bfacba57_T6_faulty_001.jpg','INSPECTION','2025-10-22 05:46:31.539467','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'Ñ\·R`ö@∫Sfûv°ùt'),(_binary 'ñy\Îf\ÀK •å\ÃS¡C','image/jpeg','SUNNY','T10_normal_002.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/baseline/7b3a3858-0a42-4ef2-8955-6c12a6098f83_T10_normal_002.jpg',191755,'7b3a3858-0a42-4ef2-8955-6c12a6098f83_T10_normal_002.jpg','BASELINE','2025-10-02 05:06:53.373309','seed',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',NULL),(_binary '≠t@`ˇÉCi°÷ü1Hµ\"','image/png',NULL,'annotated_INS-004_1761121514432.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/15cd15b0-0772-4ba1-8e18-173ff10b8b11_annotated_INS-004_1761121514432.png',127039,'15cd15b0-0772-4ba1-8e18-173ff10b8b11_annotated_INS-004_1761121514432.png','INSPECTION','2025-10-22 08:25:14.492691','Dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary '´òç†\ÕpAEçˇh\Êp\‚-'),(_binary '∞\ÊÑ\ÍÛS@hëª}2\‰\—','image/png','SUNNY','T4_normal_001.png','http://localhost:8080/files/f8d6d18e-8567-4ca2-9312-72c72d07945a/baseline/7ef93914-b99a-4ad4-b63a-41e0897df367_T4_normal_001.png',175980,'7ef93914-b99a-4ad4-b63a-41e0897df367_T4_normal_001.png','BASELINE','2025-10-02 05:06:53.385630','seed',_binary '¯\÷—éÖgL¢ìr\«-îZ',NULL),(_binary 'π8õıAâçÉBfA2h\Î','image/png',NULL,'annotated_INS-007_1759668267699.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/b4c8d168-1742-46db-8822-53558aceb354_annotated_INS-007_1759668267699.png',398324,'b4c8d168-1742-46db-8822-53558aceb354_annotated_INS-007_1759668267699.png','INSPECTION','2025-10-05 12:44:27.722873','PRABATH',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ'),(_binary '\∆\œª¸Oë;ã\Ï˛äkH','image/png',NULL,'annotated_INS-003_1759645559918.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/b9ad84d7-725c-425c-87ff-749f014f95a8_annotated_INS-003_1759645559918.png',260465,'b9ad84d7-725c-425c-87ff-749f014f95a8_annotated_INS-003_1759645559918.png','INSPECTION','2025-10-05 06:25:59.951337','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶'),(_binary '\«>ÀôCç∂Ò\À-[í','image/png',NULL,'T5_faulty_001.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/384a4794-c1f6-43fd-8003-86b00f18503b_T5_faulty_001.png',249741,'384a4794-c1f6-43fd-8003-86b00f18503b_T5_faulty_001.png','INSPECTION','2025-10-22 08:30:07.456989','Dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary '´òç†\ÕpAEçˇh\Êp\‚-'),(_binary '\”\ÀÙ√ïI«∏òm\Zá#S\Ô','image/jpeg',NULL,'T10_faulty_001 - 1.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/194a7898-7692-4a92-89a2-850b07ab6f24_T10_faulty_001 - 1.jpg',255567,'194a7898-7692-4a92-89a2-850b07ab6f24_T10_faulty_001 - 1.jpg','INSPECTION','2025-10-05 06:25:39.816969','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶'),(_binary '\ﬂÕ∂4[\rGK°Ω_ÄWŒß','image/png',NULL,'annotated_INS-010_1761112012255.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/d2e7f2cf-9094-4b04-ac48-5bc3d06c38ad_annotated_INS-010_1761112012255.png',471920,'d2e7f2cf-9094-4b04-ac48-5bc3d06c38ad_annotated_INS-010_1761112012255.png','INSPECTION','2025-10-22 05:46:52.282651','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'Ñ\·R`ö@∫Sfûv°ùt'),(_binary '\Ê\Õ¶LNÉ~7Y∂dëú','image/png',NULL,'T4_faulty_002.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/53d0498d-aea9-43df-bcbb-dccf8c1e113f_T4_faulty_002.png',260572,'53d0498d-aea9-43df-bcbb-dccf8c1e113f_T4_faulty_002.png','INSPECTION','2025-10-22 08:22:51.861436','Dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary '´òç†\ÕpAEçˇh\Êp\‚-'),(_binary 'ı¢z\\ﬂ´I(Ü¶ˆóDìu\√','image/png','SUNNY','T3_normal_001.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/baseline/354c30c9-7d9a-41a2-af17-4ec64ddc9342_T3_normal_001.png',56604,'354c30c9-7d9a-41a2-af17-4ec64ddc9342_T3_normal_001.png','BASELINE','2025-10-02 05:06:53.380115','seed',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',NULL);
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
INSERT INTO `transformers` VALUES (_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',300,'TX-002','2025-10-02 05:06:53.350689','Hettipola','','EN-122-B','Matale','Distribution','2025-10-02 05:06:53.350694',0),(_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',500,'TX-001','2025-10-02 05:06:53.312342','Thannekumbura','Near substation','EN-122-A','Kandy','Bulk','2025-10-02 05:06:53.312355',0),(_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',250,'TX-005','2025-10-02 05:06:53.367212','Mahiyanganaya','','EN-125-A','Badulla','Bulk','2025-10-02 05:06:53.367216',0),(_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',200,'TX-003','2025-10-02 05:06:53.355797','Kuliyapitiya','','EN-123-A','Kurunagala','Bulk','2025-10-02 05:06:53.355800',0),(_binary '¯\÷—éÖgL¢ìr\«-îZ',400,'TX-004','2025-10-02 05:06:53.365039','Nugegoda','','EN-124-B','Colombo','Distribution','2025-10-02 05:06:53.365042',0);
/*!40000 ALTER TABLE `transformers` ENABLE KEYS */;
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

-- Dump completed on 2025-11-10 21:19:49
