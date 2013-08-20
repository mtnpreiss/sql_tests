-- vgl. http://martinpreiss.blogspot.de/2012/12/costing-fur-rownum-queries.html
-- leider liefert der Test zwar niedrige cardinality-Angaben aber keine abwegigen Join-Reihenfolgen
-- auch andere komplexere Queries (mit mehrfachem OUTER JOIN, um einen HASH JOIN OUTER hervorzurufen)
-- lieferten brauchbare Pläne

drop table test_big;
drop table test_small;

create table test_big (
    startdate date
  , col1 number
  , col2 varchar2(100)
) 
partition by list (startdate) (
    partition p1  values (to_date('31.12.2012', 'dd.mm.yyyy'))
  , partition p2  values (to_date('01.01.2013', 'dd.mm.yyyy'))
);  

insert into test_big 
select to_date('31.12.2012', 'dd.mm.yyyy') + mod(rownum, 2) startdate
     , mod(rownum, 1000) col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 100000;

create table test_small
as
select rownum col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 100;  

exec dbms_stats.gather_table_stats(user, 'test_big')
exec dbms_stats.gather_table_stats(user, 'test_small')

explain plan for
select /*+ ordered no_use_nl(b) */ *
  from test_big b
  left outer join
       test_small s
    on (b.col1 = s.col1)
 where rownum < 10;

select * from table(dbms_xplan.display);
 