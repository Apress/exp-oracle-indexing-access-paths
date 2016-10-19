drop table cust cascade constraints;

create table cust(
 cust_id    number,
 last_name  varchar2(30),
 first_name varchar2(30),
 addr_id    number,
 create_dtt timestamp)
inmemory;

begin
for i in 1..50 loop
insert into sales
select
  trunc(dbms_random.value(1,1000)) cust_id,
  trunc(dbms_random.value(1,200))  emp_id,
  trunc(dbms_random.value(1,10))   store_id,
  trunc(dbms_random.value(1,5000)) amt,
  decode(trunc(dbms_random.value(1,5)),1,'N',2,'E',3,'S',4,'W','X') region,
  sysdate + dbms_random.value(-2000,30) sales_dtt
from dual connect by level <= 500000;
commit;
end loop;
end;
/

exec dbms_stats.gather_table_stats( user, 'SALES');

alter session set inmemory_query=disable;
explain plan for select count(*) from sales where sales_dtt > sysdate - 10;
select * from table(dbms_xplan.display);

select display_name, value
from v$mystat m,
     v$statname n
where m.statistic# = n.statistic#
and display_name in (
  'IM scan segments minmax eligible',
  'IM scan CUs pruned',
  'IM scan CUs optimized read',
  'IM scan CUs predicates optimized',
  'session logical reads - IM',
  'IM scan rows',
  'IM scan rows valid',
  'IM scan blocks cache',
  'IM scan CUs columns accessed');

SELECT owner, segment_name, bytes, inmemory_size,
populate_status, inmemory_compression, inmemory_priority
FROM v$im_segments;

select column_number, column_name
from v$im_col_cu  i,
     dba_objects  o,
     dba_tab_cols c
where i.objd = o.data_object_id
and   o.object_name = c.table_name
and   i.column_number = c.column_id
and   o.object_name = 'SALES';

set timing on;

select sum(amt), min(amt), max(amt), cust_id, trunc(sales_dtt,'MON')
from sales
where amt between 100 and 2000
and cust_id in (1,2,4,21,32,66,93,200,402,643,823,931,993)
and store_id in (1,2,3,5,7,9)
and region in ('N','W','S')
and sales_dtt between sysdate-200 and sysdate-10
group by cust_id,trunc(sales_dtt,'MON')
order by cust_id, trunc(sales_dtt,'MON');

