-- http://martinpreiss.blogspot.de/2013/09/cardinality-ohne-spaltenstatistiken.html

drop table t;

create table t
as
select 'testtesttesttesttest' || rownum id
 --    , mod(rownum, 10) col2
     , lpad('*', 50, '*') padding
  from dual
connect by level <= 100000;

-- alter table t add constraint t_pk primary key (id, col2);
alter table t add constraint t_pk primary key (id);

exec dbms_stats.gather_table_stats(user, 'T')


-- with column statistics
explain plan for
select *
  from t
 where id = 'testtesttesttesttest1';

select * from table(dbms_xplan.display);

explain plan for
select *
  from t
 where id in ('testtesttesttesttest1'
              );

select * from table(dbms_xplan.display);

explain plan for
select *
  from t
 where id in ('testtesttesttesttest1'
            , 'testtesttesttesttest2'
              );

select * from table(dbms_xplan.display);

explain plan for
select *
  from t
 where id in ('testtesttesttesttest1'
            , 'testtesttesttesttest2'
            , 'testtesttesttesttest3'
            , 'testtesttesttesttest4'
            , 'testtesttesttesttest5'
            , 'testtesttesttesttest6'
            , 'testtesttesttesttest7'
            , 'testtesttesttesttest8'
            , 'testtesttesttesttest9'
            , 'testtesttesttesttest10'
            , 'testtesttesttesttest11'
            , 'testtesttesttesttest12'
            , 'testtesttesttesttest13'
            , 'testtesttesttesttest14'
            , 'testtesttesttesttest15'
            , 'testtesttesttesttest16'
            , 'testtesttesttesttest17'
            , 'testtesttesttesttest18'
            , 'testtesttesttesttest19'
            , 'testtesttesttesttest20'
              );

select * from table(dbms_xplan.display);

exec dbms_stats.delete_column_stats(user, 'T', 'ID')
-- exec dbms_stats.delete_column_stats(user, 'T', 'COL2')

-- without column statistics
explain plan for
select *
  from t
 where id = 'testtesttesttesttest1';

select * from table(dbms_xplan.display);

explain plan for
select *
  from t
 where id in ('testtesttesttesttest1'
              );

select * from table(dbms_xplan.display);

explain plan for
select *
  from t
 where id in ('testtesttesttesttest1'
            , 'testtesttesttesttest2'
              );

select * from table(dbms_xplan.display);

explain plan for
select *
  from t
 where id in ('testtesttesttesttest1'
            , 'testtesttesttesttest2'
            , 'testtesttesttesttest3'
            , 'testtesttesttesttest4'
            , 'testtesttesttesttest5'
            , 'testtesttesttesttest6'
            , 'testtesttesttesttest7'
            , 'testtesttesttesttest8'
            , 'testtesttesttesttest9'
            , 'testtesttesttesttest10'
            , 'testtesttesttesttest11'
            , 'testtesttesttesttest12'
            , 'testtesttesttesttest13'
            , 'testtesttesttesttest14'
            , 'testtesttesttesttest15'
            , 'testtesttesttesttest16'
            , 'testtesttesttesttest17'
            , 'testtesttesttesttest18'
            , 'testtesttesttesttest19'
            , 'testtesttesttesttest20'
              );

select * from table(dbms_xplan.display);
