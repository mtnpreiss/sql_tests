-- ora-32036 bei MV-Anlage
-- als Query funktioniert die Abfrage problemlos
-- vgl. http://martinpreiss.blogspot.de/2012/10/materialized-views-und-ora-32036.html

drop materialized view test_mpr;
drop table test_base_mpr;
drop table test_add_mpr;

create table test_base_mpr
as
select rownum id
     , mod(rownum, 2) col1
  from dual
connect by level <= 100;

create table test_add_mpr
as
select rownum col1
  from dual
connect by level <= 10;


create materialized view test_mpr
as
with
basedata as (
select test_base_mpr.id
     , test_base_mpr.col1
  from test_base_mpr
  left outer join 
       test_add_mpr
    on (test_base_mpr.col1 = test_add_mpr.col1)
)
,
basedata_filtered as (
select * 
  from basedata
 where id <= 50
)
,
basedata_grouped as (
select col1
     , count(*) count_id
  from basedata_filtered
 group by col1
)
select basedata_filtered.col1
     , basedata_grouped.count_id
  from basedata_filtered
  left outer join
       basedata_grouped
    on basedata_filtered.col1 = basedata_grouped.col1
 order by basedata_filtered.col1;
-- ORA-32036: Nicht unterstützte Schreibweise für Inlining von Abfrage-Name in WITH-Klausel
 

create materialized view test_mpr
as
with
basedata_filtered as (
select *
  from (select test_base_mpr.id
             , test_base_mpr.col1
          from test_base_mpr
          left outer join
               test_add_mpr
            on (test_base_mpr.col1 = test_add_mpr.col1)
        ) basedata
 where id <= 50
)
,
basedata_grouped as (
select col1
     , count(*) count_id
  from basedata_filtered
 group by col1
)
select basedata_filtered.col1
     , basedata_grouped.count_id
  from basedata_filtered
  left outer join
       basedata_grouped
    on basedata_filtered.col1 = basedata_grouped.col1
 order by basedata_filtered.col1;
 
 
/*
----------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |                             |    50 |  1950 |    13  (24)| 00:00:01 |
|   1 |  TEMP TABLE TRANSFORMATION |                             |       |       |            |          |
|   2 |   LOAD AS SELECT           |                             |       |       |            |          |
|   3 |    VIEW                    |                             |    50 |  1300 |     7  (15)| 00:00:01 |
|   4 |     VIEW                   |                             |    50 |  1300 |     7  (15)| 00:00:01 |
|*  5 |      HASH JOIN OUTER       |                             |    50 |  1950 |     7  (15)| 00:00:01 |
|*  6 |       TABLE ACCESS FULL    | TEST_BASE_MPR               |    50 |  1300 |     3   (0)| 00:00:01 |
|   7 |       TABLE ACCESS FULL    | TEST_ADD_MPR                |    10 |   130 |     3   (0)| 00:00:01 |
|   8 |   SORT ORDER BY            |                             |    50 |  1950 |     7  (43)| 00:00:01 |
|*  9 |    HASH JOIN OUTER         |                             |    50 |  1950 |     6  (34)| 00:00:01 |
|  10 |     VIEW                   |                             |    50 |   650 |     2   (0)| 00:00:01 |
|  11 |      TABLE ACCESS FULL     | SYS_TEMP_0FD9D662D_26D541FE |    50 |  1300 |     2   (0)| 00:00:01 |
|  12 |     VIEW                   |                             |     2 |    52 |     3  (34)| 00:00:01 |
|  13 |      HASH GROUP BY         |                             |     2 |    26 |     3  (34)| 00:00:01 |
|  14 |       VIEW                 |                             |    50 |   650 |     2   (0)| 00:00:01 |
|  15 |        TABLE ACCESS FULL   | SYS_TEMP_0FD9D662D_26D541FE |    50 |  1300 |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$596C533B
   2 - SEL$3
   3 - SEL$6        / BASEDATA@SEL$3
   4 - SEL$9834E3F4 / from$_subquery$_004@SEL$6
   5 - SEL$9834E3F4
   6 - SEL$9834E3F4 / TEST_BASE_MPR@SEL$5
   7 - SEL$9834E3F4 / TEST_ADD_MPR@SEL$4
  10 - SEL$F065AEA3 / BASEDATA_FILTERED@SEL$2
  11 - SEL$F065AEA3 / T1@SEL$F065AEA3
  12 - SEL$7        / BASEDATA_GROUPED@SEL$1
  13 - SEL$7
  14 - SEL$F065AEA4 / BASEDATA_FILTERED@SEL$7
  15 - SEL$F065AEA4 / T1@SEL$F065AEA4

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("TEST_BASE_MPR"."COL1"="TEST_ADD_MPR"."COL1"(+))
   6 - filter("TEST_BASE_MPR"."ID"<=50)
   9 - access("BASEDATA_FILTERED"."COL1"="BASEDATA_GROUPED"."COL1"(+))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "BASEDATA_FILTERED"."COL1"[NUMBER,22], "BASEDATA_GROUPED"."COUNT_ID"[NUMBER,22]
   2 - SYSDEF[4], SYSDEF[0], SYSDEF[1], SYSDEF[84], SYSDEF[0]
   3 - "ID"[NUMBER,22], "BASEDATA"."COL1"[NUMBER,22]
   4 - "TEST_BASE_MPR"."ID"[NUMBER,22], "TEST_BASE_MPR"."COL1"[NUMBER,22]
   5 - (#keys=1) "TEST_BASE_MPR"."COL1"[NUMBER,22], "TEST_ADD_MPR"."COL1"[NUMBER,22],
       "TEST_BASE_MPR"."ID"[NUMBER,22]
   6 - "TEST_BASE_MPR"."ID"[NUMBER,22], "TEST_BASE_MPR"."COL1"[NUMBER,22]
   7 - "TEST_ADD_MPR"."COL1"[NUMBER,22]
   8 - (#keys=1) "BASEDATA_FILTERED"."COL1"[NUMBER,22], "BASEDATA_GROUPED"."COUNT_ID"[NUMBER,22]
   9 - (#keys=1) "BASEDATA_FILTERED"."COL1"[NUMBER,22], "BASEDATA_GROUPED"."COL1"[NUMBER,22],
       "BASEDATA_GROUPED"."COUNT_ID"[NUMBER,22]
  10 - "BASEDATA_FILTERED"."COL1"[NUMBER,22]
  11 - "C0"[NUMBER,22], "C1"[NUMBER,22]
  12 - "BASEDATA_GROUPED"."COL1"[NUMBER,22], "BASEDATA_GROUPED"."COUNT_ID"[NUMBER,22]
  13 - (#keys=1) "COL1"[NUMBER,22], COUNT(*)[22]
  14 - "COL1"[NUMBER,22]
  15 - "C0"[NUMBER,22], "C1"[NUMBER,22]

Note
-----
   - dynamic sampling used for this statement

----------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |                             |    50 |  1950 |    13  (24)| 00:00:01 |
|   1 |  TEMP TABLE TRANSFORMATION |                             |       |       |            |          |
|   2 |   LOAD AS SELECT           |                             |       |       |            |          |
|   3 |    VIEW                    |                             |    50 |  1300 |     7  (15)| 00:00:01 |
|   4 |     VIEW                   |                             |    50 |  1300 |     7  (15)| 00:00:01 |
|*  5 |      HASH JOIN OUTER       |                             |    50 |  1950 |     7  (15)| 00:00:01 |
|*  6 |       TABLE ACCESS FULL    | TEST_BASE_MPR               |    50 |  1300 |     3   (0)| 00:00:01 |
|   7 |       TABLE ACCESS FULL    | TEST_ADD_MPR                |    10 |   130 |     3   (0)| 00:00:01 |
|   8 |   SORT ORDER BY            |                             |    50 |  1950 |     7  (43)| 00:00:01 |
|*  9 |    HASH JOIN OUTER         |                             |    50 |  1950 |     6  (34)| 00:00:01 |
|  10 |     VIEW                   |                             |    50 |   650 |     2   (0)| 00:00:01 |
|  11 |      TABLE ACCESS FULL     | SYS_TEMP_0FD9D6627_26D541FE |    50 |  1300 |     2   (0)| 00:00:01 |
|  12 |     VIEW                   |                             |     2 |    52 |     3  (34)| 00:00:01 |
|  13 |      HASH GROUP BY         |                             |     2 |    26 |     3  (34)| 00:00:01 |
|  14 |       VIEW                 |                             |    50 |   650 |     2   (0)| 00:00:01 |
|  15 |        TABLE ACCESS FULL   | SYS_TEMP_0FD9D6627_26D541FE |    50 |  1300 |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$596C533B
   2 - SEL$6
   3 - SEL$5        / BASEDATA@SEL$6
   4 - SEL$37633EB5 / from$_subquery$_003@SEL$5
   5 - SEL$37633EB5
   6 - SEL$37633EB5 / TEST_BASE_MPR@SEL$4
   7 - SEL$37633EB5 / TEST_ADD_MPR@SEL$3
  10 - SEL$BB173B6F / BASEDATA_FILTERED@SEL$2
  11 - SEL$BB173B6F / T1@SEL$BB173B6F
  12 - SEL$7        / BASEDATA_GROUPED@SEL$1
  13 - SEL$7
  14 - SEL$BB173B70 / BASEDATA_FILTERED@SEL$7
  15 - SEL$BB173B70 / T1@SEL$BB173B70

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("TEST_BASE_MPR"."COL1"="TEST_ADD_MPR"."COL1"(+))
   6 - filter("TEST_BASE_MPR"."ID"<=50)
   9 - access("BASEDATA_FILTERED"."COL1"="BASEDATA_GROUPED"."COL1"(+))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "BASEDATA_FILTERED"."COL1"[NUMBER,22], "BASEDATA_GROUPED"."COUNT_ID"[NUMBER,22]
   2 - SYSDEF[4], SYSDEF[0], SYSDEF[1], SYSDEF[84], SYSDEF[0]
   3 - "ID"[NUMBER,22], "BASEDATA"."COL1"[NUMBER,22]
   4 - "TEST_BASE_MPR"."ID"[NUMBER,22], "TEST_BASE_MPR"."COL1"[NUMBER,22]
   5 - (#keys=1) "TEST_BASE_MPR"."COL1"[NUMBER,22], "TEST_ADD_MPR"."COL1"[NUMBER,22],
       "TEST_BASE_MPR"."ID"[NUMBER,22]
   6 - "TEST_BASE_MPR"."ID"[NUMBER,22], "TEST_BASE_MPR"."COL1"[NUMBER,22]
   7 - "TEST_ADD_MPR"."COL1"[NUMBER,22]
   8 - (#keys=1) "BASEDATA_FILTERED"."COL1"[NUMBER,22], "BASEDATA_GROUPED"."COUNT_ID"[NUMBER,22]
   9 - (#keys=1) "BASEDATA_FILTERED"."COL1"[NUMBER,22], "BASEDATA_GROUPED"."COL1"[NUMBER,22],
       "BASEDATA_GROUPED"."COUNT_ID"[NUMBER,22]
  10 - "BASEDATA_FILTERED"."COL1"[NUMBER,22]
  11 - "C0"[NUMBER,22], "C1"[NUMBER,22]
  12 - "BASEDATA_GROUPED"."COL1"[NUMBER,22], "BASEDATA_GROUPED"."COUNT_ID"[NUMBER,22]
  13 - (#keys=1) "COL1"[NUMBER,22], COUNT(*)[22]
  14 - "COL1"[NUMBER,22]
  15 - "C0"[NUMBER,22], "C1"[NUMBER,22]
*/  