-- vgl. https://community.oracle.com/thread/3591765?sr=inbox

drop table t;

create table t
as
select rownum id
     , mod(rownum, 10) col1
  from dual
connect by level <= 100000;

create index t_idx on t(id);

delete from t where col1 <= 5;

commit;

-- statistics after object creation and delete
select index_name, num_rows, leaf_blocks, last_analyzed from user_indexes where index_name = 'T_IDX';

INDEX_NAME                       NUM_ROWS LEAF_BLOCKS LAST_ANALYZED
------------------------------ ---------- ----------- -------------------
T_IDX                              100000         222 04.08.2014 19:59:22

-- table stats deleted
exec dbms_stats.delete_table_stats(user, 't')

select index_name, num_rows, leaf_blocks, last_analyzed from user_indexes where index_name = 'T_IDX';

INDEX_NAME                       NUM_ROWS LEAF_BLOCKS LAST_ANALYZED
------------------------------ ---------- ----------- -------------------
T_IDX


-- alter index compute statistics;
alter index t_idx compute statistics;

select index_name, num_rows, leaf_blocks, last_analyzed from user_indexes where index_name = 'T_IDX';

INDEX_NAME                       NUM_ROWS LEAF_BLOCKS LAST_ANALYZED
------------------------------ ---------- ----------- -------------------
T_IDX


-- dbms_stats
exec dbms_stats.gather_table_stats(user, 't', cascade=>true)

select index_name, num_rows, leaf_blocks, last_analyzed from user_indexes where index_name = 'T_IDX';

INDEX_NAME                       NUM_ROWS LEAF_BLOCKS LAST_ANALYZED
------------------------------ ---------- ----------- -------------------
T_IDX                               40000         222 04.08.2014 19:59:24
