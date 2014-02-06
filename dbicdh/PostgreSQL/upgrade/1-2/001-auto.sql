-- Convert schema '/home/fuzzix/projects/RailTickets/bin/../dbicdh/_source/deploy/1/001-auto.yml' to '/home/fuzzix/projects/RailTickets/bin/../dbicdh/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE user ADD COLUMN activated integer NOT NULL;

;

COMMIT;

