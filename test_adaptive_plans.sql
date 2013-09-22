-- Versuch, ein Beispiel zu erzeugen, bei dem adaptive plans ins Spiel kommen
-- als Frage im ONT-Forum untergebracht: 24.08.2013

alter session set statistics_level = all;

drop table t1;
drop table t2;

create table t1
as
select rownum id
     , mod(rownum, 10) col1
     , lpad('*', 20, '*') col2
  from dual
connect by level <= 100000;


exec dbms_stats.gather_table_stats(user, 't1')

create index t1_id_idx on t1(col1, id);


create table t2
as
select mod(rownum, 100) id_t1
     , lpad('*', 20, '*') col2
     , rownum col3
  from dual
connect by level <= 100000;

exec dbms_stats.gather_table_stats(user, 't2')

create index t2_idx on t2(id_t1);

select sum(t1.col1) sum_col3
  from t1
     , t2
 where t1.id = t2.id_t1
   and t1.col1 = 1;

select * 
  from table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));

update t1 set col1 = 1000 where id > 1;

select sum(t1.col1) sum_col3
  from t1
     , t2
 where t1.id = t2.id_t1
   and t1.col1 = 1;

select * 
  from table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));


select sum(t1.col1) sum_col3
  from t1
     , t2
 where t1.id = t2.id_t1
   and t1.col1 = 1;

@ sqlxplan_last


select /*+ use_nl(t1 t2) */
       sum(t1.col1) sum_col3
  from t1
     , t2
 where t1.id = t2.id_t1
   and t1.col1 = 1;

@ sqlxplan_last

select /*+ use_nl(t1 t2) index(t1) */
       sum(t1.col1) sum_col3
  from t1
     , t2
 where t1.id = t2.id_t1
   and t1.col1 = 1;

@ sqlxplan_last

-- Ergebnisse:

----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name   | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
----------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |        |      1 |        |      1 |00:00:11.12 |     494 |     20 |       |       |          |
|   1 |  SORT AGGREGATE     |        |      1 |      1 |      1 |00:00:11.12 |     494 |     20 |       |       |          |
|*  2 |   HASH JOIN         |        |      1 |    100M|    100M|00:00:08.47 |     494 |     20 |  2440K|  2440K| 1353K (0)|
|*  3 |    INDEX RANGE SCAN | T2_IDX |      1 |  10000 |  10000 |00:00:00.01 |      21 |     20 |       |       |          |
|*  4 |    TABLE ACCESS FULL| T1     |      1 |  10000 |  10000 |00:00:00.01 |     473 |      0 |       |       |          |
----------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."COL1"="T2"."COL1")
   3 - access("T2"."COL1"=1)

-------------------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name   | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |        |      1 |        |      1 |00:00:00.01 |     494 |       |       |          |
|   1 |  SORT AGGREGATE     |        |      1 |      1 |      1 |00:00:00.01 |     494 |       |       |          |
|*  2 |   HASH JOIN         |        |      1 |    100M|    100 |00:00:00.01 |     494 |  2440K|  2440K|  764K (0)|
|*  3 |    INDEX RANGE SCAN | T2_IDX |      1 |  10000 |     10 |00:00:00.01 |      21 |       |       |          |
|*  4 |    TABLE ACCESS FULL| T1     |      1 |  10000 |     10 |00:00:00.01 |     473 |       |       |          |
-------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."COL1"="T2"."COL1")
   3 - access("T2"."COL1"=1)
   4 - filter("T1"."COL1"=1)

-------------------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name   | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |        |      1 |        |      1 |00:00:00.01 |     494 |       |       |          |
|   1 |  SORT AGGREGATE     |        |      1 |      1 |      1 |00:00:00.01 |     494 |       |       |          |
|*  2 |   HASH JOIN         |        |      1 |    100M|    100 |00:00:00.01 |     494 |  2440K|  2440K|  781K (0)|
|*  3 |    INDEX RANGE SCAN | T2_IDX |      1 |  10000 |     10 |00:00:00.01 |      21 |       |       |          |
|*  4 |    TABLE ACCESS FULL| T1     |      1 |  10000 |     10 |00:00:00.01 |     473 |       |       |          |
-------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."COL1"="T2"."COL1")
   3 - access("T2"."COL1"=1)
   4 - filter("T1"."COL1"=1)

----------------------------------------------------------------------------------------
| Id  | Operation           | Name   | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |        |      1 |        |      1 |00:00:00.01 |     671 |
|   1 |  SORT AGGREGATE     |        |      1 |      1 |      1 |00:00:00.01 |     671 |
|   2 |   NESTED LOOPS      |        |      1 |    100M|    100 |00:00:00.01 |     671 |
|*  3 |    TABLE ACCESS FULL| T1     |      1 |  10000 |     10 |00:00:00.01 |     473 |
|*  4 |    INDEX RANGE SCAN | T2_IDX |     10 |  10000 |    100 |00:00:00.01 |     198 |
----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("T1"."COL1"=1)
   4 - access("T2"."COL1"=1)

----------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name   | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |        |      1 |        |      1 |00:00:00.01 |     220 |
|   1 |  SORT AGGREGATE                       |        |      1 |      1 |      1 |00:00:00.01 |     220 |
|   2 |   NESTED LOOPS                        |        |      1 |    100M|    100 |00:00:00.01 |     220 |
|   3 |    TABLE ACCESS BY INDEX ROWID BATCHED| T1     |      1 |  10000 |     10 |00:00:00.01 |      22 |
|*  4 |     INDEX RANGE SCAN                  | T1_IDX |      1 |  10000 |     10 |00:00:00.01 |      21 |
|*  5 |    INDEX RANGE SCAN                   | T2_IDX |     10 |  10000 |    100 |00:00:00.01 |     198 |
----------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("T1"."COL1"=1)
   5 - access("T2"."COL1"=1)


--> anscheinend keine adaptive optimization (und kein cardinality feedback)
--> TABLE ACCESS BY INDEX ROWID BATCHED: hier scheint die Angabe etwas präziser geworden zu sein 
--  und die nl batch Strategie klarer zu bezeichnen


-------------------------------------------------------------------------------

-- adaptive plan nur für erste Ausführung?
-- vgl. https://forums.oracle.com/thread/2573016

alter session set statistics_level = all;

-- creation of test tables with indexes and statistics
drop table t1;
drop table t2;

create table t1
as
select rownum id
     , mod(rownum, 10) col1
     , lpad('*', 20, '*') col2
  from dual
connect by level <= 100000;

exec dbms_stats.gather_table_stats(user, 't1')

create index t1_id_idx on t1(col1, id);

create table t2
as
select mod(rownum, 100) id_t1
     , lpad('*', 20, '*') col2
     , rownum col3
  from dual
connect by level <= 100000;

exec dbms_stats.gather_table_stats(user, 't2')

create index t2_idx on t2(id_t1);

-- a significant change of the data distribution
-- without regathering of statistics
update t1 set col1 = 1000 where id > 1;

@ trace_start

select sum(t1.col1) sum_col3
  from t1
     , t2
 where t1.id = t2.id_t1
   and t1.col1 = 1;

@ trace_stop