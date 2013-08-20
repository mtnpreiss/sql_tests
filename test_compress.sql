-- 28.02.2011
-- http://download.oracle.com/docs/cd/E11882_01/server.112/e17118/statements_7002.htm

drop table compress_str_ordered_comp;
drop table compress_str_ordered_nocomp;
drop table compress_str_skewed_comp;
drop table compress_str_skewed_nocomp;

create table compress_str_ordered_comp compress
as
select owner
     , object_type
     , object_name
  from dba_objects
 order by owner
        , object_type
        , object_name
;

create table compress_str_ordered_nocomp 
as
select owner
     , object_type
     , object_name
  from dba_objects
 order by object_type
        , owner
        , object_name	
;

create table compress_str_skewed_comp compress
as
select owner
     , object_type
     , object_name
  from dba_objects
 order by dbms_random.value
;

create table compress_str_skewed_nocomp
as
select owner
     , object_type
     , object_name
  from dba_objects
 order by dbms_random.value
;

exec dbms_stats.gather_table_stats(user, 'compress_str_ordered_comp')
exec dbms_stats.gather_table_stats(user, 'compress_str_ordered_nocomp')
exec dbms_stats.gather_table_stats(user, 'compress_str_skewed_comp')
exec dbms_stats.gather_table_stats(user, 'compress_str_skewed_nocomp')

select table_name
     , pct_free
     , blocks
	 , compression
	 , compress_for
  from user_tables
 where table_name like 'COMPRESS_STR%';


drop table compress_str_abc;
drop table compress_str_aaa;

create table compress_str_abc compress
as
select level rn
     , 'abcdefghifklmnopqrstuvwxyz' col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'compress_str_abc')

create table compress_str_aaa compress
as
select level rn
     , 'aaaaaaaaaaaaaaaaaaaaaaaaaa' col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'compress_str_aaa')


drop table compress_str_1000000;
drop table compress_str_1000;
drop table compress_str_100;
drop table compress_str_1;

create table compress_str_1_nocomp
as
select 'aaaaaaaaaaaaaaaaaaaaaaaaaa' || 1000000 col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'compress_str_1_nocomp')

create table compress_str_1000000 compress
as
select 'aaaaaaaaaaaaaaaaaaaaaaaaaa' || (1000000 + level) col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'compress_str_1000000')

create table compress_str_1000 compress
as
select 'aaaaaaaaaaaaaaaaaaaaaaaaaa' || (1000000 + mod(level, 1000)) col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'compress_str_1000')

create table compress_str_100 compress
as
select 'aaaaaaaaaaaaaaaaaaaaaaaaaa' || (1000000 + mod(level, 100)) col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'compress_str_100')


create table compress_str_1 compress
as
select 'aaaaaaaaaaaaaaaaaaaaaaaaaa' || 1000000 col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'compress_str_1')

select table_name
     , num_distinct
  from user_tab_cols
 where column_name = 'COL1'
   and table_name like 'COMPRESS_STR%';
   
TABLE_NAME                     NUM_DISTINCT
------------------------------ ------------
COMPRESS_STR_1                            1
COMPRESS_STR_100                        100
COMPRESS_STR_1000                      1000
COMPRESS_STR_1000000                1000000

select table_name
     , pct_free
     , blocks
    , compression
    , compress_for
  from user_tables
 where table_name like 'COMPRESS_STR%';
 
TABLE_NAME                       PCT_FREE     BLOCKS COMPRESS COMPRESS_FOR
------------------------------ ---------- ---------- -------- ------------
COMPRESS_STR_1_NOCOMP                  10       5500 DISABLED
COMPRESS_STR_1000000                    0       4941 ENABLED  BASIC
COMPRESS_STR_1000                       0       4941 ENABLED  BASIC
COMPRESS_STR_100                        0       2655 ENABLED  BASIC
COMPRESS_STR_1                          0       1408 ENABLED  BASIC


create table compress_str_1_nocomp
as
select 'aaaaaaaaaaaaaaaaaaaaaaaaaa' || 1000000 col1
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'compress_str_1_nocomp')
   
drop table compress_num_ord_col1;
drop table compress_num_ord_rn;
drop table compress_num_ord_random;

create table compress_num_ord_col1 compress
as
select level rn
     , mod(level, 1000) col1
  from dual
connect by level <= 1000000
 order by mod(level, 1000);
 
exec dbms_stats.gather_table_stats(user, 'compress_num_ord_col1')
 
create table compress_num_ord_rn compress
as
select level rn
     , mod(level, 1000) col1
  from dual
connect by level <= 1000000
 order by level;
 
exec dbms_stats.gather_table_stats(user, 'compress_num_ord_rn')

create table compress_num_ord_random compress
as
select level rn
     , mod(level, 1000) col1
  from dual
connect by level <= 1000000
 order by dbms_random.value;
 
exec dbms_stats.gather_table_stats(user, 'compress_num_ord_random')

select table_name
     , pct_free
     , blocks
    , compression
    , compress_for
  from user_tables
 where table_name like 'COMPRESS_NUM%';

 
 SQL create table compress_multi_column
  2  as
  3  select case when rownum <= 10 then 'AAA'
  4              when rownum <= 20 then 'BBB'
  5              when rownum <= 30 then 'CCC'
  6         end col1
  7       , case when mod(rownum, 3) = 1 then 'AAA'
  8              when mod(rownum, 3) = 2 then 'BBB'
  9              when mod(rownum, 3) = 0 then 'CCC'
 10         end col2
 11    from dual
 12  connect by level <= 30;

Tabelle wurde erstellt.

Abgelaufen: 00:00:00.31
SQL> select dbms_rowid.rowid_block_number(rowid) blockid
  2            from compress_multi_column;

   BLOCKID
----------
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019
    134019

30 Zeilen ausgewõhlt.

Abgelaufen: 00:00:00.19
SQL> alter system dump datafile 4 block 134019;

System wurde geõndert.

drop table compress_multi_column_comp;
create table compress_multi_column_comp compress
as
select case when rownum <= 10 then 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
            when rownum <= 20 then 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
            when rownum <= 30 then 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'
       end col1
     , case when mod(rownum, 3) = 1 then 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
            when mod(rownum, 3) = 2 then 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
            when mod(rownum, 3) = 0 then 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'
       end col2
  from dual
connect by level <= 1000;

