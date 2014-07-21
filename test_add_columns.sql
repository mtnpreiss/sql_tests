-- Material
-- http://martinpreiss.blogspot.de/2014/04/add-column-ddl-optimierung-in-11g.html
-- 01.04.2014

drop table tbl_1;
create table tbl_1
as
select rownum id
     , lpad('*', 50, '*') padding
  from dual
connect by level <= 1000;
 
ALTER TABLE tbl_1 ADD (col_4 NUMBER DEFAULT 100 NOT NULL);


@ trace_10053_start

create index tbl_1_idx on tbl_1(col_4);

@ trace_10053_stop


drop table tbl_2;
create table tbl_2
as
select rownum id
     , lpad('*', 50, '*') padding
     , 100 col_4
  from dual
connect by level <= 1000;


