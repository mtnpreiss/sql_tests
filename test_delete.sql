-- 07.11.2012
-- welche Arbeit leistet delete?
-- http://martinpreiss.blogspot.de/2012/11/notizen-zur-performance-von-delete.html
-- 10046er Trace: execute count = 74 -> 74 Queries im Trace (bzw. 74 Executions)?

-- 8 sec. Warten auf Log-Buffer, 7 Sec. CPU

-- Effekt nologging (mit/ohne archiving)

drop table test_delete;
create table test_delete
as
select rownum id
  from dual
connect by level <= 1000000;

Abgelaufen: 00:00:00.70

exec dbms_stats.gather_table_stats(user, 'TEST_DELETE')

-- Vergleich: Einzelsatz-Delete
create index ix_test_delete on test_delete(id);
begin
for i in 1..1000000 loop
delete from TEST_DELETE where id = i;
end loop;
end;
/

delete from test_delete;

1000000 Zeilen wurden gelöscht.

Abgelaufen: 00:00:16.63

--> Tabelle mit ca. 12 MB
--> 1557 Blocks (laut Statistik in DBA_TABLES)

--> 
--> > 100MB undo

NAME                                                         VALUE_BEGIN  VALUE_END       DIFF
------------------------------------------------------------ ----------- ---------- ----------
redo size                                                      237433608  474678404  237244796 <-- mehr als 200 MB redo!
undo change vector size                                        104039508  208034448  103994940 <-- mehr als 100 MB undo!
physical read bytes                                             15867904   28622848   12754944 <-- 1557 * 8192
physical read total bytes                                       16195584   28950528   12754944 <-- 1557 * 8192
physical IO disk bytes                                          41156608   53911552   12754944 <-- 1557 * 8192
cell physical IO interconnect bytes                             41156608   53911552   12754944 <-- 1557 * 8192
db block changes                                                 2021328    4040969    2019641
session logical reads                                            1072020    2111804    1039784
db block gets                                                    1042949    2080859    1037910
db block gets from cache                                         1039902    2077812    1037910
table scan rows gotten                                           1035663    2073158    1037495
redo entries                                                     1007505    2013778    1006273
HSC Heap Segment Block Changes                                   1000082    2000082    1000000 <-- HSC: Heap Segment Compression??
--> https://blogs.oracle.com/db/entry/master_note_for_oltp_compression
--> Total number of block changes to Tables/Heaps (Compressed or Non-Compressed)

buffer is pinned count                                           1015258    2013735     998477
session pga memory                                               7570516    7504980     -65536
IMU undo allocation size                                           64444     128440      63996
--> IMU in memory undo
--> nur bis 64 K aktiv
free buffer requested                                              16756      32997      16241
free buffer inspected                                              16737      31933      15196
calls to kcmgas                                                    14907      29589      14682
redo subscn max counts                                             13253      26418      13165
redo ordering marks                                                13205      26360      13155
IMU Redo allocation size                                           10768      21156      10388
consistent gets                                                    29071      30945       1874
consistent gets from cache                                         29062      30936       1874
no work - consistent read gets                                     23259      24978       1719
consistent gets from cache (fastpath)                              23097      24783       1686
DB time                                                             1907       3575       1668
table scan blocks gotten                                            1604       3185       1581
physical reads cache                                                1928       3485       1557
physical reads                                                      1937       3494       1557
commit cleanouts                                                    1654       3177       1523
switch current to new buffer                                        1587       3110       1523
commit cleanouts successfully completed                             1650       3173       1523
physical reads cache prefetch                                       1448       2893       1445
bytes received via SQL*Net from client                             13644      14802       1158

-- Zeiten
redo log space wait time                                             563       1382        819
--> > 8 sec. Wartezeit für Platz im Log Buffer (http://www.idevelopment.info/data/Oracle/DBA_tips/Tuning/TUNING_6.shtml)
CPU used by this session                                             961       1734        773
CPU used when call started                                           961       1734        773
change write time                                                    195        360        165
user I/O wait time                                                   241        287         46
parse time elapsed                                                    88        107         19
parse time cpu                                                        21         24          3
recursive cpu usage                                                   71         73          2

bytes sent via SQL*Net to client                                   20480      21234        754
recursive calls                                                    34595      35238        643
prefetch warmup blocks aged out before use                           245        747        502
buffer is not pinned count                                         10214      10550        336
messages sent                                                        296        562        266
db block gets from cache (fastpath)                                  885       1089        204
pinned buffers inspected                                             200        392        192
calls to get snapshot scn: kcmgss                                   3557       3711        154
enqueue releases                                                     772        912        140
enqueue requests                                                     774        914        140
physical read total IO requests                                      505        617        112
physical read IO requests                                            485        597        112
opened cursors cumulative                                           2324       2399         75
parse count (total)                                                 1459       1534         75
execute count                                                       2736       2810         74
session cursor cache hits                                           2162       2233         71
index scans kdiixs1                                                 2270       2340         70
table fetch by rowid                                                3348       3418         70
shared hash latch upgrades - no wait                                 286        354         68
hot buffers moved to head of LRU                                    3994       4055         61
physical read total multi block requests                              23         47         24
redo log space requests                                               16         33         17
--> 17 Waits für Platz im Log-Buffer

redo buffer allocation retries                                        17         33         16
consistent gets - examination                                       5277       5285          8
user calls                                                            72         78          6
SQL*Net roundtrips to/from client                                     51         55          4
write clones created in foreground                                     5          8          3
parse count (hard)                                                   248        250          2
dirty buffers inspected                                                5          7          2
CCursor + sql area evicted                                             0          2          2
sql area evicted                                                       0          2          2
index fetch by key                                                  1260       1262          2
rows fetched via callback                                            697        699          2
session cursor cache count                                            49         50          1
sorts (memory)                                                       823        824          1
table scans (short tables)                                            28         29          1
IMU Flushes                                                            3          4          1
redo synch writes                                                      7          8          1
user commits                                                           7          8          1
table scans (long tables)                                              1          2          1