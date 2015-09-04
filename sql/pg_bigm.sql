\pset null '(null)'

-- Load pg_bigm and ludia_funcs
CREATE EXTENSION pg_bigm;
CREATE EXTENSION ludia_funcs;

-- Set parameters for the tests
SET standard_conforming_strings TO off;
SET escape_string_warning TO off;
SET work_mem = '4MB';
SET enable_seqscan TO off;
SET enable_bitmapscan TO on;

-- Test the case where the columns with CHAR data type were indexed
-- with pg_bigm and pgs2norm function.
CREATE TABLE char_tbl (col1 char(256), col2 char(256), col3 char(256));
\copy char_tbl from data/test_tbl.txt
CREATE INDEX char_tbl_idx ON char_tbl USING gin (pgs2norm(col1) gin_bigm_ops,
                                                                   pgs2norm(col2) gin_bigm_ops,
                                                                   pgs2norm(col3) gin_bigm_ops);

SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'v(株)', col1) FROM char_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('v(株)'));
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, '②⓪', col1) FROM char_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('②⓪'));
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'ｱﾌﾟﾘｹｰｼｮﾝ', col1) FROM char_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱﾌﾟﾘｹｰｼｮﾝ'));

-- Test the case where the columns with VARCHAR data type were indexed
-- with pg_bigm and pgs2norm function.
CREATE TABLE varchar_tbl (col1 varchar(256), col2 varchar(256), col3 varchar(256));
\copy varchar_tbl from data/test_tbl.txt
CREATE INDEX varchar_tbl_idx ON varchar_tbl USING gin (pgs2norm(col1) gin_bigm_ops,
                                                                           pgs2norm(col2) gin_bigm_ops,
                                                                           pgs2norm(col3) gin_bigm_ops);

SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'v(株)', col1) FROM varchar_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('v(株)'));
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, '②⓪', col1) FROM varchar_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('②⓪'));
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'ｱﾌﾟﾘｹｰｼｮﾝ', col1) FROM varchar_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱﾌﾟﾘｹｰｼｮﾝ'));

-- Test the case where the columns with TEXT data type were indexed
-- with pg_bigm and pgs2norm function.
CREATE TABLE text_tbl (col1 text, col2 text, col3 text);
\copy text_tbl from data/test_tbl.txt
CREATE INDEX text_tbl_idx ON text_tbl USING gin (pgs2norm(col1) gin_bigm_ops,
                                                                  pgs2norm(col2) gin_bigm_ops,
                                                                  pgs2norm(col3) gin_bigm_ops);

SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'v(株)', col1) FROM text_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('v(株)'));
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, '②⓪', col1) FROM text_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('②⓪'));
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'ｱﾌﾟﾘｹｰｼｮﾝ', col1) FROM text_tbl
			 WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱﾌﾟﾘｹｰｼｮﾝ'));

-- Test the case where a multi-column index is created on many columns
CREATE TABLE mc31_tbl (col1 text, col2 char(256), col3 varchar(256), col4 text,
			 col5 char(256), col6 varchar(256), col7 text, col8 char(256),
			 col9 varchar(256), col10 text, col11 char(256), col12 varchar(256),
			 col13 text, col14 char(256), col15 varchar(256), col16 text,
			 col17 char(256), col18 varchar(256), col19 text, col20 char(256),
			 col21 varchar(256), col22 text, col23 char(256), col24 varchar(256),
			 col25 text, col26 char(256), col27 varchar(256), col28 text,
			 col29 char(256), col30 varchar(256), col31 text);
CREATE INDEX mc31_tbl_idx ON mc31_tbl USING gin (pgs2norm(col1) gin_bigm_ops,
			 pgs2norm(col2) gin_bigm_ops, pgs2norm(col3) gin_bigm_ops,
			 pgs2norm(col4) gin_bigm_ops, pgs2norm(col5) gin_bigm_ops,
			 pgs2norm(col6) gin_bigm_ops, pgs2norm(col7) gin_bigm_ops,
			 pgs2norm(col8) gin_bigm_ops, pgs2norm(col9) gin_bigm_ops,
			 pgs2norm(col10) gin_bigm_ops, pgs2norm(col11) gin_bigm_ops,
			 pgs2norm(col12) gin_bigm_ops, pgs2norm(col13) gin_bigm_ops,
			 pgs2norm(col14) gin_bigm_ops, pgs2norm(col15) gin_bigm_ops,
			 pgs2norm(col16) gin_bigm_ops, pgs2norm(col17) gin_bigm_ops,
			 pgs2norm(col18) gin_bigm_ops, pgs2norm(col19) gin_bigm_ops,
			 pgs2norm(col20) gin_bigm_ops, pgs2norm(col21) gin_bigm_ops,
			 pgs2norm(col22) gin_bigm_ops, pgs2norm(col23) gin_bigm_ops,
			 pgs2norm(col24) gin_bigm_ops, pgs2norm(col25) gin_bigm_ops,
			 pgs2norm(col26) gin_bigm_ops, pgs2norm(col27) gin_bigm_ops,
			 pgs2norm(col28) gin_bigm_ops, pgs2norm(col29) gin_bigm_ops,
			 pgs2norm(col30) gin_bigm_ops, pgs2norm(col31) gin_bigm_ops);
\copy mc31_tbl from 'data/test_tbl_31.txt'

SELECT col1 FROM mc31_tbl WHERE pgs2norm(col1) like likequery(pgs2norm('＿Ｓ'));
EXPLAIN (costs off ) SELECT col1 FROM mc31_tbl WHERE pgs2norm(col1) like likequery(pgs2norm('＿Ｓ'));

select col15 from mc31_tbl where pgs2norm(col15) like likequery(pgs2norm('ﾃ゛ィ'));
EXPLAIN (costs off ) select col15 from mc31_tbl where pgs2norm(col15) like likequery(pgs2norm('ﾃ゛ィ'));

select col31 from mc31_tbl where pgs2norm(col31) like likequery(pgs2norm('㊔'));
EXPLAIN (costs off) select col31 from mc31_tbl where pgs2norm(col31) like likequery(pgs2norm('㊔'));

-- Test the case where data has a special character like "\t"
CREATE TABLE snp_tbl (col1 text);
CREATE INDEX snp_tbl_idx ON snp_tbl USING gin (pgs2norm(col1) gin_bigm_ops);
INSERT INTO snp_tbl VALUES ('東京都山田太郎');
INSERT INTO snp_tbl VALUES ('東京都 山田太郎');
INSERT INTO snp_tbl VALUES ('東京都山田 太郎');
INSERT INTO snp_tbl VALUES ('東京都 山田 太郎');
INSERT INTO snp_tbl VALUES (E'東京都\t山田太郎');

-- Test whether both seq and bitmap scans return the same results
SET enable_seqscan to on;
SET enable_bitmapscan to off;
SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田太郎'));
SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田太郎'));
SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田 太郎'));
SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'東京都\t山田太郎'));
EXPLAIN (costs off) SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田太郎'));
EXPLAIN (costs off) SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田太郎'));
EXPLAIN (costs off) SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田 太郎'));
EXPLAIN (costs off) SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'東京都\t山田太郎'));

SET enable_seqscan to off;
SET enable_bitmapscan to on;
SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田太郎'));
SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田太郎'));
SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田 太郎'));
SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'東京都\t山田太郎'));
EXPLAIN (costs off) SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田太郎'));
EXPLAIN (costs off) SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田太郎'));
EXPLAIN (costs off) SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田 太郎'));
EXPLAIN (costs off) SELECT * FROM snp_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'東京都\t山田太郎'));
