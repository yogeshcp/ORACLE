@screen_setup
select * from table(dbms_xplan.display_cursor(format=>'IOSTATS ADVANCED +PEEKED_BINDS -PROJECTION -ALIAS'))
/
