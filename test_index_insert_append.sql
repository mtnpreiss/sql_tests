-- test_index_insert_append.sql
-- 03.10.2012
-- vgl. http://martinpreiss.blogspot.de/2012/10/index-aufbau-und-insert-append.html

drop table test_insert_source;
drop table test_insert_ind_recreate;
drop table test_insert_ind_maintain;

-- Anlage einer Quelltabelle mit 1M rows
create table test_insert_source
as
select rownum rn
     , mod(rownum , 2) col1
     , mod(rownum , 4) col2
     , mod(rownum , 8) col3
     , mod(rownum , 16) col4
     , lpad('*', 50, '*') col_pad
  from dual
connect by level <= 1000000;

-- Zieltabelle für Index-Anlage nach INSERT APPEND
create table test_insert_ind_recreate
as
select *
  from test_insert_source
 where 1 = 0;

-- Erstellung eines Snapshot von v$session_wait für die Test-Session
-- in einer zweiten Session:
-- create table recreate_start as
-- select *
--   from v$sesstat
--  where sid = 72;

-- Insert und folgender Aufbau der Indizes
insert /*+ append */ into test_insert_ind_recreate
select * from test_insert_source;

create index test_insert_ind_recreate_ix1 on test_insert_ind_recreate(col1);
create index test_insert_ind_recreate_ix2 on test_insert_ind_recreate(col2);
create index test_insert_ind_recreate_ix3 on test_insert_ind_recreate(col3);
create index test_insert_ind_recreate_ix4 on test_insert_ind_recreate(col4);

-- Erstellung eines Snapshot von v$session_wait für die Test-Session
-- in einer zweiten Session:
-- create table recreate_end as
-- select *
--   from v$sesstat
--  where sid = 72;


-- Zieltabelle für Index-Anlage vor INSERT APPEND
create table test_insert_ind_maintain 
as
select *
  from test_insert_source
 where 1 = 0;

-- Erstellung eines Snapshot von v$session_wait für die Test-Session
-- in einer zweiten Session:
-- create table maintain_start as
-- select *
--   from v$sesstat
--  where sid = 72;

-- Index-Anlage vor dem Insert
create index test_insert_ind_maintain_ix1 on test_insert_ind_maintain(col1);
create index test_insert_ind_maintain_ix2 on test_insert_ind_maintain(col2);
create index test_insert_ind_maintain_ix3 on test_insert_ind_maintain(col3);
create index test_insert_ind_maintain_ix4 on test_insert_ind_maintain(col4);

insert /*+ append */ into test_insert_ind_maintain
select * from test_insert_source;

-- Erstellung eines Snapshot von v$session_wait für die Test-Session
-- in einer zweiten Session:
-- create table maintain_end as
-- select *
--   from v$sesstat
--  where sid = 72;

-- Analyse-Script
with
recreate as (
select rs.statistic#
     , re.value - rs.value value_recreate
  from recreate_start rs
     , recreate_end re
 where rs.statistic# = re.statistic#
)
,
maintain as (
select ms.statistic#
     , me.value - ms.value value_maintain
  from maintain_start ms
     , maintain_end me
 where ms.statistic# = me.statistic#
)
, 
basedata as (
select recreate.statistic# statistic#
     , recreate.value_recreate
     , maintain.value_maintain
  from recreate
     , maintain
 where recreate.statistic# = maintain.statistic#
)
select sn.name
     , basedata.value_recreate
     , basedata.value_maintain
     , basedata.value_recreate - basedata.value_maintain diff
  from v$statname sn
     , basedata
 where sn.statistic# = basedata.statistic#
   and basedata.value_recreate <> basedata.value_maintain
 order by abs(basedata.value_recreate - basedata.value_maintain) desc