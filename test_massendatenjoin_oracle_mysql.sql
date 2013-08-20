-- http://martinpreiss.blogspot.de/2013/05/mysql-gefangen-im-nested-loop.html

drop table t1;
drop table t2;

create table t1
as
with 
generator1
as (
select rownum col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 1000)
,
generator2
as (
select rownum id
  from dual 
connect by level <= 32)
select generator1.*
  from generator1
     , generator2
 order by generator2.id
        , generator1.col1;
        
create table t2
as
select * from t1;        
        
exec dbms_stats.gather_table_stats(user, 'T1')        
exec dbms_stats.gather_table_stats(user, 'T2')

explain plan for
select count(*)
  from t1, t2
 where t1.col1 = t2.col1;
 
 
 
use world;

drop table t1;
drop table t2;

set @NUM = 0;

create table t1
select @NUM:=@NUM+1 col1
     , repeat('*', 100) col2
  from city t 
 limit 1000;

insert into t1
select * from t1;

insert into t1
select * from t1;

insert into t1
select * from t1;

insert into t1
select * from t1;

insert into t1
select * from t1;

create table t2
select * from t1;

explain
select count(*)
  from t1, t2
 where t1.col1 = t2.col1;
 
 
  