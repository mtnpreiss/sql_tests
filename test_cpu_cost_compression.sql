-- http://martinpreiss.blogspot.de/2013/03/cpu-kosten-von-compression-im-sql-server.html

drop table t1;

create table t1
as
select round(rownum/1000) col1
     , mod(rownum, 1000) col2
     , round(rownum/100) col3
     , mod(rownum, 100) col4
     , round(rownum/10) col5
     , mod(rownum, 10) col6
  from dual
connect by level <= 1000000;

insert into t1
select * from t1;

insert into t1
select * from t1;

insert into t1
select * from t1;

insert into t1
select * from t1;


drop table t2;

create table t2 compress
as
select * from t1;

exec dbms_stats.gather_table_stats(user, 'T1')
exec dbms_stats.gather_table_stats(user, 'T2')

select segment_name
     , blocks
     , round(bytes/1024/1024) mbyte 
  from dba_segments
 where segment_name in ('T1', 'T2');

SEGMENT_NAME             BLOCKS      MBYTE
-------------------- ---------- ----------
T1                        35840        560
T2                        10240        160

select /*+ monitor */
       sum(col1)
     , sum(col2)
     , sum(col3)
     , sum(col4)
     , sum(col5)
     , sum(col6)
  from t1;
  
select /*+ monitor */
       sum(col1)
     , sum(col2)
     , sum(col3)
     , sum(col4)
     , sum(col5)
     , sum(col6)
  from t2;  