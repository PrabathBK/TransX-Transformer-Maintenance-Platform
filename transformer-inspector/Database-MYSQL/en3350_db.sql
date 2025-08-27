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
-- Table structure for table `inspections`
--

DROP TABLE IF EXISTS `inspections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspections` (
  `id` binary(16) NOT NULL,
  `branch` varchar(255) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `inspected_by` varchar(255) NOT NULL,
  `inspection_date` date NOT NULL,
  `inspection_no` varchar(255) NOT NULL,
  `inspection_time` time(6) NOT NULL,
  `maintenance_date` date DEFAULT NULL,
  `maintenance_time` time(6) DEFAULT NULL,
  `notes` varchar(2048) DEFAULT NULL,
  `status` enum('COMPLETED','IN_PROGRESS','PENDING') NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `transformer_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKdd9p95vu842eqnl7na60jbupr` (`transformer_id`),
  CONSTRAINT `FKdd9p95vu842eqnl7na60jbupr` FOREIGN KEY (`transformer_id`) REFERENCES `transformers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspections`
--

LOCK TABLES `inspections` WRITE;
/*!40000 ALTER TABLE `inspections` DISABLE KEYS */;
INSERT INTO `inspections` VALUES (_binary '/¿\í³a\ÓM\í ¿|ûP—','Piliyandala','2025-08-27 10:00:57.300477','Prabath','2025-08-27','02','11:00:00.000000',NULL,NULL,NULL,'IN_PROGRESS','2025-08-27 10:00:57.300489',_binary '½*ÁœP_A‚‘4@Zwm]'),(_binary '<‘;P\Ì.MÈ‚a•ô\×?i','Aralganvila','2025-08-27 10:00:17.858670','Prabath','2025-08-27','01','09:00:00.000000',NULL,NULL,NULL,'IN_PROGRESS','2025-08-27 10:00:17.858688',_binary 'É¬™ŸcCˆ®Ë¦´«ÿ¼Z');
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
INSERT INTO `thermal_images` VALUES (_binary '4Ï‰‹¨ÿOØ™µŒ\0’\ïž','image/webp','CLOUDY','Screenshot-2023-12-12-174147.webp','http://localhost:8080/files/bd2ac19c-505f-4182-9134-405a11776d5d/baseline/72f7b181-f86e-4a35-a4be-6cc6926ff73a_Screenshot-2023-12-12-174147.webp',73508,'72f7b181-f86e-4a35-a4be-6cc6926ff73a_Screenshot-2023-12-12-174147.webp','BASELINE','2025-08-23 18:14:11.815318','admin',_binary '½*ÁœP_A‚‘4@Zwm]',NULL),(_binary 'L·‹JÊ¹;<É4:p','image/webp','CLOUDY','250-kva-electric-transformer-500x500.jpeg.webp','http://localhost:8080/files/d822a5c4-da88-485b-9313-f040543d1bdd/baseline/e9a2b5e0-e7d0-4c6a-8276-dc1554e7ae45_250-kva-electric-transformer-500x500.jpeg.webp',15888,'e9a2b5e0-e7d0-4c6a-8276-dc1554e7ae45_250-kva-electric-transformer-500x500.jpeg.webp','BASELINE','2025-08-27 09:59:31.458943','admin',_binary '\Ø\"¥\ÄÚˆH[“ð@T=\Ý',NULL),(_binary '­\éi\Z @±‹¨9\×7Š¾','image/webp','CLOUDY','Screenshot-2023-12-12-174147.webp','http://localhost:8080/files/1b706c90-42cd-4e7c-8b7f-64eb15acbcd8/baseline/b71601cd-e000-48fd-b7b9-73f8c4c9968c_Screenshot-2023-12-12-174147.webp',73508,'b71601cd-e000-48fd-b7b9-73f8c4c9968c_Screenshot-2023-12-12-174147.webp','BASELINE','2025-08-27 09:59:17.104514','admin',_binary 'plB\ÍN|‹d\ë¬¼\Ø',NULL),(_binary '\ã\èiðwC!€†W\é#^','image/webp',NULL,'4-benefits-of-an-isolation-transformer.jpg.webp','http://localhost:8080/files/bd2ac19c-505f-4182-9134-405a11776d5d/inspection/cebf15d6-8e6a-46f4-8d3e-0d21bc222c1e_4-benefits-of-an-isolation-transformer.jpg.webp',106496,'cebf15d6-8e6a-46f4-8d3e-0d21bc222c1e_4-benefits-of-an-isolation-transformer.jpg.webp','INSPECTION','2025-08-27 10:01:09.271916','Prabath',_binary '½*ÁœP_A‚‘4@Zwm]',_binary '/¿\í³a\ÓM\í ¿|ûP—'),(_binary '\ç“=3\ÛúK ™Å´§ƒ©0\r','image/webp','SUNNY','4-benefits-of-an-isolation-transformer.jpg.webp','http://localhost:8080/files/c9ac0699-9f63-4388-aecb-a6b4abffbc5a/baseline/5cf5cc4c-71a7-451f-8269-d0da00df5245_4-benefits-of-an-isolation-transformer.jpg.webp',106496,'5cf5cc4c-71a7-451f-8269-d0da00df5245_4-benefits-of-an-isolation-transformer.jpg.webp','BASELINE','2025-08-27 09:58:33.497004','admin',_binary 'É¬™ŸcCˆ®Ë¦´«ÿ¼Z',NULL);
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
INSERT INTO `transformers` VALUES (_binary 'plB\ÍN|‹d\ë¬¼\Ø',300,'TX-003','2025-08-27 09:50:54.625260','Thannekumbura','Near the Bridge','EN-134','Kandy','Bulk','2025-08-27 09:50:54.625274'),(_binary '½*ÁœP_A‚‘4@Zwm]',500,'TX-002','2025-08-23 18:12:45.755074','Piliyandala','junction','EN-122-9','Maharagama','Bulk','2025-08-23 18:14:33.467785'),(_binary 'É¬™ŸcCˆ®Ë¦´«ÿ¼Z',300,'TX-001','2025-08-27 09:58:20.016700','Aralaganvila',NULL,'EN-167','Polonnaruwa','Bulk','2025-08-27 09:58:20.016797'),(_binary '\Ø\"¥\ÄÚˆH[“ð@T=\Ý',200,'TX-004','2025-08-27 09:52:03.740230','Kathukurunda',NULL,'EN-156','Kalutara','Bulk','2025-08-27 09:52:03.740265');
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

-- Dump completed on 2025-08-27 15:33:47
