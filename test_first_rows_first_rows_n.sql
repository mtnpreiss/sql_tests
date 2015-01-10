-- first_rows vs. first_rows_n
-- http://jonathanlewis.wordpress.com/2014/10/28/first-rows-2/

delete from plan_table;

explain plan set statement_id '0' for select /*+ first_rows(0) */ n2 from t2 where n1 = 15;
explain plan set statement_id '1' for select /*+ first_rows(1) */ n2 from t2 where n1 = 15;
explain plan set statement_id '2' for select /*+ first_rows(2) */ n2 from t2 where n1 = 15;
explain plan set statement_id '3' for select /*+ first_rows(3) */ n2 from t2 where n1 = 15;
explain plan set statement_id '6' for select /*+ first_rows(6) */ n2 from t2 where n1 = 15;
explain plan set statement_id '12' for select /*+ first_rows(12) */ n2 from t2 where n1 = 15;
explain plan set statement_id '14' for select /*+ first_rows(14) */ n2 from t2 where n1 = 15;
explain plan set statement_id '15' for select /*+ first_rows(15) */ n2 from t2 where n1 = 15;

select statement_id
     , operation
	 , options
	 , cost
	 , cardinality
  from plan_table
 where id = 1
 order by to_number(statement_id);