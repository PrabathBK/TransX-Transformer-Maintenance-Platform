-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
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
  `confidence` decimal(5,3) DEFAULT NULL,
  `source` enum('ai','human') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_type` enum('created','edited','deleted','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'created',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `modified_at` timestamp NULL DEFAULT NULL,
  `parent_annotation_id` binary(16) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `annotation_number` int DEFAULT NULL,
  `size_px` bigint DEFAULT NULL,
  `severity_score` decimal(5,2) DEFAULT NULL,
  `flagged` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `parent_annotation_id` (`parent_annotation_id`),
  KEY `idx_inspection_id` (`inspection_id`),
  KEY `idx_inspection_active` (`inspection_id`,`is_active`),
  KEY `idx_source` (`source`),
  KEY `idx_version` (`inspection_id`,`version`),
  CONSTRAINT `annotations_ibfk_1` FOREIGN KEY (`inspection_id`) REFERENCES `inspections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `annotations_ibfk_2` FOREIGN KEY (`parent_annotation_id`) REFERENCES `annotations` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `annotations`
--

LOCK TABLES `annotations` WRITE;
/*!40000 ALTER TABLE `annotations` DISABLE KEYS */;
INSERT INTO `annotations` VALUES (_binary 'ÆÖºëuOQè6|\◊0X\ƒ',_binary 'lzAçã6|êò∂\≈',3,120,152,236,276,1,NULL,0.905,'ai','edited',NULL,'2025-10-03 00:18:01','current-user@example.com','2025-10-03 00:18:01',_binary 'jáF\«NgFFºæÖ_N',1,NULL,NULL,NULL,NULL,0),(_binary '\ZqÙ)ÜO4≥ê\Êˆô•¥é',_binary '™\“ÔÖòäMIØy0ìWhT',2,323,263,441,375,1,NULL,0.716,'ai','edited',NULL,'2025-10-01 23:56:17','current-user@example.com','2025-10-01 23:56:17',_binary '¨Ucå{DúÜ¿“üÒî&\Œ',0,NULL,NULL,NULL,NULL,0),(_binary '\“)˝\“D«é.èµOú\‘~',_binary '™\“ÔÖòäMIØy0ìWhT',4,338,259,456,371,1,NULL,0.716,'ai','edited',NULL,'2025-10-01 23:56:28','current-user@example.com','2025-10-01 23:56:28',_binary '¿Q\≈˝/Gêê\ \„\Ìë\·K',1,NULL,NULL,NULL,NULL,0),(_binary '(t¬´-eOK®C»Ü\√¿ª',_binary '\—V›üíª@êã®ŒòÜ¥Lº',2,1176,760,1228,846,1,NULL,0.348,'ai','edited',NULL,'2025-10-02 08:28:20','current-user@example.com','2025-10-02 08:28:20',_binary '˘OÄá±\‰Küè<ïî]°E',1,NULL,NULL,NULL,NULL,0),(_binary ')ø4t\ÕxJbò—ÅÛ\Zµî˙',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,705,709,881,933,2,'faulty_loose_joint',1.000,'human','deleted','current-user@example.com','2025-10-02 08:35:52','current-user@example.com','2025-10-02 08:36:02',NULL,0,NULL,NULL,NULL,NULL,0),(_binary '*{\‰jπ¯Nö©eôΩ\€y¥',_binary 'lzAçã6|êò∂\≈',1,120,152,236,276,NULL,NULL,0.905,'ai','created','AI-YOLOv8','2025-10-03 00:02:38',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,0),(_binary '1ëzWJ»´4-+o¡\⁄',_binary '\—V›üíª@êã®ŒòÜ¥Lº',2,439,371,457,395,1,NULL,0.397,'ai','edited',NULL,'2025-10-02 00:33:57','current-user@example.com','2025-10-02 00:33:57',_binary 'µ3\\Ñ\ŒL≈≥ıí˛&_',0,NULL,NULL,NULL,NULL,0),(_binary '=Û5iÇG⁄É\…Wˇ\«b¥',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1146,993,1269,1108,1,'Faulty',1.000,'human','deleted','current-user@example.com','2025-10-02 00:30:20','current-user@example.com','2025-10-02 00:30:35',NULL,0,NULL,NULL,NULL,NULL,0),(_binary 'SZñ\È{E\Ê°\‡ãz\'h±\◊',_binary 'lzAçã6|êò∂\≈',3,251,149,371,279,1,NULL,0.968,'ai','edited',NULL,'2025-10-03 00:18:01','current-user@example.com','2025-10-03 00:18:01',_binary 'Ê¢í\Ô\¬BòRb\∆%\‹ı',1,NULL,NULL,NULL,NULL,0),(_binary 'Th_¡TE*™µ\ÎΩ\Èâu•',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1248,783,1317,870,NULL,NULL,0.712,'ai','approved','AI-YOLOv8','2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:02',NULL,1,NULL,NULL,NULL,NULL,0),(_binary 'jáF\«NgFFºæÖ_N',_binary 'lzAçã6|êò∂\≈',2,120,152,236,276,1,NULL,0.905,'ai','edited',NULL,'2025-10-03 00:10:22','current-user@example.com','2025-10-03 00:10:22',_binary '*{\‰jπ¯Nö©eôΩ\€y¥',0,NULL,NULL,NULL,NULL,0),(_binary 'émﬁë\»E\ÊêH\Œ¡î«≥',_binary 'lzAçã6|êò∂\≈',1,388,151,503,279,NULL,NULL,0.960,'ai','approved','AI-YOLOv8','2025-10-03 00:02:38','current-user@example.com','2025-10-03 00:09:20',NULL,0,NULL,NULL,NULL,NULL,0),(_binary 'é…ô¨ˇCBø¶Y5±4\Z\«',_binary 'lzAçã6|êò∂\≈',1,139,52,322,135,3,'faulty_point_overload',1.000,'human','created','current-user@example.com','2025-10-03 00:02:48',NULL,NULL,NULL,0,NULL,4,15189,NULL,0),(_binary '°@\€4\ﬁNeäi˙«ßêüë',_binary '™\“ÔÖòäMIØy0ìWhT',1,131,302,339,403,NULL,NULL,0.418,'ai','approved','AI-YOLOv8','2025-10-01 23:55:19','current-user@example.com','2025-10-01 23:55:25',NULL,1,NULL,NULL,NULL,NULL,0),(_binary '´\'\€\‚ˆ\∆Eªû5ÇqE\…',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1011,950,1400,1093,1,'Faulty',1.000,'human','deleted','current-user@example.com','2025-10-02 00:34:08','current-user@example.com','2025-10-02 00:34:52',NULL,0,NULL,NULL,NULL,NULL,0),(_binary '¨Ucå{DúÜ¿“üÒî&\Œ',_binary '™\“ÔÖòäMIØy0ìWhT',1,324,264,457,390,NULL,NULL,0.716,'ai','approved','AI-YOLOv8','2025-10-01 23:55:19','current-user@example.com','2025-10-01 23:55:26',NULL,0,NULL,NULL,NULL,NULL,0),(_binary 'ÆSkCT.JVÇH˝ø¶~[',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1241,768,1321,876,NULL,NULL,0.341,'ai','approved','AI-YOLOv8','2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:01',NULL,1,NULL,NULL,NULL,NULL,0),(_binary '≥\‡ú}DÕåÜè˝-¢J',_binary 'lzAçã6|êò∂\≈',3,388,151,503,279,1,NULL,0.960,'ai','edited',NULL,'2025-10-03 00:18:01','current-user@example.com','2025-10-03 00:18:01',_binary '¿\ﬂ\‹\‰&\ÀIR†\‚\‰Äe-&f',1,NULL,NULL,NULL,NULL,0),(_binary 'µ3\\Ñ\ŒL≈≥ıí˛&_',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,324,254,342,278,NULL,NULL,0.397,'ai','created','AI-YOLOv8','2025-10-02 00:32:48',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,0),(_binary '¿Q\≈˝/Gêê\ \„\Ìë\·K',_binary '™\“ÔÖòäMIØy0ìWhT',3,328,263,446,375,1,NULL,0.716,'ai','edited',NULL,'2025-10-01 23:56:22','current-user@example.com','2025-10-01 23:56:22',_binary '\ZqÙ)ÜO4≥ê\Êˆô•¥é',0,NULL,NULL,NULL,NULL,0),(_binary '¿\ﬂ\‹\‰&\ÀIR†\‚\‰Äe-&f',_binary 'lzAçã6|êò∂\≈',2,388,151,503,279,1,NULL,0.960,'ai','edited',NULL,'2025-10-03 00:10:22','current-user@example.com','2025-10-03 00:10:22',_binary 'émﬁë\»E\ÊêH\Œ¡î«≥',0,NULL,NULL,NULL,NULL,0),(_binary '√∏®Ø6Hπàsìü3\‰',_binary 'lzAçã6|êò∂\≈',2,139,52,322,135,3,'faulty_point_overload',1.000,'human','edited',NULL,'2025-10-03 00:10:22','current-user@example.com','2025-10-03 00:10:22',_binary 'é…ô¨ˇCBø¶Y5±4\Z\«',1,NULL,4,15189,NULL,0),(_binary '\œOr:\ÌE˛§Ò‹ì\ÿ\›ˆ\◊',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,324,254,342,278,NULL,NULL,0.397,'ai','rejected','AI-YOLOv8','2025-10-02 05:18:20','current-user@example.com','2025-10-02 08:33:53',NULL,0,'User rejected this annotation',NULL,NULL,NULL,0),(_binary 'Ê¢í\Ô\¬BòRb\∆%\‹ı',_binary 'lzAçã6|êò∂\≈',2,251,149,371,279,1,NULL,0.968,'ai','edited',NULL,'2025-10-03 00:10:22','current-user@example.com','2025-10-03 00:10:22',_binary 'ˆ[\ÓSsDUëc\Ízï≥\„',0,NULL,NULL,NULL,NULL,0),(_binary 'ˆ[\ÓSsDUëc\Ízï≥\„',_binary 'lzAçã6|êò∂\≈',1,251,149,371,279,NULL,NULL,0.968,'ai','created','AI-YOLOv8','2025-10-03 00:02:38',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,0),(_binary '˘OÄá±\‰Küè<ïî]°E',_binary '\—V›üíª@êã®ŒòÜ¥Lº',1,1176,760,1228,846,NULL,NULL,0.348,'ai','approved','AI-YOLOv8','2025-10-02 00:29:55','current-user@example.com','2025-10-02 00:30:00',NULL,0,NULL,NULL,NULL,NULL,0),(_binary '¸Wîú\·@@ôZáı±ë≠\\',_binary '\—V›üíª@êã®ŒòÜ¥Lº',3,439,371,457,395,1,NULL,0.397,'ai','deleted',NULL,'2025-10-02 00:34:02','current-user@example.com','2025-10-02 00:34:05',_binary '1ëzWJ»´4-+o¡\⁄',0,NULL,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `annotations` ENABLE KEYS */;
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
INSERT INTO `inspection_comments` VALUES (_binary '\‚Ñü\ƒVED°¥ë\◊X~',_binary '™\“ÔÖòäMIØy0ìWhT','2 Anomalies Detected','Prabath','2025-10-01 23:57:03.341024','2025-10-01 23:57:03.341030');
/*!40000 ALTER TABLE `inspection_comments` ENABLE KEYS */;
UNLOCK TABLES;

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
  `status` enum('PENDING','IN_PROGRESS','COMPLETED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `notes` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inspected_at` timestamp NULL DEFAULT NULL,
  `maintenance_date` timestamp NULL DEFAULT NULL,
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
INSERT INTO `inspections` VALUES (_binary 'lzAçã6|êò∂\≈','INS-003',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',NULL,_binary 'Ú\na8\◊OrÜ¶\Í\‡©~',NULL,'SUNNY','IN_PROGRESS',NULL,'dinethra','2025-10-03 00:01:59',NULL,'2025-10-03 00:01:59','2025-10-03 00:18:01',_binary '˙V\'%∞´M	¶Ü ë9y¢\»'),(_binary '™\“ÔÖòäMIØy0ìWhT','INS-001',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',NULL,_binary '\nê¢mzC©èª9ﬁü	',NULL,'SUNNY','COMPLETED','This is transformer 1 in the dataset','Prabath','2025-10-01 23:37:55',NULL,'2025-10-01 23:37:55','2025-10-02 06:49:39',_binary '\Ã7Å∑¯LK£úyë˙õ\ﬁÒ'),(_binary '\—V›üíª@êã®ŒòÜ¥Lº','INS-002',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',NULL,_binary 'î\›-`ÆN∏§\Î\Â@j',NULL,'CLOUDY','COMPLETED','This is transformer 10 in the data set','admin','2025-10-02 00:09:25',NULL,'2025-10-02 00:09:25','2025-10-02 00:35:10',_binary '?ß\Œh\ƒ\‘CD™†˙^êäΩr'),(_binary '\Ó\‚eM~@¥Òºiu\‡ßT','INS-004',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',NULL,NULL,NULL,'CLOUDY','PENDING','test 2','Dinethra','2025-10-02 06:50:57',NULL,'2025-10-02 06:50:57','2025-10-02 06:50:57',NULL);
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
INSERT INTO `thermal_images` VALUES (_binary '\Í8‘ΩE¥ÇäImCΩÃ¶','image/png','SUNNY','T5_normal_001.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/baseline/8d3fd1ff-0c02-4d15-9b47-5df8a2d430c3_T5_normal_001.png',81998,'8d3fd1ff-0c02-4d15-9b47-5df8a2d430c3_T5_normal_001.png','BASELINE','2025-10-02 18:49:49.678565','admin',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',NULL),(_binary '˚$T\≈H3≤6\Œ1ø\√\Á','image/jpeg','SUNNY','T1_normal_003.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/baseline/c17cd32a-49ca-4b74-8165-2bcfa02bde9e_T1_normal_003.jpg',27630,'c17cd32a-49ca-4b74-8165-2bcfa02bde9e_T1_normal_003.jpg','BASELINE','2025-10-02 05:06:53.377655','seed',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',NULL),(_binary '\nê¢mzC©èª9ﬁü	','image/png',NULL,'annotated_INS-001_1759407575077.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/73cb7cce-1296-469c-ada3-d40d10b82b0b_annotated_INS-001_1759407575077.png',460877,'73cb7cce-1296-469c-ada3-d40d10b82b0b_annotated_INS-001_1759407575077.png','INSPECTION','2025-10-02 12:19:35.162562','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '%’£1åKmÜa\”<\ÁGâI','image/jpeg','SUNNY','T7_normal_001.jpg','http://localhost:8080/files/b97d67b4-412e-42c4-adec-4357667b267a/baseline/2275d00e-b2a3-482f-89a8-f80c2fe43d21_T7_normal_001.jpg',398693,'2275d00e-b2a3-482f-89a8-f80c2fe43d21_T7_normal_001.jpg','BASELINE','2025-10-02 05:06:53.391896','seed',_binary 'π}g¥A.Bƒ≠\ÏCWf{&z',NULL),(_binary '\' õ\"•I\0Ω\‡≥`áö','image/png',NULL,'annotated_INS-001_1759382729668.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/37e7988d-761a-408b-b7bf-2c375bbef7e8_annotated_INS-001_1759382729668.png',432522,'37e7988d-761a-408b-b7bf-2c375bbef7e8_annotated_INS-001_1759382729668.png','INSPECTION','2025-10-02 05:25:29.743230','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '6\€\∆UNàM°ÙΩNP¡\‰','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/c4c2f607-3ca1-4aaf-9ed2-fefb53e560d8_T10_faulty_001.jpg',255567,'c4c2f607-3ca1-4aaf-9ed2-fefb53e560d8_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:50:18.404554','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary '>\ÿ*^I≥I\r£d∑∑\ÿH','image/png',NULL,'annotated_INS-001_1759382826077.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/45e8b498-f03a-46b5-a2ce-a7fa0f1a5205_annotated_INS-001_1759382826077.png',432728,'45e8b498-f03a-46b5-a2ce-a7fa0f1a5205_annotated_INS-001_1759382826077.png','INSPECTION','2025-10-02 05:27:06.100715','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '?ß\Œh\ƒ\‘CD™†˙^êäΩr','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/c800fe50-121d-4049-b68b-cd680b9646df_T10_faulty_001.jpg',255567,'c800fe50-121d-4049-b68b-cd680b9646df_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:59:35.650531','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary '@ím\ÈA•B\Ëõ\…{\…$1¿ë','image/png',NULL,'T3_normal_001.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/30a989db-ca9a-4673-90c7-430cb45eb39c_T3_normal_001.png',56604,'30a989db-ca9a-4673-90c7-430cb45eb39c_T3_normal_001.png','INSPECTION','2025-10-02 05:52:52.431282','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'g∏éh§\ÕC?∑P}ŸîÉß','image/png',NULL,'annotated_INS-003_1759470021701.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/ad4dc80c-0c97-4613-aa5f-492c206e4f62_annotated_INS-003_1759470021701.png',304986,'ad4dc80c-0c97-4613-aa5f-492c206e4f62_annotated_INS-003_1759470021701.png','INSPECTION','2025-10-03 05:40:21.811879','dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary 'lzAçã6|êò∂\≈'),(_binary 'pû\ÍHA∏>L\œ\"\–\¬','image/jpeg',NULL,'T10_normal_002.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/9f0d22b9-f85c-4bde-8e0a-38c616f549da_T10_normal_002.jpg',191755,'9f0d22b9-f85c-4bde-8e0a-38c616f549da_T10_normal_002.jpg','INSPECTION','2025-10-02 05:50:42.571918','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'w˘¢l£A≈ªIFÉG\‡\„','image/png',NULL,'annotated_INS-002_1759384804686.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/f63cfa29-c0d4-4292-86d9-c1c5e201dd17_annotated_INS-002_1759384804686.png',260478,'f63cfa29-c0d4-4292-86d9-c1c5e201dd17_annotated_INS-002_1759384804686.png','INSPECTION','2025-10-02 06:00:04.726737','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'éáÅ1\–ONåK¥óáõH','image/png',NULL,'T4_normal_001.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/37626f90-2d81-4670-9046-73e9da4d0b46_T4_normal_001.png',175980,'37626f90-2d81-4670-9046-73e9da4d0b46_T4_normal_001.png','INSPECTION','2025-10-02 05:52:37.832675','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'î\›-`ÆN∏§\Î\Â@j','image/png',NULL,'annotated_INS-002_1759385096751.png','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/b53d1ba1-e391-47dc-877d-00775a3646ed_annotated_INS-002_1759385096751.png',260478,'b53d1ba1-e391-47dc-877d-00775a3646ed_annotated_INS-002_1759385096751.png','INSPECTION','2025-10-02 06:04:56.783291','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'ñy\Îf\ÀK •å\ÃS¡C','image/jpeg','SUNNY','T10_normal_002.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/baseline/7b3a3858-0a42-4ef2-8955-6c12a6098f83_T10_normal_002.jpg',191755,'7b3a3858-0a42-4ef2-8955-6c12a6098f83_T10_normal_002.jpg','BASELINE','2025-10-02 05:06:53.373309','seed',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',NULL),(_binary 'Æ@\Ã\Ó5\"DQπØ\…OBGE\Õ','image/png',NULL,'annotated_INS-001_1759382789633.png','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/bbe03bd7-ae93-4402-baef-91a070d27104_annotated_INS-001_1759382789633.png',432728,'bbe03bd7-ae93-4402-baef-91a070d27104_annotated_INS-001_1759382789633.png','INSPECTION','2025-10-02 05:26:29.683698','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '∞\ÊÑ\ÍÛS@hëª}2\‰\—','image/png','SUNNY','T4_normal_001.png','http://localhost:8080/files/f8d6d18e-8567-4ca2-9312-72c72d07945a/baseline/7ef93914-b99a-4ad4-b63a-41e0897df367_T4_normal_001.png',175980,'7ef93914-b99a-4ad4-b63a-41e0897df367_T4_normal_001.png','BASELINE','2025-10-02 05:06:53.385630','seed',_binary '¯\÷—éÖgL¢ìr\«-îZ',NULL),(_binary '≥Ò≤2\œI6∞ãã\n\„3<E','image/jpeg',NULL,'T7_normal_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/40d62d5b-046f-426a-831b-378e792b135d_T7_normal_001.jpg',398693,'40d62d5b-046f-426a-831b-378e792b135d_T7_normal_001.jpg','INSPECTION','2025-10-02 05:53:14.517094','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'µ∫YM}ZB∏†¥ÀÅ\◊Xh\Ó','image/jpeg',NULL,'T1_normal_003.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/bb186aa7-a454-4dc9-9714-8d2f9ecbc454_T1_normal_003.jpg',27630,'bb186aa7-a454-4dc9-9714-8d2f9ecbc454_T1_normal_003.jpg','INSPECTION','2025-10-02 05:52:14.116198','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary '\≈û∫\ÈΩI\"∂:ç\0\r&ê\Í','image/png','SUNNY','Thermal-view-of-the-transformer-core-recorded-at-different-time.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/baseline/b8bc72c1-6501-4d94-b5c2-3ff08e23c488_Thermal-view-of-the-transformer-core-recorded-at-different-time.png',85359,'b8bc72c1-6501-4d94-b5c2-3ff08e23c488_Thermal-view-of-the-transformer-core-recorded-at-different-time.png','BASELINE','2025-10-02 11:26:30.858086','admin',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',NULL),(_binary '\Ã7Å∑¯LK£úyë˙õ\ﬁÒ','image/jpeg',NULL,'T1_faulty_016.jpg','http://localhost:8080/files/46ebff1d-b4f4-4392-b464-72d0582fdc38/inspection/79b8adf1-bf93-4908-9289-8dc509163720_T1_faulty_016.jpg',32713,'79b8adf1-bf93-4908-9289-8dc509163720_T1_faulty_016.jpg','INSPECTION','2025-10-02 05:08:10.380515','Prabath',_binary 'F\Îˇ¥ÙCí¥dr\–X/\‹8',_binary '™\“ÔÖòäMIØy0ìWhT'),(_binary '\‰\nˇ\'nSK\‚ì%∫\‘5`\‰','image/jpeg',NULL,'T10_faulty_001.jpg','http://localhost:8080/files/5cfddbe0-80bc-424a-bdeb-88e05afd1bb5/inspection/a06efbea-ca0e-4d16-886c-0435304e2618_T10_faulty_001.jpg',255567,'a06efbea-ca0e-4d16-886c-0435304e2618_T10_faulty_001.jpg','INSPECTION','2025-10-02 05:39:42.298176','admin',_binary '\\˝\€\‡ÄºBJΩ\Îà\‡Z˝µ',_binary '\—V›üíª@êã®ŒòÜ¥Lº'),(_binary 'Ú\na8\◊OrÜ¶\Í\‡©~','image/png',NULL,'annotated_INS-003_1759470480727.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/432551ff-515d-4bfd-915c-1acda3939766_annotated_INS-003_1759470480727.png',305256,'432551ff-515d-4bfd-915c-1acda3939766_annotated_INS-003_1759470480727.png','INSPECTION','2025-10-03 05:48:00.798336','dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary 'lzAçã6|êò∂\≈'),(_binary 'ı¢z\\ﬂ´I(Ü¶ˆóDìu\√','image/png','SUNNY','T3_normal_001.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/baseline/354c30c9-7d9a-41a2-af17-4ec64ddc9342_T3_normal_001.png',56604,'354c30c9-7d9a-41a2-af17-4ec64ddc9342_T3_normal_001.png','BASELINE','2025-10-02 05:06:53.380115','seed',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',NULL),(_binary '˙V\'%∞´M	¶Ü ë9y¢\»','image/png',NULL,'T5_faulty_001.png','http://localhost:8080/files/f19acb31-c613-4dcb-83df-3b89ba88da3b/inspection/b29c15ec-5bb5-48b2-b06b-dcb32e665c40_T5_faulty_001.png',249741,'b29c15ec-5bb5-48b2-b06b-dcb32e665c40_T5_faulty_001.png','INSPECTION','2025-10-03 05:32:34.024841','dinethra',_binary 'Òö\À1\∆MÀÉ\ﬂ;â∫à\⁄;',_binary 'lzAçã6|êò∂\≈');
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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-03 14:17:10
