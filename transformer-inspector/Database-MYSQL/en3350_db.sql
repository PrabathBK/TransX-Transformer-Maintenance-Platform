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
INSERT INTO `thermal_images` VALUES (_binary '4œâã®ˇOÿôµå\0í\Ôû','image/webp','CLOUDY','Screenshot-2023-12-12-174147.webp','http://localhost:8080/files/bd2ac19c-505f-4182-9134-405a11776d5d/baseline/72f7b181-f86e-4a35-a4be-6cc6926ff73a_Screenshot-2023-12-12-174147.webp',73508,'72f7b181-f86e-4a35-a4be-6cc6926ff73a_Screenshot-2023-12-12-174147.webp','BASELINE','2025-08-23 18:14:11.815318','admin',_binary 'Ω*¡úP_AÇë4@Zwm]'),(_binary '\\pZßãAYîNõØ∏\€Q£','image/jpeg','SUNNY','Small-Power-Transformer-NEW.jpg','http://localhost:8080/files/6239f52a-3e3b-4405-8e9e-495ccb5bac0b/baseline/7e856318-9a31-4906-8dcd-59e001b4f25d_Small-Power-Transformer-NEW.jpg',85500,'7e856318-9a31-4906-8dcd-59e001b4f25d_Small-Power-Transformer-NEW.jpg','BASELINE','2025-08-23 09:23:53.789343','admin',_binary 'b9ı*>;DéûI\\\À[¨'),(_binary 'rMz\Â_\œFÅ¥$|\…vY','image/jpeg','CLOUDY','distortion2.jpg','http://localhost:8080/files/6239f52a-3e3b-4405-8e9e-495ccb5bac0b/baseline/686ce379-8911-4b15-ab97-91ce0b94ed29_distortion2.jpg',3899,'686ce379-8911-4b15-ab97-91ce0b94ed29_distortion2.jpg','BASELINE','2025-08-23 09:15:10.250054','admin',_binary 'b9ı*>;DéûI\\\À[¨'),(_binary '\Â∑zy\ÎH˝™,\‹c+e|','image/webp','SUNNY','4-benefits-of-an-isolation-transformer.jpg.webp','http://localhost:8080/files/39f30d6d-e745-4529-ad62-27e0fb3caa91/baseline/9bb1a00c-dfe4-4095-93ca-adeb5f3034bd_4-benefits-of-an-isolation-transformer.jpg.webp',106496,'9bb1a00c-dfe4-4095-93ca-adeb5f3034bd_4-benefits-of-an-isolation-transformer.jpg.webp','BASELINE','2025-08-23 19:21:39.741930','admin',_binary '9Û\rm\ÁEE)≠b\'\‡˚<™ë'),(_binary '\Î\‘\Â\Ï\'AN6ïñ\◊?5.CÅ','image/webp','CLOUDY','250-kva-electric-transformer-500x500.jpeg.webp','http://localhost:8080/files/3a4d2f24-773d-4f05-8bfe-45df1b730749/baseline/061e46c0-887d-476c-a8bb-3630c225e31e_250-kva-electric-transformer-500x500.jpeg.webp',15888,'061e46c0-887d-476c-a8bb-3630c225e31e_250-kva-electric-transformer-500x500.jpeg.webp','BASELINE','2025-08-23 20:01:39.125348','admin',_binary ':M/$w=Oã˛E\ﬂsI'),(_binary 'ˆ˚\«=\Œ-A¸£\·Ù\0O \ÿ','image/webp','SUNNY','three-phase-electric-transfomer-500x500.jpg.webp','http://localhost:8080/files/65783b81-c8ef-4b77-a60e-0b514b3dfee7/baseline/6d4c82ab-0e00-47ab-848c-95a132bd5fbb_three-phase-electric-transfomer-500x500.jpg.webp',22642,'6d4c82ab-0e00-47ab-848c-95a132bd5fbb_three-phase-electric-transfomer-500x500.jpg.webp','BASELINE','2025-08-23 20:00:07.630146','admin',_binary 'ex;Å\»\ÔKw¶QK=˛\Á');
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
INSERT INTO `transformers` VALUES (_binary '9Û\rm\ÁEE)≠b\'\‡˚<™ë',500,'TX-003','2025-08-23 19:20:06.436408','Nawala',NULL,'EN-122-6','Nugegoda','Bulk','2025-08-23 19:20:06.436464'),(_binary ':M/$w=Oã˛E\ﬂsI',200,'TX-004','2025-08-23 20:00:50.709263','Beliaththa',NULL,'EN-134','Hambantota','Distribution','2025-08-23 20:00:50.709313'),(_binary 'b9ı*>;DéûI\\\À[¨',1000,'TC-005','2025-08-23 09:14:50.606264','Colombo','Test Transformer','EN-155-A','Maharagama','Distribution','2025-08-23 19:18:27.005402'),(_binary 'ex;Å\»\ÔKw¶QK=˛\Á',650,'TX-001','2025-08-23 19:59:42.408275','KKR',NULL,'EN-123','Jaffna','Bulk','2025-08-23 19:59:42.408287'),(_binary 'Ω*¡úP_AÇë4@Zwm]',500,'TX-002','2025-08-23 18:12:45.755074','Piliyandala','junction','EN-122-9','Maharagama','Bulk','2025-08-23 18:14:33.467785');
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

-- Dump completed on 2025-08-24  1:36:47
