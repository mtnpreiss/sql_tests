drop table t1;
drop table t2;

create table t1 tablespace test_ts
as
select
    mod(rownum, 250)          id,
    lpad(rownum,200)    padding
from    all_objects
where   rownum <= 2500
;

create table t2 tablespace test_ts
as
select  * from t1
;

exec dbms_stats.gather_table_stats(user, 't1')
exec dbms_stats.gather_table_stats(user, 't2')

create or replace function f (i_target in number)
return number deterministic
as
    m_target    number;
begin
    select max(id) into m_target from t1 where id <= i_target;
    return m_target;
end;
/

select  /*+ gather_plan_statistics */
    id
from    t1
minus
select
    f(id)
from    t2
;

select * from table(dbms_xplan.display_cursor(null,null,'allstats last projection'));
