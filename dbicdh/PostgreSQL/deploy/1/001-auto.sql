-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Jul 31 19:29:56 2013
-- 
;
--
-- Table: tag.
--
CREATE TABLE "tag" (
  "id" serial NOT NULL,
  "name" character varying(16) NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: user.
--
CREATE TABLE "user" (
  "id" serial NOT NULL,
  "login" character varying(16) NOT NULL,
  "email" character varying(32) NOT NULL,
  "joined" integer NOT NULL,
  "preferences" character varying(128) NOT NULL,
  "password" character(60) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "user_email" UNIQUE ("email"),
  CONSTRAINT "user_login" UNIQUE ("login")
);

;
--
-- Table: bookmark.
--
CREATE TABLE "bookmark" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "url" character varying(256) NOT NULL,
  "title" character varying(128) NOT NULL,
  "description" character varying(1024) NOT NULL,
  "private" integer NOT NULL,
  "read" integer NOT NULL,
  "timestamp" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "bookmark_idx_user_id" on "bookmark" ("user_id");

;
--
-- Table: bookmark_tag.
--
CREATE TABLE "bookmark_tag" (
  "bookmark" integer NOT NULL,
  "tag" integer NOT NULL,
  PRIMARY KEY ("bookmark", "tag")
);
CREATE INDEX "bookmark_tag_idx_bookmark" on "bookmark_tag" ("bookmark");
CREATE INDEX "bookmark_tag_idx_tag" on "bookmark_tag" ("tag");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "bookmark" ADD CONSTRAINT "bookmark_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "user" ("id") DEFERRABLE;

;
ALTER TABLE "bookmark_tag" ADD CONSTRAINT "bookmark_tag_fk_bookmark" FOREIGN KEY ("bookmark")
  REFERENCES "bookmark" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "bookmark_tag" ADD CONSTRAINT "bookmark_tag_fk_tag" FOREIGN KEY ("tag")
  REFERENCES "tag" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
