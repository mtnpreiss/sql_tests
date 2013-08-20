-- vgl. http://martinpreiss.blogspot.de/2013/02/bestimmung-der-compression-von-tabellen.html

drop table test_part_compress;

create table test_part_compress ( 
    startdate date
  , col1 number
  , col2 varchar2(100) 
)
partition by range (startdate) (
    partition p1 values less than (to_date('01.01.2013','dd.mm.yyyy'))
  , partition p2 values less than (to_date('01.02.2013','dd.mm.yyyy'))
) tablespace test_ts;

insert into test_part_compress
select to_date('31.12.2012', 'dd.mm.yyyy') + mod(rownum, 2) startdate
     , mod(rownum, 10) col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 10000;

exec dbms_stats.gather_table_stats(user, 'test_part_compress')

select partition_name
     , num_rows
     , blocks
     , compression
     , compress_for
  from dba_tab_partitions
 where table_name = upper('test_part_compress');

alter table test_part_compress modify partition p1 compress;

exec dbms_stats.gather_table_stats(user, 'test_part_compress')

select partition_name
     , num_rows
     , blocks
     , compression
     , compress_for
  from dba_tab_partitions
 where table_name = upper('test_part_compress');

alter table test_part_compress move partition p1;

exec dbms_stats.gather_table_stats(user, 'test_part_compress')

select partition_name
     , num_rows
     , blocks
     , compression
     , compress_for
  from dba_tab_partitions
 where table_name = upper('test_part_compress');

alter table test_part_compress modify partition p1 nocompress;

select partition_name
     , num_rows
     , blocks
     , compression
     , compress_for
  from dba_tab_partitions
 where table_name = upper('test_part_compress');

select subobject_name
     , data_object_id
  from dba_objects
 where object_name = 'test_part_compress'
   and subobject_name is not null;

select dbms_rowid.rowid_object(rowid) object
     , dbms_compression.get_compression_type(user, 'TEST_PART_COMPRESS', rowid) compression_type
     , count(*) cnt
  from test_part_compress
 group by dbms_rowid.rowid_object(rowid)
        , dbms_compression.get_compression_type(user, 'TEST_PART_COMPRESS', rowid);

------------------------------------------------------

-- Test OTN
drop table test_part_compress;

create table test_part_compress ( 
    startdate date
  , col1 number
  , col2 varchar2(100) 
)
partition by range (startdate) (
    partition p1 values less than (to_date('01.01.2013','dd.mm.yyyy'))
  , partition p2 values less than (to_date('01.02.2013','dd.mm.yyyy'))
) tablespace test_ts;

insert into test_part_compress
select to_date('31.12.2012', 'dd.mm.yyyy') + mod(rownum, 2) startdate
     , mod(rownum, 10) col1
     , lpad('*', 100, '*') col2
  from dual
connect by level <= 10000;

alter table test_part_compress modify partition p1 compress;
alter table test_part_compress move partition p1;
alter table test_part_compress modify partition p1 nocompress;
exec dbms_stats.gather_table_stats(user, 'test_part_compress')

select partition_name
     , num_rows
     , blocks
     , compression
     , compress_for
  from dba_tab_partitions
 where table_name = upper('test_part_compress');

select subobject_name
     , data_object_id
  from dba_objects
 where object_name = 'TEST_PART_COMPRESS'
   and subobject_name is not null;

select dbms_rowid.rowid_object(rowid) object
     , dbms_compression.get_compression_type(user, 'TEST_PART_COMPRESS', rowid) compression_type
     , count(*) cnt
  from test_part_compress
 group by dbms_rowid.rowid_object(rowid)
        , dbms_compression.get_compression_type(user, 'TEST_PART_COMPRESS', rowid);

select block#
     , blocks
     , bitand(spare1, 2048) compression_defined
     , bitand(spare1, 4096) compressed
  from sys.seg$ t
 where file# = 5
   and BLOCK# in (select header_block
                    from dba_segments
                   where segment_name = 'TEST_PART_COMPRESS');

update test_part_compress set col1 = 1 where col1 = 2;

select dbms_rowid.rowid_object(rowid) object
     , dbms_compression.get_compression_type(user, 'TEST_PART_COMPRESS', rowid) compression_type
     , count(*) cnt
  from test_part_compress
 group by dbms_rowid.rowid_object(rowid)
        , dbms_compression.get_compression_type(user, 'TEST_PART_COMPRESS', rowid);

select block#
     , blocks
     , bitand(spare1, 2048) compression_defined
     , bitand(spare1, 4096) compressed
  from sys.seg$ t
 where file# = 5
   and BLOCK# in (select header_block
                    from dba_segments
                   where segment_name = 'TEST_PART_COMPRESS');

