CREATE TABLE locations_iot
(LOCATION_ID         NUMBER(4)         NOT NULL
,STREET_ADDRESS      VARCHAR2(40)
,POSTAL_CODE         VARCHAR2(12)
,CITY                VARCHAR2(30)      NOT NULL
,STATE_PROVINCE      VARCHAR2(25)
,COUNTRY_ID          CHAR(2)
,CONSTRAINT locations_iot_pk PRIMARY KEY (location_id)
)
ORGANIZATION INDEX;

CREATE TABLE locations_iot
(LOCATION_ID         NUMBER(4)         NOT NULL
,STREET_ADDRESS      VARCHAR2(40)
,POSTAL_CODE         VARCHAR2(12)
,CITY                VARCHAR2(30)      NOT NULL
,STATE_PROVINCE      VARCHAR2(25)
,COUNTRY_ID          CHAR(2)
)
ORGANIZATION INDEX;

CREATE TABLE locations_iot
(LOCATION_ID         NUMBER(4)         NOT NULL
,STREET_ADDRESS      VARCHAR2(40)
,POSTAL_CODE         VARCHAR2(12)
,CITY                VARCHAR2(30)      NOT NULL
,STATE_PROVINCE      VARCHAR2(25)      NOT NULL
,COUNTRY_ID          CHAR(2)
,constraint locations_iot_pk primary key (location_id, state_province)
)
ORGANIZATION INDEX
partition by list(STATE_PROVINCE)
(partition p_intl values
('Maharashtra','Bavaria','New South Wales', 'BE','Geneve',
 'Tokyo Prefecture', 'Sao Paulo','Manchester','Utrecht',
 'Ontario','Yukon','Oxford'),
partition p_domestic values ('Texas','New Jersey','Washington','California'));

CREATE TABLE employees
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
 ,CONSTRAINT employees_pk PRIMARY KEY (employee_id)
 )
ORGANIZATION INDEX
TABLESPACE empindex_s
PCTTHRESHOLD 40
INCLUDING salary
OVERFLOW TABLESPACE overflow_s;

CREATE TABLE employees
(
 EMPLOYEE_ID          NUMBER(6)         NOT NULL
 ,FIRST_NAME          VARCHAR2(20)
 ,LAST_NAME           VARCHAR2(25)      NOT NULL
 ,EMAIL               VARCHAR2(25)      NOT NULL
 ,PHONE_NUMBER        VARCHAR2(20)
 ,HIRE_DATE           DATE              NOT NULL
 ,JOB_ID              VARCHAR2(10)      NOT NULL
 ,SALARY              NUMBER(8,2)
 ,MANAGER_ID          NUMBER(6)
 ,DEPARTMENT_ID       NUMBER(4)
 ,COMMISSION_PCT      NUMBER(2,2)
 ,MANAGER_ID          NUMBER(6)
 ,DEPARTMENT_ID       NUMBER(4)
 ,CONSTRAINT employees_pk PRIMARY KEY (employee_id)
)
ORGANIZATION INDEX
TABLESPACE empindex_s
PCTTHRESHOLD 40
INCLUDING DEPARTMENT_ID
OVERFLOW TABLESPACE overflow_s;

select table_name, iot_type from user_tables
where iot_type like '%IOT%';

CREATE TABLE employees_iot
(
EMPLOYEE_ID          NUMBER(7)         NOT NULL
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
,CONSTRAINT employees_iot_pk PRIMARY KEY (employee_id, job_id)
)
ORGANIZATION INDEX COMPRESS 1
TABLESPACE empindex_s
PCTTHRESHOLD 40
INCLUDING salary
OVERFLOW TABLESPACE overflow_s;

ALTER TABLE employees_iot MOVE TABLESPACE empindex_s COMPRESS 1;

CREATE INDEX employees_iot_1i
ON employees_iot (department_id);

CREATE INDEX employees_iot_1i
on employees_iot (department_id)
LOCAL;

select index_name, index_type, pct_direct_access
from user_indexes;

ALTER INDEX employees_1i REBUILD;

ALTER INDEX employees_part_1i UPDATE BLOCK REFERENCES;

ALTER TABLE employees_iot MOVE;

ALTER TABLE employees_iot MOVE TABLESPACE emp_s;

ALTER TABLE employees_iot MOVE overflow;

ALTER TABLE employees_iot MOVE tablespace emp_s
overflow tablespace overflow_s;

alter table employees_iot move tablespace users online;

ALTER TABLE employees_iot MOVE;

select partition_name
from user_ind_partitions
where index_name = 'EMPLOYEES_IOT_PK';

ALTER TABLE employees_iot MOVE PARTITION p1990;

alter index employees_iot_pk rebuild;

CREATE TABLE locations_iot
 (LOCATION_ID
 ,STREET_ADDRESS
 ,POSTAL_CODE
 ,CITY
 ,STATE_PROVINCE
 ,COUNTRY_ID
 ,CONSTRAINT locations_iot_pk PRIMARY KEY (location_id)
 )
 ORGANIZATION INDEX
 as select * from locations;

CREATE TABLE locations
 (LOCATION_ID
 ,STREET_ADDRESS
 ,POSTAL_CODE
 ,CITY
 ,STATE_PROVINCE
 ,COUNTRY_ID
 ,CONSTRAINT locations_pk PRIMARY KEY (location_id)
 )
 ORGANIZATION INDEX
 as select * from locations_iot;

select i.table_name, i.index_name, i.index_type, i.pct_threshold,
nvl(column_name,'NONE') include_column
from user_indexes i left join user_tab_columns c
on (i.table_name = c.table_name)
and (i.include_column = c.column_id)
where index_type = 'IOT - TOP';

select table_name, iot_type, segment_created from user_tables;

select segment_name, segment_type
from dba_segments
where segment_name like '%IOT%'













