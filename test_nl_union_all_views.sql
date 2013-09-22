-- test_NL_UNION_ALL_Views.sql
-- 28.09.2012
-- Test des Verhaltens von NL-Joins nach Ersetzung der Faktentabelle durch eine UNION ALL-View

-- Löschung der Testobjekte
drop table fact;
drop table fact2;
drop table dim;

-- Anlage Dimensionstabelle und Index
create table dim
as
select rownum id
     , mod(rownum, 10) col1
     , lpad('*', 100, '*') padding     
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 'dim')

create index dim_idx on dim(id);

-- Anlage Faktentabelle und Index
create table fact
as
select mod(rownum, 100) id
     , mod(rownum, 1000) col1
     , lpad('*', 100, '*') padding
  from dual
connect by level <= 1000000;

exec dbms_stats.gather_table_stats(user, 'fact')

create index fact_idx on fact (id);

-- Join-Query
explain plan for
select count(fact.col1)
  from dim
     , fact
 where dim.id = fact.id
   and dim.id <= 10;

select * from table(dbms_xplan.display);   

-- Anlage einer zweiten Faktentabelle (mit nur einem Satz)
create table fact2
as
select 1 id
     , 4711 col1
     , lpad('*', 100, '*') padding     
  from dual;

exec dbms_stats.gather_table_stats(user, 'fact2')  
  
create index fact2_idx on fact2(id);

-- Anlage einer UNION ALL-View für die Fakten
create or replace view v_fact
as
select * from fact
union all
select * from fact2;

-- Join-Query
explain plan for
select count(v_fact.col1)
  from dim
     , v_fact
 where dim.id = v_fact.id
   and dim.id < 10;

select * from table(dbms_xplan.display);   

-- Join-Query
explain plan for
select /*+ use_nl(dim v_fact) */ count(v_fact.col1)
  from dim
     , v_fact
 where dim.id = v_fact.id
   and dim.id < 10;

select * from table(dbms_xplan.display);   
