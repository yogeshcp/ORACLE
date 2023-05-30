@screen_setup
set feedback off
col checker_value format a50
col value format 9999
Prompt Readiness Checklist Results
Prompt
Prompt
SELECT 'DM2_NOANALYZE Trigger Check' as checker, count(*) as value, '1' as checker_value FROM dba_triggers WHERE trigger_name = 'DM2_NOANALYZE' AND status = 'ENABLED'
UNION
--Pre-Initial Statistics Collection Checks
SELECT 'CERN_DBSTATS User Check' as checker, count(*) as value, '1' as checker_value FROM dba_users WHERE username = 'CERN_DBSTATS'
UNION
SELECT 'DM_STAT_TABLE Check' as checker, count(*) as value, '1' as checker_value FROM dba_tables WHERE owner = 'V500' and table_name = 'DM_STAT_TABLE'
UNION
SELECT 'Real Stats Functionality Check' as checker, count(*) as value, '1' as checker_value FROM dm_info WHERE info_domain = 'DATA MANAGEMENT' and info_name = 'REALSTATS PILOT'
UNION
SELECT 'Real Stats Object Check' as checker, count(*) as value, '3' as checker_value
FROM dba_objects
WHERE owner = 'CERN_DBSTATS'
  AND object_name in ('DM_CLINICAL_SEQ','DM_INFO','DM2_USER_TAB_COLS')
  AND object_type = 'SYNONYM'
UNION
SELECT 'Real Stats Configuration Check - Table Overrides' as checker, count(*) as value, '1' as checker_value
FROM dm_info d
WHERE d.info_domain = 'DM2GDBS:PREF-TAB:METHOD_OPT'
  AND d.info_name in ('V500.DM_STAT_TABLE')
  AND info_number = 1
UNION
SELECT 'Real Stats Configuration Check - Column Specific Overrides' as checker, count(*) as value, '4' as checker_value
FROM dm_info di
WHERE di.info_domain = 'DM2GDBS:PREF-COL:METHOD_OPT'
  AND di.info_name in ('V500.ENCNTR_ALIAS.ALIAS','V500.PERSON_ALIAS.ALIAS','V500.DMS_MEDIA_INSTANCE.CONTENT_UID','V500.PREFDIR_ENTRYDATA.DIST_NAME_SHORT')
  AND di.info_char = 'SIZE 1'
  AND di.info_number = 1
UNION
SELECT 'Real Stats Configuration Check - Schema Specific Overrides' as checker, count(*) as value, '3' as checker_value
FROM dm_info
WHERE info_domain in ('DM2GDBS:COL_METHOD_OPT_DEFAULT','DM2GDBS:IND_COL_METHOD_OPT_DEFAULT','DM2GDBS:SIZE254-DEFAULT')
AND info_number = 1
UNION
SELECT 'Real Stats Configuration Check - Oracle User Overrides' as checker, count(*) as value, '>0' as checker_value FROM dm_info WHERE info_domain = 'DM2_ORACLE_USER'
UNION
--Post-Initial Statistics Collection Checks
SELECT 'Statistics Check' as checker, count(*) as value, '>4000, if post initial gather, >50, otherwise' as checker_value
FROM dm_process_queue
WHERE process_type = 'STATISTICS'
  AND object_type = 'TABLE'
  AND operation_txt like '%dm2_gather_dbstats_tab%'
  AND process_status = 'SUCCESS'
  AND owner_name = 'V500'
--Post-Statistics Application Checks
UNION
SELECT 'Statistics Check - User Defined Table Statistics' as checker, count(*) as value, '0' as checker_value FROM dba_tables WHERE owner = 'V500' AND user_stats = 'YES'
UNION
SELECT 'Statistics Check - User Defined Index Statistics' as checker, count(*) as value, '0' as checker_value FROM dba_indexes WHERE owner = 'V500' AND user_stats = 'YES'
UNION
SELECT 'Statistics Check - Histogram Override Confirmation' as checker, count(*) as value, '0' as checker_value
FROM dba_tab_columns
WHERE owner = 'V500'
  AND ((table_name = 'ENCNTR_ALIAS' AND column_name = 'ALIAS')
   OR  (table_name = 'PERSON_ALIAS' AND column_name= 'ALIAS')
   OR  (table_name = 'DMS_MEDIA_INSTANCE' AND column_name ='CONTENT_UID')
   OR  (table_name = 'PREFDIR_ENTRYDATA' AND column_name = 'DIST_NAME_SHORT'))
  AND histogram != 'NONE'
UNION
SELECT 'Post Database Parameter Changes' as checker, count(*) as value, '0' as checker_value FROM dba_triggers WHERE trigger_name = 'TRG_DM_OPTIMIZER_INIT'
UNION
SELECT 'Configuration Check - Logon Trigger Metadata' as checker, count(*) as value, '0' as checker_value FROM dm_info WHERE info_domain = 'DM_SET_SESSION_PARAMETERS';

PROMPT
PROMPT
col description format a30
SELECT 'TABLES MISSING STATS' AS description, count(*)
FROM dba_tables 
WHERE owner NOT IN (SELECT info_name FROM dm_info WHERE info_domain = 'DM2_ORACLE_USER')
and last_analyzed IS NULL AND temporary != 'Y'
UNION
SELECT 'INDEXES MISSING STATS' AS description, count(*) 
FROM dba_indexes 
WHERE index_type NOT IN ('LOB','IOT')
  AND last_analyzed IS NULL
  AND tablespace_name IS NOT NULL
  AND table_owner NOT IN (SELECT info_name FROM dm_info WHERE info_domain = 'DM2_ORACLE_USER');


PROMPT
PROMPT
SELECT 'Statistics Check - Tables' as checker, min(last_analyzed), max(last_analyzed) FROM dba_tables WHERE owner = 'V500'
UNION
SELECT 'Statistics Check - Indexes' as checker, min(last_analyzed), max(last_analyzed) FROM dba_indexes WHERE owner = 'V500';

PROMPT
PROMPT
col sid format a16;
col parameter format a40;
col value format a30;
col checker_value format a20;
SELECT 'Configuration Check - SPFile Check' AS checker, sid, name AS parameter, value, ' ' AS checker_value FROM v$spparameter WHERE name = 'db_file_multiblock_read_count'
UNION ALL
SELECT 'Configuration Check - SPFile Check' AS checker, sid, name AS parameter, value, '30' AS checker_value FROM v$spparameter WHERE name = 'optimizer_index_cost_adj'
UNION ALL
SELECT 'Configuration Check - SPFile Check' AS checker, sid, name AS parameter, value, '90' AS checker_value FROM v$spparameter WHERE name = 'optimizer_index_caching'
UNION ALL
SELECT 'Configuration Check - SPFile Check' AS checker, sid, name AS parameter, value, 'ALL_ROWS' AS checker_value FROM v$spparameter WHERE name = 'optimizer_mode'
UNION ALL
SELECT 'Configuration Check - SPFile Check' AS checker, sid, name AS parameter, value, 'FALSE' AS checker_value FROM v$spparameter WHERE name = '_optimizer_adaptive_cursor_sharing';

PROMPT
PROMPT
SELECT * FROM (
SELECT 'Configuration Check - Live Parameter Check' AS checker, inst_id, name AS parameter, value, '128, if SGA >2GB' AS checker_value FROM gv$parameter
WHERE name = 'db_file_multiblock_read_count'
UNION ALL
SELECT 'Configuration Check - Live Parameter Check' AS checker, inst_id, name AS parameter, value, '30' AS checker_value FROM gv$parameter
WHERE name = 'optimizer_index_cost_adj'
UNION ALL
SELECT 'Configuration Check - Live Parameter Check' AS checker, inst_id, name AS parameter, value, '90' AS checker_value FROM gv$parameter
WHERE name = 'optimizer_index_caching'
UNION ALL
SELECT 'Configuration Check - Live Parameter Check' AS checker, inst_id, name AS parameter, value, 'ALL_ROWS' AS checker_value FROM gv$parameter
WHERE name = 'optimizer_mode'
UNION ALL
SELECT 'Configuration Check - Live Parameter Check' AS checker, inst_id, name AS parameter, value, 'FALSE' AS checker_value FROM gv$parameter
WHERE name = '_optimizer_adaptive_cursor_sharing') ORDER BY inst_id, parameter;
set feedback on