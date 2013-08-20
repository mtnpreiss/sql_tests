-- test_incremental_statistics.sql
-- 05.09.2012
-- Performance der inkrementellen Statistikerfassung
-- ziemlich unsortiertes Material zu http://martinpreiss.blogspot.de/2012/09/inkrementelle-statistiken-fur.html


drop table test_big_part;
create table test_big_part (
    startdate date
  , id number
  , n_col1 number
  , n_col2 number
  , n_col3 number
  , n_col4 number
  , v_col1 varchar2(50)
  , v_col2 varchar2(50)
  , v_col3 varchar2(50)
  , v_col4 varchar2(50)
)
partition by range (startdate)
interval (NUMTODSINTERVAL(1,'DAY'))
(
    partition test_p1 values less than (to_date('20120906', 'yyyymmdd'))
);

insert into test_big_part
with
generator as (
select trunc(sysdate) + mod(rownum, 10) a_date
  from dual
connect by level <= 100
)
,
basedata as (
select rownum id
    , mod(rownum, 2) n_col1
    , mod(rownum, 10) n_col2
    , round(rownum/10) n_col3
    , dbms_random.value * 1000 n_col4
    , lpad('*', 50, '*') v_col1
    , dbms_random.string('a', 1) v_col2
    , dbms_random.string('a', 50) v_col3
    , 'test' v_col4
  from dual
connect by level <= 100000)
select generator.a_date
     , basedata.*
  from generator
     , basedata;

commit;


begin
DBMS_STATS.GATHER_TABLE_STATS ( OwnName        => user
                              , TabName        => 'TEST_BIG_PART'      
                              , PartName       => 'TEST_P1'     
                              , Granularity    => 'PARTITION'     
                              , Method_Opt     => 'FOR ALL COLUMNS SIZE 1'     
);
end;
/

begin
DBMS_STATS.DELETE_TABLE_STATS (OwnName        => user
                              , TabName        => 'TEST_BIG_PART'   
);
end;
/

begin
DBMS_STATS.GATHER_TABLE_STATS ( OwnName        => user
                              , TabName        => 'TEST_BIG_PART'      
                              , Granularity    => 'GLOBAL AND PARTITION'     
                              , Method_Opt     => 'FOR ALL COLUMNS SIZE 1'     
);
end;
/


select table_name
     , num_rows
     , blocks
     , sample_size
     , last_analyzed
     , avg_row_len
     , global_stats
     , user_stats
  from user_tables
 where table_name = 'TEST_BIG_PART';

select partition_name
     , num_rows
     , blocks
     , sample_size
     , last_analyzed
     , avg_row_len
     , global_stats
     , user_stats
     , partition_position
     , high_value
  from dba_tab_partitions
 where table_owner like upper('TEST')
   and table_name = upper('TEST_BIG_PART')
 order by partition_position; 
 

GLOBAL_STATS -> For partitioned tables, indicates whether statistics were collected 
                for the table as a whole (YES) or were estimated from statistics 
                on underlying partitions and subpartitions (NO)

begin
DBMS_STATS.DELETE_TABLE_STATS (OwnName        => user
                              , TabName       => 'TEST_BIG_PART'   
                              , cascade_parts => false
);
end;
/


 exec dbms_stats.set_table_prefs('TEST', 'TEST_BIG_PART', 'INCREMENTAL', 'TRUE');

begin
DBMS_STATS.GATHER_TABLE_STATS ( OwnName        => user
                              , TabName        => 'TEST_BIG_PART'      
                              , Granularity    => 'AUTO'     
                              , Method_Opt     => 'FOR ALL COLUMNS SIZE 1'     
);
end;
/


insert into test_big_part
with
generator as (
select trunc(sysdate) + 10 a_date
  from dual
connect by level <= 10  
)
,
basedata as (
select rownum id
    , mod(rownum, 2) n_col1
    , mod(rownum, 10) n_col2
    , round(rownum/10) n_col3
    , dbms_random.value * 1000 n_col4
    , lpad('*', 50, '*') v_col1
    , dbms_random.string('a', 1) v_col2
    , dbms_random.string('a', 50) v_col3
    , 'test' v_col4
  from dual
connect by level <= 100000)
select generator.a_date
     , basedata.*
  from generator
     , basedata;

commit;


begin
DBMS_STATS.GATHER_TABLE_STATS ( OwnName        => user
                              , TabName        => 'TEST_BIG_PART'      
                              , Granularity    => 'GLOBAL'     
                              , Method_Opt     => 'FOR ALL COLUMNS SIZE 1'     
);
end;
/


http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_stats.htm#i1036461

begin
DBMS_STATS.GATHER_TABLE_STATS ( OwnName        => user
                              , TabName        => 'TEST_BIG_PART'      
                              , Granularity    => 'GLOBAL AND PARTITION'     
                              , Method_Opt     => 'FOR ALL COLUMNS SIZE 1'     
);
end;
/


SQL> select * from user_tab_cols where table_name = 'TEST_BIG_PART';

TABLE_NAME                     COLUMN_NAME                              DATA_TYPE                      DAT DATA_TYPE_OWNER                                                                                                          DATA_LENGTH DATA_PRECISION DATA_SCALE N  COLUMN_ID DEFAULT_LENGTH DATA_DEFAULT                   NUM_DISTINCT LOW_VALUE                                                        HIGH_VALUE                                                                                    DENSITY  NUM_NULLS NUM_BUCKETS LAST_ANALY SAMPLE_SIZE CHARACTER_SET_NAME                           CHAR_COL_DECL_LENGTH GLO USE AVG_COL_LEN CHAR_LENGTH C V80 DAT HID VIR SEGMENT_COLUMN_ID INTERNAL_COLUMN_ID HISTOGRAM       QUALIFIED_COL_NAME
------------------------------ ---------------------------------------- ------------------------------ --- ------------------------------------------------------------------------------------------------------------------------ ----------- -------------- ---------- - ---------- -------------- ------------------------------ ------------ ---------------------------------------------------------------- ------------------------------------------------------------------------------------------ ---------- ---------- ----------- ---------- ----------- -------------------------------------------- -------------------- --- --- ----------- ----------- - --- --- --- --- ----------------- ------------------ --------------- ----------------------------------------------------------------------------------------------------
TEST_BIG_PART                  STARTDATE                                DATE                                                                                                                                                                  7                           Y          1                                                         10 78700905010101                                                   7870090E010101                                                                                     ,1          0           1 05.09.2012    10000000                                                                   YES NO            8           0   NO  YES NO  NO                  1                  1 NONE            STARTDATE
TEST_BIG_PART                  ID                                       NUMBER                                                                                                                                                               22                           Y          2                                                     100824 C102                                                             C30B                                                                                       9,9183E-06          0           1 05.09.2012    10000000                                                                   YES NO            5           0   NO  YES NO  NO                  2                  2 NONE            ID
TEST_BIG_PART                  N_COL1                                   NUMBER                                                                                                                                                               22                           Y          3                                                          2 80                                                               C102                                                                                               ,5          0           1 05.09.2012    10000000                                                                   YES NO            3           0   NO  YES NO  NO                  3                  3 NONE            N_COL1
TEST_BIG_PART                  N_COL2                                   NUMBER                                                                                                                                                               22                           Y          4                                                         10 80                                                               C10A                                                                                               ,1          0           1 05.09.2012    10000000                                                                   YES NO            3           0   NO  YES NO  NO                  4                  4 NONE            N_COL2
TEST_BIG_PART                  N_COL3                                   NUMBER                                                                                                                                                               22                           Y          5                                                      10001 80                                                               C302                                                                                        ,00009999          0           1 05.09.2012    10000000                                                                   YES NO            4           0   NO  YES NO  NO                  5                  5 NONE            N_COL3
TEST_BIG_PART                  N_COL4                                   NUMBER                                                                                                                                                               22                           Y          6                                                     100944 C005165F12183740445B450F1529600B505D3D                           C20A646434235133384F1616092C4C1460185253                                                   9,9065E-06          0           1 05.09.2012    10000000                                                                   YES NO           22           0   NO  YES NO  NO                  6                  6 NONE            N_COL4
TEST_BIG_PART                  V_COL1                                   VARCHAR2                                                                                                                                                             50                           Y          7                                                          1 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A                                    1          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  7                  7 NONE            V_COL1
TEST_BIG_PART                  V_COL2                                   VARCHAR2                                                                                                                                                             50                           Y          8                                                         52 41                                                               7A                                                                                         ,019230769          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO            2          50 B NO  YES NO  NO                  8                  8 NONE            V_COL2
TEST_BIG_PART                  V_COL3                                   VARCHAR2                                                                                                                                                             50                           Y          9                                                     101080 414143584E4F6C77584D744573625A4B56637168517845676C63464A6B775676 7A7A7A7044786E57427849784E614A616574596941467A586A5958456B495169                           9,8932E-06          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  9                  9 NONE            V_COL3
TEST_BIG_PART                  V_COL4                                   VARCHAR2                                                                                                                                                             50                           Y         10                                                          1 74657374                                                         74657374                                                                                            1          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO            5          50 B NO  YES NO  NO                 10                 10 NONE            V_COL4

10 Zeilen ausgewählt.

Abgelaufen: 00:00:00.12
SQL>

begin
DBMS_STATS.GATHER_TABLE_STATS ( OwnName        => user
                              , TabName        => 'TEST_BIG_PART'      
                              , Granularity    => 'APPROX_GLOBAL AND PARTITION'     
                              , Method_Opt     => 'FOR ALL COLUMNS SIZE 1'     
);
end;
/

SQL> select * from user_tab_cols where table_name = 'TEST_BIG_PART';

TABLE_NAME                     COLUMN_NAME                              DATA_TYPE                      DAT DATA_TYPE_OWNER                                                                                                          DATA_LENGTH DATA_PRECISION DATA_SCALE N  COLUMN_ID DEFAULT_LENGTH DATA_DEFAULT                   NUM_DISTINCT LOW_VALUE                                                        HIGH_VALUE                                                                                    DENSITY  NUM_NULLS NUM_BUCKETS LAST_ANALY SAMPLE_SIZE CHARACTER_SET_NAME                           CHAR_COL_DECL_LENGTH GLO USE AVG_COL_LEN CHAR_LENGTH C V80 DAT HID VIR SEGMENT_COLUMN_ID INTERNAL_COLUMN_ID HISTOGRAM       QUALIFIED_COL_NAME
------------------------------ ---------------------------------------- ------------------------------ --- ------------------------------------------------------------------------------------------------------------------------ ----------- -------------- ---------- - ---------- -------------- ------------------------------ ------------ ---------------------------------------------------------------- ------------------------------------------------------------------------------------------ ---------- ---------- ----------- ---------- ----------- -------------------------------------------- -------------------- --- --- ----------- ----------- - --- --- --- --- ----------------- ------------------ --------------- ----------------------------------------------------------------------------------------------------
TEST_BIG_PART                  STARTDATE                                DATE                                                                                                                                                                  7                           Y          1                                                         10 78700905010101                                                   7870090E010101                                                                                     ,1          0           1 05.09.2012    10000000                                                                   YES NO            8           0   NO  YES NO  NO                  1                  1 NONE            STARTDATE
TEST_BIG_PART                  ID                                       NUMBER                                                                                                                                                               22                           Y          2                                                     100824 C102                                                             C30B                                                                                       9,9183E-06          0           1 05.09.2012    10000000                                                                   YES NO            5           0   NO  YES NO  NO                  2                  2 NONE            ID
TEST_BIG_PART                  N_COL1                                   NUMBER                                                                                                                                                               22                           Y          3                                                          2 80                                                               C102                                                                                               ,5          0           1 05.09.2012    10000000                                                                   YES NO            3           0   NO  YES NO  NO                  3                  3 NONE            N_COL1
TEST_BIG_PART                  N_COL2                                   NUMBER                                                                                                                                                               22                           Y          4                                                         10 80                                                               C10A                                                                                               ,1          0           1 05.09.2012    10000000                                                                   YES NO            3           0   NO  YES NO  NO                  4                  4 NONE            N_COL2
TEST_BIG_PART                  N_COL3                                   NUMBER                                                                                                                                                               22                           Y          5                                                      10001 80                                                               C302                                                                                        ,00009999          0           1 05.09.2012    10000000                                                                   YES NO            4           0   NO  YES NO  NO                  5                  5 NONE            N_COL3
TEST_BIG_PART                  N_COL4                                   NUMBER                                                                                                                                                               22                           Y          6                                                     100944 C005165F12183740445B450F1529600B505D3D                           C20A646434235133384F1616092C4C1460185253                                                   9,9065E-06          0           1 05.09.2012    10000000                                                                   YES NO           22           0   NO  YES NO  NO                  6                  6 NONE            N_COL4
TEST_BIG_PART                  V_COL1                                   VARCHAR2                                                                                                                                                             50                           Y          7                                                          1 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A                                    1          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  7                  7 NONE            V_COL1
TEST_BIG_PART                  V_COL2                                   VARCHAR2                                                                                                                                                             50                           Y          8                                                         52 41                                                               7A                                                                                         ,019230769          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO            2          50 B NO  YES NO  NO                  8                  8 NONE            V_COL2
TEST_BIG_PART                  V_COL3                                   VARCHAR2                                                                                                                                                             50                           Y          9                                                     101080 414143584E4F6C77584D744573625A4B56637168517845676C63464A6B775676 7A7A7A7044786E57427849784E614A616574596941467A586A5958456B495169                           9,8932E-06          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  9                  9 NONE            V_COL3
TEST_BIG_PART                  V_COL4                                   VARCHAR2                                                                                                                                                             50                           Y         10                                                          1 74657374                                                         74657374                                                                                            1          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO            5          50 B NO  YES NO  NO                 10                 10 NONE            V_COL4

10 Zeilen ausgewählt.

TABLE_NAME                       NUM_ROWS     BLOCKS SAMPLE_SIZE LAST_ANALY AVG_ROW_LEN GLO USE
------------------------------ ---------- ---------- ----------- ---------- ----------- --- ---
TEST_BIG_PART                    10000000     223370    10000000 05.09.2012         153 YES NO

PARTITION_NAME                   NUM_ROWS     BLOCKS SAMPLE_SIZE LAST_ANALY AVG_ROW_LEN GLO USE PARTITION_POSITION HIGH_VALUE
------------------------------ ---------- ---------- ----------- ---------- ----------- --- --- ------------------ ------------------------------------------------------------------------------------------
TEST_P1                           1000000      22337     1000000 05.09.2012         153 YES NO                   1 TO_DATE(' 2012-09-06 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P70                           1000000      22337     1000000 05.09.2012         153 YES NO                   2 TO_DATE(' 2012-09-07 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P71                           1000000      22337     1000000 05.09.2012         153 YES NO                   3 TO_DATE(' 2012-09-08 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P72                           1000000      22337     1000000 05.09.2012         153 YES NO                   4 TO_DATE(' 2012-09-09 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P73                           1000000      22337     1000000 05.09.2012         153 YES NO                   5 TO_DATE(' 2012-09-10 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P74                           1000000      22337     1000000 05.09.2012         153 YES NO                   6 TO_DATE(' 2012-09-11 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P75                           1000000      22337     1000000 05.09.2012         153 YES NO                   7 TO_DATE(' 2012-09-12 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P76                           1000000      22337     1000000 05.09.2012         153 YES NO                   8 TO_DATE(' 2012-09-13 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P77                           1000000      22337     1000000 05.09.2012         153 YES NO                   9 TO_DATE(' 2012-09-14 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P78                           1000000      22337     1000000 05.09.2012         153 YES NO                  10 TO_DATE(' 2012-09-15 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')



exec dbms_stats.set_table_prefs('TEST', 'TEST_BIG_PART', 'INCREMENTAL', 'TRUE');

begin
DBMS_STATS.GATHER_TABLE_STATS ( OwnName        => user
                              , TabName        => 'TEST_BIG_PART'
                              , Granularity    => 'AUTO'
                              , Method_Opt     => 'FOR ALL COLUMNS SIZE 1'
);
end;
/


TABLE_NAME                     COLUMN_NAME                              DATA_TYPE                      DAT DATA_TYPE_OWNER                                                                                                          DATA_LENGTH DATA_PRECISION DATA_SCALE N  COLUMN_ID DEFAULT_LENGTH DATA_DEFAULT                   NUM_DISTINCT LOW_VALUE                                                        HIGH_VALUE                                                                                    DENSITY  NUM_NULLS NUM_BUCKETS LAST_ANALY SAMPLE_SIZE CHARACTER_SET_NAME                           CHAR_COL_DECL_LENGTH GLO USE AVG_COL_LEN CHAR_LENGTH C V80 DAT HID VIR SEGMENT_COLUMN_ID INTERNAL_COLUMN_ID HISTOGRAM       QUALIFIED_COL_NAME
------------------------------ ---------------------------------------- ------------------------------ --- ------------------------------------------------------------------------------------------------------------------------ ----------- -------------- ---------- - ---------- -------------- ------------------------------ ------------ ---------------------------------------------------------------- ------------------------------------------------------------------------------------------ ---------- ---------- ----------- ---------- ----------- -------------------------------------------- -------------------- --- --- ----------- ----------- - --- --- --- --- ----------------- ------------------ --------------- ----------------------------------------------------------------------------------------------------
TEST_BIG_PART                  STARTDATE                                DATE                                                                                                                                                                  7                           Y          1                                                         10 78700905010101                                                   7870090E010101                                                                                     ,1          0           1 05.09.2012    10000000                                                                   YES NO            8           0   NO  YES NO  NO                  1                  1 NONE            STARTDATE
TEST_BIG_PART                  ID                                       NUMBER                                                                                                                                                               22                           Y          2                                                     100824 C102                                                             C30B                                                                                       9,9183E-06          0           1 05.09.2012    10000000                                                                   YES NO            5           0   NO  YES NO  NO                  2                  2 NONE            ID
TEST_BIG_PART                  N_COL1                                   NUMBER                                                                                                                                                               22                           Y          3                                                          2 80                                                               C102                                                                                               ,5          0           1 05.09.2012    10000000                                                                   YES NO            3           0   NO  YES NO  NO                  3                  3 NONE            N_COL1
TEST_BIG_PART                  N_COL2                                   NUMBER                                                                                                                                                               22                           Y          4                                                         10 80                                                               C10A                                                                                               ,1          0           1 05.09.2012    10000000                                                                   YES NO            3           0   NO  YES NO  NO                  4                  4 NONE            N_COL2
TEST_BIG_PART                  N_COL3                                   NUMBER                                                                                                                                                               22                           Y          5                                                      10001 80                                                               C302                                                                                        ,00009999          0           1 05.09.2012    10000000                                                                   YES NO            4           0   NO  YES NO  NO                  5                  5 NONE            N_COL3
TEST_BIG_PART                  N_COL4                                   NUMBER                                                                                                                                                               22                           Y          6                                                     100944 C005165F12183740445B450F1529600B505D3D                           C20A646434235133384F1616092C4C1460185253                                                   9,9065E-06          0           1 05.09.2012    10000000                                                                   YES NO           22           0   NO  YES NO  NO                  6                  6 NONE            N_COL4
TEST_BIG_PART                  V_COL1                                   VARCHAR2                                                                                                                                                             50                           Y          7                                                          1 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A                                    1          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  7                  7 NONE            V_COL1
TEST_BIG_PART                  V_COL2                                   VARCHAR2                                                                                                                                                             50                           Y          8                                                         52 41                                                               7A                                                                                         ,019230769          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO            2          50 B NO  YES NO  NO                  8                  8 NONE            V_COL2
TEST_BIG_PART                  V_COL3                                   VARCHAR2                                                                                                                                                             50                           Y          9                                                     101080 414143584E4F6C77584D744573625A4B56637168517845676C63464A6B775676 7A7A7A7044786E57427849784E614A616574596941467A586A5958456B495169                           9,8932E-06          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  9                  9 NONE            V_COL3
TEST_BIG_PART                  V_COL4                                   VARCHAR2                                                                                                                                                             50                           Y         10                                                          1 74657374                                                         74657374                                                                                            1          0           1 05.09.2012    10000000 CHAR_CS                                                        50 YES NO            5          50 B NO  YES NO  NO                 10                 10 NONE            V_COL4

10 Zeilen ausgewählt.

TABLE_NAME                       NUM_ROWS     BLOCKS SAMPLE_SIZE LAST_ANALY AVG_ROW_LEN GLO USE
------------------------------ ---------- ---------- ----------- ---------- ----------- --- ---
TEST_BIG_PART                    10000000     223370    10000000 05.09.2012         154 YES NO

PARTITION_NAME                   NUM_ROWS     BLOCKS SAMPLE_SIZE LAST_ANALY AVG_ROW_LEN GLO USE PARTITION_POSITION HIGH_VALUE
------------------------------ ---------- ---------- ----------- ---------- ----------- --- --- ------------------ ------------------------------------------------------------------------------------------
TEST_P1                           1000000      22337     1000000 05.09.2012         153 YES NO                   1 TO_DATE(' 2012-09-06 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P70                           1000000      22337     1000000 05.09.2012         153 YES NO                   2 TO_DATE(' 2012-09-07 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P71                           1000000      22337     1000000 05.09.2012         153 YES NO                   3 TO_DATE(' 2012-09-08 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P72                           1000000      22337     1000000 05.09.2012         153 YES NO                   4 TO_DATE(' 2012-09-09 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P73                           1000000      22337     1000000 05.09.2012         153 YES NO                   5 TO_DATE(' 2012-09-10 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P74                           1000000      22337     1000000 05.09.2012         153 YES NO                   6 TO_DATE(' 2012-09-11 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P75                           1000000      22337     1000000 05.09.2012         153 YES NO                   7 TO_DATE(' 2012-09-12 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P76                           1000000      22337     1000000 05.09.2012         153 YES NO                   8 TO_DATE(' 2012-09-13 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P77                           1000000      22337     1000000 05.09.2012         153 YES NO                   9 TO_DATE(' 2012-09-14 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P78                           1000000      22337     1000000 05.09.2012         153 YES NO                  10 TO_DATE(' 2012-09-15 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')


-- Ergänzung einer weiteren Partition mit 1M rows

TABLE_NAME                       NUM_ROWS     BLOCKS SAMPLE_SIZE LAST_ANALY AVG_ROW_LEN GLO USE
------------------------------ ---------- ---------- ----------- ---------- ----------- --- ---
TEST_BIG_PART                    11000000     245707    11000000 05.09.2012         154 YES NO

PARTITION_NAME                   NUM_ROWS     BLOCKS SAMPLE_SIZE LAST_ANALY AVG_ROW_LEN GLO USE PARTITION_POSITION HIGH_VALUE
------------------------------ ---------- ---------- ----------- ---------- ----------- --- --- ------------------ ------------------------------------------------------------------------------------------
TEST_P1                           1000000      22337     1000000 05.09.2012         153 YES NO                   1 TO_DATE(' 2012-09-06 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P70                           1000000      22337     1000000 05.09.2012         153 YES NO                   2 TO_DATE(' 2012-09-07 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P71                           1000000      22337     1000000 05.09.2012         153 YES NO                   3 TO_DATE(' 2012-09-08 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P72                           1000000      22337     1000000 05.09.2012         153 YES NO                   4 TO_DATE(' 2012-09-09 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P73                           1000000      22337     1000000 05.09.2012         153 YES NO                   5 TO_DATE(' 2012-09-10 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P74                           1000000      22337     1000000 05.09.2012         153 YES NO                   6 TO_DATE(' 2012-09-11 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P75                           1000000      22337     1000000 05.09.2012         153 YES NO                   7 TO_DATE(' 2012-09-12 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P76                           1000000      22337     1000000 05.09.2012         153 YES NO                   8 TO_DATE(' 2012-09-13 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P77                           1000000      22337     1000000 05.09.2012         153 YES NO                   9 TO_DATE(' 2012-09-14 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P78                           1000000      22337     1000000 05.09.2012         153 YES NO                  10 TO_DATE(' 2012-09-15 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
SYS_P79                           1000000      22337     1000000 05.09.2012         153 YES NO                  11 TO_DATE(' 2012-09-16 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')

TABLE_NAME                     COLUMN_NAME                              DATA_TYPE                      DAT DATA_TYPE_OWNER                                                                                                          DATA_LENGTH DATA_PRECISION DATA_SCALE N  COLUMN_ID DEFAULT_LENGTH DATA_DEFAULT                   NUM_DISTINCT LOW_VALUE                                                        HIGH_VALUE                                                                                    DENSITY  NUM_NULLS NUM_BUCKETS LAST_ANALY SAMPLE_SIZE CHARACTER_SET_NAME                           CHAR_COL_DECL_LENGTH GLO USE AVG_COL_LEN CHAR_LENGTH C V80 DAT HID VIR SEGMENT_COLUMN_ID INTERNAL_COLUMN_ID HISTOGRAM       QUALIFIED_COL_NAME
------------------------------ ---------------------------------------- ------------------------------ --- ------------------------------------------------------------------------------------------------------------------------ ----------- -------------- ---------- - ---------- -------------- ------------------------------ ------------ ---------------------------------------------------------------- ------------------------------------------------------------------------------------------ ---------- ---------- ----------- ---------- ----------- -------------------------------------------- -------------------- --- --- ----------- ----------- - --- --- --- --- ----------------- ------------------ --------------- ----------------------------------------------------------------------------------------------------
TEST_BIG_PART                  STARTDATE                                DATE                                                                                                                                                                  7                           Y          1                                                         11 78700905010101                                                   7870090F010101                                                                             ,090909091          0           1 05.09.2012    11000000                                                                   YES NO            8           0   NO  YES NO  NO                  1                  1 NONE            STARTDATE
TEST_BIG_PART                  ID                                       NUMBER                                                                                                                                                               22                           Y          2                                                     100824 C102                                                             C30B                                                                                       9,9183E-06          0           1 05.09.2012    11000000                                                                   YES NO            5           0   NO  YES NO  NO                  2                  2 NONE            ID
TEST_BIG_PART                  N_COL1                                   NUMBER                                                                                                                                                               22                           Y          3                                                          2 80                                                               C102                                                                                               ,5          0           1 05.09.2012    11000000                                                                   YES NO            3           0   NO  YES NO  NO                  3                  3 NONE            N_COL1
TEST_BIG_PART                  N_COL2                                   NUMBER                                                                                                                                                               22                           Y          4                                                         10 80                                                               C10A                                                                                               ,1          0           1 05.09.2012    11000000                                                                   YES NO            3           0   NO  YES NO  NO                  4                  4 NONE            N_COL2
TEST_BIG_PART                  N_COL3                                   NUMBER                                                                                                                                                               22                           Y          5                                                      10001 80                                                               C302                                                                                        ,00009999          0           1 05.09.2012    11000000                                                                   YES NO            4           0   NO  YES NO  NO                  5                  5 NONE            N_COL3
TEST_BIG_PART                  N_COL4                                   NUMBER                                                                                                                                                               22                           Y          6                                                     200624 BF4E38104B3B5F493C2F1511615114222B0B                             C20A646434235133384F1616092C4C1460185253                                                   4,9844E-06          0           1 05.09.2012    11000000                                                                   YES NO           22           0   NO  YES NO  NO                  6                  6 NONE            N_COL4
TEST_BIG_PART                  V_COL1                                   VARCHAR2                                                                                                                                                             50                           Y          7                                                          1 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A                                    1          0           1 05.09.2012    11000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  7                  7 NONE            V_COL1
TEST_BIG_PART                  V_COL2                                   VARCHAR2                                                                                                                                                             50                           Y          8                                                         52 41                                                               7A                                                                                         ,019230769          0           1 05.09.2012    11000000 CHAR_CS                                                        50 YES NO            2          50 B NO  YES NO  NO                  8                  8 NONE            V_COL2
TEST_BIG_PART                  V_COL3                                   VARCHAR2                                                                                                                                                             50                           Y          9                                                     200752 414143584E4F6C77584D744573625A4B56637168517845676C63464A6B775676 7A7A7A7044786E57427849784E614A616574596941467A586A5958456B495169                           4,9813E-06          0           1 05.09.2012    11000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  9                  9 NONE            V_COL3
TEST_BIG_PART                  V_COL4                                   VARCHAR2                                                                                                                                                             50                           Y         10                                                          1 74657374                                                         74657374                                                                                            1          0           1 05.09.2012    11000000 CHAR_CS                                                        50 YES NO            5          50 B NO  YES NO  NO                 10                 10 NONE            V_COL4

10 Zeilen ausgewählt.



-- nach approx
-- NUM_DISTINCT immer 0
TABLE_NAME                     COLUMN_NAME                              DATA_TYPE                      DAT DATA_TYPE_OWNER                                                                                                          DATA_LENGTH DATA_PRECISION DATA_SCALE N  COLUMN_ID DEFAULT_LENGTH DATA_DEFAULT                   NUM_DISTINCT LOW_VALUE                                                        HIGH_VALUE                                                                                    DENSITY  NUM_NULLS NUM_BUCKETS LAST_ANALYZED       SAMPLE_SIZE CHARACTER_SET_NAME                           CHAR_COL_DECL_LENGTH GLO USE AVG_COL_LEN CHAR_LENGTH C V80 DAT HID VIR SEGMENT_COLUMN_ID INTERNAL_COLUMN_ID HISTOGRAM       QUALIFIED_COL_NAME
------------------------------ ---------------------------------------- ------------------------------ --- ------------------------------------------------------------------------------------------------------------------------ ----------- -------------- ---------- - ---------- -------------- ------------------------------ ------------ ---------------------------------------------------------------- ------------------------------------------------------------------------------------------ ---------- ---------- ----------- ------------------- ----------- -------------------------------------------- -------------------- --- --- ----------- ----------- - --- --- --- --- ----------------- ------------------ --------------- ----------------------------------------------------------------------------------------------------
TEST_BIG_PART                  STARTDATE                                DATE                                                                                                                                                                  7                           Y          1                                                          0 78700905010101                                                   7870090F010101                                                                                      0          0           0 05.09.2012 10:23:34    11000000                                                                   YES NO            8           0   NO  YES NO  NO                  1                  1 NONE            STARTDATE
TEST_BIG_PART                  ID                                       NUMBER                                                                                                                                                               22                           Y          2                                                          0 C102                                                             C30B                                                                                                0          0           0 05.09.2012 10:23:34    11000000                                                                   YES NO            5           0   NO  YES NO  NO                  2                  2 NONE            ID
TEST_BIG_PART                  N_COL1                                   NUMBER                                                                                                                                                               22                           Y          3                                                          0 80                                                               C102                                                                                                0          0           0 05.09.2012 10:23:34    11000000                                                                   YES NO            3           0   NO  YES NO  NO                  3                  3 NONE            N_COL1
TEST_BIG_PART                  N_COL2                                   NUMBER                                                                                                                                                               22                           Y          4                                                          0 80                                                               C10A                                                                                                0          0           0 05.09.2012 10:23:34    11000000                                                                   YES NO            3           0   NO  YES NO  NO                  4                  4 NONE            N_COL2
TEST_BIG_PART                  N_COL3                                   NUMBER                                                                                                                                                               22                           Y          5                                                          0 80                                                               C302                                                                                                0          0           0 05.09.2012 10:23:34    11000000                                                                   YES NO            4           0   NO  YES NO  NO                  5                  5 NONE            N_COL3
TEST_BIG_PART                  N_COL4                                   NUMBER                                                                                                                                                               22                           Y          6                                                          0 BF4E38104B3B5F493C2F1511615114222B0B                             C20A646434235133384F1616092C4C1460185253                                                            0          0           0 05.09.2012 10:23:34    11000000                                                                   YES NO           22           0   NO  YES NO  NO                  6                  6 NONE            N_COL4
TEST_BIG_PART                  V_COL1                                   VARCHAR2                                                                                                                                                             50                           Y          7                                                          0 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A 2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A                                    0          0           0 05.09.2012 10:23:34    11000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  7                  7 NONE            V_COL1
TEST_BIG_PART                  V_COL2                                   VARCHAR2                                                                                                                                                             50                           Y          8                                                          0 41                                                               7A                                                                                                  0          0           0 05.09.2012 10:23:34    11000000 CHAR_CS                                                        50 YES NO            2          50 B NO  YES NO  NO                  8                  8 NONE            V_COL2
TEST_BIG_PART                  V_COL3                                   VARCHAR2                                                                                                                                                             50                           Y          9                                                          0 414143584E4F6C77584D744573625A4B56637168517845676C63464A6B775676 7A7A7A7044786E57427849784E614A616574596941467A586A5958456B495169                                    0          0           0 05.09.2012 10:23:34    11000000 CHAR_CS                                                        50 YES NO           51          50 B NO  YES NO  NO                  9                  9 NONE            V_COL3
TEST_BIG_PART                  V_COL4                                   VARCHAR2                                                                                                                                                             50                           Y         10                                                          0 74657374                                                         74657374                                                                                            0          0           0 05.09.2012 10:23:34    11000000 CHAR_CS                                                        50 YES NO            5          50 B NO  YES NO  NO                 10                 10 NONE            V_COL4

10 Zeilen ausgewählt.


begin
DBMS_STATS.DELETE_TABLE_STATS (OwnName        => user
                              , TabName       => 'TEST_BIG_PART'
                              , cascade_parts => false
);
end;
/

begin
DBMS_STATS.DELETE_TABLE_STATS (OwnName        => user
                              , TabName       => 'TEST_BIG_PART'
                              , partname      => 'SYS_P80'
);
end;
/

begin
DBMS_STATS.GATHER_TABLE_STATS (OwnName        => user
                              , TabName       => 'TEST_BIG_PART'
                              , partname      => 'SYS_P80'
                              , Method_Opt     => 'FOR ALL COLUMNS SIZE 1'     
);
end;
/

begin
DBMS_STATS.DELETE_TABLE_STATS (OwnName        => user
                              , TabName       => 'TEST_BIG_PART'
                              , cascade_parts => true
);
end;
/


