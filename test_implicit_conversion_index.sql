-- implicit conversion and index access
-- http://martinpreiss.blogspot.de/2014/07/implizite-typ-konvertierung-und-index.html

drop table t;

create table t
as 
select rownum num_col
     , to_char(rownum) char_col
  from dual 
connect by level <= 100000;

exec dbms_stats.gather_table_stats(user, 'T')

create unique index t_num_col_idx on t(num_col);

create unique index t_char_col_idx on t(char_col);

set autot trace

select count(*) 
  from t 
 where num_col = 1;
 
select count(*) 
  from t 
 where num_col = '1';
 
select count(*) 
  from t 
 where char_col = 1;
 
select count(*) 
  from t 
 where char_col = '1';
 
 