-- 07.11.2012
-- http://martinpreiss.blogspot.de/2012/11/partitioned-outer-join.html

drop table d_test;
drop table f_test;

create table d_test (
    year number
);    

insert into d_test(year) values (2010);
insert into d_test(year) values (2011);
insert into d_test(year) values (2012);
insert into d_test(year) values (2013);

create table f_test (
    deptno number
  , year number
  , turnover number
);

insert into f_test (deptno, year, turnover) values (10, 2010, 500);
insert into f_test (deptno, year, turnover) values (10, 2011, 600);
insert into f_test (deptno, year, turnover) values (10, 2012, 500);
insert into f_test (deptno, year, turnover) values (20, 2011, 500);
insert into f_test (deptno, year, turnover) values (20, 2012, 700);

create table d_dept (
    deptno number
);

insert into d_dept (deptno) values (10);
insert into d_dept (deptno) values (20);

-- outer join
select t.deptno
     , t.year
     , r.year
     , t.turnover
  from f_test t
 right outer join
       d_test r
    on (t.year = r.year)

-- partitioned outer join
select t.deptno
     , t.year
     , r.year
     , t.turnover
  from f_test t partition by (deptno)
 right outer join
       d_test r
    on (t.year = r.year)
