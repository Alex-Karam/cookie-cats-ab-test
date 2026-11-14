CREATE SCHEMA IF NOT EXISTS cookie_cats_ab_test;
########################################################

CREATE TABLE IF NOT EXISTS cookie_cats_ab_test.players_raw (
    userid TEXT,
    version TEXT,
    sum_gamerounds TEXT,
    retention_1 TEXT,
    retention_7 TEXT
);
########################################################