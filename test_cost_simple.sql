-- simple costing tests
-- 15.03.2013
-- http://martinpreiss.blogspot.de/2011/04/fts-kosten-mit-noworkload-statistics-in.html
-- http://oracle-randolf.blogspot.de/2009/04/understanding-different-modes-of-system.html

-------------------------------------------------------------------------------

-- I. FTS mit Default NOWORKLOAD system statistics
exec dbms_stats.delete_system_stats;

select * from sys.aux_stats$;

/*
PNAME                               PVAL1 PVAL2
------------------------------ ---------- ----------------
STATUS                                    COMPLETED
DSTART                                    05-29-2013 17:04
DSTOP                                     05-29-2013 17:04
FLAGS                                   0
CPUSPEEDNW                       1158,909
IOSEEKTIM                              10
IOTFRSPEED                           4096
*/

drop table t1;

create table t1 tablespace test_ts pctfree 99 pctused 1
as
select rownum id
     , mod(rownum, 100) col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 't1')

/*
select * 
  from dba_segments
 where segment_name = 'T1';
*/

explain plan for
select *
  from t1;

select * from table(dbms_xplan.display());

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------
Plan hash value: 3617692013

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 10000 |  1054K|  2715   (1)| 00:00:33 |
|   1 |  TABLE ACCESS FULL| T1   | 10000 |  1054K|  2715   (1)| 00:00:33 |
--------------------------------------------------------------------------

--> 2715 statt 2710 ohne CPU-Costing

-------------------------------------------------------------------------------

-- II. FTS mit Default NOWORKLOAD system statistics, CPUSPEEDNW gesetzt

exec dbms_stats.delete_system_stats;
exec dbms_stats.set_system_stats('CPUSPEEDNW',1000000);

select * from sys.aux_stats$;

/*
PNAME                               PVAL1 PVAL2
------------------------------ ---------- ----------------
STATUS                                    COMPLETED
DSTART                                    03-15-2013 22:07
DSTOP                                     03-15-2013 22:07
FLAGS                                   1
CPUSPEEDNW                        1000000
IOSEEKTIM                              10
IOTFRSPEED                           4096
*/

drop table t1;

create table t1 tablespace test_ts pctfree 99 pctused 1
as
select rownum id
     , mod(rownum, 100) col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 't1')

explain plan for
select *
  from t1;

select * from table(dbms_xplan.display());

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------
Plan hash value: 3617692013

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 10000 |  1054K|  2710   (0)| 00:00:33 |
|   1 |  TABLE ACCESS FULL| T1   | 10000 |  1054K|  2710   (0)| 00:00:33 |
--------------------------------------------------------------------------

--> cbo trace dazu?

-------------------------------------------------------------------------------


-- III. FTS bei ermittelten NOWORKLOAD system statistics
exec dbms_stats.delete_system_stats
exec dbms_stats.gather_system_stats('noworkload')

select * from sys.aux_stats$;

/*
PNAME                               PVAL1 PVAL2
------------------------------ ---------- ----------------
STATUS                                    COMPLETED
DSTART                                    05-29-2013 17:15
DSTOP                                     05-29-2013 17:15
FLAGS                                   1
CPUSPEEDNW                       1104,212
IOSEEKTIM                          11,179
IOTFRSPEED                           4096
*/

drop table t1;

create table t1 tablespace test_ts pctfree 99 pctused 1
as
select rownum id
     , mod(rownum, 100) col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 't1')

explain plan for
select *
  from t1;

select * from table(dbms_xplan.display());

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------
Plan hash value: 3617692013

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 10000 |  1054K|  2584   (1)| 00:00:35 |
|   1 |  TABLE ACCESS FULL| T1   | 10000 |  1054K|  2584   (1)| 00:00:35 |
--------------------------------------------------------------------------

/*
MBRC: ist der Wert des Parameters DB_FILE_MULTIBLOCK_READ_COUNT
SREADTIM: IOSEEKTIM + DB_BLOCK_SIZE/IOTRFRSPEED
MREADTIM: IOSEEKTIM + _DB_FILE_MULTIBLOCK_READ_COUNT * DB_BLOCK_SIZE/IOTRFRSPEED

-- _DB_FILE_MULTIBLOCK_READ_COUNT ermitteln
-- als sys:
select i.ksppinm name
     , sv.ksppstvl value
  from x$ksppi  i
     , x$ksppsv sv
 where i.indx = sv.indx and upper(i.ksppinm) like upper('%read_count%')
*/

SREADTIM = 11.179 + 8192/4096
         = 11.179 + 2
         = 13.179

MREADTIM = 11.179 + 8 * 8192/4096
         = 11.179 + 16
         = 27.179

-- FTS cost = (Anzahl Blocks)/(_DB_FILE_MULTIBLOCK_READ_COUNT) * MREADTIM/SREADTIM
--          = 10000/8 * 27.179/13.179 = 2577,8701

exec dbms_stats.set_system_stats('CPUSPEEDNW',1000000);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------
Plan hash value: 3617692013

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 10000 |  1054K|  2579   (0)| 00:00:34 |
|   1 |  TABLE ACCESS FULL| T1   | 10000 |  1054K|  2579   (0)| 00:00:34 |
--------------------------------------------------------------------------