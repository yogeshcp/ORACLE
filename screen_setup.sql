set lines 160
set pages 1000
set long 999999999
set serveroutput on size 1000000
set verify off
clear breaks
col accepted format a8
col enabled format a8
col script format a45
col plan_hash format 9999999999
col num_rows format 999,999,999,999
col sql_id format a13
col execs format 9,999,999
col disk_reads format 99,999,999,999
col avg_disk format 9,999,999.99
col buffer_gets format 99,999,999,999
col avg_buffer format 99,999,999.99
col etime format 9,999,999.99
col avg_etime format 999,999.99
col inst_id format 99 HEADING "INST"
col last_child_num format 99999 heading "LAST|CHILD|NUM"
col child_cnt format 99999 heading "CHILD|CNT"
