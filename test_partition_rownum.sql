-- 20.12.2012

drop table test_big;
drop table test_small1;
drop table test_small2;

create table test_big ( 
    startdate date
  , col1 number
  , col2 varchar2(100) 
)
partition by range (startdate) (
    partition p1 values less than (to_date('01.01.2013','dd.mm.yyyy'))
  , partition p2 values less than (to_date('01.02.2013','dd.mm.yyyy'))
);

insert into test_big
select to_date('31.12.2012', 'dd.mm.yyyy') + mod(rownum, 2) startdate
     , mod(rownum, 10) col1
     , lpad('*', 10, '*') col2
  from dual
connect by level <= 100000;

create table test_small1
as
select rownum col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 100;

create table test_small2
as
select rownum col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 100;

exec dbms_stats.gather_table_stats(user, 'test_big')
exec dbms_stats.gather_table_stats(user, 'test_small1')
exec dbms_stats.gather_table_stats(user, 'test_small2')

explain plan for
select /*+ use_hash (test_big) */
       test_big.*
     , test_small1.col2
     , test_small2.col2
  from test_big
  left outer join test_small1
    on (test_big.col1 = test_small1.col1)
  left outer join test_small2
    on (test_big.col1 = test_small2.col1)
 where test_big.col2 = lpad('*', 10, '*')
   and rownum < 10;

select * from table(dbms_xplan.display);
