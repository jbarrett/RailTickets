-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Thu Aug 15 13:54:30 2013
-- 
;
SET foreign_key_checks=0;
--
-- Table: `tag`
--
CREATE TABLE `tag` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(16) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` integer NOT NULL auto_increment,
  `login` varchar(16) NOT NULL,
  `email` varchar(32) NOT NULL,
  `joined` integer NOT NULL,
  `preferences` varchar(128) NOT NULL,
  `activated` integer NOT NULL,
  `password` char(60) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `user_email` (`email`),
  UNIQUE `user_login` (`login`)
) ENGINE=InnoDB;
--
-- Table: `bookmark`
--
CREATE TABLE `bookmark` (
  `id` integer NOT NULL auto_increment,
  `user_id` integer NOT NULL,
  `url` text NOT NULL,
  `title` varchar(128) NOT NULL,
  `description` text NOT NULL,
  `private` integer NOT NULL,
  `read` integer NOT NULL,
  `timestamp` integer NOT NULL,
  INDEX `bookmark_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `bookmark_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB;
--
-- Table: `bookmark_tag`
--
CREATE TABLE `bookmark_tag` (
  `bookmark` integer NOT NULL,
  `tag` integer NOT NULL,
  INDEX `bookmark_tag_idx_bookmark` (`bookmark`),
  INDEX `bookmark_tag_idx_tag` (`tag`),
  PRIMARY KEY (`bookmark`, `tag`),
  CONSTRAINT `bookmark_tag_fk_bookmark` FOREIGN KEY (`bookmark`) REFERENCES `bookmark` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bookmark_tag_fk_tag` FOREIGN KEY (`tag`) REFERENCES `tag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
SET foreign_key_checks=1;
