\pset null '(null)'

-- Load pg_bigm and ludia_funcs
CREATE EXTENSION pg_bigm;
CREATE EXTENSION ludia_funcs;

-- Set parameters for the tests
SET client_min_messages TO LOG;
SET standard_conforming_strings TO off;
SET escape_string_warning TO off;
SET work_mem = '4MB';
SET maintenance_work_mem TO '512MB';
SET enable_seqscan TO off;
SET enable_bitmapscan TO on;

-- Test the case where the columns with CHAR data type were indexed
-- with pg_bigm and pgs2norm function.
CREATE TABLE char_tbl (col1 char(256), col2 char(256), col3 char(256));
\copy char_tbl from data/test_tbl.txt
CREATE INDEX char_tbl_idx ON char_tbl USING gin (pgs2norm(col1) gin_bigm_ops,
                                                                   pgs2norm(col2) gin_bigm_ops,
                                                                   pgs2norm(col3) gin_bigm_ops)
                                                                   WITH (FASTUPDATE = off);

SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'v(株)', col1) FROM char_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('v(株)'))
    ORDER BY col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, '②⓪', col1) FROM char_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('②⓪'))
    ORDER BY col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'ｱﾌﾟﾘｹｰｼｮﾝ', col1) FROM char_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱﾌﾟﾘｹｰｼｮﾝ'))
    ORDER BY col1;

-- Test the case where the columns with VARCHAR data type were indexed
-- with pg_bigm and pgs2norm function.
CREATE TABLE varchar_tbl (col1 varchar(256), col2 varchar(256), col3 varchar(256));
\copy varchar_tbl from data/test_tbl.txt
CREATE INDEX varchar_tbl_idx ON varchar_tbl USING gin (pgs2norm(col1) gin_bigm_ops,
                                                                           pgs2norm(col2) gin_bigm_ops,
                                                                           pgs2norm(col3) gin_bigm_ops)
                                                                           WITH (FASTUPDATE = off);

SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'v(株)', col1) FROM varchar_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('v(株)'))
    ORDER BY col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, '②⓪', col1) FROM varchar_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('②⓪'))
    ORDER BY col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'ｱﾌﾟﾘｹｰｼｮﾝ', col1) FROM varchar_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱﾌﾟﾘｹｰｼｮﾝ'))
    ORDER BY col1;

-- Test the case where the columns with TEXT data type were indexed
-- with pg_bigm and pgs2norm function.
CREATE TABLE text_tbl (col1 text, col2 text, col3 text);
\copy text_tbl from data/test_tbl.txt
CREATE INDEX text_tbl_idx ON text_tbl USING gin (pgs2norm(col1) gin_bigm_ops,
                                                                  pgs2norm(col2) gin_bigm_ops,
                                                                  pgs2norm(col3) gin_bigm_ops)
                                                                  WITH (FASTUPDATE = off);

SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'v(株)', col1) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('v(株)'))
    ORDER BY col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, '②⓪', col1) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('②⓪'))
    ORDER BY col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'ｱﾌﾟﾘｹｰｼｮﾝ', col1) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱﾌﾟﾘｹｰｼｮﾝ'))
    ORDER BY col1;

-- Test the case where condition has "AND".
SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col1) LIKE likequery(pgs2norm('解釈')) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('実装')) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('場合'));
EXPLAIN (costs off) SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col1) LIKE likequery(pgs2norm('解釈')) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('実装')) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('場合'));
SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col1) LIKE likequery(pgs2norm('解釈')) AND
    pgs2norm(col2) LIKE likequery(pgs2norm('ﾕｰｻ゛')) AND
    pgs2norm(col3) LIKE likequery(pgs2norm('ＳｑＬ'));
EXPLAIN (costs off) SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col1) LIKE likequery(pgs2norm('解釈')) AND
    pgs2norm(col2) LIKE likequery(pgs2norm('ﾕｰｻ゛')) AND
    pgs2norm(col3) LIKE likequery(pgs2norm('ＳｑＬ'));

-- Test the case where condition has "OR".
SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col2) LIKE likequery(pgs2norm('ﾊ゜ラメータ')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('㉜')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('  '));
EXPLAIN (costs off) SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col2) LIKE likequery(pgs2norm('ﾊ゜ラメータ')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('㉜')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('  '));
SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col1) LIKE likequery(pgs2norm('ﾊ゜ラメータ')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('㉜')) OR
    pgs2norm(col3) LIKE likequery(pgs2norm('  '));
EXPLAIN (costs off) SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col1) LIKE likequery(pgs2norm('ﾊ゜ラメータ')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('㉜')) OR
    pgs2norm(col3) LIKE likequery(pgs2norm('  '));

-- Test the case where condition has "NOT".
SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col3) LIKE likequery(pgs2norm('ludia')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('㊐')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('Ⓟ'));
EXPLAIN (costs off) SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col3) LIKE likequery(pgs2norm('ludia')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('㊐')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('Ⓟ'));
SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col2) LIKE likequery(pgs2norm('ludia')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('㊐')) AND
    NOT pgs2norm(col1) LIKE likequery(pgs2norm('Ⓟ'));
EXPLAIN (costs off) SELECT count(*) FROM text_tbl WHERE
    pgs2norm(col2) LIKE likequery(pgs2norm('ludia')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('㊐')) AND
    NOT pgs2norm(col1) LIKE likequery(pgs2norm('Ⓟ'));

-- Test for text search with many conditions
SELECT count(*) FROM text_tbl WHERE
    (pgs2norm(col1) LIKE likequery(pgs2norm('文字')) AND
	pgs2norm(col1) LIKE likequery(pgs2norm('無効')) AND
	pgs2norm(col1) NOT LIKE likequery(pgs2norm('設定'))) OR
	(pgs2norm(col2) LIKE likequery(pgs2norm('文字')) AND
	pgs2norm(col2) LIKE likequery(pgs2norm('無効')) AND
	pgs2norm(col2) NOT LIKE likequery(pgs2norm('設定'))) OR
	(pgs2norm(col3) LIKE likequery(pgs2norm('文字')) AND
	pgs2norm(col3) LIKE likequery(pgs2norm('無効')) AND
	pgs2norm(col3) NOT LIKE likequery(pgs2norm('設定')));
EXPLAIN (costs off) SELECT count(*) FROM text_tbl WHERE
    (pgs2norm(col1) LIKE likequery(pgs2norm('文字')) AND
	pgs2norm(col1) LIKE likequery(pgs2norm('無効')) AND
	pgs2norm(col1) NOT LIKE likequery(pgs2norm('設定'))) OR
	(pgs2norm(col2) LIKE likequery(pgs2norm('文字')) AND
	pgs2norm(col2) LIKE likequery(pgs2norm('無効')) AND
	pgs2norm(col2) NOT LIKE likequery(pgs2norm('設定'))) OR
	(pgs2norm(col3) LIKE likequery(pgs2norm('文字')) AND
	pgs2norm(col3) LIKE likequery(pgs2norm('無効')) AND
	pgs2norm(col3) NOT LIKE likequery(pgs2norm('設定')));

-- Test for UPDATE and DELETE
UPDATE text_tbl SET col1 = col2, col2 = col3, col3 = col1;
UPDATE text_tbl SET col1 = col2, col2 = col3, col3 = col1;
UPDATE text_tbl SET col1 = col2, col2 = col3, col3 = col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'v(株)', col1) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('v(株)'))
    ORDER BY col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, '②⓪', col1) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('②⓪'))
    ORDER BY col1;
SELECT pgs2snippet1(1, 32, 1, '★', '★', 0, 'ｱﾌﾟﾘｹｰｼｮﾝ', col1) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱﾌﾟﾘｹｰｼｮﾝ'))
    ORDER BY col1;

-- The text search for updated or deleted records must return no results
-- even when recheck is skipped on the text search.
EXPLAIN (costs off) UPDATE text_tbl SET col1 =
    (select string_agg(chr(num), '') from generate_series(ascii('㋐'), ascii('㋾')) num)
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('㊀'));
UPDATE text_tbl SET col1 =
    (select string_agg(chr(num), '') from generate_series(ascii('㋐'), ascii('㋾')) num)
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('㊀'));
SELECT count(*) FROM text_tbl WHERE pgs2norm(col1) LIKE likequery(pgs2norm('㊀'));
EXPLAIN (costs off) DELETE FROM text_tbl WHERE pgs2norm(col1) like likequery(pgs2norm('⑬'));
DELETE FROM text_tbl WHERE pgs2norm(col1) like likequery(pgs2norm('⑬'));
SELECT count(*) FROM text_tbl WHERE pgs2norm(col1) like likequery(pgs2norm('⑬'));

-- Test whether both seq scan and bitmap scan return the same results
SET enable_seqscan to on;
SET enable_bitmapscan to off;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田 太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'東京都\t山田太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田　太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('京都山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('京都 山田'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('都 山田'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('都 山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('  山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('京都  '))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'都\t'))
    ORDER BY col1;
SELECT count(*) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('　'));
SELECT count(*) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(' '));
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(' 山 '))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ポ'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ﾎﾟ'))
    ORDER BY col1;
SELECT count(*) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('A'));
SELECT count(*) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('a'));
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('AA'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('田'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    OR pgs2norm(col1) LIKE likequery(pgs2norm('ポ'))
    ORDER BY col1;

EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田太郎'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田 太郎'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'東京都\t山田太郎'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('都 山田'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('  山'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'都\t'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('　'))
    ORDER BY col1;

SET enable_seqscan to off;
SET enable_bitmapscan to on;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田 太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'東京都\t山田太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田　太郎'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('京都山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('京都 山田'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('都 山田'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('都 山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('  山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('京都  '))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'都\t'))
    ORDER BY col1;
SELECT count(*) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('　'));
SELECT count(*) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(' '));
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(' 山 '))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ポ'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ﾎﾟ'))
    ORDER BY col1;
SELECT count(*) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('A'));
SELECT count(*) FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('a'));
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('AA'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('田'))
    ORDER BY col1;
SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    OR pgs2norm(col1) LIKE likequery(pgs2norm('ポ'))
    ORDER BY col1;

EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都山田太郎'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都 山田 太郎'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'東京都\t山田太郎'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('都 山田'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('  山'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(E'都\t'))
    ORDER BY col1;
EXPLAIN (costs off) SELECT replace(col1, E'\t', '*') FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('　'))
    ORDER BY col1;

-- Test whether recheck is skipped expectedly when keyword length is 1 or 2
SET ludia_funcs.enable_debug TO on;
SELECT col1 FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都')) ORDER BY col1;
SELECT col1 FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('京都')) ORDER BY col1;
SELECT col1 FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('京')) ORDER BY col1;
SELECT pgs2snippet1(1, 50, 1, '*', '*', 0, '東', col1) FROM text_tbl
    WHERE pgs2norm(col2) LIKE likequery(pgs2norm('東')) ORDER BY col1;
SELECT col1 FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('山'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('京'));
SELECT col1 FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('山田'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('京都'));
SELECT col1 FROM text_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('東京都'))
    AND pgs2norm(col1) LIKE likequery(pgs2norm('太'));
SET ludia_funcs.enable_debug TO off;

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
    pgs2norm(col30) gin_bigm_ops, pgs2norm(col31) gin_bigm_ops)
    WITH (FASTUPDATE = off);
\copy mc31_tbl from 'data/test_tbl_31.txt'

SELECT col1 FROM mc31_tbl
    WHERE pgs2norm(col1) like likequery(pgs2norm('＿Ｓ'))
    ORDER BY col1;
EXPLAIN (costs off ) SELECT col1 FROM mc31_tbl
    WHERE pgs2norm(col1) like likequery(pgs2norm('＿Ｓ'))
    ORDER BY col1;

SELECT col15 FROM mc31_tbl
    WHERE pgs2norm(col15) LIKE likequery(pgs2norm('ﾃ゛ィ'))
    ORDER BY col15;
EXPLAIN (costs off ) SELECT col15 FROM mc31_tbl
    WHERE pgs2norm(col15) LIKE likequery(pgs2norm('ﾃ゛ィ'))
    ORDER BY col15;

SELECT col31 FROM mc31_tbl
    WHERE pgs2norm(col31) LIKE likequery(pgs2norm('㊔'))
    ORDER BY col31;
EXPLAIN (costs off) SELECT col31 FROM mc31_tbl
    WHERE pgs2norm(col31) LIKE likequery(pgs2norm('㊔'))
    ORDER BY col31;

-- Test the cases where various text search patterns are used.
CREATE TABLE abc_tbl (col1 text, col2 text, col3 text);
\copy abc_tbl from data/abc_data.tsv
CREATE INDEX abc_idx ON abc_tbl USING gin
    (pgs2norm(col1) gin_bigm_ops, pgs2norm(col2) gin_bigm_ops, pgs2norm(col3) gin_bigm_ops)
    WITH (FASTUPDATE = off);

SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));
SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));
SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) AND
    pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));
SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));
SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));
SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) OR
    pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));
SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) AND
    pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));
SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) OR
    pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));
SELECT count(*) FROM abc_tbl WHERE
    ((pgs2norm(col1) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col1) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col1) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col2) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col2) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col2) LIKE likequery(pgs2norm('CCC'))) OR
    ((pgs2norm(col3) LIKE likequery(pgs2norm('AAA')) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('BBB'))) AND
    NOT pgs2norm(col3) LIKE likequery(pgs2norm('CCC')));

-- Test whether pg_bigm and pgs2norm can handle all the UTF8 characters
CREATE UNLOGGED TABLE utf8_tbl (code int, col1 text);
INSERT INTO utf8_tbl VALUES (-1, NULL);
INSERT INTO utf8_tbl VALUES (0, '');
INSERT INTO utf8_tbl SELECT code, repeat(chr(code), 3) FROM generate_series(1, 55295) code;
INSERT INTO utf8_tbl SELECT code, repeat(chr(code), 3) FROM generate_series(57344, 1114111) code;
CREATE INDEX utf8_tbl_idx ON utf8_tbl USING gin (pgs2norm(col1) gin_bigm_ops)
    WITH (FASTUPDATE = off);

-- Test for multi-byte, single-byte, upper-case and lower-case alphabet characters
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('aa')) ORDER BY code;
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('BB')) ORDER BY code;
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｃｃ')) ORDER BY code;
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ＤＤ')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('aa')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('BB')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｃｃ')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ＤＤ')) ORDER BY code;

-- Test for multi-byte, single-byte numbers
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('11')) ORDER BY code;
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('２２')) ORDER BY code;
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('③③')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('11')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('２２')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('③③')) ORDER BY code;

-- Test for Japanese katakana
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱｱ')) ORDER BY code;
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('イイ')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('ｱｱ')) ORDER BY code;
EXPLAIN (costs off) SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm('イイ')) ORDER BY code;

-- Text for NULL
SELECT * FROM utf8_tbl
    WHERE pgs2norm(col1) LIKE likequery(pgs2norm(NULL)) ORDER BY code;
