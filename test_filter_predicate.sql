-- 19.12.2013
-- https://forums.oracle.com/thread/2614597

drop table t1;
drop table t2;
drop table t3;
 
create table t1
as
select rownum col1
  from dual
connect by level <= 1000;
 
create table t2
as
select rownum col1
  from dual
connect by level <= 1000;
 
create table t3
as
select rownum col1
  from dual
connect by level <= 1000;

exec dbms_stats.gather_table_stats(user, 'T1')
exec dbms_stats.gather_table_stats(user, 'T2')
exec dbms_stats.gather_table_stats(user, 'T3') 

explain plan for
select coll, col1
  from (select 'AAA' coll, col1 from t1
          union all
        select 'BBB' coll, col1 from t2
          union all
        select 'CCC' coll, col1 from t3
       )
 where coll = 'AAA';

-----------------------------------------------------------------------------
| Id  | Operation            | Name | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |      |  1002 | 18036 |     4   (0)| 00:00:01 |
|   1 |  VIEW                |      |  1002 | 18036 |     4   (0)| 00:00:01 |
|   2 |   UNION-ALL          |      |       |       |            |          |
|   3 |    TABLE ACCESS FULL | T1   |  1000 |  4000 |     4   (0)| 00:00:01 |
|*  4 |    FILTER            |      |       |       |            |          |
|   5 |     TABLE ACCESS FULL| T2   |  1000 |  4000 |     4   (0)| 00:00:01 |
|*  6 |    FILTER            |      |       |       |            |          |
|   7 |     TABLE ACCESS FULL| T3   |  1000 |  4000 |     4   (0)| 00:00:01 |
-----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - filter(NULL IS NOT NULL)
   6 - filter(NULL IS NOT NULL)