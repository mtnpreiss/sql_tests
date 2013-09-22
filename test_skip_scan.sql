-- 22.01.2013
-- http://jonathanlewis.wordpress.com/2013/01/03/skip-scan-2/

drop table t1;

create table t1 tablespace test_ts
as
with generator as (
    select  --+ materialize
        rownum  id
    from    all_objects
    where   rownum <= 3000
)
select
    mod(rownum,2500)                addr_id2500,
    mod(rownum,50)                  addr_id0050,
    trunc(sysdate) + trunc(mod(rownum,2501)/3)  effective_date,
    lpad(rownum,10,'0')             small_vc,
    rpad('x',100)                   padding
from
    generator   v1,
    generator   v2
where
    rownum <= 250000
;

exec dbms_stats.gather_table_stats(user,'t1')

create index t1_i1 on t1(effective_date);
create index t1_i2500 on t1(addr_id2500, effective_date);
create index t1_i0050 on t1(addr_id0050, effective_date);


/*+ opt_param('_optimizer_cost_model','io') */

explain plan for
select /*+ opt_param('_optimizer_cost_model','io') */
    small_vc
from    t1
where
    addr_id0050 between 24 and 26
and effective_date = to_date('30.01.2013', 'dd.mm.yyyy')



drop table t2;

create table t2
as
with generator as (
    select  --+ materialize
        rownum  id
    from    all_objects
    where   rownum <= 3000
)
select
    mod(rownum,2500)                addr_id2500,
    trunc((rownum - 1) /5000)                  addr_id0050,
    trunc(sysdate) + trunc(mod(rownum,2501)/3)  effective_date,
    lpad(rownum,10,'0')             small_vc,
    rpad('x',100)                   padding
from
    generator   v1,
    generator   v2
where
    rownum <= 250000
;

exec dbms_stats.gather_table_stats(user,'t1')

create index t2_i1 on t2(effective_date);
create index t2_i2500 on t2(addr_id2500, effective_date);
create index t2_i0050 on t2(addr_id0050, effective_date);

explain plan for
select /*+ opt_param('_optimizer_cost_model','io') */
    small_vc
from    t2
where
    addr_id0050 between 24 and 26
and effective_date = to_date('30.01.2013', 'dd.mm.yyyy');


/*
Jonathan,

very interesting. 

It seems to me that the predicate section for the skip scan is a little bit misleading. With a NO_INDEX_SS-Hint I get (in 11.1.0.7) the same predicates including the filter on effective_date:

[sourcecode]
select --+ opt_param('_optimizer_cost_model','io') NO_INDEX_SS(t1)
    small_vc
from    t1
where
    addr_id0050 between 24 and 26
and effective_date = to_date('30.01.2013', 'dd.mm.yyyy');

------------------------------------------------------------------------
| Id  | Operation                   | Name     | Rows  | Bytes | Cost  |
------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |          |    24 |   528 |    89 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T1       |    24 |   528 |    89 |
|*  2 |   INDEX RANGE SCAN          | T1_I0050 |    24 |       |    64 |
------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ADDR_ID0050">=24 AND "EFFECTIVE_DATE"=TO_DATE('
              2013-01-30 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND "ADDR_ID0050"<=26)
       filter("EFFECTIVE_DATE"=TO_DATE(' 2013-01-30 00:00:00',
              'syyyy-mm-dd hh24:mi:ss'))
[/sourcecode]

So in this case the engine has to read the index for the range addr_id0050 between 24 and 26 and then only uses the entries with the fitting effective_date to do the table access. Autotrace tells me that the query uses 53 consistent gets - while the skip scan only uses 27 consistent gets. For the skip scan I assume the engine reads only the relevant parts of the index structure (i.e. the leaf_blocks with the fitting effective_date) - and so the filter predicate on effective_date seems to me to be redundant.

When I change your query to use a IN-list instead of the range I get a plan with more plausible predicates and I assume the internal work is very similar to the skip scan case (at least I also get 27 consistent gets):

[sourcecode]
select --+ opt_param('_optimizer_cost_model','io') 
    small_vc
from    t1
where
    addr_id0050 in (24, 25, 26)
and effective_date = to_date('30.01.2013', 'dd.mm.yyyy')

-------------------------------------------------------------------------
| Id  | Operation                    | Name     | Rows  | Bytes | Cost  |
-------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |          |    18 |   396 |    23 |
|   1 |  INLIST ITERATOR             |          |       |       |       |
|   2 |   TABLE ACCESS BY INDEX ROWID| T1       |    18 |   396 |    23 |
|*  3 |    INDEX RANGE SCAN          | T1_I0050 |    18 |       |     5 |
-------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access(("ADDR_ID0050"=24 OR "ADDR_ID0050"=25 OR
              "ADDR_ID0050"=26) AND "EFFECTIVE_DATE"=TO_DATE(' 2013-01-30 00:00:00',
              'syyyy-mm-dd hh24:mi:ss'))
[/sourcecode]

Regards

Martin
*/