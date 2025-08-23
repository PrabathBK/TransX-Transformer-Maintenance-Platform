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
  `type` enum('BASELINE','MAINTENANCE') NOT NULL,
  `uploaded_at` datetime(6) DEFAULT NULL,
  `uploader` varchar(255) DEFAULT NULL,
  `transformer_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKnsq63y0cepal10a8rt4twhq2e` (`transformer_id`),
  CONSTRAINT `FKnsq63y0cepal10a8rt4twhq2e` FOREIGN KEY (`transformer_id`) REFERENCES `transformers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thermal_images`
--

LOCK TABLES `thermal_images` WRITE;
/*!40000 ALTER TABLE `thermal_images` DISABLE KEYS */;
INSERT INTO `thermal_images` VALUES (_binary '\\pZ§‹AY”N›¯¸\ÛQ£','image/jpeg','SUNNY','Small-Power-Transformer-NEW.jpg','http://localhost:8080/files/6239f52a-3e3b-4405-8e9e-495ccb5bac0b/baseline/7e856318-9a31-4906-8dcd-59e001b4f25d_Small-Power-Transformer-NEW.jpg',85500,'7e856318-9a31-4906-8dcd-59e001b4f25d_Small-Power-Transformer-NEW.jpg','BASELINE','2025-08-23 09:23:53.789343','admin',_binary 'b9õ*>;DŽžI\\\Ë[¬'),(_binary 'rMz\å_\ÏF´$|\ÉvY','image/jpeg','CLOUDY','distortion2.jpg','http://localhost:8080/files/6239f52a-3e3b-4405-8e9e-495ccb5bac0b/baseline/686ce379-8911-4b15-ab97-91ce0b94ed29_distortion2.jpg',3899,'686ce379-8911-4b15-ab97-91ce0b94ed29_distortion2.jpg','BASELINE','2025-08-23 09:15:10.250054','admin',_binary 'b9õ*>;DŽžI\\\Ë[¬'),(_binary '’§\"\ÒaKÙ°¯Ñ‘À[','image/jpeg','SUNNY','image4.jpg','http://localhost:8080/files/bb249afe-bca2-4076-8cbf-e1e7bb17e92b/baseline/fed6e107-3bea-4201-b410-b565844cba80_image4.jpg',28974,'fed6e107-3bea-4201-b410-b565844cba80_image4.jpg','BASELINE','2025-08-21 04:33:28.431639','seed',_binary '»$šþ¼¢@vŒ¿\á\ç»\é+'),(_binary '±]£K@;¾	0c€\Æó','image/jpeg','CLOUDY','og-large-transformer-pole-mounted.jpg','http://localhost:8080/files/591637b5-3b1a-45b2-91b6-6fddf2603b7c/baseline/6cf4d8b2-5f0d-4deb-a26d-125efa7a396b_og-large-transformer-pole-mounted.jpg',173571,'6cf4d8b2-5f0d-4deb-a26d-125efa7a396b_og-large-transformer-pole-mounted.jpg','BASELINE','2025-08-23 09:24:08.617974','admin',_binary 'Y7µ;\ZE²‘¶o\Ýò`;|'),(_binary '\Ê?(¿#>H:¸³,6\å¨$','image/png','SUNNY','Screenshot 2025-08-19 215858.png','http://localhost:8080/files/591637b5-3b1a-45b2-91b6-6fddf2603b7c/baseline/362ac48e-1f42-41bc-99ad-c420ea4f3dd6_Screenshot 2025-08-19 215858.png',11608,'362ac48e-1f42-41bc-99ad-c420ea4f3dd6_Screenshot 2025-08-19 215858.png','BASELINE','2025-08-23 09:14:14.177615','admin',_binary 'Y7µ;\ZE²‘¶o\Ýò`;|'),(_binary '\ë\Å\æ\r™IRŽúº\Ñ>B\'','image/jpeg','SUNNY','image2.jpg','http://localhost:8080/files/c808c23c-b6a4-4256-b5fe-28c1e82fdcc0/baseline/1e01e917-9abf-400c-8463-8ac2c33262a2_image2.jpg',9852,'1e01e917-9abf-400c-8463-8ac2c33262a2_image2.jpg','BASELINE','2025-08-21 04:33:28.397229','seed',_binary '\È\Â<¶¤BVµþ(Á\è/\ÜÀ');
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
INSERT INTO `transformers` VALUES (_binary 'Y7µ;\ZE²‘¶o\Ýò`;|',1000,'TX-001','2025-08-23 09:13:59.694803','Gampaha','test','EN-144-B','Nugegoda','Bulk','2025-08-23 09:13:59.694803'),(_binary 'b9õ*>;DŽžI\\\Ë[¬',1000,'TC-005','2025-08-23 09:14:50.606264','Colombo','test11','EN-155-A','Maharagama','Distribution','2025-08-23 09:14:50.606264'),(_binary '»$šþ¼¢@vŒ¿\á\ç»\é+',400,'TX-004','2025-08-21 04:33:28.334043','Nugegoda','','EN-124-B','Colombo','Distribution','2025-08-21 04:33:28.334043'),(_binary '\È\Â<¶¤BVµþ(Á\è/\ÜÀ',300,'TX-002','2025-08-21 04:33:28.312820','Hettipola','','EN-122-B','Matale','Distribution','2025-08-21 04:33:28.312820');
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

-- Dump completed on 2025-08-23 15:18:15
