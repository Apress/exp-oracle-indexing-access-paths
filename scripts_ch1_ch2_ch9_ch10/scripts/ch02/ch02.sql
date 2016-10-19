create table cust(
 cust_id number
,last_name varchar2(30)
,first_name varchar2(30));

create index cust_idx1
on cust(last_name);

insert into cust (cust_id, last_name, first_name) values(1,  'STARK','JIM');
insert into cust (cust_id, last_name, first_name) values(2,  'GREY','BOB');
insert into cust (cust_id, last_name, first_name) values(3,  'KHAN','BRAD');
insert into cust (cust_id, last_name, first_name) values(4,  'ACER','SCOTT');
insert into cust (cust_id, last_name, first_name) values(5,  'DOSS','JOE');
insert into cust (cust_id, last_name, first_name) values(6,  'WYNN','SUE');
insert into cust (cust_id, last_name, first_name) values(7,  'FIX', 'MAY');
insert into cust (cust_id, last_name, first_name) values(8,  'MOSS','BETH');
-- Insert some random data here
insert into cust
select level + 16
  ,dbms_random.string('U',dbms_random.value(3,15)) rand_last_name
  ,dbms_random.string('U',dbms_random.value(3,15)) rand_first_name
from dual
connect by level <= 100000;
--
insert into cust (cust_id, last_name, first_name) values(9,  'QUIN','JAY');
insert into cust (cust_id, last_name, first_name) values(10, 'POPE','TODD');
insert into cust (cust_id, last_name, first_name) values(11, 'XUI', 'ANN');
insert into cust (cust_id, last_name, first_name) values(12, 'ACER','SID');
insert into cust (cust_id, last_name, first_name) values(13, 'TAFT','HAL');
insert into cust (cust_id, last_name, first_name) values(14, 'ZIMM','KATE');
insert into cust (cust_id, last_name, first_name) values(15, 'LEE', 'KIM');
insert into cust (cust_id, last_name, first_name) values(16, 'OLDS','JEFF');

exec dbms_stats.gather_table_stats( user, 'CUST' );

set lines 132 pages 50
column last_name format a15 
column first_name format a15

select
  cust_id, last_name, first_name,
  dbms_rowid.rowid_to_absolute_fno(rowid, user, 'CUST') absolute_fno,
  dbms_rowid.rowid_block_number(rowid) blocknumber,
  dbms_rowid.rowid_row_number(rowid) rownumber
from cust
where cust_id <= 16
order by cust_id;

analyze index cust_idx1 validate structure;

select name, height from index_stats;
select blevel from user_indexes where index_name='CUST_IDX1';

select cust_id, last_name, first_name from cust where last_name='ACER';

set autotrace on;
select cust_id, last_name, first_name from cust where last_name='ACER';
set autotrace off;

set serverout on
exec dbms_stats.gather_table_stats(user,'CUST');
variable used_bytes number
variable alloc_bytes number
exec dbms_space.create_index_cost( 'create index cust_idx2 on cust(first_name)', -
               :used_bytes, :alloc_bytes );
print :used_bytes
print :alloc_bytes

create index cust_idx2 on cust(first_name);

select bytes from user_segments where segment_name='CUST_IDX2';

create tablespace reporting_data
  datafile '/u01/dbfile/O1212/reporting_data01.dbf' size 1G;
--
create tablespace reporting_index
  datafile '/u01/dbfile/O1212/reporting_index01.dbf' size 1G;

create table cust(
 cust_id number
,last_name varchar2(30)
,first_name varchar2(30))
tablespace reporting_data;

create index cust_idx1
on cust(last_name)
tablespace reporting_index;

drop table address;
drop table cust; 

CREATE TABLE cust(
 cust_id    NUMBER
,last_name  VARCHAR2(30)
,first_name VARCHAR2(30))
TABLESPACE reporting_data;
--
ALTER TABLE cust ADD CONSTRAINT cust_pk PRIMARY KEY (cust_id)
USING INDEX TABLESPACE reporting_index;
--
ALTER TABLE cust ADD CONSTRAINT cust_uk1 UNIQUE (last_name, first_name)
USING INDEX TABLESPACE reporting_index;
--
CREATE TABLE address(
 address_id NUMBER
,cust_id    NUMBER
,street     VARCHAR2(30)
,city       VARCHAR2(30)
,state      VARCHAR2(30))
TABLESPACE reporting_data;
--
ALTER TABLE address ADD CONSTRAINT addr_fk1
FOREIGN KEY (cust_id) REFERENCES cust(cust_id);
--
CREATE INDEX addr_fk1 ON address(cust_id)
TABLESPACE reporting_index;

set lines 132 pages 50
col index_name form a20
col index_type form a20
col table_name form a20
col tablespace_name form a20
col status form a20

select index_name, index_type, table_name, tablespace_name, status
from user_indexes
where table_name in ('CUST','ADDRESS');

col column_name form a20
col column_position form 9999999

select index_name, column_name, column_position
from user_ind_columns
where table_name in ('CUST','ADDRESS')
order by index_name, column_position;

col segment_name form a20
col segment_type form a20

select a.segment_name, a.segment_type, a.extents, a.bytes
from user_segments a, user_indexes  b
where a.segment_name = b.index_name
and   b.table_name in ('CUST','ADDRESS');

insert into cust values(1,'STARK','JIM');
insert into address values(100,1,'Vacuum Ave','Portland','OR');

set long 1000000
select dbms_metadata.get_ddl('INDEX','ADDR_FK1') from dual;

select dbms_metadata.get_ddl('INDEX', index_name) from user_indexes;

alter index addr_fk1 invisible;
alter index addr_fk1 visible;
alter index addr_fk1 unusable;
alter index addr_fk1 rebuild;
drop index addr_fk1;

drop table cust cascade constraints;

create table cust(
 cust_id      number
,first_name  varchar2(200)
,last_name   varchar2(200));

--ALTER TABLE cust ADD CONSTRAINT cust_pk PRIMARY KEY (cust_id);

ALTER TABLE cust ADD CONSTRAINT cust_pk PRIMARY KEY (cust_id)
USING INDEX TABLESPACE reporting_index;

drop table cust cascade constraints;

create table cust(
 cust_id      number         primary key
,first_name  varchar2(30)
,last_name   varchar2(30));


drop table cust cascade constraints;

create table cust(
 cust_id      number         constraint cust_pk primary key
,first_name  varchar2(30)
,last_name   varchar2(30));

drop table cust cascade constraints;

create table cust(
 cust_id      number constraint cust_pk primary key
                    using index tablespace reporting_index
,first_name  varchar2(30)
,last_name   varchar2(30));

drop table cust cascade constraints;

create table cust(
 cust_id number
,first_name  varchar2(30)
,last_name   varchar2(30)
,constraint cust_pk primary key (cust_id)
using index tablespace reporting_index);

drop table cust cascade constraints;

create table cust(
 cust_id number
,first_name  varchar2(30)
,last_name   varchar2(30));

create unique index cust_pk
on cust(cust_id);

alter table cust
add constraint cust_pk
primary key (cust_id);

create index cust_pk
on cust(cust_id, first_name, last_name);

alter table cust
add constraint cust_pk
primary key (cust_id);

select index_name, index_type, uniqueness
from user_indexes
where table_name = 'CUST';

col constraint_name form a20

select constraint_name, constraint_type
from user_constraints
where table_name = 'CUST';

drop index cust_pk;

--alter table cust disable constraint cust_pk;
--alter table cust drop constraint cust_pk;
--alter table cust drop primary key;

--alter table cust drop constraint cust_pk cascade;
--alter table cust disable constraint cust_pk cascade;
alter table cust drop primary key cascade;

drop table cust cascade constraints;

create table cust(
 cust_id      number
,first_name  varchar2(30)
,last_name   varchar2(30));

alter table cust add constraint cust_uk1 unique (last_name, first_name);

drop table cust cascade constraints;

create table cust(
 cust_id      number constraint cust_pk primary key
                    using index tablespace users
,first_name  varchar2(30)
,last_name   varchar2(30)
,ssn         varchar2(15) constraint cust_uk1 unique
                          using index tablespace reporting_index);
drop table cust cascade constraints;

create table cust(
 cust_id      number constraint cust_pk primary key
,first_name  varchar2(30)
,last_name   varchar2(30)
,ssn         varchar2(15) constraint cust_uk1 unique);

drop table cust cascade constraints;

create table cust(
 cust_id      number constraint cust_pk primary key
,first_name  varchar2(30)
,last_name   varchar2(30)
,ssn         varchar2(15)
,constraint cust_uk1 unique (first_name, last_name));

drop table cust cascade constraints;

create table cust(
 cust_id      number
,first_name  varchar2(30)
,last_name   varchar2(30));

create unique index cust_uk1 on cust(first_name, last_name);

alter table cust add constraint cust_uk1 unique(first_name, last_name);

drop table cust cascade constraints;

create table cust(
 cust_id      number
,first_name  varchar2(30)
,last_name   varchar2(30));

create unique index cust_uk1 on cust(first_name, last_name);

insert into cust values (1, 'JAMES', 'STARK');
insert into cust values (2, 'JAMES', 'STARK');

select
  constraint_name
from user_constraints
where constraint_name='CUST_UK1';

select index_name, uniqueness
from user_indexes where index_name='CUST_UK1';

drop table cust cascade constraints;

create table cust(
 cust_id      number constraint cust_pk primary key
,first_name  varchar2(30)
,last_name   varchar2(30)
,ssn         varchar2(15)
,constraint cust_uk1 unique (first_name, last_name));

--alter table cust drop constraint cust_uk1;
--alter table cust drop constraint cust_uk1 keep index;

drop table address cascade constraints;

CREATE TABLE address(
 address_id NUMBER
,cust_id    NUMBER
,street     VARCHAR2(30)
,city       VARCHAR2(30)
,state      VARCHAR2(30));

alter table address add constraint addr_fk1
foreign key (cust_id) references cust(cust_id);

create index addr_fk1
on address(cust_id);

create index addr_fk1
on address(cust_id)
tablespace reporting_index;

SELECT
 CASE WHEN ind.index_name IS NOT NULL THEN
   CASE WHEN ind.index_type IN ('BITMAP') THEN
     '** Bitmp idx **'
   ELSE
     'indexed'
   END
 ELSE
   '** Check idx **'
 END checker
,ind.index_type
,cons.owner, cons.table_name child_table, cons.cols, ind.index_name, cons.constraint_name
,(SELECT r.table_name
  FROM dba_constraints r
  WHERE cons.owner         = r.owner
  AND cons.r_constraint_name = r.constraint_name
  ) parent_table
FROM (SELECT
        c.owner, c.table_name, c.constraint_name, c.r_constraint_name
       ,LISTAGG(cc.column_name, ',' ) WITHIN GROUP (ORDER BY cc.column_name) cols
      FROM dba_constraints  c
          ,dba_cons_columns cc
      WHERE c.owner           = cc.owner
      AND   c.owner = UPPER('&&schema')
      AND   c.constraint_name = cc.constraint_name
      AND   c.constraint_type = 'R'
      GROUP BY c.owner, c.table_name, c.constraint_name, c.r_constraint_name) cons
LEFT OUTER JOIN
(SELECT
  table_owner, table_name, index_name, index_type, cbr
 ,LISTAGG(column_name, ',' ) WITHIN GROUP (ORDER BY column_name) cols
 FROM (SELECT
        ic.table_owner, ic.table_name, ic.index_name
       ,ic.column_name, ic.column_position, i.index_type
       ,CONNECT_BY_ROOT(ic.column_name) cbr
       FROM dba_ind_columns ic
           ,dba_indexes     i
       WHERE ic.table_owner = UPPER('&&schema')
       AND   ic.table_owner = i.table_owner
       AND   ic.table_name  = i.table_name
       AND   ic.index_name  = i.index_name
       CONNECT BY PRIOR ic.column_position-1 = ic.column_position
       AND PRIOR ic.index_name = ic.index_name)
  GROUP BY table_owner, table_name, index_name, index_type, cbr) ind
ON  cons.cols       = ind.cols
AND cons.table_name = ind.table_name
AND cons.owner      = ind.table_owner
ORDER BY checker, cons.owner, cons.table_name;

drop table d;

create table d(x varchar2(32727));

set lines 80
desc d;

insert into d values(rpad('abc',10000,'abc'));
select substr(x,9500,10) from d where UPPER(x) like 'ABC%';

set lines 132

col object_name form a28
col object_type form a15

select object_name, object_type from user_objects;

select table_name, column_name, segment_name, tablespace_name, in_row
from user_lobs where table_name='D';

create index di on d(x);

insert into d select to_char(level)|| rpad('abc',10000,'xyz')
    from dual connect by level < 1001
    union
    select to_char(level)
    from dual connect by level < 1001;

alter table d add (xv as (substr(x,1,10)));

create index de on d(xv);

exec dbms_stats.gather_table_stats(user,'D');

set autotrace traceonly explain
select count(*) from d where x = '800';

select count(*) from d where x >'800' and x<'900';

set autotrace off;

drop table d;
create table d(x varchar2(32727));
alter table d add (xv as (standard_hash(x)));
create index de on d(xv);
exec dbms_stats.gather_table_stats(user,'D');

set autotrace traceonly explain
select count(*) from d where x='300';
select count(*) from d where x >'800' and x<'900';

set autotrace off;

drop table d;
create table d(x varchar2(32767));

insert into d
  select to_char(level)|| rpad('abc',10000,'xyz')
  from dual connect by level < 1001
  union
  select to_char(level)
  from dual connect by level < 1001;

create index de on d(substr(x,1,10));

exec dbms_stats.gather_table_stats(user,'D');

set autotrace traceonly explain
select count(*) from d where x = '800';
select count(*) from d where x>'200' and x<'400';

create index te on d(standard_hash(x));

set autotrace traceonly explain
select count(*) from d where x = '800';

set autotrace off;
