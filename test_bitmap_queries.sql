-- 09.05.2011

prompt	Bitmap Index on clustered column with 20 values

select
	/*+ index(t1) nocpu_costing */
	small_vc
from	t1
where	n1	= 2
;

prompt	Bitmap Index on scattered column with 20 values

select
	/*+ index(t1) nocpu_costing */
	small_vc
from	t1
where	n2	= 2
;

prompt	Bitmap Index on clustered column with 25 values

select
	/*+ index(t1) nocpu_costing */
	small_vc
from	t1
where	n3	= 2
;

prompt	Bitmap Index on scattered column with 25 values

select
	/*+ index(t1) nocpu_costing */
	small_vc
from	t1
where	n4	= 2
;

prompt	B-tree Index on clustered column with 25 values

select
	small_vc
from	t1
where	n5	= 2
;

prompt	B-tree Index on scattered column with 25 values

select
	small_vc
from	t1
where	n6	= 2
;
