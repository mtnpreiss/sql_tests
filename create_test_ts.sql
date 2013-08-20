-- Anlage eines Test-Tablespaces ohne ASSM
-- zu FTS-costing-Tests
-- Database ORCL auf 12c (VM)
-- 07.07.2013

CREATE TABLESPACE test_ts
datafile '/u01/app/oracle/oradata/orcl/test_ts01.dbf' size 1000M autoextend on maxsize unlimited
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M
SEGMENT SPACE MANAGEMENT MANUAL;