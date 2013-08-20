drop table test_free_space;

create table test_free_space tablespace TEST_TS
as
select rownum id
  from dual
;

select dbms_rowid.rowid_relative_fno(rowid) file_no
     , dbms_rowid.rowid_block_number(rowid) block_no
  from test_free_space;

alter system dump datafile 5 block min 94849 block max 94849;

fsbo=0x14
fseo=0x1f7f
avsp=0x1f6b
tosp=0x1f6b

alter table test_free_space move;

fsbo=0x14
fseo=0x1f7f
avsp=0x1f6b
tosp=0x1f6b



drop table test_free_space ;
drop table test2_free_space ;

drop CLUSTER test_cluster;
CREATE CLUSTER test_cluster
   (id NUMBER(4))
SIZE 512
tablespace TEST_TS
;
CREATE INDEX test_cluster_ix ON CLUSTER test_cluster;

create table test_free_space 
(id number(4))
cluster test_cluster(id)
;

create table test2_free_space 
(id number(4))
cluster test_cluster(id)
;

insert into test_free_space values(1);
insert into test2_free_space values(1);

insert into test2_free_space
select rownum id
  from dual 
connect by level <= 1000;


create table test_free_space tablespace TEST_TS
as
select rownum id
  from dual
;

alter table test_free_space minimize records_per_block;

alter system dump datafile 5 block min 138505 block max 138505;

select object_id 
  from user_objects 
 where object_name = 'TEST_FREE_SPACE';

select rowcnt
     , blkcnt
     , spare1
  from sys.tab$
 where obj# = 101401;

drop table test_free_space;

create table test_free_space tablespace TEST_TS
as
select rownum id
     , lpad('*', 100, '*') padding
  from dual
connect by level <= 1000
;

select id
     , dbms_rowid.rowid_relative_fno(rowid) file_no
     , dbms_rowid.rowid_block_number(rowid) block_no
  from test_free_space
 where rownum < 10;

alter system dump datafile 5 block min 155929 block max 155929;

alter table test_free_space compress;

alter table test_free_space move;

alter system dump datafile 5 block min 155953 block max 155953;

fsbo=0x5c6
fseo=0x639
avsp=0x9
tosp=0x9
--> 0x639 - 0x5c6 ==> 115 byte (statt 9 byte)

alter system dump datafile 5 block min 155937 block max 155937;


drop table test_free_space;

create table test_free_space tablespace TEST_TS pctfree 90 pctused 10
as
select rownum id
     , lpad('*', 100, '*') padding
  from dual
connect by level <= 1000
;

alter table test_free_space move;

select id
     , dbms_rowid.rowid_relative_fno(rowid) file_no
     , dbms_rowid.rowid_block_number(rowid) block_no
  from test_free_space
 where rownum < 10;

alter system dump datafile 5 block min 195129 block max 195129;

fsbo=0x20
fseo=0x1c9b
avsp=0x1c7b
tosp=0x1c7b


drop table test_free_space;

create table test_free_space tablespace TEST_TS
as
select rownum id
     , lpad('*', 10, '*') padding
  from dual
connect by level <= 10000
;

alter table test_free_space compress;

alter table test_free_space move;

select id
     , dbms_rowid.rowid_relative_fno(rowid) file_no
     , dbms_rowid.rowid_block_number(rowid) block_no
  from test_free_space
 where rownum < 10;

alter system dump datafile 5 block min 353 block max 353;


fsbo=0x5d6
fseo=0x64d
avsp=0xd
tosp=0xd

--> 119 statt 13

-- 11.2.0.1
-- db_block_size: 8K
-- MSSM TS

drop table test_free_space;

create table test_free_space tablespace test_ts
as
select mod(rownum, 10) id
     , lpad('*', 10, '*') padding
  from dual
connect by level <= 10000
;

alter table test_free_space compress;

alter table test_free_space move;

select id
     , dbms_rowid.rowid_relative_fno(rowid) file_no
     , dbms_rowid.rowid_block_number(rowid) block_no
  from test_free_space
 where rownum < 10;

alter system dump datafile 5 block min 155929 block max 155929;

fsbo=0x5d4
fseo=0x113a
avsp=0x36
tosp=0x36

0x113a - 0x5d4 = B66 => 2918


drop table test_free_space;

create table test_free_space tablespace test_ts
as
select mod(rownum, 10) id
     , lpad('*', 10, '*') padding
  from dual
connect by level <= 10000
;

select id
     , dbms_rowid.rowid_relative_fno(rowid) file_no
     , dbms_rowid.rowid_block_number(rowid) block_no
  from test_free_space
 where rownum < 10;

-------------------------------------------------------------------------------

Jonathan,

some ideas without a meaningful order:
1. table cluster - though you said "simple heap table"; but then I realized that COMPRESS and MOVE don't work for table clusters (like most people I don't use them frequently). Apart from this there is no difference between tosp and (fseo-fsbo) after object creation.
2. minimize records_per_block: has also no effect on the space measures
3. pctfree: has no effect on the space measures
4. basic compression (as suggested by GregG)

[sourcecode]
-- 11.2.0.1
-- db_block_size: 8K
-- MSSM TS

drop table test_free_space;

create table test_free_space tablespace test_ts
as
select mod(rownum, 10) id
     , lpad('*', 10, '*') padding
  from dual
connect by level <= 10000;

alter table test_free_space compress;

alter table test_free_space move;

select id
     , dbms_rowid.rowid_relative_fno(rowid) file_no
     , dbms_rowid.rowid_block_number(rowid) block_no
  from test_free_space
 where rownum < 3;

ID    FILE_NO   BLOCK_NO
-- ---------- ----------
 1          5     155929
 2          5     155929

alter system dump datafile 5 block min 155929 block max 155929;
[/sourcecode]

In the block dump I see:

fsbo=0x5d4
fseo=0x113a
avsp=0x36
tosp=0x36

0x113a - 0x5d4 = B66 => 2918 (instead of 0x36 => 54). 

The fseo=0x113a corresponds with the offset of the last (or better: first) record 726

[sourcecode]
0x1e:pti[0]	nrow=11	offs=0
0x22:pti[1]	nrow=716	offs=11
0x26:pri[0]	offs=0x1f51
0x28:pri[1]	offs=0x1f58
0x2a:pri[2]	offs=0x1f5f
0x2c:pri[3]	offs=0x1f66
0x2e:pri[4]	offs=0x1f6d
0x30:pri[5]	offs=0x1f74
...
0x5d0:pri[725]	offs=0x113f
0x5d2:pri[726]	offs=0x113a
[/sourcecode]

The symbol table seems to reside in the very last rows of the block (0x1f51). So I could imagine two possible explanations: a) the block header including the row directory is bigger than fsbo (1492) seems to suggest; or b) Oracle has adjusted the tosp, avsp values since the block is full (though SPARE1 in tab$ is 736 and not 726)

But perhaps that shows only the limits of my imagination...

Martin

P.S.: it's hard, but I really seem to have nothing better to do.





drop table test_free_space;

create table test_free_space tablespace test_ts
as
select mod(rownum, 10) col1
     , lpad('*', 4000, '*') padding
     , lpad('*', 4000, '*') padding2
  from dual
connect by level <= 10000;

alter table test_free_space move;

select id
     , dbms_rowid.rowid_relative_fno(rowid) file_no
     , dbms_rowid.rowid_block_number(rowid) block_no
  from test_free_space
 where rownum < 3;

alter system dump datafile 5 block min 169 block max 169;


drop table test_free_space;

create table test_free_space tablespace test_ts
as
select 'A' col1
  from dual
connect by level <= 10000;

alter table test_free_space move;

select min(dbms_rowid.rowid_block_number(rowid)) file_no
  from test_free_space;

alter system dump datafile 5 block min 153 block max 153;


select dbms_rowid.rowid_block_number(rowid) block_no
     , count(*)
  from test_free_space
 group by dbms_rowid.rowid_block_number(rowid)
;


drop table test_free_space;

create table test_free_space tablespace test_ts
as
select 0 col1
  from dual
connect by level <= 10000;

alter table test_free_space move;

select min(dbms_rowid.rowid_block_number(rowid)) file_no
  from test_free_space;

alter system dump datafile 5 block min 153 block max 153;


select dbms_rowid.rowid_block_number(rowid) block_no
     , count(*)
  from test_free_space
 group by dbms_rowid.rowid_block_number(rowid)
;


drop table test_free_space;

create table test_free_space tablespace test_ts pctfree 0
as
select cast (null as number) col1
  from dual
connect by level <= 10000;

alter table test_free_space move;

select min(dbms_rowid.rowid_block_number(rowid)) file_no
  from test_free_space;

alter system dump datafile 5 block min 145 block max 145;


select dbms_rowid.rowid_block_number(rowid) block_no
     , count(*)
  from test_free_space
 group by dbms_rowid.rowid_block_number(rowid)
;
