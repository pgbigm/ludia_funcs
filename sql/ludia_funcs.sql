\pset null '(null)'

-- Load ludia_funcs module
LOAD '$libdir/ludia_funcs';
CREATE EXTENSION ludia_funcs;

SET standard_conforming_strings TO off;
SET escape_string_warning TO off;

-- pgs2snippet1() checks
SET ludia_funcs.escape_snippet_keyword TO on;

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\"', '\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"￥"', '\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"￥"', '￥');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\"', '￥');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"""', '"');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"”"', '"');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"”"', '”');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"""', '”');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\"', '\\\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\\\"', '\\\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\\\"', '\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"""', '""');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""""', '""');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""""', '"');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\"', 'あ\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\"', '\\あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"あ\\"', 'あ\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\あ"', '\\あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"あ\\"', '\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\あ"', '\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"あ\\"', 'あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\あ"', 'あ');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"""', 'あ"');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"""', '"あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"あ""', 'あ"');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""あ"', '"あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"あ""', '"');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""あ"', '"');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"あ""', 'あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""あ"', 'あ');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う\\え"', 'う\\え');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う\\"', 'う\\え');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\え"', 'う\\え');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\"', 'う\\え');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う\\え"', 'うえ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う\\"', 'うえ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\え"', 'うえ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う\\え"', 'う');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う"え"', 'う"え');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う""', 'う"え');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""え"', 'う"え');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"""', 'う"え');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う"え"', 'うえ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う""', 'うえ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""え"', 'うえ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"う"え"', 'う');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\\\"', 'あいう\\えお');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\\\"', 'あいう\\\\えお');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\""', 'あいう"えお');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"\\""', 'あいう\\"えお');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"+"', '+');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"+"', 'あいう+えお');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""+"', 'あいう"+えお');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"-"', '-');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"-"', 'あいう-えお');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""-"', 'あいう"-えお');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '" え"', 'あいう えお');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"" え"', 'あいう" えお');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '', 'あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, 'あ', '');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""', 'あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"あ"', '');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '+', '+"\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"', '+"\\');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '\\', '+"\\');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""', 'あ');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '""', 'あ', 1);

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"+"BB"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"+""B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"+"+B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"+"\\B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A""+"BB"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A""+""B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A""+"+B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A""+"\\B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A+"+"BB"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A+"+""B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A+"+"+B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A+"+"\\B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A\\"+"BB"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A\\"+""B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A\\"+"+B"', 'AA"A+A\\B+B"BB');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"A\\"+"\\B"', 'AA"A+A\\B+B"BB');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AB"CD"', 'AB"CD');
SET ludia_funcs.escape_snippet_keyword TO off;
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AB"CD"', 'AB"CD');

SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A" + "BBB" + "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A" + "BBB"   "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A" + "BBB" - "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A"   "BBB" + "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A"   "BBB"   "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A"   "BBB" - "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A" - "BBB" + "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A" - "BBB"   "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA\\"A" - "BBB" - "CCC"', 'AA"ABBBCCCDDDEEE');

SET ludia_funcs.escape_snippet_keyword TO on;
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A" + "BBB" + "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A" + "BBB"   "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A" + "BBB" - "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A"   "BBB" + "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A"   "BBB"   "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A"   "BBB" - "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A" - "BBB" + "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A" - "BBB"   "CCC"', 'AA"ABBBCCCDDDEEE');
SELECT pgs2snippet1(1, 300, 1, '@', '@', 0, '"AA"A" - "BBB" - "CCC"', 'AA"ABBBCCCDDDEEE');

SELECT pgs2snippet1(1,300,1,'∇','∇',0,NULL,'あｲうｴおａbｃdｅかｷくｹこjｋlｍn');
SELECT pgs2snippet1(1,300,1,'∇','∇',0,'あｲうｴおａbｃdｅかｷくｹこjｋlｍn',NULL);
SELECT pgs2snippet1(1,300,1,'∇','∇',0,'エおA','あｲうｴおａbｃdｅかｷくｹこjｋlｍn');
SELECT pgs2snippet1(1,300,1,'∇','∇',0,'えおA','あｲうｴおａbｃdｅかｷくｹこjｋlｍn');

SELECT pgs2snippet1(1,300,1,'∇','∇',0,'エおA',repeat(chr(13078),10) || chr(65018) || 'あｲうｴおａbｃdｅ' || chr(65018) || repeat(chr(13078),10) || 'かｷくｹこjｋlｍn' || chr(65018) || repeat(chr(13078),10));
SELECT pgs2snippet1(1,300,1,'∇','∇',0,'""' || chr(13078) || chr(65018) || 'かキ""',chr(65018) || 'あｲうｴおａbｃdｅ' || chr(65018) || repeat(chr(13078),10) || 'かｷくｹこjｋlｍn' || chr(65018)||repeat(chr(13078),10));
SELECT pgs2snippet1(1,300,1,'∇','∇',0,'"' || chr(13078) || chr(65018) || 'abｶ'|| '"','"' || repeat(chr(13078),10) || chr(65018) || 'あｲうｴおａbｃdｅ' || chr(65018) || repeat(chr(13078),10) || 'かｷくｹこjｋlｍn' || chr(65018) || repeat(chr(13078),10) || '"');
SELECT pgs2snippet1(1,3000,1,'∇','∇',0,'"' || chr(13078) || chr(65018) || '"','"' || repeat(chr(13078),10)|| repeat(chr(65018),10) || '"');
SELECT pgs2snippet1(1,3000,1,'∇','∇',0,'"' || repeat(chr(13078),10) || repeat(chr(65018),10) || '"','"' || chr(13078) || chr(65018)|| '"');

SELECT pgs2snippet1(1,300,1,'∇','∇',0,repeat('x',300),'abcde');
SELECT pgs2snippet1(1,300,1,'∇','∇',0,repeat('+',300),'+');
SELECT pgs2snippet1(1,300,1,'∇','∇',0,'エおA','あｲうｴおａbｃdｅかｷくｹこjｋlｍn') FROM generate_series(1,10);

-- pgs2norm() checks
SELECT pgs2norm(NULL);

SELECT count(pgs2norm(chr(code))) FROM generate_series(1, 55295) code;
SELECT count(pgs2norm(chr(code))) FROM generate_series(57344, 1114111) code;

SELECT pgs2norm('あｲうｴおａbｃdｅかｷくｹこｊkｌmｎ') FROM generate_series(1,10);

SELECT pgs2norm(repeat(chr(13078),10) || chr(65018) || 'あｲうｴおａbｃdｅ' || chr(65018) || repeat(chr(13078),10) || 'かｷくｹこjｋlｍn' || chr(65018) || repeat(chr(13078),10));
SELECT pgs2norm(repeat(chr(13078),10) || chr(65018) || repeat(chr(13078),10) || chr(65018) || repeat(chr(13078),10));
SELECT pgs2norm(repeat(chr(8279),8));
