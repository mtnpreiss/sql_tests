drop table tab_part;
 
create table tab_part (
    col_part number
  , padding varchar2(100)
)
partition by list (col_part)
(
    partition P00 values (0)
  , partition P01 values (1)
  , partition P02 values (2)
  , partition P03 values (3)
  , partition P04 values (4)
  , partition P05 values (5)
  , partition P06 values (6)
  , partition P07 values (7)
  , partition P08 values (8)
  , partition P09 values (9)
);
 
insert into tab_part
with
gen1 as (
select rownum from dual connect by level <= 10
)
,
gen2 as (
select mod(rownum, 10)
     , lpad('*', 100, '*')
  from dual
connect by level <= 100000
)
select gen2.*
  from gen1, gen2;
 
exec dbms_stats.gather_table_stats(user, 'tab_part')
 
drop table tab_nopart;
 
create table tab_nopart
as
select *
  from tab_part;
 
exec dbms_stats.gather_table_stats(user, 'tab_nopart')

alter system flush buffer_cache;

select count(*) from tab_part;
select count(*) from tab_nopart;
