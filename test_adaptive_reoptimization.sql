-- 10.01.2015
-- http://martinpreiss.blogspot.de/2015/01/adaptive-reoptimization.html

drop table t;

create table t
as
select rownum id
     , case when rownum <= 100 then 1 else 0 end col1
  , lpad('*', 50, '*') padding
  from dual
connect by level <= 100000
;

create index t_idx on t(col1);

exec dbms_stats.gather_table_stats(user, 't', method_opt=> 'for all columns size 1')

alter system flush shared_pool;

select count(padding) from t where col1 = 0;
select * from v$sql_reoptimization_hints;

select count(padding) from t where col1 = 0;
select * from v$sql_reoptimization_hints;

select * from table(dbms_xplan.display_cursor('0cya1ntq6cnhh',null));

--exec dbms_monitor.session_trace_enable();
select count(padding) from t where col1 = 0 and sign(col1) != 1;
--exec dbms_monitor.session_trace_disable();


select * from v$sql_reoptimization_hints;
select count(padding) from t where col1 = 0 and sign(col1) != 1;
select * from v$sql_reoptimization_hints;
select * from table(dbms_xplan.display_cursor('a0wqpdz7d9r7n',null));

