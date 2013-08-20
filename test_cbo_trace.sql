-- 18.03.2013

drop table t1;

create table t1 tablespace test_ts
as
select rownum id
     , mod(rownum, 100) col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 't1')

create index t1_col1_idx on t1(col1);

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

select *
  from t1
 where col1 = 1;

ALTER SESSION SET EVENTS '10053 trace name context OFF';