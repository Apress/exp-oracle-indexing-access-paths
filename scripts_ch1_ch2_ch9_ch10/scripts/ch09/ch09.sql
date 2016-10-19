set lines 132
col client_name form a32
col status form a20
col consumer_group form a20

SELECT client_name, status, consumer_group
FROM dba_autotask_client
ORDER BY client_name;

col window_name form a20
col next_time form a20

SELECT window_name,
TO_CHAR(window_next_time,'DD-MON-YY HH24:MI:SS') next_time,
sql_tune_advisor, optimizer_stats, segment_advisor
FROM dba_autotask_window_clients;

set long 10000000
variable advice_out clob;
begin
 :advice_out := DBMS_AUTO_SQLTUNE.REPORT_AUTO_TUNING_TASK(LEVEL=>'ALL');
end;
/
print :advice_out

col task_name form a30

select task_name, execution_start from dba_advisor_log
where task_name='SYS_AUTO_SQL_TUNING_TASK'
order by 2;

SET LINESIZE 132 PAGESIZE 0 LONG 10000
SELECT DBMS_SQLTUNE.SCRIPT_TUNING_TASK('SYS_AUTO_SQL_TUNING_TASK')FROM dual;

BEGIN
  dbms_auto_task_admin.disable(
  client_name => 'sql tuning advisor',
  operation => NULL,
  window_name => 'TUESDAY_WINDOW');
END;
/

set pages 50

SELECT window_name,TO_CHAR(window_next_time,'DD-MON-YY HH24:MI:SS')
,sql_tune_advisor
FROM dba_autotask_window_clients;

BEGIN
  DBMS_AUTO_TASK_ADMIN.DISABLE(
  client_name => 'sql tuning advisor',
  operation => NULL,
  window_name => NULL);
END;
/

select client_name, status from dba_autotask_client;

BEGIN
  DBMS_AUTO_TASK_ADMIN.ENABLE(
  client_name => 'sql tuning advisor',
  operation => NULL,
  window_name => NULL);
END;
/

select snap_id from dba_hist_snapshot order by 1;

col sql_text form a30

SELECT
 sql_id
,substr(sql_text,1,30) sql_text
,disk_reads
,cpu_time
,elapsed_time
FROM table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(3802,3803,
            null, null, 'disk_reads',null, null, null, 10))
ORDER BY disk_reads DESC;

SELECT sql_id, substr(sql_text,1,30) sql_text
,disk_reads, cpu_time, elapsed_time, parsing_schema_name
FROM table(
DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(3802,3803,
'parsing_schema_name <> ''SYS''',
NULL, NULL,NULL,NULL, 1, NULL, 'ALL'));

SELECT
 sql_id
,substr(sql_text,1,30) sql_text
,disk_reads
,cpu_time
,elapsed_time
,buffer_gets
,parsing_schema_name
FROM table(
DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(
 begin_snap => 3802 
,end_snap => 3803 
,basic_filter => 'parsing_schema_name <> ''SYS'''
,ranking_measure1 => 'buffer_gets'
,result_limit => 10
));

SELECT
 sql_id
,substr(sql_text,1,30) sql_text
,disk_reads
,cpu_time
,elapsed_time
FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE('disk_reads > 1000000'))
ORDER BY sql_id;

SELECT sql_id, substr(sql_text,1,30) sql_text
,disk_reads, cpu_time, elapsed_time
FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE('parsing_schema_name <> ''SYS''
                                             AND elapsed_time > 100000'))
ORDER BY sql_id;

SELECT
 sql_id
,substr(sql_text,1,30) sql_text
,disk_reads
,cpu_time
,elapsed_time
,buffer_gets
,parsing_schema_name
FROM table(
DBMS_SQLTUNE.SELECT_CURSOR_CACHE(
 basic_filter => 'parsing_schema_name <> ''SYS'''
,ranking_measure1 => 'cpu_time'
,result_limit => 10
));

SELECT * FROM table(DBMS_SQLTUNE.SELECT_CURSOR_CACHE('sql_id = ''d9gtffrh94mch'''));

BEGIN
  dbms_sqltune.create_sqlset(
    sqlset_name => 'MY_TUNING_SET'
   ,description => 'STS from AWR');
END;
/

select snap_id, begin_interval_time
from dba_hist_snapshot order by 1;

DECLARE
  base_cur dbms_sqltune.sqlset_cursor;
BEGIN
  OPEN base_cur FOR
    SELECT value(x)
    FROM table(dbms_sqltune.select_workload_repository(
      3802,3803, null, null,'disk_reads',
      null, null, null, 15)) x;
  --
  dbms_sqltune.load_sqlset(
    sqlset_name => 'MY_TUNING_SET',
    populate_cursor => base_cur);
END;
/

-- Create the tuning set
EXEC DBMS_SQLTUNE.CREATE_SQLSET('HIGH_DISK_READS');
-- populate the tuning set from the cursor cache
DECLARE
  cur DBMS_SQLTUNE.SQLSET_CURSOR;
BEGIN
  OPEN cur FOR
  SELECT VALUE(x)
  FROM table(
  DBMS_SQLTUNE.SELECT_CURSOR_CACHE(
  'parsing_schema_name <> ''SYS'' AND disk_reads > 1000000', 
  NULL, NULL, NULL, NULL, 1, NULL,'ALL')) x;
--
  DBMS_SQLTUNE.LOAD_SQLSET(sqlset_name => 'HIGH_DISK_READS',
    populate_cursor => cur);
END;
/

BEGIN
  -- Create the tuning set
  DBMS_SQLTUNE.CREATE_SQLSET(
    sqlset_name => 'PROD_WORKLOAD'
   ,description => 'Prod workload sample');
  --
  DBMS_SQLTUNE.CAPTURE_CURSOR_CACHE_SQLSET(
    sqlset_name     => 'PROD_WORKLOAD'
   ,time_limit      => 3600
   ,repeat_interval => 20);
END;
/

BEGIN
  DBMS_SQLTUNE.CAPTURE_CURSOR_CACHE_SQLSET(
    sqlset_name     => 'PROD_WORKLOAD'
   ,time_limit      => 60
   ,repeat_interval => 10
   ,capture_mode    => DBMS_SQLTUNE.MODE_ACCUMULATE_STATS);
END;
/


col name form a40

SELECT name, created, statement_count FROM dba_sqlset;

col sqlset_name form a20

SELECT sqlset_name, elapsed_time, cpu_time, buffer_gets, disk_reads, sql_text
FROM dba_sqlset_statements;

SELECT
 sql_id, elapsed_time, cpu_time, buffer_gets, disk_reads, sql_text
FROM TABLE(DBMS_SQLTUNE.SELECT_SQLSET('PROD_WORKLOAD'));

select sqlset_name, disk_reads, cpu_time, elapsed_time, buffer_gets
from dba_sqlset_statements;

BEGIN
  DBMS_SQLTUNE.DELETE_SQLSET(
    sqlset_name  => 'PROD_WORKLOAD'
   ,basic_filter => 'disk_reads < 200');
END;
/

exec  DBMS_SQLTUNE.DELETE_SQLSET(sqlset_name  => 'PROD_WORKLOAD');

DECLARE
  cur dbms_sqltune.sqlset_cursor;
BEGIN
  OPEN cur FOR
    SELECT value(x)
    FROM table(dbms_sqltune.select_workload_repository(
      26800,26900, null, null,'disk_reads',
      null, null, null, 15)) x;
  --
  dbms_sqltune.load_sqlset(
    sqlset_name => 'MY_TUNING_SET',
    populate_cursor => cur,
    load_option => 'MERGE');
END;
/


DECLARE
  tune_task VARCHAR2(30);
  tune_sql  CLOB;
BEGIN
  tune_sql := 'select count(*) from cust';
  tune_task := DBMS_SQLTUNE.CREATE_TUNING_TASK(
    sql_text    => tune_sql
   ,user_name   => 'MV_MAINT'
   ,scope       => 'COMPREHENSIVE'
   ,time_limit  => 60
   ,task_name   => 'tune_test'
   ,description => 'Provide SQL text'
);
END;
/

SELECT sql_id, sql_text
FROM v$sql
where sql_text like '%&&mytext%';

DECLARE
  tune_task VARCHAR2(30);
  tune_sql  CLOB;
BEGIN
  tune_task := DBMS_SQLTUNE.CREATE_TUNING_TASK(
    sql_id      => 'b62q7nc33gzwx'
   ,task_name   => 'tune_test2'
   ,description => 'Provide SQL ID'
);
END;
/

select sql_id, sql_text from dba_hist_sqltext;

select snap_id from dba_hist_snapshot order by 1;

DECLARE
  tune_task VARCHAR2(30);
  tune_sql  CLOB;

BEGIN
  tune_task := DBMS_SQLTUNE.CREATE_TUNING_TASK(
    sql_id      => '1tbu2jp7kv0pm'
   ,begin_snap  => 21690
   ,end_snap    => 21864
   ,task_name   => 'tune_test3'
);
END;
/

variable mytt varchar2(30);
exec :mytt := DBMS_SQLTUNE.CREATE_TUNING_TASK(sqlset_name => 'PROD_WORKLOAD');
print :mytt

exec dbms_sqltune.execute_tuning_task(task_name => 'tune_test');

set long 10000 longchunksize 10000 linesize 132 pagesize 200
select dbms_sqltune.report_tuning_task('tune_test') from dual;

select owner, task_name, advisor_name, created
from dba_advisor_tasks
order by created;
