@screen_setup
PROMPT WARNING: This Script will invalidate ALL cursors for a table in the cache.  This should
PROMPT only be done as a LAST RESORT when high version counts are causing performance issues.
PROMPT ALL queries against this table will be invalidated and need to be reparsed.
prompt Note: UPPERCASE values are required.
COMMENT ON TABLE "&TABLE_OWNER"."&TABLE_NAME" IS 'Comment using invalidate.sql force reparse.';
set verify on
