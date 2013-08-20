-- 22.09.2012
-- korrelierte Spaltenstatistiken

-- der Versuch belegt (im zweiten Beispiel), dass der CBO die DISTINCT_KEYS-Angabe 
-- nur berücksichtigt, wenn alle Index-Spalten im WHERE erscheinen (was einleuchtet)

-- man könnte noch prüfen, ob die DISTINCT_KEYS als Obergrenze für Subsets gelten

-- Fall 1: komplett korreliert

drop table t;

create table t
as
select mod(rownum, 10) col1
     , mod(rownum, 10) col2
     , mod(rownum, 10) col3
  from dual
connect by level <= 100000;

exec dbms_stats.gather_table_stats(user, 'T')

create index t_idx on t(col1, col2, col3);


explain plan for
select /*+ index(t t_idx) */ * 
  from t
 where col1 = 1;

select * from table(dbms_xplan.display);

explain plan for
select /*+ index(t t_idx) */ * 
  from t
 where col1 = 1
   and col2 = 1;

select * from table(dbms_xplan.display);

explain plan for
select /*+ index(t t_idx) */ * 
  from t
 where col1 = 1
   and col2 = 1
   and col3 = 1;

select * from table(dbms_xplan.display);


-- Fall 2: teilweise korreliert

drop table t;

create table t
as
select mod(rownum, 10) col1
     , mod(rownum, 10) col2
     , trunc(rownum/ 10)  col3
  from dual
connect by level <= 100000;

exec dbms_stats.gather_table_stats(user, 'T')

create index t_idx on t(col1, col2, col3);


explain plan for
select /*+ index(t t_idx) */ 
       count(*)
  from t
 where col1 = 1;

select * from table(dbms_xplan.display);

explain plan for
select /*+ index(t t_idx) */ 
       count(*) 
  from t
 where col1 = 1
   and col2 = 1;

select * from table(dbms_xplan.display);

explain plan for
select /*+ index(t t_idx) */ 
       count(*) 
  from t
 where col1 = 1
   and col2 = 1
   and col3 = 1;

select * from table(dbms_xplan.display);
