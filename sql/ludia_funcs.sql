LOAD '$libdir/ludia_funcs';
CREATE EXTENSION ludia_funcs;

SET standard_conforming_strings TO off;
SET escape_string_warning TO off;

\pset null '(null)'

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
