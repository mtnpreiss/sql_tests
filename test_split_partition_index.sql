-- 31.10.2012
-- test_split_partition_index.sql
-- Material zum Thema des Index-Zustands bei Split Partition

drop table test_mpr;

create table test_mpr (
    part_col number
  , col1 number
)
partition by list (part_col)
(
    partition part_default values (default)
)
;

insert /*+ append */ into test_mpr
select mod(rownum, 2) id
     , rownum
  from dual
connect by level <= 2000000;

commit;

insert /*+ append */ into test_mpr
select mod(rownum, 2) id
     , rownum
  from dual
connect by level <= 2000000;

commit;

create index test_mpr_ix on test_mpr (
     col1
) local;

-- Stat-Snapshot 1

alter table test_mpr
split partition part_default values(1)
into (partition p1, partition part_default)
update indexes;

-- Stat-Snapshot 2

drop table test_mpr;

create table test_mpr (
    part_col number
  , col1 number
)
partition by list (part_col)
(
    partition part_default values (default)
)
;

insert /*+ append */ into test_mpr
select mod(rownum, 2) id
     , rownum
  from dual
connect by level <= 2000000;

commit;

insert /*+ append */ into test_mpr
select mod(rownum, 2) id
     , rownum
  from dual
connect by level <= 2000000;

commit;

create index test_mpr_ix on test_mpr (
     col1
) local;

-- Snapshot 3

alter table test_mpr
split partition part_default values(1)
into (partition p1, partition part_default);

alter index TEST_MPR_IX rebuild partition P1;

alter index TEST_MPR_IX rebuild partition PART_DEFAULT;

-- Snapshot 4



drop table test_mpr;

create table test_mpr (
    part_col number
  , col1 number
)
partition by list (part_col)
(
    partition part_default values (default)
)
;

insert /*+ append */ into test_mpr
select mod(rownum, 2) id
     , rownum
  from dual
connect by level <= 2000000;

commit;

insert /*+ append */ into test_mpr
select mod(rownum, 2) id
     , rownum
  from dual
connect by level <= 2000000;

commit;

insert into test_mpr
select 3, 1 from dual;

create index test_mpr_ix on test_mpr (
     col1
) local;

alter table test_mpr
split partition part_default values(3)
into (partition p1, partition part_default)
update indexes;

drop table maintain_start;
drop table maintain_end;
drop table recreate_start;
drop table recreate_end;

create table maintain_start as
select *
  from v$sesstat
 where sid = 130;
 
create table maintain_end as
select *
  from v$sesstat
 where sid = 130; 
 
create table recreate_start as
select *
  from v$sesstat
 where sid = 130;
 
create table recreate_end as
select *
  from v$sesstat
 where sid = 130;  