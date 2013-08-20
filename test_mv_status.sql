-- 23.11.2012
-- Status-Angaben für MVs
-- vgl. http://martinpreiss.blogspot.de/2012/11/status-einer-materialized-view.html

-- Basisdaten und Analysefälle
drop table test_mpr;
drop materialized view test_mv_mpr;

create table test_mpr 
as 
select rownum id
     , mod(rownum, 10) col1 
  from dual 
connect by level <= 1000;

create materialized view test_mv_mpr 
as 
select col1
     , count(*) row_count
  from test_mpr
 group by col1;

drop table test_mpr;

insert into test_mpr 
select rownum id
     , mod(rownum, 10) col1 
  from dual 
connect by level <= 1000;

commit;


-- Analyse-Queries 
select object_name
     , object_type
     , status
  from dba_objects
 where object_name = 'TEST_MV_MPR';
 
select mview_name
     , invalid
     , known_stale 
  from dba_mview_analysis 
 where mview_name = 'TEST_MV_MPR';
 
select mview_name
     , staleness
     , compile_state
  from dba_mviews
 where mview_name = 'TEST_MV_MPR'; 


