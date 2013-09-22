-- test_part_index_costing.sql
-- Analyse der Kosten für den Zugriff auf partitionierte Indizes
-- 16.07.2012
-- Ergebnisse unter http://martinpreiss.blogspot.de/2012/07/costing-fur-partitionierte-indizes.html

sehr ähnliche Informationen in den 10053er Trace Files:

geringfügige Abweichungen bei den Statistiken für Tabelle und Index:

-- part
***************************************
BASE STATISTICAL INFORMATION
***********************
Table Stats::
  Table: TEST_PART_INDEX_COST  Alias: TEST_PART_INDEX_COST  (Using composite stats)
    #Rows: 920000  #Blks:  9528  AvgRowLen:  66.00
Index Stats::
  Index: IX_TEST_PART_INDEX_COST  Col#: 3
    USING COMPOSITE STATS
    LVLS: 2  #LB: 19990  #DK: 100  LB/K: 32.00  DB/K: 1533.00  CLUF: 919803.00

-- no part
Table Stats::
  Table: TEST_INDEX_COST  Alias: TEST_INDEX_COST
    #Rows: 920000  #Blks:  10097  AvgRowLen:  66.00
Index Stats::
  Index: IX_TEST_INDEX_COST  Col#: 3
    LVLS: 2  #LB: 19988  #DK: 100  LB/K: 199.00  DB/K: 9198.00  CLUF: 919803.00

	
CF, LVLS, #DK identisch
#LB nahezu identisch
Abweichungen bei den per-key-Angaben: wegen "USING COMPOSITE STATS"

Cost für no part:

select 2 + ceil(19988 * .01)  from dual;

2+CEIL(19988*.01)
-----------------
              202
--> entpricht den Angaben im Trace

  Access Path: index (AllEqRange)
    Index: IX_TEST_INDEX_COST
    resc_io: 202.00  resc_cpu: 3278531
    ix_sel: 0.010000  ix_sel_with_filters: 0.010000 
    Cost: 202.20  Resp: 202.20  Degree: 1

--> der Formelabschnitt	CF * ix_sel_with_filters kann offenbar ignoriert werden, da 
--  kein Tabellenzugriff erforderlich ist

Die Angabe entspricht fast genau der Buffers-Angabe (203) des xplan

Cost für part:

SQL> select 2 + ceil(19990 * .01)  from dual;

2+CEIL(19990*.01)
-----------------
              202
--> also der Formel nach die gleichen Kosten wie für den no-part-Fall

Frage: wo kommen die 212 her, die der CBO berechnet?

  Access Path: index (AllEqRange)
    Index: IX_TEST_PART_INDEX_COST
    resc_io: 212.00  resc_cpu: 3349745
    ix_sel: 0.010000  ix_sel_with_filters: 0.010000 
    Cost: 212.20  Resp: 212.20  Degree: 1

-- 202 + (5 zusätzliche part-Index-Zugriffe	* 2 Ebenen: Root, Branch)

--> plausibel: demnach sollten alle Index-Zugriffe im Beispiel für die partitionierte Tabelle um 10 teueren sein
--> passt für Beispiel:
select count(*) from test_part_index_cost where col1 <  3;
609 zu 619

-- tatsächlich werden 220 Buffer-Zugriffe benötigt
-- Statistiken möglicherweise nicht völlig akkurat:
		 
SQL> select * from index_stats;

    HEIGHT     BLOCKS NAME                                                         PARTITION_NAME                    LF_ROWS    LF_BLKS LF_ROWS_LEN LF_BLK_LEN    BR_ROWS    BR_BLKS BR_ROWS_LEN BR_BLK_LEN DEL_LF_ROWS DEL_LF_ROWS_LEN DISTINCT_KEYS MOST_REPEATED_KEY BTREE_SPACE USED_SPACE   PCT_USED ROWS_PER_KEY BLKS_GETS_PER_ACCESS   PRE_ROWS PRE_ROWS_LEN OPT_CMPR_COUNT OPT_CMPR_PCTSAVE
---------- ---------- ------------------------------------------------------------ ------------------------------ ---------- ---------- ----------- ---------- ---------- ---------- ----------- ---------- ----------- --------------- ------------- ----------------- ----------- ---------- ---------- ------------ -------------------- ---------- ------------ -------------- ----------------
         3      20736 IX_TEST_INDEX_COST                                                                              920000      19988    12870800       8000      19987         36      279444       8032           0               0           100              9200   160193152   13150244          9         9200               4603,5          0            0              1               20

Abgelaufen: 00:00:00.12
SQL> analyze index IX_TEST_PART_INDEX_COST validate structure;

Index wurde analysiert.

Abgelaufen: 00:00:04.21
SQL> select * from index_stats;

    HEIGHT     BLOCKS NAME                                                         PARTITION_NAME                    LF_ROWS    LF_BLKS LF_ROWS_LEN LF_BLK_LEN    BR_ROWS    BR_BLKS BR_ROWS_LEN BR_BLK_LEN DEL_LF_ROWS DEL_LF_ROWS_LEN DISTINCT_KEYS MOST_REPEATED_KEY BTREE_SPACE USED_SPACE   PCT_USED ROWS_PER_KEY BLKS_GETS_PER_ACCESS   PRE_ROWS PRE_ROWS_LEN OPT_CMPR_COUNT OPT_CMPR_PCTSAVE
---------- ---------- ------------------------------------------------------------ ------------------------------ ---------- ---------- ----------- ---------- ---------- ---------- ----------- ---------- ----------- --------------- ------------- ----------------- ----------- ---------- ---------- ------------ -------------------- ---------- ------------ -------------- ----------------
         3       3456 IX_TEST_PART_INDEX_COST                                      P201212                            155000       3368     2168450       8000       3367          7       47103       8032           0               0           100              1550    27000224    2215553          9         1550                778,5          0            0              1               20
--> Analyze für alle Partitionen

SQL> select (4 * 3368) +(2 * 3259) from dual;

(4*3368)+(2*3259)
-----------------
            19990

--> Erklärung bei Hotsos?
--> http://www.hotsos.com/e-library/abstract.php?id=158			
		 