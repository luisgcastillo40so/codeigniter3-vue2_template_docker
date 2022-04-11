-- create user --
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'passw@rd';

-- create database --
CREATE DATABASE IF NOT EXISTS `local_db` CHARACTER SET utf8mb4;
CREATE DATABASE IF NOT EXISTS `test_db` CHARACTER SET utf8mb4;

-- grants privileges to user accounts --
GRANT ALL ON local_db.* TO 'appuser'@'%';
GRANT ALL ON test_db.* TO 'appuser'@'%';
