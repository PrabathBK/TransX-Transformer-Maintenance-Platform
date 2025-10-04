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
INSERT INTO `annotations` VALUES (_binary '\Zqô)†O4³\æö™¥´',_binary 'ª\Òï…˜ŠMI¯y0“WhT',2,323,263,441,375,1,NULL,NULL,0.716,'ai','edited',NULL,NULL,'2025-10-01 23:56:17','current-user@example.com','2025-10-01 23:56:17',_binary '¬UcŒ{Dœ†ÀÒŸñ”&\Î',0,NULL),(_binary '\Ò)ı\ÒDÇ.µOœ\Ô~',_binary 'ª\Òï…˜ŠMI¯y0“WhT',4,338,259,456,371,1,NULL,2,0.716,'ai','edited',NULL,NULL,'2025-10-01 23:56:28','current-user@example.com','2025-10-01 23:56:28',_binary 'ÀQ\Åı/G\Ê\ã\í‘\áK',1,NULL),(_binary '1‘zWJÈ«4-+oÁ\Ú',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',2,439,371,457,395,1,NULL,NULL,0.397,'ai','edited',NULL,NULL,'2025-10-02 00:33:57','current-user@example.com','2025-10-02 00:33:57',_binary 'µ3\\„\ÎLÅ³õ’ş&_',0,NULL),(_binary '=ó5i‚GÚƒ\ÉWÿ\Çb´',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',1,1146,993,1269,1108,1,'Faulty',NULL,1.000,'human','deleted','current-user@example.com',NULL,'2025-10-02 00:30:20','current-user@example.com','2025-10-02 00:30:35',NULL,0,NULL),(_binary 'Th_ÁTE*ªµ\ë½\é‰u¥',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',1,1248,783,1317,870,NULL,NULL,1,0.712,'ai','approved','AI-YOLOv8',NULL,'2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:02',NULL,1,NULL),(_binary '™|ª†\İK±¸ø>®ê‡¯W',_binary 'ª\Òï…˜ŠMI¯y0“WhT',1,333,269,469,383,0,'Faulty',3,0.805,'ai','approved','AI-YOLOv8','prabath','2025-10-04 08:44:42','current-user@example.com','2025-10-04 08:44:44',NULL,1,NULL),(_binary '¡@\Û4\ŞNeŠiúÇ§Ÿ‘',_binary 'ª\Òï…˜ŠMI¯y0“WhT',1,131,302,339,403,NULL,NULL,1,0.418,'ai','approved','AI-YOLOv8',NULL,'2025-10-01 23:55:19','current-user@example.com','2025-10-01 23:55:25',NULL,1,NULL),(_binary '«\'\Û\âö\ÆE»5‚qE\É',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',1,1011,950,1400,1093,1,'Faulty',NULL,1.000,'human','deleted','current-user@example.com',NULL,'2025-10-02 00:34:08','current-user@example.com','2025-10-02 00:34:52',NULL,0,NULL),(_binary '¬UcŒ{Dœ†ÀÒŸñ”&\Î',_binary 'ª\Òï…˜ŠMI¯y0“WhT',1,324,264,457,390,NULL,NULL,NULL,0.716,'ai','approved','AI-YOLOv8',NULL,'2025-10-01 23:55:19','current-user@example.com','2025-10-01 23:55:26',NULL,0,NULL),(_binary '®\r\ékM\ã½~œ›\Ş9\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',1,1248,783,1317,870,1,'faulty_loose_joint',2,0.712,'ai','approved','AI-YOLOv8','AI-System','2025-10-04 10:16:51','current-user@example.com','2025-10-04 10:16:59',NULL,1,NULL),(_binary '®SkCT.JV‚Hı¿¦~[',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',1,1241,768,1321,876,NULL,NULL,2,0.341,'ai','approved','AI-YOLOv8',NULL,'2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:01',NULL,1,NULL),(_binary '°jJ\ÌEÂˆûù’y´N',_binary 'ª\Òï…˜ŠMI¯y0“WhT',1,132,309,339,402,0,'Faulty',4,0.594,'ai','approved','AI-YOLOv8','prabath','2025-10-04 08:44:42','current-user@example.com','2025-10-04 08:44:55',NULL,1,NULL),(_binary 'µ3\\„\ÎLÅ³õ’ş&_',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',1,324,254,342,278,NULL,NULL,NULL,0.397,'ai','created','AI-YOLOv8',NULL,'2025-10-02 00:32:48',NULL,NULL,NULL,0,NULL),(_binary 'ÀQ\Åı/G\Ê\ã\í‘\áK',_binary 'ª\Òï…˜ŠMI¯y0“WhT',3,328,263,446,375,1,NULL,NULL,0.716,'ai','edited',NULL,NULL,'2025-10-01 23:56:22','current-user@example.com','2025-10-01 23:56:22',_binary '\Zqô)†O4³\æö™¥´',0,NULL),(_binary 'ùO€‡±\äKŸ<•”]¡E',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',1,1176,760,1228,846,NULL,NULL,3,0.348,'ai','approved','AI-YOLOv8',NULL,'2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:00',NULL,1,NULL),(_binary 'üW”œ\á@@™Z‡õ±‘­\\',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',3,439,371,457,395,1,NULL,NULL,0.397,'ai','deleted',NULL,NULL,'2025-10-02 00:34:02','current-user@example.com','2025-10-02 00:34:05',_binary '1‘zWJÈ«4-+oÁ\Ú',0,NULL);
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
INSERT INTO `box_numbering_sequence` VALUES (_binary 'ª\Òï…˜ŠMI¯y0“WhT',5,'2025-10-04 14:14:41'),(_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',3,'2025-10-04 15:46:51'),(_binary '\ÑVİŸ’»@‹¨Î˜†´L¼',4,'2025-10-04 13:00:27');
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
INSERT INTO `inspection_comments` VALUES (_binary '\â„Ÿ\ÄVED¡´‘\×X~',_binary 'ª\Òï…˜ŠMI¯y0“WhT','2 Anomalies Detected','Prabath','2025-10-01 23:57:03.341024','2025-10-01 23:57:03.341030');
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
INSERT INTO `inspection_history` VALUES (_binary 'N{\ÃZ¡9ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to DRAFT','Prabath','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"DRAFT\", \"current_inspector\": null}','2025-10-04 15:46:34'),(_binary 'U“d¡9ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-04 15:46:45'),(_binary 'Xm®¡9ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 2, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-10-04 15:46:51'),(_binary 'Xù¨¡9ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',2,'AI_DETECTION_RUN','AI detected box #2 - faulty_loose_joint (confidence: 0.712)','AI-System',NULL,'{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 2, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','2025-10-04 15:46:51'),(_binary ']Dˆ¡9ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',2,'BOX_APPROVED','Box #2 approved','AI-System','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 2, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 2, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"approved\"}','2025-10-04 15:46:59'),(_binary 'x*Áš¡,ğ‚\Î\í¿ö‘õ\Z',_binary 'ª\Òï…˜ŠMI¯y0“WhT',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','prabath',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805}, {\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-10-04 14:14:41'),(_binary 'x4uŒ¡,ğ‚\Î\í¿ö‘õ\Z',_binary 'ª\Òï…˜ŠMI¯y0“WhT',3,'AI_DETECTION_RUN','AI detected box #3 - Faulty (confidence: 0.805)','prabath',NULL,'{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805, \"action_type\": \"created\"}','2025-10-04 14:14:41'),(_binary 'x5BZ¡,ğ‚\Î\í¿ö‘õ\Z',_binary 'ª\Òï…˜ŠMI¯y0“WhT',4,'AI_DETECTION_RUN','AI detected box #4 - Faulty (confidence: 0.594)','prabath',NULL,'{\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594, \"action_type\": \"created\"}','2025-10-04 14:14:41'),(_binary 'y€Cl¡,ğ‚\Î\í¿ö‘õ\Z',_binary 'ª\Òï…˜ŠMI¯y0“WhT',3,'BOX_APPROVED','Box #3 approved','prabath','{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805, \"action_type\": \"approved\"}','2025-10-04 14:14:43'),(_binary '~¸¢R¡,ğ‚\Î\í¿ö‘õ\Z',_binary 'ª\Òï…˜ŠMI¯y0“WhT',NULL,'INSPECTOR_CHANGED','Inspector changed from prabath to Prabath. Reason: Inspector takeover','Prabath','{\"inspector\": \"prabath\"}','{\"inspector\": \"Prabath\", \"change_reason\": \"Inspector takeover\"}','2025-10-04 14:14:52'),(_binary '€5ö„¡,ğ‚\Î\í¿ö‘õ\Z',_binary 'ª\Òï…˜ŠMI¯y0“WhT',4,'BOX_APPROVED','Box #4 approved','prabath','{\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594, \"action_type\": \"approved\"}','2025-10-04 14:14:55'),(_binary '›ó¶¡7ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-04 15:34:26'),(_binary '\ØÃ¡7ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 392, \"x2\": 510, \"y1\": 230, \"y2\": 283}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 1, \"class_name\": \"potential_faulty\", \"confidence\": 0.571}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-10-04 15:34:30'),(_binary '\Ù\ÅL¡7ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',1,'AI_DETECTION_RUN','AI detected box #1 - potential_faulty (confidence: 0.571)','AI-System',NULL,'{\"bbox\": {\"x1\": 392, \"x2\": 510, \"y1\": 230, \"y2\": 283}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 1, \"class_name\": \"potential_faulty\", \"confidence\": 0.571, \"action_type\": \"created\"}','2025-10-04 15:34:30'),(_binary '¡\'p8¡7ğ‚\Î\í¿ö‘õ\Z',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 392, \"x2\": 510, \"y1\": 230, \"y2\": 283}, \"class_id\": 3, \"box_number\": 1, \"class_name\": \"potential_faulty\", \"confidence\": 0.571, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 392, \"x2\": 510, \"y1\": 230, \"y2\": 283}, \"class_id\": 3, \"box_number\": 1, \"class_name\": \"potential_faulty\", \"confidence\": 0.571, \"action_type\": \"approved\"}','2025-10-04 15:34:34');
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
INSERT INTO `inspections` VALUES (_binary 'ª\Òï…˜ŠMI¯y0“WhT','INS-001',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',NULL,_binary 'T\é¢ošşOj³\äö[\0Lzz',NULL,'SUNNY','IN_PROGRESS','This is transformer 1 in the dataset','Prabath','Prabath','2025-10-01 23:37:55',NULL,NULL,NULL,'2025-10-01 23:37:55','2025-10-04 08:45:06',_binary '\Ì7·øLK£œy‘ú›\Şñ'),(_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE','INS-003',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',NULL,_binary 'úµ \ê\ÃûA²\év\Ã~1lº',NULL,'SUNNY','IN_PROGRESS',NULL,'Prabath',NULL,'2025-10-04 10:03:31',NULL,NULL,NULL,'2025-10-04 10:03:32','2025-10-04 10:17:19',_binary 'h\ĞBŠA½93ù\Íß›'),(_binary '\ÑVİŸ’»@‹¨Î˜†´L¼','INS-002',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',NULL,_binary '”\İ-`®N¸¤\ë\å@j',NULL,'CLOUDY','COMPLETED','This is transformer 10 in the data set','admin',NULL,'2025-10-02 00:09:25',NULL,NULL,NULL,'2025-10-02 00:09:25','2025-10-02 00:35:10',_binary '?§\Îh\Ä\ÔCDª ú^Š½r');
/*!40000 ALTER TABLE `inspections` ENABLE KEYS */;
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
INSERT INTO `thermal_images` VALUES (_binary 'û$T\ÅH3²6\Î1¿\Ã\ç','image/jpeg','SUNNY','T1_normal_003.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/baseline/c17cd32a-49ca-4b74-8165-2bcfa02bde9e_T1_normal_003.jpg',27630,'c17cd32a-49ca-4b74-8165-2bcfa02bde9e_T1_normal_003.jpg','BASELINE','2025-10-02 05:06:53.377655','seed',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',NULL),(_binary '	4ƒL$†’.H3¨ùL','image/jpeg',NULL,'T1_normal_003.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/89d5800d-07c3-4825-bbac-fa1be0b96ea5_T1_normal_003.jpg',27630,'89d5800d-07c3-4825-bbac-fa1be0b96ea5_T1_normal_003.jpg','INSPECTION','2025-10-04 15:34:25.964238','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE'),(_binary '%Õ£1ŒKm†a\Ó<\çG‰I','image/jpeg','SUNNY','T7_normal_001.jpg','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/baseline/2275d00e-b2a3-482f-89a8-f80c2fe43d21_T7_normal_001.jpg',398693,'2275d00e-b2a3-482f-89a8-f80c2fe43d21_T7_normal_001.jpg','BASELINE','2025-10-02 05:06:53.391896','seed',_binary '¹}g´A.BÄ­\ìCWf{&z',NULL),(_binary '\' ›\"¥I\0½\à³`‡š','image/png',NULL,'annotated_INS-001_1759382729668.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/37e7988d-761a-408b-b7bf-2c375bbef7e8_annotated_INS-001_1759382729668.png',432522,'37e7988d-761a-408b-b7bf-2c375bbef7e8_annotated_INS-001_1759382729668.png','INSPECTION','2025-10-02 05:25:29.743230','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'ª\Òï…˜ŠMI¯y0“WhT'),(_binary '6\Û\ÆUNˆM¡ô½NPÁ\ä','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/c4c2f607-3ca1-4aaf-9ed2-fefb53e560d8_T10_faulty_001.jpg',255567,'c4c2f607-3ca1-4aaf-9ed2-fefb53e560d8_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:50:18.404554','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary '>\Ø*^I³I\r£d··\ØH','image/png',NULL,'annotated_INS-001_1759382826077.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/45e8b498-f03a-46b5-a2ce-a7fa0f1a5205_annotated_INS-001_1759382826077.png',432728,'45e8b498-f03a-46b5-a2ce-a7fa0f1a5205_annotated_INS-001_1759382826077.png','INSPECTION','2025-10-02 05:27:06.100715','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'ª\Òï…˜ŠMI¯y0“WhT'),(_binary '?§\Îh\Ä\ÔCDª ú^Š½r','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/c800fe50-121d-4049-b68b-cd680b9646df_T10_faulty_001.jpg',255567,'c800fe50-121d-4049-b68b-cd680b9646df_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:59:35.650531','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary '@’m\éA¥B\è›\É{\É$1À‘','image/png',NULL,'T3_normal_001.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/30a989db-ca9a-4673-90c7-430cb45eb39c_T3_normal_001.png',56604,'30a989db-ca9a-4673-90c7-430cb45eb39c_T3_normal_001.png','INSPECTION','2025-10-02 05:52:52.431282','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary 'T\é¢ošşOj³\äö[\0Lzz','image/png',NULL,'annotated_INS-001_1759587305430.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/7a61334c-771a-47a2-9bef-342b4eaea051_annotated_INS-001_1759587305430.png',423780,'7a61334c-771a-47a2-9bef-342b4eaea051_annotated_INS-001_1759587305430.png','INSPECTION','2025-10-04 14:15:05.531210','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'ª\Òï…˜ŠMI¯y0“WhT'),(_binary 'h\ĞBŠA½93ù\Íß›','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/17c3c4d5-6a75-46d7-9673-a3a8f295db03_T10_faulty_001.jpg',255567,'17c3c4d5-6a75-46d7-9673-a3a8f295db03_T10_faulty_001.jpg','INSPECTION','2025-10-04 15:46:45.959981','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE'),(_binary 'p\êHA¸>L\Ï\"\Ğ\Â','image/jpeg',NULL,'T10_normal_002.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/9f0d22b9-f85c-4bde-8e0a-38c616f549da_T10_normal_002.jpg',191755,'9f0d22b9-f85c-4bde-8e0a-38c616f549da_T10_normal_002.jpg','INSPECTION','2025-10-02 05:50:42.571918','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary 'wù¢l£AÅ»IFƒG\à\ã','image/png',NULL,'annotated_INS-002_1759384804686.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/f63cfa29-c0d4-4292-86d9-c1c5e201dd17_annotated_INS-002_1759384804686.png',260478,'f63cfa29-c0d4-4292-86d9-c1c5e201dd17_annotated_INS-002_1759384804686.png','INSPECTION','2025-10-02 06:00:04.726737','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary '‡1\ĞONŒK´—‡›H','image/png',NULL,'T4_normal_001.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/37626f90-2d81-4670-9046-73e9da4d0b46_T4_normal_001.png',175980,'37626f90-2d81-4670-9046-73e9da4d0b46_T4_normal_001.png','INSPECTION','2025-10-02 05:52:37.832675','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary '”\İ-`®N¸¤\ë\å@j','image/png',NULL,'annotated_INS-002_1759385096751.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/b53d1ba1-e391-47dc-877d-00775a3646ed_annotated_INS-002_1759385096751.png',260478,'b53d1ba1-e391-47dc-877d-00775a3646ed_annotated_INS-002_1759385096751.png','INSPECTION','2025-10-02 06:04:56.783291','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary '–y\ëf\ËK ¥Œ\ÌSÁC','image/jpeg','SUNNY','T10_normal_002.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/baseline/7b3a3858-0a42-4ef2-8955-6c12a6098f83_T10_normal_002.jpg',191755,'7b3a3858-0a42-4ef2-8955-6c12a6098f83_T10_normal_002.jpg','BASELINE','2025-10-02 05:06:53.373309','seed',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',NULL),(_binary '®@\Ì\î5\"DQ¹¯\ÉOBGE\Í','image/png',NULL,'annotated_INS-001_1759382789633.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/bbe03bd7-ae93-4402-baef-91a070d27104_annotated_INS-001_1759382789633.png',432728,'bbe03bd7-ae93-4402-baef-91a070d27104_annotated_INS-001_1759382789633.png','INSPECTION','2025-10-02 05:26:29.683698','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'ª\Òï…˜ŠMI¯y0“WhT'),(_binary '°\æ„\êóS@h‘»}2\ä\Ñ','image/png','SUNNY','T4_normal_001.png','http://localhost:8080/files/f8d6d18e-8567-4ca2-9312-72c72d07945a/baseline/7ef93914-b99a-4ad4-b63a-41e0897df367_T4_normal_001.png',175980,'7ef93914-b99a-4ad4-b63a-41e0897df367_T4_normal_001.png','BASELINE','2025-10-02 05:06:53.385630','seed',_binary 'ø\ÖÑ…gL¢“r\Ç-”Z',NULL),(_binary '³ñ²2\ÏI6°‹‹\n\ã3<E','image/jpeg',NULL,'T7_normal_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/40d62d5b-046f-426a-831b-378e792b135d_T7_normal_001.jpg',398693,'40d62d5b-046f-426a-831b-378e792b135d_T7_normal_001.jpg','INSPECTION','2025-10-02 05:53:14.517094','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary 'µºYM}ZB¸ ´Ë\×Xh\î','image/jpeg',NULL,'T1_normal_003.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/bb186aa7-a454-4dc9-9714-8d2f9ecbc454_T1_normal_003.jpg',27630,'bb186aa7-a454-4dc9-9714-8d2f9ecbc454_T1_normal_003.jpg','INSPECTION','2025-10-02 05:52:14.116198','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary 'ºµ	·QMg¦î‰€œ\Äc','image/png',NULL,'annotated_INS-003_1759592078682.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/536159a7-93a6-4804-9e43-b7e60eba1ae7_annotated_INS-003_1759592078682.png',333013,'536159a7-93a6-4804-9e43-b7e60eba1ae7_annotated_INS-003_1759592078682.png','INSPECTION','2025-10-04 15:34:38.709739','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE'),(_binary '\Ì7·øLK£œy‘ú›\Şñ','image/jpeg',NULL,'T1_faulty_016.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/79b8adf1-bf93-4908-9289-8dc509163720_T1_faulty_016.jpg',32713,'79b8adf1-bf93-4908-9289-8dc509163720_T1_faulty_016.jpg','INSPECTION','2025-10-02 05:08:10.380515','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'ª\Òï…˜ŠMI¯y0“WhT'),(_binary '\ä\nÿ\'nSK\â“%º\Ô5`\ä','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/a06efbea-ca0e-4d16-886c-0435304e2618_T10_faulty_001.jpg',255567,'a06efbea-ca0e-4d16-886c-0435304e2618_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:39:42.298176','admin',_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',_binary '\ÑVİŸ’»@‹¨Î˜†´L¼'),(_binary 'õ¢z\\ß«I(†¦ö—D“u\Ã','image/png','SUNNY','T3_normal_001.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/baseline/354c30c9-7d9a-41a2-af17-4ec64ddc9342_T3_normal_001.png',56604,'354c30c9-7d9a-41a2-af17-4ec64ddc9342_T3_normal_001.png','BASELINE','2025-10-02 05:06:53.380115','seed',_binary 'ñš\Ë1\ÆMËƒ\ß;‰ºˆ\Ú;',NULL),(_binary 'úµ \ê\ÃûA²\év\Ã~1lº','image/png',NULL,'annotated_INS-003_1759592838741.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/adc0fb01-bf4e-408b-a17f-da49a258b62e_annotated_INS-003_1759592838741.png',260465,'adc0fb01-bf4e-408b-a17f-da49a258b62e_annotated_INS-003_1759592838741.png','INSPECTION','2025-10-04 15:47:18.782839','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE'),(_binary 'ş’\äB„SIş–¹‡¾˜ª','image/png',NULL,'annotated_INS-003_1759592833470.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/3608f4cb-0d54-44ca-9499-13d0aba0621a_annotated_INS-003_1759592833470.png',82224,'3608f4cb-0d54-44ca-9499-13d0aba0621a_annotated_INS-003_1759592833470.png','INSPECTION','2025-10-04 15:47:13.511390','Prabath',_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',_binary 'Ğ˜ˆ\æüLAÆ©]‚\r\âõE');
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKrf31hajpol0ljs9b1kjwthqax` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transformers`
--

LOCK TABLES `transformers` WRITE;
/*!40000 ALTER TABLE `transformers` DISABLE KEYS */;
INSERT INTO `transformers` VALUES (_binary 'F\ëÿ´ôC’´dr\ĞX/\Ü8',300,'TX-002','2025-10-02 05:06:53.350689','Hettipola','','EN-122-B','Matale','Distribution','2025-10-02 05:06:53.350694'),(_binary '\\ı\Û\à€¼BJ½\ëˆ\àZıµ',500,'TX-001','2025-10-02 05:06:53.312342','Thannekumbura','Near substation','EN-122-A','Kandy','Bulk','2025-10-02 05:06:53.312355'),(_binary '¹}g´A.BÄ­\ìCWf{&z',250,'TX-005','2025-10-02 05:06:53.367212','Mahiyanganaya','','EN-125-A','Badulla','Bulk','2025-10-02 05:06:53.367216'),(_binary 'ñš\Ë1\ÆMËƒ\ß;‰ºˆ\Ú;',200,'TX-003','2025-10-02 05:06:53.355797','Kuliyapitiya','','EN-123-A','Kurunagala','Bulk','2025-10-02 05:06:53.355800'),(_binary 'ø\ÖÑ…gL¢“r\Ç-”Z',400,'TX-004','2025-10-02 05:06:53.365039','Nugegoda','','EN-124-B','Colombo','Distribution','2025-10-02 05:06:53.365042');
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

-- Dump completed on 2025-10-04 21:18:37
