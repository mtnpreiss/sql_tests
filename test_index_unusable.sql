-- unterschiedliches Verhalten von Indizes (unique/nonunique) 
-- bei INSERT nach Setzung auf unusable
-- Anfrage an R. Foote: http://richardfoote.wordpress.com/2011/02/27/oracle11g-zero-sized-unusable-indexes-part-ii-nathan-adler/#comment-12687

set timin off

drop table test_unusable; 
create table test_unusable ( id number);
create index test_unusable_ix1 on test_unusable(id);
alter index test_unusable_ix1 unusable;
insert into test_unusable
select rownum id
  from dual
connect by level <= 10000;       
--> 10000 rows inserted

drop table test_unusable; 
create table test_unusable ( id number);
create unique index test_unusable_ix1 on test_unusable(id);
alter index test_unusable_ix1 unusable;
insert into test_unusable
select rownum id
  from dual
connect by level <= 10000;       
--> ora-01502: index ‘string.string’ or partition of such index is in unusable state

set timin on