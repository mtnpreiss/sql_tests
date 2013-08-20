-- 18.03.2012

CREATE TABLE tab_mv_refresh (
    artikel_id NUMBER(10)
  , filial_id NUMBER(10)
  , datum DATE
  , umsatz number(16,4)
)
PARTITION BY RANGE (datum)
(
    PARTITION tab_mv_refresh_2007 VALUES LESS THAN (TO_DATE('20080101', 'YYYYMMDD'))
  , PARTITION tab_mv_refresh_2008 VALUES LESS THAN (TO_DATE('20090101', 'YYYYMMDD'))
  , PARTITION tab_mv_refresh_2009 VALUES LESS THAN (TO_DATE('20100101', 'YYYYMMDD'))
  , PARTITION tab_mv_refresh_2010 VALUES LESS THAN (TO_DATE('20110101', 'YYYYMMDD'))
  , PARTITION tab_mv_refresh_2011 VALUES LESS THAN (TO_DATE('20120101', 'YYYYMMDD'))
  , PARTITION tab_mv_refresh_2012 VALUES LESS THAN (TO_DATE('20130101', 'YYYYMMDD'))
  , PARTITION tab_mv_refresh_maxvalue VALUES LESS THAN (MAXVALUE)
);

insert /*+ append */ into tab_mv_refresh
select round(dbms_random.value * 10000) artikel_id
     , round(dbms_random.value * 100) filial_id
     , to_date('01.01.2007', 'dd.mm.yyyy') + round(dbms_random.value * 10000) datum
     , round(dbms_random.value * 500) umsatz
  from dual
connect by level <= 1000000;