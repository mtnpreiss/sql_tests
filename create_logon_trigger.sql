-- test_logon_trigger.sql
-- 09.05.2012
-- Logon Trigger zur automatischen Aktivierung von SQL-Trace für den User TEST

create or replace trigger test_logon_trigger
after logon on database
begin
if user = 'TEST' then
    execute immediate 'alter session set sql_trace = true';
end if;
end;
/