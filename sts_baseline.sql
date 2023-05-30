accept tuning_set_in  prompt 'Enter Tuning Set: '
var tuning_set varchar2(30);
exec :tuning_set := trim('&tuning_set_in');

accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid varchar2(30);
exec :sqlid := trim('&sqlid_in');

@screen_setup
prompt This procedure will create a baseline from one captured
prompt in a SQL TUNING SET.  Provide the tuning set name and
prompt sql_id and the procedure will replace the CCL Comment
prompt 'O1' with 'O8' (if present) to match the change from
prompt RBO to CBO, then run the query, then create a baseline for it.
prompt Note this may run for some time depending on the query
prompt
exec dm_perf.sts_baseline(:tuning_set, :sqlid);
