drop table test_dim;
drop table test_fact;

create table test_dim
as
with 
generator as (
select to_date('01.01.2012', 'dd.mm.yyyy') - 1 + rownum a_date
  from dual
connect by level <= 366
)
select trunc(a_date, 'mm') a_month
     , min(a_date) min_date
     , max(a_date) max_date
  from generator
 group by trunc(a_date, 'mm')
 order by trunc(a_date, 'mm')
;

create table test_fact
as
with 
generator as (
select to_date('01.10.2012', 'dd.mm.yyyy') - 1 + rownum a_date
  from dual
connect by level <= 92
)
,
facts as (
select 1000 val
  from dual
connect by level <= 10000
)
select a_date
     , 1000 col1
  from generator
     , facts;

exec dbms_stats.gather_table_stats(user, 'test_dim')
exec dbms_stats.gather_table_stats(user, 'test_fact')

explain plan for
with
date_range as (
select /*+ materialize */
       a_month
     , min_date
     , max_date
  from test_dim
 where a_month >= to_date('01.10.2012', 'dd.mm.yyyy')
)
select a_month
     , count(*)
  from date_range
  join test_fact
    on (test_fact.a_date between date_range.min_date and date_range.max_date)
 group by a_month
;

select * from table(dbms_xplan.display);

explain plan for
with
date_range as (
select /*+ inline */
       a_month
     , min_date
     , max_date
  from test_dim
 where a_month >= to_date('01.10.2012', 'dd.mm.yyyy')
)
select a_month
     , count(*)
  from date_range
  join test_fact
    on (test_fact.a_date between date_range.min_date and date_range.max_date)
 group by a_month
;

select * from table(dbms_xplan.display);


ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';

with
date_range as (
select /*+ materialize */
       a_month
     , min_date
     , max_date
  from test_dim
 where a_month >= to_date('01.10.2012', 'dd.mm.yyyy')
)
select a_month
     , count(*)
  from date_range
  join test_fact
    on (test_fact.a_date between date_range.min_date and date_range.max_date)
 group by a_month
 order by a_month;
ALTER SESSION SET EVENTS '10053 trace name context OFF';


explain plan for
with
date_range as (
select /*+ inline */
       a_month
     , min_date
     , max_date
  from test_dim
 where a_month = to_date('01.12.2012', 'dd.mm.yyyy')
)
select a_month
     , count(*)
  from date_range
  join test_fact
    on (test_fact.a_date <= date_range.min_date)
 group by a_month

Plan hash value: 754084496

----------------------------------------------------------------------------------
| Id  | Operation            | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |           |     1 |    24 |  1045   (0)| 00:00:06 |
|   1 |  SORT GROUP BY NOSORT|           |     1 |    24 |  1045   (0)| 00:00:06 |
|   2 |   NESTED LOOPS       |           | 78828 |  1847K|  1045   (0)| 00:00:06 |
|*  3 |    TABLE ACCESS FULL | TEST_DIM  |     1 |    16 |     4   (0)| 00:00:01 |
|*  4 |    TABLE ACCESS FULL | TEST_FACT | 78828 |   615K|  1041   (0)| 00:00:06 |
----------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("A_MONTH"=TO_DATE(' 2012-01-01 00:00:00', 'syyyy-mm-dd
              hh24:mi:ss'))
   4 - filter("TEST_FACT"."A_DATE"<="MIN_DATE")

explain plan for
with
date_range as (
select /*+ inline */
       a_month
     , min_date
     , max_date
  from test_dim
 where a_month = to_date('01.01.2012', 'dd.mm.yyyy')
)
select a_month
     , count(*)
  from date_range
  join test_fact
    on (test_fact.a_date >= date_range.min_date)
 group by a_month

----------------------------------------------------------------------------------
| Id  | Operation            | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |           |     1 |    24 |  1045   (0)| 00:00:06 |
|   1 |  SORT GROUP BY NOSORT|           |     1 |    24 |  1045   (0)| 00:00:06 |
|   2 |   NESTED LOOPS       |           |   835K|    19M|  1045   (0)| 00:00:06 |
|*  3 |    TABLE ACCESS FULL | TEST_DIM  |     1 |    16 |     4   (0)| 00:00:01 |
|*  4 |    TABLE ACCESS FULL | TEST_FACT |   835K|  6529K|  1041   (0)| 00:00:06 |
----------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("A_MONTH"=TO_DATE(' 2012-01-01 00:00:00', 'syyyy-mm-dd
              hh24:mi:ss'))
   4 - filter("TEST_FACT"."A_DATE">="MIN_DATE")