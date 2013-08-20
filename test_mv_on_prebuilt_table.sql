-- 25.05.2011

-- Materialized View on Prebuilt Table
-- http://download.oracle.com/docs/cd/E11882_01/server.112/e16579/basicmv.htm#DWHSG8215
-- http://oraclesponge.wordpress.com/2006/04/12/a-quick-materialized-view-performance-note/

-- damit eine MV auf Basis einer Prebuilt Table f�r Query-Rewrite verwendet werden kann,
-- muss der Parameter QUERY_REWRITE_INTEGRITY auf einen geeigneten Wert gesetzt sein
-- (STALE_TOLERATED oder TRUSTED)

sho parameter QUERY_REWRITE_INTEGRITY

-- (L�schung und) Anlage einer Basistabelle mit Detaildaten
drop table base_table;
create table base_table
as
select mod(rownum, 20) group_id
     , dbms_random.value value
  from dual
connect by level < 1000000;

select * 
  from base_table
 where rownum < 10;

-- (L�schung und) Anlage einer aggregierten Tabelle
drop table mv_aggregated;
create table mv_aggregated
as
select group_id
     , sum(value) value
  from base_table
 group by group_id;

-- Anlage einer Materialized View on prebuilt table
create materialized view mv_aggregated
on prebuilt table 
enable query rewrite
as
select group_id
     , sum(value) value
  from base_table
 group by group_id;

-- enth�lt 20 S�tze (= mod(rownum, 20))
select * from mv_aggregated;

set autot trace

-- Zugriff auf Aggregation
select * from mv_aggregated;

-- kein Rewrite! --> �ber 2000 LIOs
select group_id
     , sum(value) value
  from base_table
 group by group_id;

set autot off

-- QUERY_REWRITE_INTEGRITY auf einen Wert setzen, der das Rewrite gestattet
alter session set QUERY_REWRITE_INTEGRITY = STALE_TOLERATED;

set autot trace

-- Rewrite
select group_id
     , sum(value) value
  from base_table
 group by group_id;

set autot off

-- L�schung der MView
drop materialized view mv_aggregated;

-- Tabelle bleibt erhalten
select * from mv_aggregated;

-- Parameter wird zur�ck gesetzt
alter session set QUERY_REWRITE_INTEGRITY = ENFORCED;
