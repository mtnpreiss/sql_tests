-- vgl. http://martinpreiss.blogspot.de/2012/04/table-compression-und-updates.html

-- test_compression.sql
-- drop test tables
drop table t_nocompress purge;
drop table t_compress_direct purge;
drop table t_compress_oltp purge;

-- create test tables in MSSM tablespace
create table t_nocompress tablespace test_ts
as
select rownum id
     , lpad('*', 40, '*') col1 
  from dual 
connect by level <= 100000;

create table t_compress_direct tablespace test_ts
as
select *
  from t_nocompress;
  
create table t_compress_oltp tablespace test_ts
as
select *
  from t_nocompress;

-- segment size without compression
select segment_name, blocks
  from user_segments
 where segment_name like 'T%COMPRESS%';

-- compression for two tables
alter table t_compress_direct move compress;

alter table t_compress_oltp move compress for all operations;

-- size after compression
select segment_name, blocks
  from user_segments
 where segment_name like 'T%COMPRESS%';

-- compression type
select table_name
     , compression
     , compress_for
  from user_tables
 where table_name like 'T%COMPRESS%';

-- Updates for all tables
update t_nocompress set col1 = lpad('*', 10, '*');
commit;
update t_compress_direct set col1 = lpad('*', 10, '*');
commit;
update t_compress_oltp set col1 = lpad('*', 10, '*');
commit;

-- size after update
select segment_name, blocks
  from user_segments
 where segment_name like 'T%COMPRESS%';