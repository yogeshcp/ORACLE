ACCEPT plan_name_in PROMPT 'Enter Plan Name: '
var plan_name VARCHAR2(30);
exec :plan_name := trim('&plan_name_in');

@screen_setup
SELECT substr(PLAN_TABLE_OUTPUT, 1, 155) as plan_data
FROM table(dbms_xplan.display_sql_plan_baseline(plan_name=>:plan_name));
