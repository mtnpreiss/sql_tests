-- 11.12.2013
-- test_compression.sql
-- 11.1.0.7 und 12.1.0.1

drop table t_no_compress;
drop table t_basic_compress;
drop table t_oltp_compress;

create table t_no_compress
as
select rownum id
     , 10 col1
     , lpad('*', 50, '*') padding
  from dual
connect by level <= 100000;

create table t_basic_compress compress
as
select *
  from t_no_compress;
  
create table t_oltp_compress compress for oltp
as
select *
  from t_no_compress;
  

exec dbms_stats.gather_table_stats(user, 't_no_compress', estimate_percent=>0)
exec dbms_stats.gather_table_stats(user, 't_basic_compress', estimate_percent=>0)
exec dbms_stats.gather_table_stats(user, 't_oltp_compress', estimate_percent=>0)  

select table_name
     , num_rows
     , blocks 
     , compression
     , compress_for
  from user_tables where table_name in ('T_NO_COMPRESS', 'T_BASIC_COMPRESS', 'T_OLTP_COMPRESS')
 order by table_name;
  
update t_no_compress set col1 = col1 + 1;  
update t_basic_compress set col1 = col1 + 1;  
update t_oltp_compress set col1 = col1 + 1;  

exec dbms_stats.gather_table_stats(user, 't_no_compress', estimate_percent=>0)
exec dbms_stats.gather_table_stats(user, 't_basic_compress', estimate_percent=>0)
exec dbms_stats.gather_table_stats(user, 't_oltp_compress', estimate_percent=>0)  

select table_name
     , num_rows
     , blocks 
     , compression
     , compress_for
  from user_tables where table_name in ('T_NO_COMPRESS', 'T_BASIC_COMPRESS', 'T_OLTP_COMPRESS')
 order by table_name;
  
