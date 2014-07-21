-- test ANSI outer join 
-- http://martinpreiss.blogspot.de/2014/04/zur-semantik-der-on-clause-im-ansi-left.html

drop table t1;
drop table t2;

create table t1
as
select rownum id
     , 0 col1
  from dual
connect by level <= 10;

create table t2
as
select rownum id
     , 1 col1
  from dual
connect by level <= 5;

select t1.id t1_id
     , t2.id t2_id
  from t1
  left outer join
       t2
    on (t1.id = t2.id)
 order by t1.id;

select t1.id t1_id
     , t2.id t2_id
  from t1
  left outer join
       t2
    on (t1.id = t2.id and t2.col1 = 0)
 order by t1.id;

select t1.id t1_id
     , t2.id t2_id
  from t1
  left outer join
       t2
    on (t1.id = t2.id and t1.col1 = 1)
 order by t1.id;
