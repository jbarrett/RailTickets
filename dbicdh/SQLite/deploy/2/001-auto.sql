-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Aug 15 13:54:30 2013
-- 

;
BEGIN TRANSACTION;
--
-- Table: tag
--
CREATE TABLE tag (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(16) NOT NULL
);
--
-- Table: user
--
CREATE TABLE user (
  id INTEGER PRIMARY KEY NOT NULL,
  login varchar(16) NOT NULL,
  email varchar(32) NOT NULL,
  joined integer NOT NULL,
  preferences varchar(128) NOT NULL,
  activated integer NOT NULL,
  password char(60) NOT NULL
);
CREATE UNIQUE INDEX user_email ON user (email);
CREATE UNIQUE INDEX user_login ON user (login);
--
-- Table: bookmark
--
CREATE TABLE bookmark (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  url varchar(256) NOT NULL,
  title varchar(128) NOT NULL,
  description varchar(1024) NOT NULL,
  private integer NOT NULL,
  read integer NOT NULL,
  timestamp integer NOT NULL,
  FOREIGN KEY (user_id) REFERENCES user(id)
);
CREATE INDEX bookmark_idx_user_id ON bookmark (user_id);
--
-- Table: bookmark_tag
--
CREATE TABLE bookmark_tag (
  bookmark integer NOT NULL,
  tag integer NOT NULL,
  PRIMARY KEY (bookmark, tag),
  FOREIGN KEY (bookmark) REFERENCES bookmark(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (tag) REFERENCES tag(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX bookmark_tag_idx_bookmark ON bookmark_tag (bookmark);
CREATE INDEX bookmark_tag_idx_tag ON bookmark_tag (tag);
COMMIT;
