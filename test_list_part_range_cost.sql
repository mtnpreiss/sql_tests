-- vgl. http://martinpreiss.blogspot.de/2012/10/cardinality-schatzung-mit-methodopt-for.html

drop table list_part;

create table list_part (
    start_date date
  , col1 number
)
partition by list (start_date) 
(
    partition P_min values (to_date('01.01.1970', 'dd.mm.yyyy'))
  , partition P201201 values (to_date('01.01.2012', 'dd.mm.yyyy'))
  , partition P201202 values (to_date('01.02.2012', 'dd.mm.yyyy'))
  , partition P201203 values (to_date('01.03.2012', 'dd.mm.yyyy'))
  , partition P201204 values (to_date('01.04.2012', 'dd.mm.yyyy'))
  , partition P201205 values (to_date('01.05.2012', 'dd.mm.yyyy'))
  , partition P201206 values (to_date('01.06.2012', 'dd.mm.yyyy'))
  , partition P201207 values (to_date('01.07.2012', 'dd.mm.yyyy'))
  , partition P201208 values (to_date('01.08.2012', 'dd.mm.yyyy'))
  , partition P201209 values (to_date('01.09.2012', 'dd.mm.yyyy'))
  , partition P201210 values (to_date('01.10.2012', 'dd.mm.yyyy'))
);

insert into list_part
select add_months(to_date('01.01.2012', 'dd.mm.yyyy'), trunc((rownum - 1)/1000) ) start_date
     , rownum col1
  from dual
connect by level <= 10000;  

exec dbms_stats.gather_table_stats(user, 'list_part')


explain plan for
select count(*) 
  from list_part
 where start_date >= to_date('20121001','yyyymmdd') 
   and start_date <= to_date('20121031','yyyymmdd');