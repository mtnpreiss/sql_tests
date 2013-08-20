-- 28.05.2012

drop table t_driving;

create table t_driving
as
select rownum id
     , mod(rownum, 200) col1
     , lpad('*', 100, '*') padding
  from dual
connect by level <= 100000;

drop table t_inner;

create table t_inner
as
select rownum id
     , trunc((rownum - 1)/5000) col1
     , lpad('*', 100, '*') padding
  from dual
connect by level <= 100000;

exec dbms_stats.gather_table_stats(user, 't_driving')

exec dbms_stats.gather_table_stats(user, 't_inner')

create index ix_t_driving on t_driving(col1);

create index ix_t_inner on t_inner(col1);


explain plan for
select /*+ leading(d) use_nl(d i) */
       count(*)
  from t_driving d
     , t_inner i
 where d.col1 = i.col1
   and d.col1 = 1;

@ xplan

-----------------------------------------------------------------------------------
| Id  | Operation          | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |              |     1 |     7 |  5002   (0)| 00:00:26 |
|   1 |  SORT AGGREGATE    |              |     1 |     7 |            |          |
|   2 |   NESTED LOOPS     |              |  2500K|    16M|  5002   (0)| 00:00:26 |
|*  3 |    INDEX RANGE SCAN| IX_T_DRIVING |   500 |  2000 |     2   (0)| 00:00:01 |
|*  4 |    INDEX RANGE SCAN| IX_T_INNER   |  5000 | 15000 |    10   (0)| 00:00:01 |
-----------------------------------------------------------------------------------

--> (500 * 10) + 2

-- cardinality 500 --> korrekter Wert 
--> (500 * 10) + 2
explain plan for
select /*+ leading(d) use_nl(d i) cardinality(d 500) */
       count(*)
  from t_driving d
     , t_inner i
 where d.col1 = i.col1
   and d.col1 = 1

-----------------------------------------------------------------------------------
| Id  | Operation          | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |              |     1 |     7 |  5002   (0)| 00:00:26 |
|   1 |  SORT AGGREGATE    |              |     1 |     7 |            |          |
|   2 |   NESTED LOOPS     |              |  2500K|    16M|  5002   (0)| 00:00:26 |
|*  3 |    INDEX RANGE SCAN| IX_T_DRIVING |   500 |  2000 |     2   (0)| 00:00:01 |
|*  4 |    INDEX RANGE SCAN| IX_T_INNER   |  5000 | 15000 |    10   (0)| 00:00:01 |
-----------------------------------------------------------------------------------

-- cardinality 100
--> (100 * 10) + 2

-----------------------------------------------------------------------------------
| Id  | Operation          | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |              |     1 |     7 |  1002   (0)| 00:00:06 |
|   1 |  SORT AGGREGATE    |              |     1 |     7 |            |          |
|   2 |   NESTED LOOPS     |              |   500K|  3417K|  1002   (0)| 00:00:06 |
|*  3 |    INDEX RANGE SCAN| IX_T_DRIVING |   100 |   400 |     2   (0)| 00:00:01 |
|*  4 |    INDEX RANGE SCAN| IX_T_INNER   |  5000 | 15000 |    10   (0)| 00:00:01 |
-----------------------------------------------------------------------------------

-- cardinality 50
--> (50 * 10) + 2

-----------------------------------------------------------------------------------
| Id  | Operation          | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |              |     1 |     7 |   502   (0)| 00:00:03 |
|   1 |  SORT AGGREGATE    |              |     1 |     7 |            |          |
|   2 |   NESTED LOOPS     |              |   250K|  1708K|   502   (0)| 00:00:03 |
|*  3 |    INDEX RANGE SCAN| IX_T_DRIVING |    50 |   200 |     2   (0)| 00:00:01 |
|*  4 |    INDEX RANGE SCAN| IX_T_INNER   |  5000 | 15000 |    10   (0)| 00:00:01 |
-----------------------------------------------------------------------------------

-- cardinality 10
--> (10 * 10) + 2

-----------------------------------------------------------------------------------
| Id  | Operation          | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |              |     1 |     7 |   102   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE    |              |     1 |     7 |            |          |
|   2 |   NESTED LOOPS     |              | 50000 |   341K|   102   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN| IX_T_DRIVING |    10 |    40 |     2   (0)| 00:00:01 |
|*  4 |    INDEX RANGE SCAN| IX_T_INNER   |  5000 | 15000 |    10   (0)| 00:00:01 |
-----------------------------------------------------------------------------------

