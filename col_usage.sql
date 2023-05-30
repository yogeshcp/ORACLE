@screen_setup
set feedback off

accept tname_in  prompt 'Enter Table Name: '
var t_name varchar2(30);

exec :t_name := upper(trim('&tname_in'));

select
  o.name,
  c.name,
  u.equality_preds,
  u.equijoin_preds,
  u.nonequijoin_preds,
  u.range_preds,
  u.like_preds,
  u.null_preds
from
        sys.col_usage$ u
  join  sys.obj$       o      on u.obj# = o.obj#
  join  sys.col$       c      on u.obj# = c.obj# and u.intcol# = c.col#
and o.name=:t_name;
set verify on
set feedback on
