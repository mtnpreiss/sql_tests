-- test_extended_stats_and_col_usage.sql
-- http://martinpreiss.blogspot.de/2012/03/extended-statistics-und-column-usage.html

-- Tabelle löschen
drop table test_extended_stats;

-- Tabelle neu anlegen
create table test_extended_stats
as
select rownum id
     , mod(rownum, 100) col1
     , mod(rownum, 100) col2
  from dual
connect by level <= 100000;

-- extended statistics anlegen
select dbms_stats.create_extended_stats(null, 'TEST_EXTENDED_STATS', '(col1, col2)') from dual;

-- Statistiken nach Anlage der virtuellen Spalte erfassen
-- exec dbms_stats.gather_table_stats(user, 'test_extended_stats')

-- Query mit Einschränkung auf col1 und col2 ausführen
select count(*) from test_extended_stats where col1 = 1 and col2 = 1;

-- dba_tab_cols vor dem dbms_stats-Aufruf
select column_name
     , sample_size
     , num_distinct
     , last_analyzed
     , histogram 
  from dba_tab_cols
 where table_name = 'TEST_EXTENDED_STATS'
 order by column_name;

-- Statistiken erzeugen 
exec dbms_stats.gather_table_stats(user, 'test_extended_stats')

-- column usage
select c.name column_name
     , u.equality_preds
     , u.timestamp
  from sys.col_usage$ u
     , sys.col$ c
 where c.obj# = u.obj#
   and c.intcol# = u.intcol#
   and u.obj# in (select object_id from dba_objects where object_name = 'TEST_EXTENDED_STATS');

-- dba_tab_cols nach dem dbms_stats-Aufruf
select column_name
     , sample_size
     , num_distinct
     , last_analyzed
     , histogram
  from dba_tab_cols
 where table_name = 'TEST_EXTENDED_STATS'
 order by column_name;

