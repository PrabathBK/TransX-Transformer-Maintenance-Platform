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
INSERT INTO `inspections` VALUES (_binary '[)ì3£iC(ç§¶´\·\‡Q\ ','Wilgamuwa','2025-08-27 10:34:31.060523','Prabath','2025-08-28','03','09:00:00.000000',NULL,NULL,NULL,'PENDING','2025-08-27 10:34:48.615428',_binary 'q®Éb8@C∫ÚZ(ZA∏'),(_binary 'âˇ\¬˚0@HÜöl11:Jg•','Nugegoda','2025-08-27 16:50:54.798912','Dinethra','2025-08-27','000654234','07:00:00.000000','2025-08-28','14:24:00.000000',NULL,'IN_PROGRESS','2025-08-27 16:50:54.798912',_binary '\"\ÍXB\Î^Dmál\‘,¡*Û\Ÿ');
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
INSERT INTO `thermal_images` VALUES (_binary 'HôÙû\·ãC)ÖßE\Ô\ƒ\›\…\·','image/webp',NULL,'Screenshot-2023-12-12-174147.webp','http://localhost:8080/files/71a8831b-6238-4043-baf2-5a28035a41b8/inspection/b6636ac8-15c2-412e-baad-19ffc579d697_Screenshot-2023-12-12-174147.webp',73508,'b6636ac8-15c2-412e-baad-19ffc579d697_Screenshot-2023-12-12-174147.webp','INSPECTION','2025-08-27 10:34:45.458630','Prabath',_binary 'q®Éb8@C∫ÚZ(ZA∏',_binary '[)ì3£iC(ç§¶´\·\‡Q\ '),(_binary 'L∑ùãêJ π;<…ç4:p','image/webp','CLOUDY','250-kva-electric-transformer-500x500.jpeg.webp','http://localhost:8080/files/d822a5c4-da88-485b-9313-f040543d1bdd/baseline/e9a2b5e0-e7d0-4c6a-8276-dc1554e7ae45_250-kva-electric-transformer-500x500.jpeg.webp',15888,'e9a2b5e0-e7d0-4c6a-8276-dc1554e7ae45_250-kva-electric-transformer-500x500.jpeg.webp','BASELINE','2025-08-27 09:59:31.458943','admin',_binary '\ÿ\"•\ƒ⁄àH[ì@T=\›',NULL),(_binary '\\\‰Úî\‰˙Göö˝Ω¶\ŒOöu','image/jpeg','CLOUDY','images.jpeg','http://localhost:8080/files/22ea5842-eb5e-446d-876c-d42cc12af3d9/baseline/4878714c-df21-4698-b055-cc30eeada7ec_images.jpeg',6363,'4878714c-df21-4698-b055-cc30eeada7ec_images.jpeg','BASELINE','2025-08-27 16:47:08.241121','admin',_binary '\"\ÍXB\Î^Dmál\‘,¡*Û\Ÿ',NULL),(_binary 'Å\0≠;öD‘ú\ÕÒ¨\ÕW=','image/webp','SUNNY','250-kva-electric-transformer-500x500.jpeg.webp','http://localhost:8080/files/78ac221d-a96c-4334-821c-0456c521d2f9/baseline/dbf274d5-290c-4062-8cac-c2b20b4c55a0_250-kva-electric-transformer-500x500.jpeg.webp',15888,'dbf274d5-290c-4062-8cac-c2b20b4c55a0_250-kva-electric-transformer-500x500.jpeg.webp','BASELINE','2025-08-27 10:33:58.794901','admin',_binary 'x¨\"©lC4ÇV\≈!\“˘',NULL),(_binary '≠\Èi\Z†@±ã®9\◊7äæ','image/webp','CLOUDY','Screenshot-2023-12-12-174147.webp','http://localhost:8080/files/1b706c90-42cd-4e7c-8b7f-64eb15acbcd8/baseline/b71601cd-e000-48fd-b7b9-73f8c4c9968c_Screenshot-2023-12-12-174147.webp',73508,'b71601cd-e000-48fd-b7b9-73f8c4c9968c_Screenshot-2023-12-12-174147.webp','BASELINE','2025-08-27 09:59:17.104514','admin',_binary 'plêB\ÕN|ãd\Î¨º\ÿ',NULL),(_binary '∞<ı8\‡∑MçØ3.h•.\Ÿ\Á','image/jpeg',NULL,'ima.jpeg','http://localhost:8080/files/22ea5842-eb5e-446d-876c-d42cc12af3d9/inspection/058c6b48-c302-4ec4-86d0-0674c721e2c8_ima.jpeg',7494,'058c6b48-c302-4ec4-86d0-0674c721e2c8_ima.jpeg','INSPECTION','2025-08-27 16:51:41.022277','Dinethra',_binary '\"\ÍXB\Î^Dmál\‘,¡*Û\Ÿ',_binary 'âˇ\¬˚0@HÜöl11:Jg•'),(_binary 'º \Œ°æA*ö/n\◊}®','image/webp','CLOUDY','tran.webp','http://localhost:8080/files/22ea5842-eb5e-446d-876c-d42cc12af3d9/baseline/910f4287-7431-4ac0-b99a-edd887f25993_tran.webp',58736,'910f4287-7431-4ac0-b99a-edd887f25993_tran.webp','BASELINE','2025-08-27 16:47:40.048997','admin',_binary '\"\ÍXB\Î^Dmál\‘,¡*Û\Ÿ',NULL),(_binary '\◊a£\›9K∆ì*ªm6†´','image/webp','CLOUDY','4-benefits-of-an-isolation-transformer.jpg.webp','http://localhost:8080/files/71a8831b-6238-4043-baf2-5a28035a41b8/baseline/4a3bcbea-3933-4f8d-a8a7-be51210f4810_4-benefits-of-an-isolation-transformer.jpg.webp',106496,'4a3bcbea-3933-4f8d-a8a7-be51210f4810_4-benefits-of-an-isolation-transformer.jpg.webp','BASELINE','2025-08-27 10:33:45.346504','admin',_binary 'q®Éb8@C∫ÚZ(ZA∏',NULL);
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
INSERT INTO `transformers` VALUES (_binary 'plêB\ÕN|ãd\Î¨º\ÿ',300,'TX-003','2025-08-27 09:50:54.625260','Thannekumbura','Near the Bridge','EN-134','Kandy','Bulk','2025-08-27 09:50:54.625274'),(_binary '\"\ÍXB\Î^Dmál\‘,¡*Û\Ÿ',500,'TX-002','2025-08-27 16:46:12.202305','Piliyandala','junction','EN-122-9','Maharagama','Bulk','2025-08-27 16:46:21.498260'),(_binary 'q®Éb8@C∫ÚZ(ZA∏',350,'TX-005','2025-08-27 10:33:32.697239','Hettipola','Town','EN-177','Matale','Distribution','2025-08-27 10:33:32.697251'),(_binary 'x¨\"©lC4ÇV\≈!\“˘',400,'TX-001','2025-08-27 10:33:02.405830','Aralaganvila',NULL,'EN-125','Polonnaruwa','Bulk','2025-08-27 10:33:02.405841'),(_binary '\ÿ\"•\ƒ⁄àH[ì@T=\›',200,'TX-004','2025-08-27 09:52:03.740230','Kathukurunda',NULL,'EN-156','Kalutara','Bulk','2025-08-27 09:52:03.740265');
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

-- Dump completed on 2025-08-27 22:23:46
