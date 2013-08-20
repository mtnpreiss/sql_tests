-- 25.05.2011
-- http://martinpreiss.blogspot.de/2011/05/atomicrefresh.html

-- Test: MView-Refreh mit Delete oder Truncate
-- vgl. http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:616795500346622064
-- "Beware that of course the data will disappear during the refresh - as long as you are OK with that, it'll direct path."

set timin off
prompt
prompt ****************************
prompt * MView-Refresh mit Delete *
prompt ****************************

prompt ====================
prompt Test-Objekte droppen
prompt ====================

set feedback off
drop table bi_stats_temp;
create table bi_stats_temp
( id number
, name varchar2(64)
, statistic# number
, value number);

drop table test_refresh;
set feedback on
drop materialized view mv_test_refresh;

prompt 
prompt ====================
prompt Test-Tabelle anlegen
prompt ====================

set timin on

create table test_refresh
as
select rownum id
     , lpad('*', 100, '*') pad
  from dual
connect by level <= 1000000;

prompt 
prompt ===============
prompt Test-MV anlegen
prompt ===============

create materialized view mv_test_refresh
as
select *
  from test_refresh;

set timin off

prompt 
prompt ===================
prompt Test-Tabelle leeren
prompt ===================

truncate table test_refresh;

prompt 
prompt ===========================
prompt default MV-Refresh (delete)
prompt ===========================

set feedback off
insert into bi_stats_temp
select 0
     , sn.name
     , ss.statistic#
     , ss.value
  from v$sesstat ss
     , v$statname sn
 where ss.statistic# = sn.statistic#
   and ss.sid in (select sid from v$mystat);
set feedback on

set timin on
exec dbms_mview.refresh( 'mv_test_refresh', 'C' );
set timin off
prompt

set feedback off
insert into bi_stats_temp
select 1
     , sn.name
     , ss.statistic#
     , ss.value
  from v$sesstat ss
     , v$statname sn
 where ss.statistic# = sn.statistic#
   and ss.sid in (select sid from v$mystat);
set feedback on

pause weiter mit ENTER ..

prompt
prompt ******************************
prompt * MView-Refresh mit Truncate *
prompt ******************************
prompt

prompt ====================
prompt Test-Objekte droppen
prompt ====================

set feedback off
drop table test_refresh;
set feedback on
drop materialized view mv_test_refresh;

prompt 
prompt ====================
prompt Test-Tabelle anlegen
prompt ====================

set timin on
create table test_refresh
as
select rownum id
     , lpad('*', 100, '*') pad
  from dual
connect by level <= 1000000;

prompt 
prompt ===============
prompt Test-MV anlegen
prompt ===============

create materialized view mv_test_refresh
as
select *
  from test_refresh;
set timin off

prompt 
prompt ===================
prompt Test-Tabelle leeren
prompt ===================

truncate table test_refresh;

prompt 
prompt =============================
prompt default MV-Refresh (truncate)
prompt =============================

set feedback off
insert into bi_stats_temp
select 2
     , sn.name
     , ss.statistic#
     , ss.value
  from v$sesstat ss
     , v$statname sn
 where ss.statistic# = sn.statistic#
   and ss.sid in (select sid from v$mystat);
set feedback on

set timin on
exec dbms_mview.refresh( 'mv_test_refresh', 'C', atomic_refresh => FALSE );
set timin off


set feedback off
insert into bi_stats_temp
select 3
     , sn.name
     , ss.statistic#
     , ss.value
  from v$sesstat ss
     , v$statname sn
 where ss.statistic# = sn.statistic#
   and ss.sid in (select sid from v$mystat);
set feedback on

commit;

select st_del.name
     , en_del.value - st_del.value value_delete
     , en_tru.value - st_tru.value value_truncate
     , round((en_tru.value - st_tru.value)/nullif((en_del.value - st_del.value), 0) * 100, 2) pct_tru_del
  from (select * from bi_stats_temp where id = 0) st_del
     , (select * from bi_stats_temp where id = 1) en_del
     , (select * from bi_stats_temp where id = 2) st_tru
     , (select * from bi_stats_temp where id = 3) en_tru
 where st_del.statistic# = en_del.statistic#
   and en_del.statistic# = st_tru.statistic#
   and st_tru.statistic# = en_tru.statistic#
   and st_del.statistic# in (9, 13, 58, 134, 176)
 order by 1;


-- drop table test_refresh;
-- drop table mv_test_refresh;
-- drop table bi_stats_temp;

prompt ================================================================================