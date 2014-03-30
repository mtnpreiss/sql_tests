-- http://jonathanlewis.wordpress.com/2013/12/17/dbms_space_usage/
-- http://richardfoote.wordpress.com/2010/02/08/index-block-dumps-and-treedumps-part-i-knock-on-wood/

drop table t;

create table t(a number);

create index t_idx on t(a);

begin
for i in 1..1000 loop
insert into t(a) 
select i * 1000 + rownum from dual connect by level <= 1000;

delete from t where mod(a, 10) <> 1 and a >= i * 1000;
commit;
end loop;
end;
/


exec dbms_stats.gather_table_stats(user, 'T', cascade => true)

exec get_space_usage()

select object_id from user_objects where object_name = 'T_IDX';
rem ALTER SESSION SET EVENTS 'immediate trace name treedump level 106315';
