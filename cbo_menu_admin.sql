@screen_setup
set verify off
set serveroutput on
clear screen
host tail -n1 VERSION | awk -F\| '{print $1" Version "$2" Last update "$3}'
set feedback off
exec dm_perf.disp_version;

prompt
prompt Note: Recommended Terminal Lines: 160
prompt
col owner format a30
SELECT owner, substr(object_name,1,12)
       object_name, object_type,
       to_char(last_ddl_time,'MM/DD/YYYY HH24:MI:SS') created,
       status
FROM dba_objects
WHERE object_name IN ('DM_PERF', 'CBO_PERF_GTTD');

set feedback on

prompt
prompt Analysis              Mitigation            Monitoring            Baseline Mgmt         Reporting           Statistics
prompt __________________    __________________    __________________    __________________    ________________    __________________
prompt @use_rbo              @compare_rbo          monsql.ksh            @drop_baseline*       @baselines          @indexes
prompt @use_cbo              @compare_awr          @monsql               @enable_baseline*     @baseline_report    @histogram
prompt @sql_stats            @get_query            @monsqlexec           @disable_baseline*    @baseline_handle    @dic_stats_view
prompt @awr_stats            @get_query_awr        @monsqlsort           @import_baselines*                        @col_usage
prompt @sql_text             @run_hist_query       @monsqlfind           @export_baselines*                        @monstats
prompt @awr_text             @set_baseline*        @monsqlsum                                                      @recent_stats
prompt @sql_children         @sts_baseline*        @top                  Cursor Mgmt
prompt @query_defs           @hint_baseline*       @top_io               __________________
prompt @xplan_cache          @get_query_admin      @top_cpu              @flush_cursor*
prompt @xplan_awr            @get_query_awr_admin  @longops              @keep_cursor*
prompt @xplan_sts                                  @cursql               @unkeep_cursor*
prompt @xplan_baseline                             @version_count        @invalidate*
prompt @find_sql                                   @monlock
prompt @find_awr                                   @monblock
prompt @find_sts                                   @sql_report
prompt @acs_stats                                  @long_parse
prompt                                             @shared_phv
prompt
prompt @readiness_check
prompt
prompt Items marked with an * are not accessible via the Read-Only version of the CBO Toolkit
prompt
