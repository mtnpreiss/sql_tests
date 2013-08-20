-- vgl. http://martinpreiss.blogspot.de/2012/12/cost-fur-group-by.html

drop table t1;
drop table t2;

CREATE TABLE t1 AS 
  SELECT LEVEL AS id1, 
         MOD(LEVEL, 20) fil1, 
         rpad('x', 1000) padding 
    FROM dual 
  CONNECT BY LEVEL < 10000 
;

CREATE TABLE t2 AS 
  SELECT LEVEL AS id2, 
         MOD(LEVEL, 5) fil2, 
         rpad('x', 1000) padding 
    FROM dual 
  CONNECT BY LEVEL < 10000 
;

exec dbms_stats.gather_table_stats(user, 't1', method_opt => 'for all columns size 1')
exec dbms_stats.gather_table_stats(user, 't2', method_opt => 'for all columns size 1')

select * 
  from user_tab_cols
 where table_name in ('T1', 'T2');


explain plan for
SELECT 
 t1.id1 
  FROM t1, 
       t2 
 WHERE t2.id2 = t1.id1 
   AND t1.fil1 = 1 
   AND t2.fil2 = 1 
 GROUP BY t1.id1;

@ xplan

explain plan for
SELECT 
--+ OPT_PARAM('_optimizer_improve_selectivity' 'false') 
 t1.id1 
  FROM t1, 
       t2 
 WHERE t2.id2 = t1.id1 
   AND t1.fil1 = 1 
   AND t2.fil2 = 1 
 GROUP BY t1.id1;

@ xplan

drop table t3;
create table t3
as
select mod(rownum, 10) col1
     , mod(rownum, 15) col2
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 't3', method_opt => 'for all columns size 1')

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

select col1, col2, count(*)
  from t3
 group by col1, col2;

ALTER SESSION SET EVENTS '10053 trace name context OFF';


GROUP BY cardinality x, table cardinality: y
hier join cardinality

--> Sanity Check: Anzahl Sätze


drop table t4;
create table t4
as
select mod(rownum, 10) col1
     , mod(rownum, 15) col2
     , mod(rownum, 20) col3
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 't4', method_opt => 'for all columns size 1')

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

select col1, col2, col3, count(*)
  from t4
 group by col1, col2, col3;

ALTER SESSION SET EVENTS '10053 trace name context OFF';


drop table t5;
create table t5
as
select mod(rownum, 10) col1
     , mod(rownum, 15) col2
     , mod(rownum, 20) col3
     , mod(rownum, 5) col4
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 't5', method_opt => 'for all columns size 1')

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

select col1, col2, col3, col4, count(*)
  from t5
 group by col1, col2, col3, col4;

ALTER SESSION SET EVENTS '10053 trace name context OFF';

drop table t1;
drop table t2;

CREATE TABLE t1 AS 
  SELECT LEVEL AS id1, 
         MOD(LEVEL, 10) fil1, 
         MOD(LEVEL, 5) fil3, 
         rpad('x', 1000) padding 
    FROM dual 
  CONNECT BY LEVEL < 10000 
;

CREATE TABLE t2 AS 
  SELECT LEVEL AS id2, 
         MOD(LEVEL, 20) fil2, 
         MOD(LEVEL, 15) fil4, 
         rpad('x', 1000) padding 
    FROM dual 
  CONNECT BY LEVEL < 10000 
;

exec dbms_stats.gather_table_stats(user, 't1', method_opt => 'for all columns size 1')
exec dbms_stats.gather_table_stats(user, 't2', method_opt => 'for all columns size 1')

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

explain plan for
SELECT /*+ OPT_PARAM('_optimizer_improve_selectivity' 'false') */
       t1.fil1
     , t2.fil2
  FROM t1, 
       t2 
 WHERE t2.id2 = t1.id1 
   and t1.fil3 = 1 
   AND t2.fil4 = 1 
 GROUP BY t1.fil1
        , t2.fil2;

ALTER SESSION SET EVENTS '10053 trace name context OFF';
