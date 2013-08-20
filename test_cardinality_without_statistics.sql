-- http://martinpreiss.blogspot.de/2013/01/costing-ohne-statistiken.html

drop table test_tbl purge ;

create table test_tbl (id number ) tablespace test_ts;

begin
 for i in 1 .. 10000 loop
 insert into test_tbl values (i);
 end loop;
 commit;
 end;
/

alter session set optimizer_dynamic_sampling = 0 ;

explain plan for 
select * from test_tbl where id = 9999;

select * from table(dbms_xplan.display);

alter system dump datafile 11 block 128;

alter session set events '10053 trace name context forever, level 1';
select * 
  from test_tbl
 where id = 9998;
alter session set events '10053 trace name context off';


create index test_tbl_ix on test_tbl(id) invisible;

alter system dump datafile 11 block 128;

alter session set events '10053 trace name context forever, level 1';
select * 
  from test_tbl
 where id = 9993;
alter session set events '10053 trace name context off';