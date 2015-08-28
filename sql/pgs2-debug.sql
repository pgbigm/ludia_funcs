-- Load ludia_funcs module
CREATE EXTENSION ludia_funcs;

-- client_min_messages needs to be set to LOG because the debug messages
-- caused by ludia_funcs.enable_debug are output with LOG level.
SET ludia_funcs.enable_debug TO on;
SET client_min_messages TO LOG;

-- Check that the cached normalization result is returned if the argument is
-- the same string as that of the last call of pgs2norm
SET ludia_funcs.norm_cache_limit TO '1kB';
SELECT pgs2norm('あいうカキクｻｼｽ7７⑦Ⅶⅶ');
SELECT pgs2norm('あいうカキクｻｼｽ7７⑦Ⅶⅶ');
SELECT pgs2norm('あいうカキクｻｼｽ7７⑦Ⅶⅶ');

-- Since only the last result is cached, the following second call of pgs2norm
-- cannot return the cached one.
SELECT pgs2norm('ABCDEfghijｋｌｍｎｏＰＱＲＳＴ');
SELECT pgs2norm('あいうカキクｻｼｽ7７⑦Ⅶⅶ');

-- The cached result is returned only when the input string is completely
-- the same as that in the cache.
SELECT pgs2norm('PostgreSQLはデータベースです。');
SELECT pgs2norm('PostgreSQLはデータベースです');
SELECT pgs2norm('ostgreSQLはデータベースです');
SELECT pgs2norm('POSTGRESQLはデータベースです。');

-- If the maximum allowed size of the cache (i.e., norm_cache_size) is
-- too small to store both input and normalized strings, they are not cached.
SELECT pgs2norm(repeat(chr(13088),30) || repeat(chr(13078),30));

-- If norm_cache_size is increased large enough, they are cached.
SET ludia_funcs.norm_cache_limit TO '2kB';
SELECT pgs2norm(repeat(chr(13088),30) || repeat(chr(13078),30));

-- Check that work_mem is used as the maximum allowed size of the cache
-- when norm_cache_size is set to -1.
SET ludia_funcs.norm_cache_limit TO -1;
SET work_mem TO '64kB';
SELECT pgs2norm(repeat(chr(13077),35) || repeat(chr(13183),35));

-- Check that both input and normalized strings are always cached
-- if norm_cache_size is set to 0.
SET ludia_funcs.norm_cache_limit TO 0;
SELECT pgs2norm(string_agg(chr(num), '')) from generate_series(13056, 13143) num;

-- Clean up ludia_funcs module
DROP EXTENSION ludia_funcs;
