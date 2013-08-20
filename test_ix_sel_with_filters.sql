-- Material zu http://martinpreiss.blogspot.com/2011/12/ixselwithfilters.html

drop table test_ind_selectivity;

create table test_ind_selectivity tablespace test_ts
as
select rownum id
     , mod(rownum, 10) col1
     , mod(rownum, 100) col2
     , mod(rownum, 1000) col3
     , lpad('*', 100, '*') pad
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'TEST_IND_SELECTIVITY', method_opt=>'FOR ALL COLUMNS SIZE 1')


create index test_ind_selectivity_ix1 on test_ind_selectivity(col1, col2, col3);


select index_name
     , blevel
     , leaf_blocks
     , clustering_factor
  from user_indexes
 where table_name = upper('test_ind_selectivity');


INDEX_NAME                         BLEVEL LEAF_BLOCKS CLUSTERING_FACTOR
------------------------------ ---------- ----------- -----------------
TEST_IND_SELECTIVITY_IX1                2        2894           1000000

cost = blevel + ceiling(leaf_blocks + effective index selectivity) + ceiling(clustering_factor * effective table selectivity)




ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

select /*+ index(test_ind_selectivity) test1 */ count(id) from test_ind_selectivity where col1 = 1;

select /*+ index(test_ind_selectivity) test2 */ count(id) from test_ind_selectivity where col1 = 1 and col2 = 1;

select /*+ index(test_ind_selectivity) test3 */ count(id) from test_ind_selectivity where col1 = 1 and col2 = 1 and col3 = 1;

select /*+ index(test_ind_selectivity) test4 */ count(id) from test_ind_selectivity where col1 = 1 and col3 = 1;

ALTER SESSION SET EVENTS '10053 trace name context OFF';


-- Einschränkung auf col1

***************************************
BASE STATISTICAL INFORMATION
***********************
Table Stats::
  Table: TEST_IND_SELECTIVITY  Alias: TEST_IND_SELECTIVITY
    #Rows: 1000000  #Blks:  16907  AvgRowLen:  116.00
Index Stats::
  Index: TEST_IND_SELECTIVITY_IX1  Col#: 2 3 4
    LVLS: 2  #LB: 2894  #DK: 1000  LB/K: 2.00  DB/K: 1000.00  CLUF: 1000000.00
    User hint to use this index
Access path analysis for TEST_IND_SELECTIVITY
***************************************
SINGLE TABLE ACCESS PATH 
  Single Table Cardinality Estimation for TEST_IND_SELECTIVITY[TEST_IND_SELECTIVITY] 
  Table: TEST_IND_SELECTIVITY  Alias: TEST_IND_SELECTIVITY
    Card: Original: 1000000.000000  Rounded: 100000  Computed: 100000.00  Non Adjusted: 100000.00


  Access Path: index (RangeScan)
    Index: TEST_IND_SELECTIVITY_IX1
    resc_io: 100292.00  resc_cpu: 751223460
    ix_sel: 0.100000  ix_sel_with_filters: 0.100000 
    Cost: 100292.15  Resp: 100292.15  Degree: 1
  Best:: AccessPath: IndexRange
  Index: TEST_IND_SELECTIVITY_IX1
         Cost: 100292.15  Degree: 1  Resp: 100292.15  Card: 100000.00  Bytes: 0

***************************************


-- Einschränkung auf col1 und col2

***************************************
BASE STATISTICAL INFORMATION
***********************
Table Stats::
  Table: TEST_IND_SELECTIVITY  Alias: TEST_IND_SELECTIVITY
    #Rows: 1000000  #Blks:  16907  AvgRowLen:  116.00
Index Stats::
  Index: TEST_IND_SELECTIVITY_IX1  Col#: 2 3 4
    LVLS: 2  #LB: 2894  #DK: 1000  LB/K: 2.00  DB/K: 1000.00  CLUF: 1000000.00
    User hint to use this index
Access path analysis for TEST_IND_SELECTIVITY
***************************************
SINGLE TABLE ACCESS PATH 
  Single Table Cardinality Estimation for TEST_IND_SELECTIVITY[TEST_IND_SELECTIVITY] 
  ColGroup (#1, Index) TEST_IND_SELECTIVITY_IX1
    Col#: 2 3 4    CorStregth: -1.00
  ColGroup Usage:: PredCnt: 2  Matches Full:  Partial: 
  Table: TEST_IND_SELECTIVITY  Alias: TEST_IND_SELECTIVITY
    Card: Original: 1000000.000000  Rounded: 1000  Computed: 1000.00  Non Adjusted: 1000.00
  ColGroup Usage:: PredCnt: 2  Matches Full:  Partial: 
  ColGroup Usage:: PredCnt: 2  Matches Full:  Partial: 
  Access Path: index (RangeScan)
    Index: TEST_IND_SELECTIVITY_IX1
    resc_io: 1005.00  resc_cpu: 7547047
    ix_sel: 0.001000  ix_sel_with_filters: 0.001000 
    Cost: 1005.00  Resp: 1005.00  Degree: 1
  Best:: AccessPath: IndexRange
  Index: TEST_IND_SELECTIVITY_IX1
         Cost: 1005.00  Degree: 1  Resp: 1005.00  Card: 1000.00  Bytes: 0

***************************************


-- Einschränkung auf col1 und col2 und col3

***************************************
BASE STATISTICAL INFORMATION
***********************
Table Stats::
  Table: TEST_IND_SELECTIVITY  Alias: TEST_IND_SELECTIVITY
    #Rows: 1000000  #Blks:  16907  AvgRowLen:  116.00
Index Stats::
  Index: TEST_IND_SELECTIVITY_IX1  Col#: 2 3 4
    LVLS: 2  #LB: 2894  #DK: 1000  LB/K: 2.00  DB/K: 1000.00  CLUF: 1000000.00
    User hint to use this index
Access path analysis for TEST_IND_SELECTIVITY
***************************************
SINGLE TABLE ACCESS PATH 
  Single Table Cardinality Estimation for TEST_IND_SELECTIVITY[TEST_IND_SELECTIVITY] 
  ColGroup (#1, Index) TEST_IND_SELECTIVITY_IX1
    Col#: 2 3 4    CorStregth: 1000.00
  ColGroup Usage:: PredCnt: 3  Matches Full: #1  Partial:  Sel: 0.0010
  Table: TEST_IND_SELECTIVITY  Alias: TEST_IND_SELECTIVITY
    Card: Original: 1000000.000000  Rounded: 1000  Computed: 1000.00  Non Adjusted: 1000.00
  ColGroup Usage:: PredCnt: 3  Matches Full: #1  Partial:  Sel: 0.0010
  ColGroup Usage:: PredCnt: 3  Matches Full: #1  Partial:  Sel: 0.0010
  Access Path: index (AllEqRange)
    Index: TEST_IND_SELECTIVITY_IX1
    resc_io: 1005.00  resc_cpu: 7567047
    ix_sel: 0.001000  ix_sel_with_filters: 0.001000 
    Cost: 1005.00  Resp: 1005.00  Degree: 1
  Best:: AccessPath: IndexRange
  Index: TEST_IND_SELECTIVITY_IX1
         Cost: 1005.00  Degree: 1  Resp: 1005.00  Card: 1000.00  Bytes: 0

***************************************


-- Einschränkung auf col1 und col3

***************************************
BASE STATISTICAL INFORMATION
***********************
Table Stats::
  Table: TEST_IND_SELECTIVITY  Alias: TEST_IND_SELECTIVITY
    #Rows: 1000000  #Blks:  16907  AvgRowLen:  116.00
Index Stats::
  Index: TEST_IND_SELECTIVITY_IX1  Col#: 2 3 4
    LVLS: 2  #LB: 2894  #DK: 1000  LB/K: 2.00  DB/K: 1000.00  CLUF: 1000000.00
    User hint to use this index
Access path analysis for TEST_IND_SELECTIVITY
***************************************
SINGLE TABLE ACCESS PATH 
  Single Table Cardinality Estimation for TEST_IND_SELECTIVITY[TEST_IND_SELECTIVITY] 
  ColGroup (#1, Index) TEST_IND_SELECTIVITY_IX1
    Col#: 2 3 4    CorStregth: -1.00
  ColGroup Usage:: PredCnt: 2  Matches Full:  Partial: #1 (2 4 )  Sel: 0.0010
  Table: TEST_IND_SELECTIVITY  Alias: TEST_IND_SELECTIVITY
    Card: Original: 1000000.000000  Rounded: 1000  Computed: 1000.00  Non Adjusted: 1000.00
kkofmx: index filter:"TEST_IND_SELECTIVITY"."COL3"=1


  ColGroup Usage:: PredCnt: 2  Matches Full:  Partial: #1 (2 4 )  Sel: 0.0010
  ColGroup Usage:: PredCnt: 2  Matches Full:  Partial: #1 (2 4 )  Sel: 0.0010
  Access Path: index (skip-scan)
    SS sel: 0.001000  ANDV (#skips): 100.000000
    SS io: 300.000000 vs. index scan io: 8455.000000
    Skip Scan rejected
  Access Path: index (RangeScan)
    Index: TEST_IND_SELECTIVITY_IX1
    resc_io: 1292.00  resc_cpu: 29410900
    ix_sel: 0.100000  ix_sel_with_filters: 0.001000 
 ***** Logdef predicate Adjustment ****** 
 Final IO cst 0.00 , CPU cst 50.00
 ***** End Logdef Adjustment ****** 
    Cost: 1292.01  Resp: 1292.01  Degree: 1
  Best:: AccessPath: IndexRange
  Index: TEST_IND_SELECTIVITY_IX1
         Cost: 1292.01  Degree: 1  Resp: 1292.01  Card: 1000.00  Bytes: 0

***************************************
