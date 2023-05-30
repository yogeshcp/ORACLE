accept oname_in default 'V500'  prompt 'Enter Owner [V500]: '
accept lookback_days_in default 1 prompt 'Days to look back [1]: '
var o_name varchar2(32);
var lookback_days number;
exec :o_name := trim(upper('&oname_in'));
exec :lookback_days := &lookback_days_in;

set feedback off

EXECUTE DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;

prompt
prompt Displaying TABLE STATS Data for &&oname_in
@screen_setup
col owner format a8
col stale format a5
col size_gb format 9,999.99
col percent_stale format  999.99
select owner, table_name, size_gb, num_rows, least(table_mods/num_rows*100.0, 100) as percent_stale, stale, last_analyzed
from
(select ut.owner
  ,ut.table_name
  ,ut.blocks * 8192 / 1024 / 1024 / 1024 as SIZE_GB
  ,ut.num_rows
  ,nvl(dtm.inserts, 0) + nvl(dtm.updates, 0) + nvl(dtm.deletes, 0) as table_mods
  ,ut.stale_stats as stale
  ,last_analyzed
from dba_tab_statistics ut, sys.dba_tab_modifications dtm
where ut.table_name not like 'BIN%'
      and dtm.table_name not like 'BIN%'
      and ut.owner not in ('ORACLE_OCM','XS$NULL','DBSNMP','CTXSYS','LBACSYS','MDDATA','MDSYS','DMSYS','OLAPSYS','ORDPLUGINS','ORDSYS',
                           'OUTLN','SI_INFORMTN_SCHEMA','SYS','SYSMAN','SYSTEM','RMAN','PERFSTAT','WMSYS','XDB','TSMSYS','DIP',
                           'AQADM','EXFSYS','WKSYS','WK_TEST')
      and dtm.table_owner not in ('ORACLE_OCM','XS$NULL','DBSNMP','CTXSYS','LBACSYS','MDDATA','MDSYS','DMSYS','OLAPSYS','ORDPLUGINS','ORDSYS',
                                  'OUTLN','SI_INFORMTN_SCHEMA','SYS','SYSMAN','SYSTEM','RMAN','PERFSTAT','WMSYS','XDB','TSMSYS','DIP',
                                  'AQADM','EXFSYS','WKSYS','WK_TEST')
and ut.table_name = dtm.table_name (+)
and ut.owner = dtm.table_owner (+)
and ut.owner = upper(:o_name)) x
where x.num_rows > 0
and x.last_analyzed > SYSDATE - :lookback_days
order by x.table_mods/x.num_rows*100.0;

prompt
prompt                         *** ALWAYS gather statistics using the Cerner supported method. ***
prompt




