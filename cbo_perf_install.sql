-- cbo_perf_install.sql
-- installs the CBO Toolkit

set lines 132
set pages 100
set serveroutput on size 100000
!mkdir -p /atg/cbo/query
CREATE OR REPLACE DIRECTORY DM_PERF_DIR AS '/atg/cbo/query';

prompt Enter Username for installation, if prompted for "1".  Recommended is CERN_DBSTATS.
GRANT READ, WRITE ON DIRECTORY DM_PERF_DIR TO &&1;

GRANT EXECUTE ANY PROCEDURE TO &&1;
GRANT CREATE PUBLIC SYNONYM, DROP PUBLIC SYNONYM TO &&1;
GRANT SELECT ANY TABLE TO &&1;
GRANT ADMINISTER SQL MANAGEMENT OBJECT TO &&1;
GRANT EXECUTE_CATALOG_ROLE TO &&1;
GRANT EXECUTE ON DBMS_SHARED_POOL TO &&1;
GRANT UNLIMITED TABLESPACE TO &&1;

CREATE OR REPLACE PUBLIC SYNONYM dbms_shared_pool FOR sys.dbms_shared_pool;

prompt Error 'ORA-00955: name is already used by an existing object' from CREATE GLOBAL TEMPORARY table statement below is acceptable
CREATE GLOBAL TEMPORARY TABLE &1 .cbo_perf_gttd
(child_number NUMBER,
 sql_id VARCHAR2(13))
ON COMMIT DELETE ROWS;

CREATE OR REPLACE PUBLIC SYNONYM cbo_perf_gttd FOR &&1 .cbo_perf_gttd;

prompt creating package dm_perf under schema &&1
@./dm_perf_pkg.plb
show errors

prompt Creating package body dm_perf under schema &&1
@./dm_perf_pkg_body.plb
show errors

CREATE OR REPLACE PUBLIC SYNONYM dm_perf FOR &&1 .dm_perf;

GRANT EXECUTE ON &&1 .dm_perf TO PUBLIC;

@cbo_menu

prompt If owner is not &&1 or status is not VALID, do not continue!

exit;