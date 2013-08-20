-- 13.06.2012
-- https://forums.oracle.com/forums/thread.jspa?threadID=2401526&tstart=0

drop table t1;
create table t1 (
x number
,y varchar2(20)
,constraint t1_pk primary key(x)
);

create materialized view m1 
refresh complete
on demand
with primary key
as select * from t1;

drop table t2;
create table t2 (
y number
,constraint fk_test foreign key (y) references t1(x) on delete cascade initially deferred deferrable
);

insert into t1
select rownum, rownum from dual connect by level <= 10;

insert into t2
select rownum from dual connect by level <= 5;