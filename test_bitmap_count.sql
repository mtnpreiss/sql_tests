-- http://martinpreiss.blogspot.de/2012/06/lokale-bitmap-indizes-und-count.html

drop table stat_start;
drop table stat_end;

drop table test_partition_bidx;
create table test_partition_bidx
( id number
, startdate date
, col1 number
, padding varchar2(100) 
)
   partition by list (startdate)
  (partition p1 values ( to_date('30.06.2012','dd.mm.yyyy')),
   partition p2 values ( to_date('01.07.2012','dd.mm.yyyy')),
   partition p3 values ( to_date('02.07.2012','dd.mm.yyyy')),
   partition p4 values ( to_date('03.07.2012','dd.mm.yyyy')),
   partition p5 values ( to_date('04.07.2012','dd.mm.yyyy'))
  );

insert into test_partition_bidx
select rownum
     , to_date('30.06.2012','dd.mm.yyyy') + trunc((rownum -1)/200000) 
     , trunc(rownum - 1/10000)
     , lpad('*', 100, '*') 
  from dual 
connect by level <= 1000000;

-- Statistiken erzeugen
exec dbms_stats.gather_table_stats(user, 'test_partition_bidx')

-- bitmap index anlegen
create bitmap index ix_test_partition_bidx on test_partition_bidx(col1) local;

-- Query-Ausführung mit autotrace
-- set autot on
-- select count(*) from test_partition_bidx where startdate = '01.07.2012';


create table stat_start as select * from v$mystat;

select /* index (t) */ count(*) from test_partition_bidx t where startdate = '01.07.2012';

create table stat_end as select * from v$mystat;

with 
basedata as (
select t.STATISTIC# t#, r.STATISTIC# r#, t.value t_v, r.value r_v 
  from stat_start t 
  full outer join
       stat_end r 
  on (t.STATISTIC# = r.STATISTIC#)
)
select x.*, (select name from v$statname s where s.STATISTIC# = x.t#) name, r_v - t_v 
  from basedata x where t_v <> r_v;