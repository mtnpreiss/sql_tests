-- 19.12.2013
-- http://jonathanlewis.wordpress.com/2013/12/17/dbms_space_usage/


-- 11.2.0.1
-- ASSM
 
-- creation of a table with a (non-unique) index wasting a lot of space
-- by creating rows and deleting most of them (but not all) immediately
drop table t;
create table t (a number);
create index t_idx on t(a);
 
begin
for i in 1..1000 loop
insert into t(a) 
select i * 100 + rownum
  from dual
connect by level <= 100  
;
 
delete from t
 where a > i * 100
   and mod(a, 100) <> 1;
    
end loop;
 
commit;
 
end;
/   
 
declare
  unf number;
  unfb number;
  fs1 number;
  fs1b number;
  fs2 number;
  fs2b number;
  fs3 number;
  fs3b number;
  fs4 number;
  fs4b number;
  full number;
  fullb number;
begin
  dbms_space.space_usage(user,'T_IDX','INDEX',unf,unfb,fs1,fs1b,fs2,fs2b,fs3,fs3b,fs4,fs4b,full,fullb);
  dbms_output.put_line('unformatted blocks/bytes: ' || unf || ' / ' || unfb);
  dbms_output.put_line('fs1 blocks/bytes: ' || fs1 || ' / ' || fs1b);
  dbms_output.put_line('fs2 blocks/bytes: ' || fs2 || ' / ' || fs2b);
  dbms_output.put_line('fs3 blocks/bytes: ' || fs3 || ' / ' || fs3b);
  dbms_output.put_line('fs4 blocks/bytes: ' || fs4 || ' / ' || fs4b);
  dbms_output.put_line('full blocks/bytes: ' || full || ' / ' || fullb);
end;
/ 
 
unformatted blocks/bytes: 0 / 0
fs1 blocks/bytes: 0 / 0
fs2 blocks/bytes: 45 / 368640
fs3 blocks/bytes: 0 / 0
fs4 blocks/bytes: 0 / 0
full blocks/bytes: 199 / 1630208
 
analyze index t_idx validate structure;
 
select height, blocks, lf_blks, br_blks, btree_space, pct_used, del_lf_rows
  from index_stats;
 
    HEIGHT     BLOCKS    LF_BLKS    BR_BLKS BTREE_SPACE   PCT_USED DEL_LF_ROWS
---------- ---------- ---------- ---------- ----------- ---------- -----------
         2        256        199          1     1600032        100       99000
 
-- create a tree dump
select object_id from user_objects where object_name = 'T_IDX';
 
 OBJECT_ID
----------
     89087
 
ALTER SESSION SET EVENTS 'immediate trace name treedump level 89087';
 
-- snippet from the tree dump
----- begin tree dump
 
*** 2013-12-18 08:23:11.242
branch: 0x1007a73 16808563 (0: nrow: 199, level: 1)
   leaf: 0x1007a75 16808565 (-1: nrow: 533 rrow: 6)
   leaf: 0x1007a76 16808566 (0: nrow: 533 rrow: 5)
   leaf: 0x1007a77 16808567 (1: nrow: 533 rrow: 5)
   leaf: 0x1007a74 16808564 (2: nrow: 533 rrow: 6)
   leaf: 0x1007a7d 16808573 (3: nrow: 533 rrow: 5)
   leaf: 0x1007a7e 16808574 (4: nrow: 533 rrow: 5)
   leaf: 0x1007a7f 16808575 (5: nrow: 533 rrow: 6)
...
   leaf: 0x1007e8c 16809612 (193: nrow: 500 rrow: 5)
   leaf: 0x1007e90 16809616 (194: nrow: 500 rrow: 5)
   leaf: 0x1007e94 16809620 (195: nrow: 500 rrow: 5)
   leaf: 0x1007e98 16809624 (196: nrow: 500 rrow: 5)
   leaf: 0x1007e9c 16809628 (197: nrow: 387 rrow: 3)
----- end tree dump

-- dump creation
select header_file, header_block from dba_segments where segment_name = 'T_IDX';
 
HEADER_FILE HEADER_BLOCK
----------- ------------
          4        31346
 
alter system dump datafile 4 block 31346;
 
-- and some information from the trace file
 
  Extent Control Header
  -----------------------------------------------------------------
  Extent Header:: spare1: 0      spare2: 0      #extents: 17     #blocks: 256   
                  last map  0x00000000  #maps: 0      offset: 2716  
      Highwater::  0x01007f00  ext#: 16     blk#: 128    ext size: 128   
  #blocks in seg. hdr's freelists: 0     
  #blocks below: 244   
  mapblk  0x00000000  offset: 16    
                   Unlocked
  --------------------------------------------------------
  Low HighWater Mark : 
      Highwater::  0x01007e90  ext#: 16     blk#: 16     ext size: 128   
  #blocks in seg. hdr's freelists: 0     
  #blocks below: 132   
  mapblk  0x00000000  offset: 16    
  Level 1 BMB for High HWM block: 0x01007e81
  Level 1 BMB for Low HWM block: 0x01007e80
  
  