@screen_setup
@baseline_handle
prompt Enter PlanName to drop a single baseline or SQLHandle to drop
prompt ALL baselines for a sql_id
exec dm_perf.drop_baseline('&Plan_or_Handle');

