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
INSERT INTO `annotations` VALUES (_binary '∑\‡UˆL:ó\ƒ\r[4mó¶',_binary '™\“ÔÖòäMIØy0ìWhT',1,408,243,524,362,0,'Faulty',6,0.668,'ai','approved','AI-YOLOv8','Prabath','2025-10-05 07:13:14','current-user@example.com','2025-10-05 07:13:19',NULL,1,NULL),(_binary '52)NÅ¢\‚J;[ñM',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',1,957,793,1145,1073,2,'faulty_point_overload',5,0.803,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 07:11:27','current-user@example.com','2025-10-05 07:11:30',NULL,1,NULL),(_binary '\ZqÙ)ÜO4≥ê\Êˆô•¥é',_binary '™\“ÔÖòäMIØy0ìWhT',2,323,263,441,375,1,NULL,NULL,0.716,'ai','edited',NULL,NULL,'2025-10-01 23:56:17','current-user@example.com','2025-10-01 23:56:17',_binary '¨Ucå{DúÜ¿“üÒî&\Œ',0,NULL),(_binary '\“)˝\“D«é.èµOú\‘~',_binary '™\“ÔÖòäMIØy0ìWhT',4,338,259,456,371,1,NULL,2,0.716,'ai','deleted',NULL,NULL,'2025-10-01 23:56:28','current-user@example.com','2025-10-05 07:12:57',_binary '¿Q\≈˝/Gêê\ \„\Ìë\·K',0,NULL),(_binary '!åß@\\ûohºYA |',_binary 'ò¥{\–/C9á^k\√\–cÆ',1,75,128,145,233,0,'Faulty',1,0.951,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 07:08:34','current-user@example.com','2025-10-05 07:08:36',NULL,1,NULL),(_binary '1ëzWJ»´4-+o¡\⁄',_binary '\—V›üíª@êã®ŒòÜ¥Lº',2,439,371,457,395,1,NULL,NULL,0.397,'ai','edited',NULL,NULL,'2025-10-02 00:33:57','current-user@example.com','2025-10-02 00:33:57',_binary 'µ3\\Ñ\ŒL≈≥ıí˛&_',0,NULL),(_binary '=Û5iÇG⁄É\…Wˇ\«b¥',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1146,993,1269,1108,1,'Faulty',NULL,1.000,'human','deleted','current-user@example.com',NULL,'2025-10-02 00:30:20','current-user@example.com','2025-10-02 00:30:35',NULL,0,NULL),(_binary 'FÄ\0≠¡\ÍD˛Éí∞G.Q\Õ',_binary '™\“ÔÖòäMIØy0ìWhT',1,223,284,413,381,0,'Faulty',5,0.686,'ai','approved','AI-YOLOv8','Prabath','2025-10-05 07:13:14','current-user@example.com','2025-10-05 07:13:21',NULL,1,NULL),(_binary 'HÄô∂C¬á)L˚ˆå#e',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',1,66,145,166,328,0,'Faulty',1,0.959,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 07:07:33','current-user@example.com','2025-10-05 07:07:36',NULL,1,NULL),(_binary 'Së÷å˘Lªê\‹7˛5å\‘',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,133,381,341,469,0,'Faulty',1,0.817,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 07:14:21','current-user@example.com','2025-10-05 07:14:24',NULL,1,NULL),(_binary 'Th_¡TE*™µ\ÎΩ\Èâu•',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1248,783,1317,870,NULL,NULL,1,0.712,'ai','approved','AI-YOLOv8',NULL,'2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:02',NULL,1,NULL),(_binary 'dˆo¯?Eº®\Îûg\Í\—b',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',1,173,151,257,271,3,'potential_faulty',2,0.935,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 07:07:33','current-user@example.com','2025-10-05 07:07:37',NULL,1,NULL),(_binary 'Åféë\›Mú∏6\÷\–\◊Y',_binary 'ò¥{\–/C9á^k\√\–cÆ',1,224,121,292,228,0,'Faulty',2,0.913,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 07:08:34','current-user@example.com','2025-10-05 07:08:37',NULL,1,NULL),(_binary 'ô|™Üé\›K±∏¯>ÆÍáØW',_binary '™\“ÔÖòäMIØy0ìWhT',1,333,269,469,383,0,'Faulty',3,0.805,'ai','deleted','AI-YOLOv8','prabath','2025-10-04 08:44:42','current-user@example.com','2025-10-05 07:13:06',NULL,0,NULL),(_binary '°@\€4\ﬁNeäi˙«ßêüë',_binary '™\“ÔÖòäMIØy0ìWhT',1,131,302,339,403,NULL,NULL,1,0.418,'ai','deleted','AI-YOLOv8',NULL,'2025-10-01 23:55:19','current-user@example.com','2025-10-05 07:13:11',NULL,0,NULL),(_binary '´\'\€\‚ˆ\∆Eªû5ÇqE\…',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1011,950,1400,1093,1,'Faulty',NULL,1.000,'human','deleted','current-user@example.com',NULL,'2025-10-02 00:34:08','current-user@example.com','2025-10-02 00:34:52',NULL,0,NULL),(_binary '¨Ucå{DúÜ¿“üÒî&\Œ',_binary '™\“ÔÖòäMIØy0ìWhT',1,324,264,457,390,NULL,NULL,NULL,0.716,'ai','approved','AI-YOLOv8',NULL,'2025-10-01 23:55:19','current-user@example.com','2025-10-01 23:55:26',NULL,0,NULL),(_binary 'ÆSkCT.JVÇH˝ø¶~[',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1241,768,1321,876,NULL,NULL,2,0.341,'ai','approved','AI-YOLOv8',NULL,'2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:01',NULL,1,NULL),(_binary 'ÆñFh7H˙û\ÁcÇ\Õ\Ô',_binary 'ò¥{\–/C9á^k\√\–cÆ',1,149,123,220,233,0,'Faulty',3,0.905,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 07:08:34','current-user@example.com','2025-10-05 07:08:38',NULL,1,NULL),(_binary 'Æ\Ì\Zí\≈Lèu&ÚTKA\√',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,318,327,490,442,0,'Faulty',2,0.804,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 07:14:21','current-user@example.com','2025-10-05 07:14:24',NULL,1,NULL),(_binary '∞jJ\ÃE¬à˚˘íy¥N',_binary '™\“ÔÖòäMIØy0ìWhT',1,132,309,339,402,0,'Faulty',4,0.594,'ai','deleted','AI-YOLOv8','prabath','2025-10-04 08:44:42','current-user@example.com','2025-10-05 07:12:51',NULL,0,NULL),(_binary 'µ3\\Ñ\ŒL≈≥ıí˛&_',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,324,254,342,278,NULL,NULL,NULL,0.397,'ai','created','AI-YOLOv8',NULL,'2025-10-02 00:32:48',NULL,NULL,NULL,0,NULL),(_binary '∏5\€∫AÍ†™a∂∑\Ÿ>;',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,238,241,350,304,1,'Faulty',3,1.000,'human','deleted','current-user@example.com',NULL,'2025-10-21 13:02:25','current-user@example.com','2025-10-21 13:02:37',NULL,0,NULL),(_binary '¿Q\≈˝/Gêê\ \„\Ìë\·K',_binary '™\“ÔÖòäMIØy0ìWhT',3,328,263,446,375,1,NULL,NULL,0.716,'ai','edited',NULL,NULL,'2025-10-01 23:56:22','current-user@example.com','2025-10-01 23:56:22',_binary '\ZqÙ)ÜO4≥ê\Êˆô•¥é',0,NULL),(_binary '\√RçÜlD…§{\Z\—“á\√',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',2,319,184,468,268,1,'Faulty',3,1.000,'human','deleted',NULL,NULL,'2025-10-21 12:58:31','current-user@example.com','2025-10-21 12:58:37',_binary 'ˇ;≥OH+BÉÄSI3tFB',0,NULL),(_binary '˘OÄá±\‰Küè<ïî]°E',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1176,760,1228,846,NULL,NULL,3,0.348,'ai','approved','AI-YOLOv8',NULL,'2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:00',NULL,1,NULL),(_binary '¸Wîú\·@@ôZáı±ë≠\\',_binary '\—V›üíª@êã®ŒòÜ¥Lº',3,439,371,457,395,1,NULL,NULL,0.397,'ai','deleted',NULL,NULL,'2025-10-02 00:34:02','current-user@example.com','2025-10-02 00:34:05',_binary '1ëzWJ»´4-+o¡\⁄',0,NULL),(_binary '˝´n¨ºuGMû±¨±≠°92',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',1,1248,783,1317,870,1,'faulty_loose_joint',1,0.712,'ai','approved','AI-YOLOv8','AI-System','2025-10-05 00:55:46','current-user@example.com','2025-10-05 00:55:54',NULL,1,NULL),(_binary 'ˇ;≥OH+BÉÄSI3tFB',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,318,214,467,298,1,'Faulty',3,1.000,'human','created','current-user@example.com',NULL,'2025-10-21 12:58:04',NULL,NULL,NULL,0,NULL);
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
INSERT INTO `box_numbering_sequence` VALUES (_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',3,'2025-10-05 12:37:33'),(_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',6,'2025-10-05 12:41:27'),(_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',2,'2025-10-05 06:25:46'),(_binary 'ò¥{\–/C9á^k\√\–cÆ',4,'2025-10-05 12:38:33'),(_binary '™\“ÔÖòäMIØy0ìWhT',7,'2025-10-05 12:43:13'),(_binary '\—V›üíª@êã®ŒòÜ¥Lº',4,'2025-10-04 13:00:27'),(_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'2025-10-05 12:44:21');
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
INSERT INTO `inspection_comments` VALUES (_binary '\‚Ñü\ƒVED°¥ë\◊X~',_binary '™\“ÔÖòäMIØy0ìWhT','2 Anomalies Detected','Prabath','2025-10-01 23:57:03.341024','2025-10-01 23:57:03.341030'),(_binary '˙£\«H¶M`å[©åsY\Ì',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞','add comment','admin','2025-10-05 01:40:22.567215','2025-10-05 01:40:22.567259');
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
INSERT INTO `inspection_history` VALUES (_binary '_†T°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','PRABATH','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 12:44:17'),(_binary 'Ú	$°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.817}, {\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.804}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 12:44:21'),(_binary 'Û	ñ°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,'AI_DETECTION_RUN','AI detected box #1 - Faulty (confidence: 0.817)','AI-System',NULL,'{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"created\"}','2025-10-05 12:44:21'),(_binary 'Ûf°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',2,'AI_DETECTION_RUN','AI detected box #2 - Faulty (confidence: 0.804)','AI-System',NULL,'{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"created\"}','2025-10-05 12:44:21'),(_binary 'Pp°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"approved\"}','2025-10-05 12:44:23'),(_binary '≠G°\ÈÇ\Œ\Ìøˆëı\Z',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',2,'BOX_APPROVED','Box #2 approved','AI-System','{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"approved\"}','2025-10-05 12:44:24'),(_binary '°5º°\ËÇ\Œ\Ìøˆëı\Z',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 12:37:29'),(_binary '∫Ùd°\ËÇ\Œ\Ìøˆëı\Z',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 66, \"x2\": 166, \"y1\": 145, \"y2\": 328}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.959}, {\"bbox\": {\"x1\": 173, \"x2\": 257, \"y1\": 151, \"y2\": 271}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 2, \"class_name\": \"potential_faulty\", \"confidence\": 0.935}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 12:37:33'),(_binary 'ø\Ó°\ËÇ\Œ\Ìøˆëı\Z',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',1,'AI_DETECTION_RUN','AI detected box #1 - Faulty (confidence: 0.959)','AI-System',NULL,'{\"bbox\": {\"x1\": 66, \"x2\": 166, \"y1\": 145, \"y2\": 328}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.959, \"action_type\": \"created\"}','2025-10-05 12:37:33'),(_binary 'ø_¬°\ËÇ\Œ\Ìøˆëı\Z',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',2,'AI_DETECTION_RUN','AI detected box #2 - potential_faulty (confidence: 0.935)','AI-System',NULL,'{\"bbox\": {\"x1\": 173, \"x2\": 257, \"y1\": 151, \"y2\": 271}, \"source\": \"ai\", \"class_id\": 3, \"box_number\": 2, \"class_name\": \"potential_faulty\", \"confidence\": 0.935, \"action_type\": \"created\"}','2025-10-05 12:37:33'),(_binary '.\Ìx°\ËÇ\Œ\Ìøˆëı\Z',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 66, \"x2\": 166, \"y1\": 145, \"y2\": 328}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.959, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 66, \"x2\": 166, \"y1\": 145, \"y2\": 328}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.959, \"action_type\": \"approved\"}','2025-10-05 12:37:35'),(_binary 'ø\œ<°\ËÇ\Œ\Ìøˆëı\Z',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ',2,'BOX_APPROVED','Box #2 approved','AI-System','{\"bbox\": {\"x1\": 173, \"x2\": 257, \"y1\": 151, \"y2\": 271}, \"class_id\": 3, \"box_number\": 2, \"class_name\": \"potential_faulty\", \"confidence\": 0.935, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 173, \"x2\": 257, \"y1\": 151, \"y2\": 271}, \"class_id\": 3, \"box_number\": 2, \"class_name\": \"potential_faulty\", \"confidence\": 0.935, \"action_type\": \"approved\"}','2025-10-05 12:37:36'),(_binary '\›\‡å°¥Ç\Œ\Ìøˆëı\Z',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 06:25:39'),(_binary ' Ü°¥Ç\Œ\Ìøˆëı\Z',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 06:25:46'),(_binary ' á\‡ò°¥Ç\Œ\Ìøˆëı\Z',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',1,'AI_DETECTION_RUN','AI detected box #1 - faulty_loose_joint (confidence: 0.712)','AI-System',NULL,'{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','2025-10-05 06:25:46'),(_binary '%3î°¥Ç\Œ\Ìøˆëı\Z',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"approved\"}','2025-10-05 06:25:53'),(_binary '2]åî°\ËÇ\Œ\Ìøˆëı\Z',_binary 'ò¥{\–/C9á^k\√\–cÆ',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','system','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 12:38:29'),(_binary '4∏Z°\ËÇ\Œ\Ìøˆëı\Z',_binary 'ò¥{\–/C9á^k\√\–cÆ',NULL,'AI_DETECTION_RUN','AI detected 3 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 75, \"x2\": 145, \"y1\": 128, \"y2\": 233}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.951}, {\"bbox\": {\"x1\": 224, \"x2\": 292, \"y1\": 121, \"y2\": 228}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.913}, {\"bbox\": {\"x1\": 149, \"x2\": 220, \"y1\": 123, \"y2\": 233}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.905}], \"total_detections\": 3, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 3, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 12:38:33'),(_binary '4ª\r°\ËÇ\Œ\Ìøˆëı\Z',_binary 'ò¥{\–/C9á^k\√\–cÆ',1,'AI_DETECTION_RUN','AI detected box #1 - Faulty (confidence: 0.951)','AI-System',NULL,'{\"bbox\": {\"x1\": 75, \"x2\": 145, \"y1\": 128, \"y2\": 233}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.951, \"action_type\": \"created\"}','2025-10-05 12:38:33'),(_binary '4ª∏ä°\ËÇ\Œ\Ìøˆëı\Z',_binary 'ò¥{\–/C9á^k\√\–cÆ',2,'AI_DETECTION_RUN','AI detected box #2 - Faulty (confidence: 0.913)','AI-System',NULL,'{\"bbox\": {\"x1\": 224, \"x2\": 292, \"y1\": 121, \"y2\": 228}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.913, \"action_type\": \"created\"}','2025-10-05 12:38:33'),(_binary '4º\Ë°\ËÇ\Œ\Ìøˆëı\Z',_binary 'ò¥{\–/C9á^k\√\–cÆ',3,'AI_DETECTION_RUN','AI detected box #3 - Faulty (confidence: 0.905)','AI-System',NULL,'{\"bbox\": {\"x1\": 149, \"x2\": 220, \"y1\": 123, \"y2\": 233}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.905, \"action_type\": \"created\"}','2025-10-05 12:38:33'),(_binary '69Ã∞°\ËÇ\Œ\Ìøˆëı\Z',_binary 'ò¥{\–/C9á^k\√\–cÆ',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 75, \"x2\": 145, \"y1\": 128, \"y2\": 233}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.951, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 75, \"x2\": 145, \"y1\": 128, \"y2\": 233}, \"class_id\": 0, \"box_number\": 1, \"class_name\": \"Faulty\", \"confidence\": 0.951, \"action_type\": \"approved\"}','2025-10-05 12:38:36'),(_binary '6N\œ°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to DRAFT','Prabath','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"DRAFT\", \"current_inspector\": null}','2025-10-05 07:09:19'),(_binary '6ûÙ°\ËÇ\Œ\Ìøˆëı\Z',_binary 'ò¥{\–/C9á^k\√\–cÆ',2,'BOX_APPROVED','Box #2 approved','AI-System','{\"bbox\": {\"x1\": 224, \"x2\": 292, \"y1\": 121, \"y2\": 228}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.913, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 224, \"x2\": 292, \"y1\": 121, \"y2\": 228}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.913, \"action_type\": \"approved\"}','2025-10-05 12:38:36'),(_binary '7NP°\ËÇ\Œ\Ìøˆëı\Z',_binary 'ò¥{\–/C9á^k\√\–cÆ',3,'BOX_APPROVED','Box #3 approved','AI-System','{\"bbox\": {\"x1\": 149, \"x2\": 220, \"y1\": 123, \"y2\": 233}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.905, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 149, \"x2\": 220, \"y1\": 123, \"y2\": 233}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.905, \"action_type\": \"approved\"}','2025-10-05 12:38:37'),(_binary ';€ü†°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 07:09:28'),(_binary '@\‚ü–°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817}, {\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.804}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 07:09:37'),(_binary '@\Â[v°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',2,'AI_DETECTION_RUN','AI detected box #2 - Faulty (confidence: 0.817)','AI-System',NULL,'{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"created\"}','2025-10-05 07:09:37'),(_binary '@\ÊHt°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',3,'AI_DETECTION_RUN','AI detected box #3 - Faulty (confidence: 0.804)','AI-System',NULL,'{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"created\"}','2025-10-05 07:09:37'),(_binary 'BV\ÓÓÆ¨≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to COMPLETED','PRABATH','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"COMPLETED\", \"current_inspector\": null}','2025-10-21 18:32:11'),(_binary 'F¸∫°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',2,'BOX_APPROVED','Box #2 approved','AI-System','{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"approved\"}','2025-10-05 07:09:47'),(_binary 'IR\Z8°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',3,'BOX_REJECTED','Box #3 rejected','AI-System','{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 318, \"x2\": 490, \"y1\": 327, \"y2\": 442}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.804, \"action_type\": \"rejected\"}','2025-10-05 07:09:51'),(_binary 'IÒb~Æ¨≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 238, \"x2\": 350, \"y1\": 241, \"y2\": 304}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-21 18:32:24'),(_binary 'Qm7îÆ¨≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_DELETED','Box #3 deleted','current-user@example.com','{\"bbox\": {\"x1\": 238, \"x2\": 350, \"y1\": 241, \"y2\": 304}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 238, \"x2\": 350, \"y1\": 241, \"y2\": 304}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"deleted\"}','2025-10-21 18:32:37'),(_binary 'cp•B°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',2,'AI_DETECTION_RUN','AI detected box #2 - Faulty (confidence: 0.817)','AI-System',NULL,'{\"bbox\": {\"x1\": 132, \"x2\": 289, \"y1\": 380, \"y2\": 447}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"edited\"}','2025-10-05 07:10:35'),(_binary 'cs;‡°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',2,'BOX_EDITED','Box #2 modified','AI-System','{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"approved\"}','{\"bbox\": {\"x1\": 133, \"x2\": 341, \"y1\": 381, \"y2\": 469}, \"class_id\": 0, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"approved\"}','2025-10-05 07:10:35'),(_binary 'fÄg§°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',2,'AI_DETECTION_RUN','AI detected box #2 - Faulty (confidence: 0.817)','AI-System',NULL,'{\"bbox\": {\"x1\": 327, \"x2\": 484, \"y1\": 368, \"y2\": 435}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"edited\"}','2025-10-05 07:10:40'),(_binary 'fÅPÿ°∫Ç\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',2,'BOX_EDITED','Box #2 modified','AI-System','{\"bbox\": {\"x1\": 132, \"x2\": 289, \"y1\": 380, \"y2\": 447}, \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 132, \"x2\": 289, \"y1\": 380, \"y2\": 447}, \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"edited\"}','2025-10-05 07:10:40'),(_binary 'x*¡ö°,Ç\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','prabath',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805}, {\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-10-04 14:14:41'),(_binary 'x4uå°,Ç\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',3,'AI_DETECTION_RUN','AI detected box #3 - Faulty (confidence: 0.805)','prabath',NULL,'{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805, \"action_type\": \"created\"}','2025-10-04 14:14:41'),(_binary 'x5BZ°,Ç\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',4,'AI_DETECTION_RUN','AI detected box #4 - Faulty (confidence: 0.594)','prabath',NULL,'{\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594, \"action_type\": \"created\"}','2025-10-04 14:14:41'),(_binary 'yÄCl°,Ç\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',3,'BOX_APPROVED','Box #3 approved','prabath','{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805, \"action_type\": \"approved\"}','2025-10-04 14:14:43'),(_binary '~∏¢R°,Ç\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',NULL,'INSPECTOR_CHANGED','Inspector changed from prabath to Prabath. Reason: Inspector takeover','Prabath','{\"inspector\": \"prabath\"}','{\"inspector\": \"Prabath\", \"change_reason\": \"Inspector takeover\"}','2025-10-04 14:14:52'),(_binary 'Ä5ˆÑ°,Ç\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',4,'BOX_APPROVED','Box #4 approved','prabath','{\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594, \"action_type\": \"approved\"}','2025-10-04 14:14:55'),(_binary 'é6:r°πÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 07:04:37'),(_binary 'ïÖ¡~°\ËÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to DRAFT','Prabath','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"DRAFT\", \"current_inspector\": null}','2025-10-05 12:41:16'),(_binary 'ô\”\ÍN°\ËÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 12:41:23'),(_binary 'úøÙ°\ËÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 957, \"x2\": 1145, \"y1\": 793, \"y2\": 1073}, \"source\": \"ai\", \"class_id\": 2, \"box_number\": 5, \"class_name\": \"faulty_point_overload\", \"confidence\": 0.803}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 12:41:27'),(_binary 'úMB°\ËÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',5,'AI_DETECTION_RUN','AI detected box #5 - faulty_point_overload (confidence: 0.803)','AI-System',NULL,'{\"bbox\": {\"x1\": 957, \"x2\": 1145, \"y1\": 793, \"y2\": 1073}, \"source\": \"ai\", \"class_id\": 2, \"box_number\": 5, \"class_name\": \"faulty_point_overload\", \"confidence\": 0.803, \"action_type\": \"created\"}','2025-10-05 12:41:27'),(_binary 'ú\Â£“°πÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 07:05:02'),(_binary 'ú\Ìg°πÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',1,'AI_DETECTION_RUN','AI detected box #1 - faulty_loose_joint (confidence: 0.712)','AI-System',NULL,'{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','2025-10-05 07:05:02'),(_binary 'ùùq6°\ËÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',5,'BOX_APPROVED','Box #5 approved','AI-System','{\"bbox\": {\"x1\": 957, \"x2\": 1145, \"y1\": 793, \"y2\": 1073}, \"class_id\": 2, \"box_number\": 5, \"class_name\": \"faulty_point_overload\", \"confidence\": 0.803, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 957, \"x2\": 1145, \"y1\": 793, \"y2\": 1073}, \"class_id\": 2, \"box_number\": 5, \"class_name\": \"faulty_point_overload\", \"confidence\": 0.803, \"action_type\": \"approved\"}','2025-10-05 12:41:29'),(_binary 'ßûZ°\ÁÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'STATUS_CHANGED','Inspection status changed from IN_PROGRESS to DRAFT','Prabath','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','{\"status\": \"DRAFT\", \"current_inspector\": null}','2025-10-05 12:34:36'),(_binary 'ß°º$°\ÁÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',2,'BOX_EDITED','Box #2 modified','AI-System','{\"bbox\": {\"x1\": 327, \"x2\": 484, \"y1\": 368, \"y2\": 435}, \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 327, \"x2\": 484, \"y1\": 368, \"y2\": 435}, \"class_id\": 1, \"box_number\": 2, \"class_name\": \"Faulty\", \"confidence\": 0.817, \"action_type\": \"edited\"}','2025-10-05 12:34:37'),(_binary '¨f°\ÁÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'STATUS_CHANGED','Inspection status changed from DRAFT to IN_PROGRESS','Prabath','{\"status\": \"DRAFT\", \"current_inspector\": null}','{\"status\": \"IN_PROGRESS\", \"current_inspector\": null}','2025-10-05 12:34:45'),(_binary '¨à¶Ã°πÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',1,'BOX_APPROVED','Box #1 approved','AI-System','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 1, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"approved\"}','2025-10-05 07:05:28'),(_binary 'Æ\√rƒÆ´≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','current-user@example.com',NULL,'{\"bbox\": {\"x1\": 318, \"x2\": 467, \"y1\": 214, \"y2\": 298}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-21 18:28:04'),(_binary 'Æ\·˜\Ï°\ÁÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',NULL,'AI_DETECTION_RUN','AI detected 1 anomalies using YOLOv8p2','AI-System',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 4, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712}], \"total_detections\": 1, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 1, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 12:34:49'),(_binary 'Æ\„°\ÁÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',4,'AI_DETECTION_RUN','AI detected box #4 - faulty_loose_joint (confidence: 0.712)','AI-System',NULL,'{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"source\": \"ai\", \"class_id\": 1, \"box_number\": 4, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','2025-10-05 12:34:49'),(_binary '∞ø\…,°\ÁÇ\Œ\Ìøˆëı\Z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞',4,'BOX_APPROVED','Box #4 approved','AI-System','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 4, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 1248, \"x2\": 1317, \"y1\": 783, \"y2\": 870}, \"class_id\": 1, \"box_number\": 4, \"class_name\": \"faulty_loose_joint\", \"confidence\": 0.712, \"action_type\": \"approved\"}','2025-10-05 12:34:52'),(_binary 'æ“§Æ´≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_CREATED','User created box #3 - Faulty (confidence: 1.000)','system',NULL,'{\"bbox\": {\"x1\": 319, \"x2\": 468, \"y1\": 184, \"y2\": 268}, \"source\": \"human\", \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','2025-10-21 18:28:31'),(_binary 'æ\‘X÷Æ´≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_EDITED','Box #3 modified','current-user@example.com','{\"bbox\": {\"x1\": 318, \"x2\": 467, \"y1\": 214, \"y2\": 298}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 318, \"x2\": 467, \"y1\": 214, \"y2\": 298}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"created\"}','2025-10-21 18:28:31'),(_binary '\¬§ÄÆ´≤7£\‡|ÀÜ',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ',3,'BOX_DELETED','Box #3 deleted','current-user@example.com','{\"bbox\": {\"x1\": 319, \"x2\": 468, \"y1\": 184, \"y2\": 268}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 319, \"x2\": 468, \"y1\": 184, \"y2\": 268}, \"class_id\": 1, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 1.000, \"action_type\": \"deleted\"}','2025-10-21 18:28:36'),(_binary '\ÕÚ\—°\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',4,'BOX_DELETED','Box #4 deleted','prabath','{\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594, \"action_type\": \"approved\"}','{\"bbox\": {\"x1\": 132, \"x2\": 339, \"y1\": 309, \"y2\": 402}, \"class_id\": 0, \"box_number\": 4, \"class_name\": \"Faulty\", \"confidence\": 0.594, \"action_type\": \"deleted\"}','2025-10-05 12:42:50'),(_binary '\—kö$°\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',2,'BOX_DELETED','Box #2 deleted','current-user@example.com','{\"bbox\": {\"x1\": 338, \"x2\": 456, \"y1\": 259, \"y2\": 371}, \"class_id\": 1, \"box_number\": 2, \"class_name\": null, \"confidence\": 0.716, \"action_type\": \"edited\"}','{\"bbox\": {\"x1\": 338, \"x2\": 456, \"y1\": 259, \"y2\": 371}, \"class_id\": 1, \"box_number\": 2, \"class_name\": null, \"confidence\": 0.716, \"action_type\": \"deleted\"}','2025-10-05 12:42:56'),(_binary '\÷\‚T °\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',3,'BOX_DELETED','Box #3 deleted','prabath','{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805, \"action_type\": \"approved\"}','{\"bbox\": {\"x1\": 333, \"x2\": 469, \"y1\": 269, \"y2\": 383}, \"class_id\": 0, \"box_number\": 3, \"class_name\": \"Faulty\", \"confidence\": 0.805, \"action_type\": \"deleted\"}','2025-10-05 12:43:05'),(_binary '\Ÿ\Á˘\Í°\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',1,'BOX_DELETED','Box #1 deleted','current-user@example.com','{\"bbox\": {\"x1\": 131, \"x2\": 339, \"y1\": 302, \"y2\": 403}, \"class_id\": null, \"box_number\": 1, \"class_name\": null, \"confidence\": 0.418, \"action_type\": \"approved\"}','{\"bbox\": {\"x1\": 131, \"x2\": 339, \"y1\": 302, \"y2\": 403}, \"class_id\": null, \"box_number\": 1, \"class_name\": null, \"confidence\": 0.418, \"action_type\": \"deleted\"}','2025-10-05 12:43:10'),(_binary '€•\…L°\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',NULL,'AI_DETECTION_RUN','AI detected 2 anomalies using YOLOv8p2','Prabath',NULL,'{\"detected_boxes\": [{\"bbox\": {\"x1\": 223, \"x2\": 413, \"y1\": 284, \"y2\": 381}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 5, \"class_name\": \"Faulty\", \"confidence\": 0.686}, {\"bbox\": {\"x1\": 408, \"x2\": 524, \"y1\": 243, \"y2\": 362}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 6, \"class_name\": \"Faulty\", \"confidence\": 0.668}], \"total_detections\": 2, \"detection_metadata\": {\"model_type\": \"YOLOv8p2\", \"total_detections\": 2, \"confidence_threshold\": \"user_specified\"}}','2025-10-05 12:43:13'),(_binary '€¶é\‡°\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',5,'AI_DETECTION_RUN','AI detected box #5 - Faulty (confidence: 0.686)','Prabath',NULL,'{\"bbox\": {\"x1\": 223, \"x2\": 413, \"y1\": 284, \"y2\": 381}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 5, \"class_name\": \"Faulty\", \"confidence\": 0.686, \"action_type\": \"created\"}','2025-10-05 12:43:13'),(_binary '€¶\‡¿°\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',6,'AI_DETECTION_RUN','AI detected box #6 - Faulty (confidence: 0.668)','Prabath',NULL,'{\"bbox\": {\"x1\": 408, \"x2\": 524, \"y1\": 243, \"y2\": 362}, \"source\": \"ai\", \"class_id\": 0, \"box_number\": 6, \"class_name\": \"Faulty\", \"confidence\": 0.668, \"action_type\": \"created\"}','2025-10-05 12:43:13'),(_binary '\ﬁ\Îu‘°\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',6,'BOX_APPROVED','Box #6 approved','Prabath','{\"bbox\": {\"x1\": 408, \"x2\": 524, \"y1\": 243, \"y2\": 362}, \"class_id\": 0, \"box_number\": 6, \"class_name\": \"Faulty\", \"confidence\": 0.668, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 408, \"x2\": 524, \"y1\": 243, \"y2\": 362}, \"class_id\": 0, \"box_number\": 6, \"class_name\": \"Faulty\", \"confidence\": 0.668, \"action_type\": \"approved\"}','2025-10-05 12:43:19'),(_binary 'ﬂø=∫°\ËÇ\Œ\Ìøˆëı\Z',_binary '™\“ÔÖòäMIØy0ìWhT',5,'BOX_APPROVED','Box #5 approved','Prabath','{\"bbox\": {\"x1\": 223, \"x2\": 413, \"y1\": 284, \"y2\": 381}, \"class_id\": 0, \"box_number\": 5, \"class_name\": \"Faulty\", \"confidence\": 0.686, \"action_type\": \"created\"}','{\"bbox\": {\"x1\": 223, \"x2\": 413, \"y1\": 284, \"y2\": 381}, \"class_id\": 0, \"box_number\": 5, \"class_name\": \"Faulty\", \"confidence\": 0.686, \"action_type\": \"approved\"}','2025-10-05 12:43:20');
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
INSERT INTO `inspections` VALUES (_binary 'G´~©∫EIY§\n≥\◊@eÄˆ','INS-005',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',NULL,_binary 'Úïa∞ïO¶©l\ﬁpª75z',NULL,'SUNNY','IN_PROGRESS',NULL,'Prabath',NULL,'2025-10-05 07:07:15',NULL,NULL,NULL,'2025-10-05 07:07:15','2025-10-05 07:07:42',_binary 'äeHÜUEƒ¥jÛÑ`K\∆x'),(_binary 'kÙ1ﬂæC¨ñfæ~\’b∞','INS-004',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',NULL,_binary '¯+)h7CªäµDâã	',NULL,'SUNNY','IN_PROGRESS','Add note','Prabath',NULL,'2025-10-05 01:34:03',NULL,NULL,NULL,'2025-10-05 01:34:03','2025-10-05 07:11:33',_binary '!\Ó\œ\ﬁ\—@Aßì¸Ñ\ÌGƒ•c'),(_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶','INS-003',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',NULL,_binary '\€¡Bˇ§E,£X_N~â',NULL,'CLOUDY','IN_PROGRESS',NULL,'Prabath',NULL,'2025-10-05 00:55:02',NULL,NULL,NULL,'2025-10-05 00:55:02','2025-10-05 00:56:06',_binary '\”\ÀÙ√ïI«∏òm\Zá#S\Ô'),(_binary 'ò¥{\–/C9á^k\√\–cÆ','INS-006',_binary '¯\÷—éÖgL¢ìr\«-îZ',NULL,_binary '©†\œˇ+\ÈI3∫u\r\◊\rv¶',NULL,'CLOUDY','IN_PROGRESS',NULL,NULL,NULL,'2025-10-05 07:08:21',NULL,NULL,NULL,'2025-10-05 07:08:21','2025-10-05 07:08:59',_binary '\÷aó\0@Ÿòø>ù!\√'),(_binary '™\“ÔÖòäMIØy0ìWhT','INS-001',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',NULL,_binary 'Nj<˛DEç∞ç\nö∞˜N',NULL,'SUNNY','IN_PROGRESS','This is transformer 1 in the dataset','Prabath','Prabath','2025-10-01 23:37:55',NULL,NULL,NULL,'2025-10-01 23:37:55','2025-10-05 07:13:30',_binary '\Ã7Å∑¯LK£úyë˙õ\ﬁÒ'),(_binary '\—V›üíª@êã®ŒòÜ¥Lº','INS-002',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',NULL,_binary 'î\›-`ÆN∏§\Î\Â@j',NULL,'CLOUDY','COMPLETED','This is transformer 10 in the data set','admin',NULL,'2025-10-02 00:09:25',NULL,NULL,NULL,'2025-10-02 00:09:25','2025-10-02 00:35:10',_binary '?ß\Œh\ƒ\‘CD™†˙^êäΩr'),(_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ','INS-007',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',NULL,_binary 'π8õıAâçÉBfA2h\Î',NULL,'RAINY','COMPLETED',NULL,'PRABATH',NULL,'2025-10-05 07:14:09',NULL,NULL,NULL,'2025-10-05 07:14:09','2025-10-21 13:02:12',_binary 'fkæ\Á ˝Lú8Ü\Âà');
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
INSERT INTO `thermal_images` VALUES (_binary '˚$T\≈H3≤6\Œ1ø\√\Á','image/jpeg','SUNNY','T1_normal_003.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/baseline/c17cd32a-49ca-4b74-8165-2bcfa02bde9e_T1_normal_003.jpg',27630,'c17cd32a-49ca-4b74-8165-2bcfa02bde9e_T1_normal_003.jpg','BASELINE','2025-10-02 05:06:53.377655','seed',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',NULL),(_binary 'TÒ=\“B(∫ÿëX\—wh\r','image/png',NULL,'annotated_INS-004_1759647946299.png','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/428851e2-2527-42dd-bc01-d56af93a4423_annotated_INS-004_1759647946299.png',260465,'428851e2-2527-42dd-bc01-d56af93a4423_annotated_INS-004_1759647946299.png','INSPECTION','2025-10-05 07:05:46.393771','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞'),(_binary 'Nj<˛DEç∞ç\nö∞˜N','image/png',NULL,'annotated_INS-001_1759668210352.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/1fd3d605-b7f0-4f52-8277-c65d413c9e27_annotated_INS-001_1759668210352.png',425394,'1fd3d605-b7f0-4f52-8277-c65d413c9e27_annotated_INS-001_1759668210352.png','INSPECTION','2025-10-05 12:43:30.378108','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary 'äeHÜUEƒ¥jÛÑ`K\∆x','image/png',NULL,'T3_faulty_002 - 3.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/e2337f58-2211-4f50-a54f-daeccccb3f9d_T3_faulty_002 - 3.png',193940,'e2337f58-2211-4f50-a54f-daeccccb3f9d_T3_faulty_002 - 3.png','INSPECTION','2025-10-05 12:37:29.812934','Prabath',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ'),(_binary '\€¡Bˇ§E,£X_N~â','image/png',NULL,'annotated_INS-003_1759645566246.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/68ecee6d-b8ea-4742-ac9c-bcddb4303e25_annotated_INS-003_1759645566246.png',260465,'68ecee6d-b8ea-4742-ac9c-bcddb4303e25_annotated_INS-003_1759645566246.png','INSPECTION','2025-10-05 06:26:06.271825','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶'),(_binary '!\Ó\œ\ﬁ\—@Aßì¸Ñ\ÌGƒ•c','image/jpeg',NULL,'T7_faulty_003 - 5.jpg','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/b3760261-bf34-4170-af4e-0cf737cf1428_T7_faulty_003 - 5.jpg',281442,'b3760261-bf34-4170-af4e-0cf737cf1428_T7_faulty_003 - 5.jpg','INSPECTION','2025-10-05 12:41:23.354773','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞'),(_binary '%’£1åKmÜa\”<\ÁGâI','image/jpeg','SUNNY','T7_normal_001.jpg','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/baseline/2275d00e-b2a3-482f-89a8-f80c2fe43d21_T7_normal_001.jpg',398693,'2275d00e-b2a3-482f-89a8-f80c2fe43d21_T7_normal_001.jpg','BASELINE','2025-10-02 05:06:53.391896','seed',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',NULL),(_binary '\' õ\"•I\0Ω\‡≥`áö','image/png',NULL,'annotated_INS-001_1759382729668.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/37e7988d-761a-408b-b7bf-2c375bbef7e8_annotated_INS-001_1759382729668.png',432522,'37e7988d-761a-408b-b7bf-2c375bbef7e8_annotated_INS-001_1759382729668.png','INSPECTION','2025-10-02 05:25:29.743230','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '6\€\∆UNàM°ÙΩNP¡\‰','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/c4c2f607-3ca1-4aaf-9ed2-fefb53e560d8_T10_faulty_001.jpg',255567,'c4c2f607-3ca1-4aaf-9ed2-fefb53e560d8_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:50:18.404554','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary ':§ì¿ü∂MI•R≥\Ëãt\·','image/png',NULL,'annotated_INS-004_1759648243007.png','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/e04d0608-4752-4676-8fe3-722d4630302f_annotated_INS-004_1759648243007.png',398566,'e04d0608-4752-4676-8fe3-722d4630302f_annotated_INS-004_1759648243007.png','INSPECTION','2025-10-05 07:10:43.094197','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞'),(_binary '>\ÿ*^I≥I\r£d∑∑\ÿH','image/png',NULL,'annotated_INS-001_1759382826077.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/45e8b498-f03a-46b5-a2ce-a7fa0f1a5205_annotated_INS-001_1759382826077.png',432728,'45e8b498-f03a-46b5-a2ce-a7fa0f1a5205_annotated_INS-001_1759382826077.png','INSPECTION','2025-10-02 05:27:06.100715','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '?ß\Œh\ƒ\‘CD™†˙^êäΩr','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/c800fe50-121d-4049-b68b-cd680b9646df_T10_faulty_001.jpg',255567,'c800fe50-121d-4049-b68b-cd680b9646df_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:59:35.650531','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary '@ím\ÈA•B\Ëõ\…{\…$1¿ë','image/png',NULL,'T3_normal_001.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/30a989db-ca9a-4673-90c7-430cb45eb39c_T3_normal_001.png',56604,'30a989db-ca9a-4673-90c7-430cb45eb39c_T3_normal_001.png','INSPECTION','2025-10-02 05:52:52.431282','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'Bª^\„rQCÜ∞ë\·\ﬂ8S_õ','image/png',NULL,'annotated_INS-004_1759648194987.png','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/50210041-359d-434b-9654-66d44414bc53_annotated_INS-004_1759648194987.png',398884,'50210041-359d-434b-9654-66d44414bc53_annotated_INS-004_1759648194987.png','INSPECTION','2025-10-05 07:09:55.042678','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞'),(_binary 'T\È¢oö˛Oj≥\‰ˆ[\0Lzz','image/png',NULL,'annotated_INS-001_1759587305430.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/7a61334c-771a-47a2-9bef-342b4eaea051_annotated_INS-001_1759587305430.png',423780,'7a61334c-771a-47a2-9bef-342b4eaea051_annotated_INS-001_1759587305430.png','INSPECTION','2025-10-04 14:15:05.531210','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary 'fkæ\Á ˝Lú8Ü\Âà','image/jpeg',NULL,'T1_faulty_015 - 2.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/778191ce-9870-4d21-9b4f-91a13560a8e4_T1_faulty_015 - 2.jpg',31721,'778191ce-9870-4d21-9b4f-91a13560a8e4_T1_faulty_015 - 2.jpg','INSPECTION','2025-10-05 12:44:17.082663','PRABATH',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ'),(_binary 'pû\ÍHA∏>L\œ\"\–\¬','image/jpeg',NULL,'T10_normal_002.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/9f0d22b9-f85c-4bde-8e0a-38c616f549da_T10_normal_002.jpg',191755,'9f0d22b9-f85c-4bde-8e0a-38c616f549da_T10_normal_002.jpg','INSPECTION','2025-10-02 05:50:42.571918','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'w˘¢l£A≈ªIFÉG\‡\„','image/png',NULL,'annotated_INS-002_1759384804686.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/f63cfa29-c0d4-4292-86d9-c1c5e201dd17_annotated_INS-002_1759384804686.png',260478,'f63cfa29-c0d4-4292-86d9-c1c5e201dd17_annotated_INS-002_1759384804686.png','INSPECTION','2025-10-02 06:00:04.726737','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'éáÅ1\–ONåK¥óáõH','image/png',NULL,'T4_normal_001.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/37626f90-2d81-4670-9046-73e9da4d0b46_T4_normal_001.png',175980,'37626f90-2d81-4670-9046-73e9da4d0b46_T4_normal_001.png','INSPECTION','2025-10-02 05:52:37.832675','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'î\›-`ÆN∏§\Î\Â@j','image/png',NULL,'annotated_INS-002_1759385096751.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/b53d1ba1-e391-47dc-877d-00775a3646ed_annotated_INS-002_1759385096751.png',260478,'b53d1ba1-e391-47dc-877d-00775a3646ed_annotated_INS-002_1759385096751.png','INSPECTION','2025-10-02 06:04:56.783291','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'ñy\Îf\ÀK •å\ÃS¡C','image/jpeg','SUNNY','T10_normal_002.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/baseline/7b3a3858-0a42-4ef2-8955-6c12a6098f83_T10_normal_002.jpg',191755,'7b3a3858-0a42-4ef2-8955-6c12a6098f83_T10_normal_002.jpg','BASELINE','2025-10-02 05:06:53.373309','seed',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',NULL),(_binary '©†\œˇ+\ÈI3∫u\r\◊\rv¶','image/png',NULL,'annotated_INS-006_1759667938724.png','http://localhost:8080/files/f8d6d18e-8567-4ca2-9312-72c72d07945a/inspection/3f7eddcb-a122-45b1-afc7-d189dad0d8c5_annotated_INS-006_1759667938724.png',500812,'3f7eddcb-a122-45b1-afc7-d189dad0d8c5_annotated_INS-006_1759667938724.png','INSPECTION','2025-10-05 12:38:58.769292','system',_binary '¯\÷—éÖgL¢ìr\«-îZ',_binary 'ò¥{\–/C9á^k\√\–cÆ'),(_binary '™\ŒΩí\‘MpÄìçV\Œ!ç§','image/jpeg',NULL,'T1_faulty_015 - 2.jpg','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/51a4bc29-3a92-4884-a0ec-8f6fb042e596_T1_faulty_015 - 2.jpg',31721,'51a4bc29-3a92-4884-a0ec-8f6fb042e596_T1_faulty_015 - 2.jpg','INSPECTION','2025-10-05 07:09:28.818594','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞'),(_binary 'Æ@\Ã\Ó5\"DQπØ\…OBGE\Õ','image/png',NULL,'annotated_INS-001_1759382789633.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/bbe03bd7-ae93-4402-baef-91a070d27104_annotated_INS-001_1759382789633.png',432728,'bbe03bd7-ae93-4402-baef-91a070d27104_annotated_INS-001_1759382789633.png','INSPECTION','2025-10-02 05:26:29.683698','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '∞\ÊÑ\ÍÛS@hëª}2\‰\—','image/png','SUNNY','T4_normal_001.png','http://localhost:8080/files/f8d6d18e-8567-4ca2-9312-72c72d07945a/baseline/7ef93914-b99a-4ad4-b63a-41e0897df367_T4_normal_001.png',175980,'7ef93914-b99a-4ad4-b63a-41e0897df367_T4_normal_001.png','BASELINE','2025-10-02 05:06:53.385630','seed',_binary '¯\÷—éÖgL¢ìr\«-îZ',NULL),(_binary '≥Ò≤2\œI6∞ãã\n\„3<E','image/jpeg',NULL,'T7_normal_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/40d62d5b-046f-426a-831b-378e792b135d_T7_normal_001.jpg',398693,'40d62d5b-046f-426a-831b-378e792b135d_T7_normal_001.jpg','INSPECTION','2025-10-02 05:53:14.517094','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'µ∫YM}ZB∏†¥ÀÅ\◊Xh\Ó','image/jpeg',NULL,'T1_normal_003.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/bb186aa7-a454-4dc9-9714-8d2f9ecbc454_T1_normal_003.jpg',27630,'bb186aa7-a454-4dc9-9714-8d2f9ecbc454_T1_normal_003.jpg','INSPECTION','2025-10-02 05:52:14.116198','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'π8õıAâçÉBfA2h\Î','image/png',NULL,'annotated_INS-007_1759668267699.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/b4c8d168-1742-46db-8822-53558aceb354_annotated_INS-007_1759668267699.png',398324,'b4c8d168-1742-46db-8822-53558aceb354_annotated_INS-007_1759668267699.png','INSPECTION','2025-10-05 12:44:27.722873','PRABATH',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '\Ê=ÉA\ÈM\r∞∏3\∆œ°\Õ'),(_binary '\∆\œª¸Oë;ã\Ï˛äkH','image/png',NULL,'annotated_INS-003_1759645559918.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/b9ad84d7-725c-425c-87ff-749f014f95a8_annotated_INS-003_1759645559918.png',260465,'b9ad84d7-725c-425c-87ff-749f014f95a8_annotated_INS-003_1759645559918.png','INSPECTION','2025-10-05 06:25:59.951337','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶'),(_binary ' ≥\Ô1v´E˙Ø\0Fé\ÂøY','image/png',NULL,'annotated_INS-006_1759667923189.png','http://localhost:8080/files/f8d6d18e-8567-4ca2-9312-72c72d07945a/inspection/cbe03572-ee2d-4954-bd63-37ee67698d76_annotated_INS-006_1759667923189.png',190421,'cbe03572-ee2d-4954-bd63-37ee67698d76_annotated_INS-006_1759667923189.png','INSPECTION','2025-10-05 12:38:43.210618','system',_binary '¯\÷—éÖgL¢ìr\«-îZ',_binary 'ò¥{\–/C9á^k\√\–cÆ'),(_binary '\Ã7Å∑¯LK£úyë˙õ\ﬁÒ','image/jpeg',NULL,'T1_faulty_016.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/79b8adf1-bf93-4908-9289-8dc509163720_T1_faulty_016.jpg',32713,'79b8adf1-bf93-4908-9289-8dc509163720_T1_faulty_016.jpg','INSPECTION','2025-10-02 05:08:10.380515','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '\”\ÀÙ√ïI«∏òm\Zá#S\Ô','image/jpeg',NULL,'T10_faulty_001 - 1.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/194a7898-7692-4a92-89a2-850b07ab6f24_T10_faulty_001 - 1.jpg',255567,'194a7898-7692-4a92-89a2-850b07ab6f24_T10_faulty_001 - 1.jpg','INSPECTION','2025-10-05 06:25:39.816969','Prabath',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary 'ë®\‰W◊ΩHü®ôzÉØ≤π¶'),(_binary '\÷aó\0@Ÿòø>ù!\√','image/png',NULL,'T4_faulty_002 - 4.png','http://localhost:8080/files/f8d6d18e-8567-4ca2-9312-72c72d07945a/inspection/36971a7e-79a7-4d36-bdc7-88d3f9cad264_T4_faulty_002 - 4.png',208612,'36971a7e-79a7-4d36-bdc7-88d3f9cad264_T4_faulty_002 - 4.png','INSPECTION','2025-10-05 12:38:29.777357','unknown',_binary '¯\÷—éÖgL¢ìr\«-îZ',_binary 'ò¥{\–/C9á^k\√\–cÆ'),(_binary '\ÿ\‰\Z\Áy\»HKåëî9\⁄{Ÿ¨','image/jpeg',NULL,'T10_faulty_001 - 1.jpg','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/c677e67d-f954-4c21-a535-d8ebea93ee84_T10_faulty_001 - 1.jpg',255567,'c677e67d-f954-4c21-a535-d8ebea93ee84_T10_faulty_001 - 1.jpg','INSPECTION','2025-10-05 12:34:44.990665','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞'),(_binary '\‰\nˇ\'nSK\‚ì%∫\‘5`\‰','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/a06efbea-ca0e-4d16-886c-0435304e2618_T10_faulty_001.jpg',255567,'a06efbea-ca0e-4d16-886c-0435304e2618_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:39:42.298176','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'Úïa∞ïO¶©l\ﬁpª75z','image/png',NULL,'annotated_INS-005_1759667862289.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/e9ccb458-7c87-4237-9e9a-d7d1491dfb6e_annotated_INS-005_1759667862289.png',219268,'e9ccb458-7c87-4237-9e9a-d7d1491dfb6e_annotated_INS-005_1759667862289.png','INSPECTION','2025-10-05 12:37:42.344307','Prabath',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary 'G´~©∫EIY§\n≥\◊@eÄˆ'),(_binary 'ı¢z\\ﬂ´I(Ü¶ˆóDìu\√','image/png','SUNNY','T3_normal_001.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/baseline/354c30c9-7d9a-41a2-af17-4ec64ddc9342_T3_normal_001.png',56604,'354c30c9-7d9a-41a2-af17-4ec64ddc9342_T3_normal_001.png','BASELINE','2025-10-02 05:06:53.380115','seed',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',NULL),(_binary '¯+)h7CªäµDâã	','image/png',NULL,'annotated_INS-004_1759668092560.png','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/4c84c66e-49d7-4216-95b8-9938cbb5837e_annotated_INS-004_1759668092560.png',216121,'4c84c66e-49d7-4216-95b8-9938cbb5837e_annotated_INS-004_1759668092560.png','INSPECTION','2025-10-05 12:41:32.578812','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞'),(_binary '˚B\≈\‹S\"O\Î≤∏•Ùb','image/jpeg',NULL,'T10_faulty_001 - 1.jpg','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/91aceb34-240a-42c2-ba65-c71acd0a31e5_T10_faulty_001 - 1.jpg',255567,'91aceb34-240a-42c2-ba65-c71acd0a31e5_T10_faulty_001 - 1.jpg','INSPECTION','2025-10-05 07:04:37.402252','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞'),(_binary '˛¯\‚u˚\Ê@Hõ∫¥ºl;Ø˛','image/png',NULL,'annotated_INS-004_1759667694306.png','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/inspection/e85ed18d-e127-4eac-8c38-2f21caccda59_annotated_INS-004_1759667694306.png',260466,'e85ed18d-e127-4eac-8c38-2f21caccda59_annotated_INS-004_1759667694306.png','INSPECTION','2025-10-05 12:34:54.331948','Prabath',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',_binary 'kÙ1ﬂæC¨ñfæ~\’b∞');
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
INSERT INTO `transformers` VALUES (_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',300,'TX-002','2025-10-02 05:06:53.350689','Hettipola','','EN-122-B','Matale','Distribution','2025-10-02 05:06:53.350694'),(_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',500,'TX-001','2025-10-02 05:06:53.312342','Thannekumbura','Near substation','EN-122-A','Kandy','Bulk','2025-10-02 05:06:53.312355'),(_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',250,'TX-005','2025-10-02 05:06:53.367212','Mahiyanganaya','','EN-125-A','Badulla','Bulk','2025-10-02 05:06:53.367216'),(_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',200,'TX-003','2025-10-02 05:06:53.355797','Kuliyapitiya','','EN-123-A','Kurunagala','Bulk','2025-10-02 05:06:53.355800'),(_binary '¯\÷—éÖgL¢ìr\«-îZ',400,'TX-004','2025-10-02 05:06:53.365039','Nugegoda','','EN-124-B','Colombo','Distribution','2025-10-02 05:06:53.365042');
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

-- Dump completed on 2025-10-22  0:06:58
