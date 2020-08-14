-- MySQL dump 10.13  Distrib 8.0.20, for Linux (x86_64)
--
-- Host: localhost    Database: govwifi_test
-- ------------------------------------------------------
-- Server version	8.0.20

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `accountage`
--

DROP TABLE IF EXISTS `accountage`;
/*!50001 DROP VIEW IF EXISTS `accountage`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `accountage` AS SELECT
                                         1 AS `username`,
                                         1 AS `lastlogon`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `activation`
--

DROP TABLE IF EXISTS `activation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activation` (
                              `site_id` int DEFAULT NULL,
                              `dailycode` char(6) DEFAULT NULL,
                              `contact` varchar(100) DEFAULT NULL,
                              `activated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activation`
--

LOCK TABLES `activation` WRITE;
/*!40000 ALTER TABLE `activation` DISABLE KEYS */;
/*!40000 ALTER TABLE `activation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `building_identifiers`
--

DROP TABLE IF EXISTS `building_identifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `building_identifiers` (
                                        `id` int NOT NULL AUTO_INCREMENT,
                                        `building_id` int DEFAULT NULL,
                                        `identifier` varchar(20) DEFAULT NULL,
                                        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                        `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                        PRIMARY KEY (`id`),
                                        UNIQUE KEY `building_id` (`building_id`,`identifier`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `building_identifiers`
--

LOCK TABLES `building_identifiers` WRITE;
/*!40000 ALTER TABLE `building_identifiers` DISABLE KEYS */;
/*!40000 ALTER TABLE `building_identifiers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buildings`
--

DROP TABLE IF EXISTS `buildings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `buildings` (
                             `id` int NOT NULL AUTO_INCREMENT,
                             `site_id` int DEFAULT NULL,
                             `dpo_id` int DEFAULT NULL,
                             `address` varchar(200) DEFAULT NULL,
                             `postcode` varchar(10) DEFAULT NULL,
                             `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buildings`
--

LOCK TABLES `buildings` WRITE;
/*!40000 ALTER TABLE `buildings` DISABLE KEYS */;
/*!40000 ALTER TABLE `buildings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bulk_registration_emails`
--

DROP TABLE IF EXISTS `bulk_registration_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bulk_registration_emails` (
                                            `id` int NOT NULL AUTO_INCREMENT,
                                            `bulk_registration_id` int NOT NULL,
                                            `contact_email` varchar(100) DEFAULT NULL,
                                            `email_sent` tinyint(1) DEFAULT '0',
                                            `email_sent_at` timestamp NULL DEFAULT NULL,
                                            `failed` tinyint(1) DEFAULT '0',
                                            `last_failed_at` timestamp NULL DEFAULT NULL,
                                            PRIMARY KEY (`id`),
                                            KEY `bulk_registration_emails_contact_email` (`contact_email`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4782 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bulk_registration_emails`
--

LOCK TABLES `bulk_registration_emails` WRITE;
/*!40000 ALTER TABLE `bulk_registration_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `bulk_registration_emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bulk_registrations`
--

DROP TABLE IF EXISTS `bulk_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bulk_registrations` (
                                      `id` int NOT NULL AUTO_INCREMENT,
                                      `org_id` int NOT NULL,
                                      `sponsor_name` varchar(100) DEFAULT NULL,
                                      `sponsor_email` varchar(100) DEFAULT NULL,
                                      `batch_size` int DEFAULT NULL,
                                      `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                      PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bulk_registrations`
--

LOCK TABLES `bulk_registrations` WRITE;
/*!40000 ALTER TABLE `bulk_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `bulk_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dpos`
--

DROP TABLE IF EXISTS `dpos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dpos` (
                        `id` int NOT NULL AUTO_INCREMENT,
                        `name` varchar(50) DEFAULT NULL,
                        `address` varchar(200) DEFAULT NULL,
                        `email` varchar(100) DEFAULT NULL,
                        `phone` varchar(100) DEFAULT NULL,
                        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dpos`
--

LOCK TABLES `dpos` WRITE;
/*!40000 ALTER TABLE `dpos` DISABLE KEYS */;
/*!40000 ALTER TABLE `dpos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `environments`
--

DROP TABLE IF EXISTS `environments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `environments` (
                                `id` int NOT NULL AUTO_INCREMENT,
                                `name` varchar(100) DEFAULT NULL,
                                `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                                `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `environments`
--

LOCK TABLES `environments` WRITE;
/*!40000 ALTER TABLE `environments` DISABLE KEYS */;
/*!40000 ALTER TABLE `environments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `first_logons_per_user`
--

DROP TABLE IF EXISTS `first_logons_per_user`;
/*!50001 DROP VIEW IF EXISTS `first_logons_per_user`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `first_logons_per_user` AS SELECT
                                                    1 AS `username`,
                                                    1 AS `firstlogon`,
                                                    1 AS `created_at`,
                                                    1 AS `timediff`,
                                                    1 AS `minutes`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `journey_types`
--

DROP TABLE IF EXISTS `journey_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journey_types` (
                                 `id` int NOT NULL AUTO_INCREMENT,
                                 `name` varchar(100) DEFAULT NULL,
                                 `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                                 `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `journey_types`
--

LOCK TABLES `journey_types` WRITE;
/*!40000 ALTER TABLE `journey_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `journey_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
                            `ap` char(17) DEFAULT NULL,
                            `location` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!50001 DROP VIEW IF EXISTS `logs`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `logs` AS SELECT
                                   1 AS `start`,
                                   1 AS `stop`,
                                   1 AS `shortname`,
                                   1 AS `username`,
                                   1 AS `contact`,
                                   1 AS `sponsor`,
                                   1 AS `InMB`,
                                   1 AS `OutMB`,
                                   1 AS `mac`,
                                   1 AS `ap`,
                                   1 AS `name`,
                                   1 AS `org_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
                                 `id` varchar(36) DEFAULT NULL,
                                 `reference` varchar(200) DEFAULT NULL,
                                 `email_address` varchar(100) DEFAULT NULL,
                                 `phone_number` varchar(100) DEFAULT NULL,
                                 `type` varchar(6) DEFAULT NULL,
                                 `status` varchar(15) DEFAULT NULL,
                                 `template_version` varchar(10) DEFAULT NULL,
                                 `template_id` varchar(36) DEFAULT NULL,
                                 `template_uri` varchar(100) DEFAULT NULL,
                                 `body` varchar(1024) DEFAULT NULL,
                                 `subject` varchar(100) DEFAULT NULL,
                                 `created_at` DATETIME DEFAULT NULL,
                                 `sent_at` DATETIME DEFAULT NULL,
                                 `completed_at` DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `org_admin`
--

DROP TABLE IF EXISTS `org_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `org_admin` (
                             `org_id` int DEFAULT NULL,
                             `name` varchar(30) DEFAULT NULL,
                             `email` varchar(80) NOT NULL,
                             `mobile` varchar(30) DEFAULT NULL,
                             `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `org_admin`
--

LOCK TABLES `org_admin` WRITE;
/*!40000 ALTER TABLE `org_admin` DISABLE KEYS */;
/*!40000 ALTER TABLE `org_admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `organisation`
--

DROP TABLE IF EXISTS `organisation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `organisation` (
                                `id` int NOT NULL AUTO_INCREMENT,
                                `name` varchar(300) DEFAULT NULL,
                                `notifications` varchar(80) DEFAULT NULL,
                                `email_manager_address` varchar(80) DEFAULT NULL,
                                `mou_signed` tinyint(1) DEFAULT '0',
                                `mou_signed_at` timestamp NULL DEFAULT NULL,
                                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organisation`
--

LOCK TABLES `organisation` WRITE;
/*!40000 ALTER TABLE `organisation` DISABLE KEYS */;
/*!40000 ALTER TABLE `organisation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `orgs_admins_view`
--

DROP TABLE IF EXISTS `orgs_admins_view`;
/*!50001 DROP VIEW IF EXISTS `orgs_admins_view`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `orgs_admins_view` AS SELECT
                                               1 AS `id`,
                                               1 AS `orgname`,
                                               1 AS `email_manager_address`,
                                               1 AS `name`,
                                               1 AS `email`,
                                               1 AS `mobile`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `session` (
                           `start` timestamp NULL DEFAULT NULL,
                           `stop` timestamp NULL DEFAULT NULL,
                           `siteIP` char(15) DEFAULT NULL,
                           `username` char(6) DEFAULT NULL,
                           `InMB` int unsigned DEFAULT NULL,
                           `OutMB` int unsigned DEFAULT NULL,
                           `mac` char(17) DEFAULT NULL,
                           `ap` char(17) DEFAULT NULL,
                           `building_identifier` varchar(20) DEFAULT NULL,
                           KEY `siteIP` (`siteIP`,`username`),
                           KEY `sessions_username` (`username`),
                           KEY `sessions_start_username` (`start`,`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site`
--

DROP TABLE IF EXISTS `site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site` (
                        `id` int NOT NULL AUTO_INCREMENT,
                        `radkey` varchar(48) DEFAULT NULL,
                        `kioskkey` char(5) DEFAULT NULL,
                        `datacontroller` varchar(100) DEFAULT NULL,
                        `address` varchar(200) DEFAULT NULL,
                        `postcode` varchar(10) DEFAULT NULL,
                        `activation_regex` varchar(100) DEFAULT NULL,
                        `activation_days` int DEFAULT NULL,
                        `org_id` int DEFAULT NULL,
                        `site_manager_id` int DEFAULT NULL,
                        `dailycode` char(5) DEFAULT NULL,
                        `dailycodedate` smallint DEFAULT NULL,
                        `hidden` tinyint(1) NOT NULL DEFAULT '0',
                        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=436 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site`
--

LOCK TABLES `site` WRITE;
/*!40000 ALTER TABLE `site` DISABLE KEYS */;
/*!40000 ALTER TABLE `site` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_managers`
--

DROP TABLE IF EXISTS `site_managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_managers` (
                                 `id` int NOT NULL AUTO_INCREMENT,
                                 `managing_org_id` int DEFAULT NULL,
                                 `department_id` int DEFAULT NULL,
                                 `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_managers`
--

LOCK TABLES `site_managers` WRITE;
/*!40000 ALTER TABLE `site_managers` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_managers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `siteip`
--

DROP TABLE IF EXISTS `siteip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `siteip` (
                          `ip` char(15) NOT NULL,
                          `site_id` int DEFAULT NULL,
                          `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          PRIMARY KEY (`ip`),
                          KEY `siteip_site_id` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `siteip`
--

LOCK TABLES `siteip` WRITE;
/*!40000 ALTER TABLE `siteip` DISABLE KEYS */;
/*!40000 ALTER TABLE `siteip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sourceip`
--

DROP TABLE IF EXISTS `sourceip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sourceip` (
                            `min` int unsigned DEFAULT NULL,
                            `max` int unsigned DEFAULT NULL,
                            `site_id` int DEFAULT NULL,
                            KEY `minip` (`min`) USING BTREE,
                            KEY `maxip` (`max`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sourceip`
--

LOCK TABLES `sourceip` WRITE;
/*!40000 ALTER TABLE `sourceip` DISABLE KEYS */;
/*!40000 ALTER TABLE `sourceip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_logs`
--

DROP TABLE IF EXISTS `survey_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_logs` (
                               `id` int NOT NULL AUTO_INCREMENT,
                               `survey_setting_id` int NOT NULL,
                               `username` varchar(10) NOT NULL,
                               `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                               `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                               PRIMARY KEY (`id`),
                               KEY `survey_logs_survey_setting_id` (`survey_setting_id`) USING BTREE,
                               KEY `survey_logs_username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=102121 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_logs`
--

LOCK TABLES `survey_logs` WRITE;
/*!40000 ALTER TABLE `survey_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_settings`
--

DROP TABLE IF EXISTS `survey_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_settings` (
                                   `id` int NOT NULL AUTO_INCREMENT,
                                   `survey_id` int NOT NULL,
                                   `journey_type_id` int NOT NULL,
                                   `min_delay_minutes` int NOT NULL,
                                   `max_delay_minutes` int NOT NULL,
                                   `survey_url` varchar(100) NOT NULL,
                                   `email_subject` varchar(100) DEFAULT NULL,
                                   `email_template` varchar(100) DEFAULT NULL,
                                   `text_template` varchar(100) DEFAULT NULL,
                                   `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                                   `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                   PRIMARY KEY (`id`),
                                   KEY `survey_settings_survey_id` (`survey_id`) USING BTREE,
                                   KEY `survey_settings_journey_type_id` (`journey_type_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_settings`
--

LOCK TABLES `survey_settings` WRITE;
/*!40000 ALTER TABLE `survey_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `survey_settings_view`
--

DROP TABLE IF EXISTS `survey_settings_view`;
/*!50001 DROP VIEW IF EXISTS `survey_settings_view`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `survey_settings_view` AS SELECT
                                                   1 AS `survey_name`,
                                                   1 AS `survey_active`,
                                                   1 AS `environment_name`,
                                                   1 AS `survey_type`,
                                                   1 AS `journey_type`,
                                                   1 AS `survey_setting_id`,
                                                   1 AS `min_delay_minutes`,
                                                   1 AS `max_delay_minutes`,
                                                   1 AS `survey_url`,
                                                   1 AS `email_subject`,
                                                   1 AS `email_template`,
                                                   1 AS `text_template`,
                                                   1 AS `created_at`,
                                                   1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `survey_types`
--

DROP TABLE IF EXISTS `survey_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_types` (
                                `id` int NOT NULL AUTO_INCREMENT,
                                `name` varchar(100) DEFAULT NULL,
                                `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                                `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_types`
--

LOCK TABLES `survey_types` WRITE;
/*!40000 ALTER TABLE `survey_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `surveys`
--

DROP TABLE IF EXISTS `surveys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `surveys` (
                           `id` int NOT NULL AUTO_INCREMENT,
                           `environment_id` int NOT NULL,
                           `name` varchar(100) DEFAULT NULL,
                           `active` tinyint(1) NOT NULL DEFAULT '0',
                           `survey_type_id` int NOT NULL,
                           `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                           `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           PRIMARY KEY (`id`),
                           KEY `surveys_environment_id` (`environment_id`) USING BTREE,
                           KEY `surveys_survey_type_id` (`survey_type_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `surveys`
--

LOCK TABLES `surveys` WRITE;
/*!40000 ALTER TABLE `surveys` DISABLE KEYS */;
/*!40000 ALTER TABLE `surveys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_infile`
--

DROP TABLE IF EXISTS `temp_infile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_infile` (
                               `bulk_registration_id` int NOT NULL,
                               `contact_email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_infile`
--

LOCK TABLES `temp_infile` WRITE;
/*!40000 ALTER TABLE `temp_infile` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_infile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_infile_hmt`
--

DROP TABLE IF EXISTS `temp_infile_hmt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_infile_hmt` (
                                   `displayname` varchar(100) DEFAULT NULL,
                                   `Lastname` varchar(100) DEFAULT NULL,
                                   `firstname` varchar(100) DEFAULT NULL,
                                   `alias` varchar(100) DEFAULT NULL,
                                   `contact_email` varchar(100) DEFAULT NULL,
                                   `hidden` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_infile_hmt`
--

LOCK TABLES `temp_infile_hmt` WRITE;
/*!40000 ALTER TABLE `temp_infile_hmt` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_infile_hmt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_infile_mrc`
--

DROP TABLE IF EXISTS `temp_infile_mrc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_infile_mrc` (
    `contact_email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_infile_mrc`
--

LOCK TABLES `temp_infile_mrc` WRITE;
/*!40000 ALTER TABLE `temp_infile_mrc` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_infile_mrc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_infile_nibsc`
--

DROP TABLE IF EXISTS `temp_infile_nibsc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_infile_nibsc` (
    `contact_email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_infile_nibsc`
--

LOCK TABLES `temp_infile_nibsc` WRITE;
/*!40000 ALTER TABLE `temp_infile_nibsc` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_infile_nibsc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_last_logins`
--

DROP TABLE IF EXISTS `user_last_logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_last_logins` (
                                    `username` varchar(10) NOT NULL,
                                    `last_login` datetime DEFAULT NULL,
                                    PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_last_logins`
--

LOCK TABLES `user_last_logins` WRITE;
/*!40000 ALTER TABLE `user_last_logins` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_last_logins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userdetails`
--

DROP TABLE IF EXISTS `userdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `userdetails` (
                               `username` varchar(10) NOT NULL DEFAULT '',
                               `contact` varchar(100) DEFAULT NULL,
                               `sponsor` varchar(100) DEFAULT NULL,
                               `password` varchar(64) DEFAULT NULL,
                               `email` varchar(100) DEFAULT NULL,
                               `mobile` varchar(20) DEFAULT NULL,
                               `notifications_opt_out` tinyint(1) NOT NULL DEFAULT '0',
                               `survey_opt_out` tinyint(1) NOT NULL DEFAULT '0',
                               `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                               `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                               `last_login` datetime DEFAULT NULL,
                               PRIMARY KEY (`username`),
                               KEY `userdetails_created_at` (`created_at`),
                               KEY `userdetails_contact` (`contact`),
                               KEY `userdetails_last_login` (`last_login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userdetails`
--

LOCK TABLES `userdetails` WRITE;
/*!40000 ALTER TABLE `userdetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `userdetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
                         `id` varchar(36) DEFAULT NULL,
                         `name` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('534fea88-d830-11ea-ab7a-0242ac180002','Andromeda');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verify`
--

DROP TABLE IF EXISTS `verify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verify` (
                          `code` char(6) NOT NULL,
                          `email` varchar(100) DEFAULT NULL,
                          `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                          PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verify`
--

LOCK TABLES `verify` WRITE;
/*!40000 ALTER TABLE `verify` DISABLE KEYS */;
/*!40000 ALTER TABLE `verify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `accountage`
--

/*!50001 DROP VIEW IF EXISTS `accountage`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
    /*!50013 DEFINER=`MK6FC8F8V282XCD`@`%` SQL SECURITY DEFINER */
    /*!50001 VIEW `accountage` AS select `userdetails`.`username` AS `username`,max(`session`.`start`) AS `lastlogon` from (`userdetails` join `session`) where (`userdetails`.`username` = `session`.`username`) group by `userdetails`.`username` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `first_logons_per_user`
--

/*!50001 DROP VIEW IF EXISTS `first_logons_per_user`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
    /*!50013 DEFINER=`MK6FC8F8V282XCD`@`%` SQL SECURITY DEFINER */
    /*!50001 VIEW `first_logons_per_user` AS select `userlogons`.`username` AS `username`,`userlogons`.`firstlogon` AS `firstlogon`,`userlogons`.`created_at` AS `created_at`,timediff(`userlogons`.`firstlogon`,`userlogons`.`created_at`) AS `timediff`,((hour(timediff(`userlogons`.`firstlogon`,`userlogons`.`created_at`)) * 60) + minute(timediff(`userlogons`.`firstlogon`,`userlogons`.`created_at`))) AS `minutes` from (select `s1`.`username` AS `username`,(select min(`s2`.`start`) from `session` `s2` where (`s1`.`username` = `s2`.`username`)) AS `firstlogon`,`userdetails`.`created_at` AS `created_at` from (`userdetails` left join `session` `s1` on((`userdetails`.`username` = `s1`.`username`))) where (`s1`.`username` is not null) group by `s1`.`username`) `userlogons` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `logs`
--

/*!50001 DROP VIEW IF EXISTS `logs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
    /*!50013 DEFINER=`MK6FC8F8V282XCD`@`%` SQL SECURITY DEFINER */
    /*!50001 VIEW `logs` AS select `session`.`start` AS `start`,`session`.`stop` AS `stop`,`site`.`address` AS `shortname`,`session`.`username` AS `username`,`userdetails`.`contact` AS `contact`,`userdetails`.`sponsor` AS `sponsor`,`session`.`InMB` AS `InMB`,`session`.`OutMB` AS `OutMB`,`session`.`mac` AS `mac`,`session`.`ap` AS `ap`,`organisation`.`name` AS `name`,`site`.`org_id` AS `org_id` from ((((`session` left join `siteip` on((`siteip`.`ip` = `session`.`siteIP`))) left join `site` on((`siteip`.`site_id` = `site`.`id`))) left join `organisation` on((`site`.`org_id` = `organisation`.`id`))) left join `userdetails` on((`session`.`username` = `userdetails`.`username`))) order by `session`.`start` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `orgs_admins_view`
--

/*!50001 DROP VIEW IF EXISTS `orgs_admins_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
    /*!50013 DEFINER=`MK6FC8F8V282XCD`@`%` SQL SECURITY DEFINER */
    /*!50001 VIEW `orgs_admins_view` AS select `organisation`.`id` AS `id`,`organisation`.`name` AS `orgname`,`organisation`.`email_manager_address` AS `email_manager_address`,`org_admin`.`name` AS `name`,`org_admin`.`email` AS `email`,`org_admin`.`mobile` AS `mobile` from (`organisation` join `org_admin`) where (`organisation`.`id` = `org_admin`.`org_id`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `survey_settings_view`
--

/*!50001 DROP VIEW IF EXISTS `survey_settings_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
    /*!50013 DEFINER=`MK6FC8F8V282XCD`@`%` SQL SECURITY DEFINER */
    /*!50001 VIEW `survey_settings_view` AS select `surveys`.`name` AS `survey_name`,`surveys`.`active` AS `survey_active`,`environments`.`name` AS `environment_name`,`survey_types`.`name` AS `survey_type`,`journey_types`.`name` AS `journey_type`,`survey_settings`.`id` AS `survey_setting_id`,`survey_settings`.`min_delay_minutes` AS `min_delay_minutes`,`survey_settings`.`max_delay_minutes` AS `max_delay_minutes`,`survey_settings`.`survey_url` AS `survey_url`,`survey_settings`.`email_subject` AS `email_subject`,`survey_settings`.`email_template` AS `email_template`,`survey_settings`.`text_template` AS `text_template`,`survey_settings`.`created_at` AS `created_at`,`survey_settings`.`updated_at` AS `updated_at` from ((((`survey_settings` left join `surveys` on((`survey_settings`.`survey_id` = `surveys`.`id`))) left join `environments` on((`surveys`.`environment_id` = `environments`.`id`))) left join `survey_types` on((`surveys`.`survey_type_id` = `survey_types`.`id`))) left join `journey_types` on((`survey_settings`.`journey_type_id` = `journey_types`.`id`))) */;
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

-- Dump completed on 2020-08-06 22:10:37
