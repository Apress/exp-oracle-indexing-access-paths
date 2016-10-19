CREATE INDEX employees_part_1i
ON employees_part (hire_date)
TABLESPACE empindex_s
LOCAL;

CREATE INDEX employees_part_i1
ON employees_part (hire_date)
LOCAL
(partition pi1990  tablespace EMP1990_S
,partition pi1991  tablespace EMP1991_S
,partition pi1992  tablespace EMP1992_S
,partition pi1993  tablespace EMP1993_S
,partition pi1994  tablespace EMP1994_S
,partition pi1995  tablespace EMP1995_S
,partition pi1996  tablespace EMP1996_S
,partition pi1997  tablespace EMP1997_S
,partition pi1998  tablespace EMP1998_S
,partition pi1999  ta21
tablespace EMP1999_S
,partition pi2000  tablespace EMP2000_S
,partition pimax   tablespace EMPMAX_S);


CREATE INDEX EMPLOYEES_I1
ON EMPLOYEES (HIRE_DATE)
TABLESPACE EMPINDEX_S
LOCAL;

CREATE UNIQUE INDEX employees_part_pk
ON employees_part (employee_id)
LOCAL;

CREATE UNIQUE INDEX employees_part_pk
ON employees_part (employee_id, hire_date)
LOCAL;

CREATE UNIQUE INDEX employees_part_pk
ON employees_part (employee_id, hire_date)
LOCAL;

alter table employees_part add constraint employees_part_pk
primary key (employee_id, hire_date);

alter table employees_part disable constraint employees_part_pk;

select i.index_name, c.constraint_type, i.partitioned
from user_indexes i left join user_constraints c
on (i.index_name = c.constraint_name)
where i.index_name = 'EMPLOYEES_PART_PK';

alter table employees_part disable constraint employees_part_pk;

select i.index_name, c.constraint_type, i.partitioned
from user_indexes i left join user_constraints c
on (i.index_name = c.constraint_name)
where i.index_name = 'EMPLOYEES_PART_PK';

alter table employees_part add constraint employees_part_pk
primary key (employee_id);

select i.index_name, c.constraint_type, i.partitioned
from user_indexes i join user_constraints c
on (i.index_name = c.constraint_name)
where i.index_name = 'EMPLOYEES_PART_PK';

CREATE INDEX employees_gi2
ON employees (manager_id)
GLOBAL
partition by range(manager_id)
(partition manager_100 values less than (100),
partition manager_200 values less than (200),
partition manager_300 values less than (300),
partition manager_400 values less than (400),
partition manager_500 values less than (500),
partition manager_600 values less than (600),
partition manager_700 values less than (700),
partition manager_800 values less than (800),
partition manager_900 values less than (900),
partition manager_max values less than (maxvalue));

CREATE INDEX employees_gi2
ON employees (manager_id)
GLOBAL
partition by range(manager_id)
(partition manager_100 values less than (100),
partition manager_200 values less than (200),
partition manager_300 values less than (300),
partition manager_400 values less than (400),
partition manager_500 values less than (500),
partition manager_600 values less than (600),
partition manager_700 values less than (700),
partition manager_800 values less than (800),
partition manager_900 values less than (900));

alter index employees_12
split partition manager_max at (1000)
into (partition manager_max, partition manager_1000);

SELECT partition_name, status from user_ind_partitions
WHERE index_name = 'EMPLOYEES_GI2';

ALTER index employees_i2
DROP partition manager_125;

select partition_name, status from user_ind_partitions
where index_name = 'EMPLOYEES_GI2';

ALTER INDEX employees_i2 rebuild partition manager_300;

ALTER INDEX employees_i2
DROP PARTITION manager_max;

create unique index employees_uk1
on employees (manager_id, employee_id)
global
partition by range(manager_id)
(partition manager_100 values less than (100),
partition manager_200 values less than (200),
partition manager_300 values less than (300),
partition manager_400 values less than (400),
partition manager_500 values less than (500),
partition manager_600 values less than (600),
partition manager_700 values less than (700),
partition manager_800 values less than (800),
partition manager_900 values less than (900),
partition manager_max values less than (maxvalue));

create unique index employees_uk1
on employees (employee_id)
global
partition by range(manager_id)
(partition manager_100 values less than (100),
partition manager_200 values less than (200),
partition manager_300 values less than (300),
partition manager_400 values less than (400),
partition manager_500 values less than (500),
partition manager_600 values less than (600),
partition manager_700 values less than (700),
partition manager_800 values less than (800),
partition manager_900 values less than (900),
partition manager_max values less than (maxvalue));
partition by range(manager_id);

CREATE INDEX employees_ih1
ON employees (department_id)
GLOBAL
PARTITION BY HASH(department_id) partitions 4;

CREATE TABLE employees_part
(
 EMPLOYEE_ID          NUMBER(6)         NOT NULL
 ,FIRST_NAME          VARCHAR2(20)
 ,LAST_NAME           VARCHAR2(25)      NOT NULL
 ,EMAIL               VARCHAR2(25)      NOT NULL
 ,PHONE_NUMBER        VARCHAR2(20)
 ,HIRE_DATE           DATE              NOT NULL
 ,JOB_ID              VARCHAR2(10)      NOT NULL
 ,SALARY              NUMBER(8,2)
 ,COMMISSION_PCT      NUMBER(2,2)
 ,MANAGER_ID          NUMBER(6)
 ,DEPARTMENT_ID       NUMBER(4)
 ,GENDER               CHAR
 ,constraint employees_part_pk primary key (employee_id, hire_date)
)
indexing off
partition by range(hire_date)
(
partition p2013 values less than ('2014-01-01'),
partition p2014 values less than ('2015-01-01') indexing off,
partition p2015 values less than ('2016-01-01') indexing on,
partition p2016 values less than ('2017-01-01') indexing on,
partition p2017 values less than ('2018-01-01'),
partition p9999 values less than ('9999-12-31'),
partition pmax values less than (MAXVALUE)
);

CREATE INDEX ep_di_i on employees_part(department_id) 
LOCAL INDEXING PARTIAL;

select partition_name, status
from dba_ind_partitions
where index_name = 'EP_DI_I';

select partition_name, bytes
from dba_segments
where segment_name = 'EP_DI_I';

ALTER INDEX ep_di_i rebuild partition p2014;


CREATE INDEX ep_di_i on employees_part(department_id) 
GLOBAL INDEXING PARTIAL;

select index_name, status
from dba_indexes
where index_name = 'EP_DI_I';

select segment_name, bytes
from dba_segments
where segment_name = 'EP_DI_I';

alter table employees_part truncate partition p2015;

select * from employees_part
where hire_date between '2015-11-01' and '2016-05-01'
and department_id = 5;

alter table employees_parttest add partition p2010
values less than ('2011-01-01') tablespace users;

SELECT index_name, null partition_name, status
FROM user_indexes
WHERE table_name = 'EMPLOYEES_PARTTEST'
AND partitioned = 'NO'
UNION
SELECT index_name, partition_name, status
FROM user_ind_partitions
WHERE index_name in
(SELECT index_name from user_indexes
WHERE table_name = 'EMPLOYEES_PARTTEST')
ORDER BY 1,2,3;

ALTER TABLE employees_parttest truncate partition p1995;

alter table employees_parttest move partition p1995 tablespace emp1995_s;

ALTER TABLE employees_parttest SPLIT PARTITION Pmax at ('2000-01-01') INTO
(partition P1999 tablespace users,
partition pmax tablespace users);

CREATE TABLE employees_part
(
 EMPLOYEE_ID          NUMBER(6)         NOT NULL
 ,FIRST_NAME          VARCHAR2(20)
 ,LAST_NAME           VARCHAR2(25)      NOT NULL
 ,EMAIL               VARCHAR2(25)      NOT NULL
 ,PHONE_NUMBER        VARCHAR2(20)
 ,HIRE_DATE           DATE              NOT NULL
 ,JOB_ID              VARCHAR2(10)      NOT NULL
 ,SALARY              NUMBER(8,2)
 ,COMMISSION_PCT      NUMBER(2,2)
 ,MANAGER_ID          NUMBER(6)
 ,DEPARTMENT_ID       NUMBER(4)
 ,constraint employees_part_pk primary key (employee_id, hire_date)
)
partition by range(hire_date)
(
partition p1990 values less than ('1991-01-01'),
partition p1991 values less than ('1992-01-01'),
partition p1992 values less than ('1993-01-01'),
partition p1993 values less than ('1994-01-01'),
partition p1994 values less than ('1995-01-01'),
partition p1995 values less than ('1996-01-01'),
partition p1996 values less than ('1997-01-01'),
partition p1997 values less than ('1998-01-01'),
partition p1998 values less than ('1999-01-01'),
partition p1999 values less than ('2000-01-01'),
partition p2000 values less than ('2001-01-01'),
partition p9999 values less than ('9999-12-31'),
partition pmax values less than (MAXVALUE);

ALTER TABLE employees_parttest EXCHANGE PARTITION p1995
WITH TABLE employees_parttest_exch;

ALTER TABLE employees_parttest DROP PARTITION p1995;

ALTER TABLE employees_parttest MERGE PARTITIONS p1995 , pmax
into PARTITION pmax;

ALTER TABLE employees_parttest merge PARTITIONS p1995 , pmax
INTO PARTITION pmax
UPDATE INDEXES;

ALTER INDEX EMPLOYEES_PARTTEST_I1 REBUILD;

alter index EMPLOYEES_PARTTEST_I1  rebuild parallel(degree 4);

ALTER INDEX employees_parttest_gi1
rebuild partition MANAGER_MAX;

ALTER INDEX EMPLOYEES_PARTTEST_GI1 REBUILD;

select partition_name, num_rows
from user_tab_partitions
where table_name = 'EMPLOYEES_PART'
and partition_name = 'P2014';

alter table employees_part drop partition p2014 update global indexes;

alter table employees_part_pi drop partition p2014 update global indexes;

analyze index ep_di_i validate structure;

select index_name, status, orphaned_entries
from dba_indexes
where index_name = 'EP_DI_I';

select name, lf_rows, del_lf_rows from index_stats;

alter table employees_parttest
modify partition pmax
unusable local indexes;

alter table employees_parttest
modify partition pmax
rebuild unusable local indexes;

alter index test_i3 modify default attributes tablespace test09index_s;

insert into testtab values (1,'2009-05-01');

select partition_name, tablespace_name from user_ind_partitions;

select table_name, index_name, partition_name, p.status
from user_ind_partitions p join user_indexes i using(index_name)
where table_name = 'EMPLOYEES_PARTTEST'
union
select table_name, index_name, null, status
from user_indexes
where table_name = 'EMPLOYEES_PARTTEST'
order by 2,3;

select table_name, index_name, partitioning_type, locality, alignment
from user_part_indexes;

select segment_name, partition_name, round(bytes/1048576) meg
from dba_segments
where (segment_name, partition_name) in
(select index_name, subpartition_name
from user_ind_subpartitions
where index_name in
(select index_name from user_indexes
where table_name = 'BILLING_FACT'))
and bytes > 1048576*8192
order by 3 desc;



































