-- 06.05.2012
-- http://martinpreiss.blogspot.de/2012/05/hash-join-arbeitsweise.html

drop table t1;

create table t1
as
select rownum id
     , mod(rownum, 100) col1
     , lpad('*', 100, '*') padding
  from dual
connect by level <= 1000000;

drop table t2;

create table t2
as
select rownum id
     , mod(rownum, 100) col1
     , lpad('*', 200, '*') padding
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'T1')
exec dbms_stats.gather_table_stats(user, 'T2')

explain plan for
select count(*)
  from t1, t2
 where t1.col1 = t2.col1
   and t1.col1 = 2;

select *
  from table(dbms_xplan.display);

explain plan for
select /*+ use_hash(t2) swap_join_inputs (t2) */
       count(*)
  from t1, t2
 where t1.col1 = t2.col1
   and t1.col1 = 4;

select *
  from table(dbms_xplan.display);

explain plan for
select /*+ leading(t1, t2) use_hash(t2) */
       count(*)
  from t1, t2
 where t1.col1 = t2.col1
   and t1.col1 = 1;

select *
  from table(dbms_xplan.display);

explain plan for
select /*+ ordered use_hash(t2) */
       count(*)
  from t1, t2
 where t1.col1 = t2.col1
   and t1.col1 = 1;

select *
  from table(dbms_xplan.display);

drop table t3;

create table t3
as
select rownum id
     , mod(rownum, 10) col1
     , lpad('*', 100, '*') padding
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'T3')

explain plan for
select /*+ ordered use_hash(t1 t2 t3) swap_join_inputs (t3) */
       count(*)
  from t2, t3, t1
 where t1.col1 = t2.col1
   and t2.col1 = t3.col1
   and t1.col1 = 1;

@ xplan

How to switch the driving table in a hash join [ID 171940.1]

ALTER SESSION SET EVENTS
    '10104 trace name context forever, level 10';



ALTER SESSION SET EVENTS
    '10104 trace name context off';