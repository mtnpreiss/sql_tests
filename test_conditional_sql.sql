-- http://jonathanlewis.wordpress.com/2014/01/02/conditional-sql-4/
-- 02.01.2014

drop table t;

create table t (codfsc not null, coduic not null, state not null, padding)
as
select ' a' || mod(rownum, 100) codfsc
     , ' b' || mod(rownum, 100) coduic
     , mod(rownum, 2) state
     , lpad('*', 50, '*') padding
  from dual
connect by level <= 100000;

exec dbms_stats.gather_table_stats(user, 't')

create index t_i_codfsc on t(codfsc);
create index t_i_coduic on t(coduic);

create index t_fbi_codfsc on t(upper(trim(codfsc)));
create index t_fbi_coduic on t(upper(trim(coduic)));

var test1 varchar2(10)
var test2 varchar2(10)
var test3 varchar2(10)
exec :test1 := 'A2';
exec :test2 := 'A2';
exec :test3 := 'A2';

explain plan for
select * from t where state = 0 and ( upper(trim(codfsc)) = :test1 or upper(trim(coduic)) = :test2 );

select * from table(dbms_xplan.display);

explain plan for
select * from t where state = 0 and ( upper(trim(codfsc)) = :test1 or upper(trim(coduic)) = :test2 or length(:test3) is null );

select * from table(dbms_xplan.display);

explain plan for
select * from t where state = 0 and ( upper(trim(codfsc)) = :test1 or upper(trim(coduic)) = :test2 or :test3 is null );

select * from table(dbms_xplan.display);


var test4 varchar2(10)
var test5 varchar2(10)
var test6 varchar2(10)
exec :test4 := ' a2';
exec :test5 := ' a2';
exec :test6 := ' a2';

explain plan for
select * from t where state = 0 and ( codfsc = :test4 or coduic = :test5 );

select * from table(dbms_xplan.display);

explain plan for
select * from t where state = 0 and ( codfsc = :test4 or coduic = :test5 or length(:test6) is null );

select * from table(dbms_xplan.display);

explain plan for
select * from t where state = 0 and ( codfsc = :test4 or coduic = :test5 or :test6 is null );

select * from table(dbms_xplan.display);


explain plan for
select * from t where state = 0 and ( upper(trim(codfsc)) = :test1 or upper(trim(coduic)) = :test2 or case when :test3 is null then 1 else 0 end = 1 );

select * from table(dbms_xplan.display);
