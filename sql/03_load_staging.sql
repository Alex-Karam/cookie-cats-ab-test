LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cookie_cats.csv'
INTO TABLE cookie_cats_ab_test.players_raw
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(userid, version, sum_gamerounds, retention_1, retention_7);
########################################################
