#!/usr/bin/ksh
if [[ `whoami` != "oracle" ]]
then
  echo "You must run this script as user oracle."
  exit 1
fi

if [[ $ORACLE_HOME = "" ]]
then
  echo "ORACLE_HOME and ORACLE_SID must be set to use this script"
  exit 1
fi

if [[ $ORACLE_SID = "" ]]
then
  echo "ORACLE_HOME and ORACLE_SID must be set to use this script"
  exit 1
fi

REFRESH=$1
if [[ $REFRESH = "" ]]
then
  REFRESH=15
fi

HIST=$2
if [[ $HIST = "" ]]
then
  HIST=60
fi

clear
echo "Running monsql on instance $ORACLE_SID Refresh Time:[$REFRESH] seconds, SQL History:[$HIST] Minutes. "
echo "usage: monsql.ksh [refresh_sec] [history_min]"
sleep 5
while true
do
  $ORACLE_HOME/bin/sqlplus -s / as sysdba<<!
  @screen_setup
  set feedback off
  var lookback_hours number;
  exec :lookback_hours := ${HIST}/60;
  var search_string VARCHAR2(50);
  exec :search_string := 'DM_PERF_NOFILTER';
  var sorter VARCHAR2(13);
  exec :sorter := 'MONSQL';
  @$CBO_HOME/monsql_query.sql
  exit
!
  sleep $REFRESH
  clear
  echo "Running monsql on instance $ORACLE_SID Refresh Time:[$REFRESH] seconds, SQL History:[$HIST] Minutes. "
  echo "usage: monsql.ksh [refresh_sec] [history_min]"
done

