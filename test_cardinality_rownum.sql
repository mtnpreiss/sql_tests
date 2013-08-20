-- 19.12.2012

drop table t1;
drop table t2;

create table t1
as
select rownum id
     , lpad('*', 100, '*') col1
  from dual
connect by level <= 100;

create table t2
as
select rownum id
     , lpad('*', 100, '*') col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'T1')
exec dbms_stats.gather_table_stats(user, 'T2')

create or replace view v1
as
select *
  from t2;

explain plan for
select count(v1.col1)
  from t1
  left outer join
       v1
    on t1.id = v1.id
 where rownum < 10;

@ xplan
