-- http://martinpreiss.blogspot.de/2014/12/join-cardinality-und-sanity-checks.html

-- based on the example from http://jonathanlewis.wordpress.com/2014/12/03/upgrades-5/
-- gather statistics
exec dbms_stats.gather_table_stats(user, 't2', method_opt=>'for all columns size 1')

-- gather CBO trace for cached query
begin
dbms_sqldiag.dump_trace( p_sql_id => '82gmrg5fsgwjd'
                       , p_child_number => 0
					   , p_component => 'Compiler'
					   , p_file_id => 'My_Trace_File');
end;
/					   


-- from CBO trace
ColGroup cardinality sanity check: ndv for  T1[T1] = 270.000000  T2[T2] = 90000.000000 
Join selectivity using 1 ColGroups: 4.0502e-04 (sel1 = 0.000000, sel2 = 0.000000)
Join Card:  2531.389226 = outer (2500.000000) * inner (2500.000000) * sel (4.0502e-04)
Join Card - Rounded: 2531 Computed: 2531.389226

ColGroup cardinality sanity check: ndv for  T1[T1] = 270.000000  T2[T2] = 82710.000000 
Join selectivity using 1 ColGroups: 4.0552e-04 (sel1 = 0.000000, sel2 = 0.000000)
Join Card:  2534.468775 = outer (2500.000000) * inner (2500.000000) * sel (4.0552e-04)
Join Card - Rounded: 2534 Computed: 2534.468775

ColGroup cardinality sanity check: ndv for  T1[T1] = 270.000000  T2[T2] = 72000.000000 
Join selectivity using 1 ColGroups: 4.0634e-04 (sel1 = 0.000000, sel2 = 0.000000)
Join Card:  2539.618041 = outer (2500.000000) * inner (2500.000000) * sel (4.0634e-04)
Join Card - Rounded: 2540 Computed: 2539.618041

ColGroup cardinality sanity check: ndv for  T1[T1] = 270.000000  T2[T2] = 66168.000000 
Join selectivity using 1 ColGroups: 4.0700e-04 (sel1 = 0.000000, sel2 = 0.000000)
Join Card:  2543.752544 = outer (2500.000000) * inner (2500.000000) * sel (4.0700e-04)
Join Card - Rounded: 2544 Computed: 2543.752544

-- trying to get from 1/NDV to cardinality
select 4.0502e-04 * 1/90000 from dual;
select 4.0552e-04 * 1/82710 from dual;
select 4.0634e-04 * 1/72000 from dual;
select 4.0700e-04 * 1/66168 from dual;

select 90000/4.0502e-04   from dual;
select 82710/4.0552e-04   from dual;
select 72000/4.0634e-04  from dual;
select 66168/4.0700e-04  from dual;

select 1/90000 * 2500 * 1150 from dual;
select 1/82710 * 2500 * 1150 from dual;
select 1/72000 * 2500 * 1150 from dual;
select 1/66168 * 2500 * 1150 from dual;
select 1/54000 * 2500 * 1150 from dual;

select 1/90000 * 2500 from dual;
select 1/82710 * 2500 from dual;
select 1/72000 * 2500 from dual;
select 1/66168 * 2500 from dual;