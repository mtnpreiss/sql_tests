-- 13.05.2011

select distinct sid from v$mystat;

  SID
-----
  131
  
select * from v$lock where sid = 131;

ADDR             KADDR                   SID TY        ID1        ID2      LMODE    REQUEST      CTIME      BLOCK
---------------- ---------------- ---------- -- ---------- ---------- ---------- ---------- ---------- ----------
000007FF60C55958 000007FF60C559B0        131 AE        100          0          4          0         34          0


select type
     , name
     , description 
  from v$lock_type
 where type = 'AE'
/


TYPE       NAME                           DESCRIPTION
---------- ------------------------------ -----------------------------------
AE         Edition Lock                   Prevent Dropping an edition in use

"AE is about application code versioning (editions) which should be released as part of Oracle 11.2 I think."
http://www.freelists.org/post/oracle-l/Lock-Type-in-VLOCK,1
"The AE lock is the 11g “Application Edition” lock"
http://jonathanlewis.wordpress.com/2010/02/15/lock-horror/

Was eine Edition in diesem Zusammenhang ist, scheint nicht völlig klar zu sein
http://dbaspot.com/oracle-server/426641-what-edition.html
http://psoug.org/reference/editions.html


drop table test;
create table test
as
select rownum id
     , lpad('*', 1000, '*') pad
  from dual
connect by level <= 1000000; 

update test set id = -1 where id = 1;

select * from v$lock where sid = 131;

ADDR             KADDR                   SID TYPE              ID1        ID2      LMODE    REQUEST      CTIME      BLOCK
---------------- ---------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
000007FF60C55958 000007FF60C559B0        131 AE                100          0          4          0        831          0
000000001B105268 000000001B1052C8        131 TM              72590          0          3          0          6          0
000007FF5CD334B0 000007FF5CD33528        131 TX             458780        898          6          0          6          0

TYPE       NAME                           DESCRIPTION
---------- ------------------------------ ---------------------------------------------------------------------
TM         DML                            Synchronizes accesses to an object
TX         Transaction                    Lock held by a transaction to allow other transactions to wait for it

select *
  from test
 where id < 10
   for update;
   
ADDR             KADDR                   SID TYPE              ID1        ID2      LMODE    REQUEST      CTIME      BLOCK
---------------- ---------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
000007FF60C55958 000007FF60C559B0        131 AE                100          0          4          0       1050          0
000000001B160F18 000000001B160F78        131 TM              72590          0          3          0          6          0
000007FF5CD334B0 000007FF5CD33528        131 TX             393219        973          6          0          6          0

-- in einer zweiten Session:
SQL> truncate table test;
truncate table test
               *
FEHLER in Zeile 1:
ORA-00054: Ressource belegt und Anforderung mit NOWAIT angegeben oder Timeout abgelaufen


Abgelaufen: 00:00:00.02
SQL> drop table test;
drop table test
           *
FEHLER in Zeile 1:
ORA-00054: Ressource belegt und Anforderung mit NOWAIT angegeben oder Timeout abgelaufen   

-- in Session 2, während der Tabellenaufbau in Session 1 läuft:
select count(*) from test;
--> Query wartet

-- Session 2:
select count(*) from test;
-- Session 1:
SQL> drop table test;
--> liefert ohne längere Wartezeit:
Tabelle wurde gelöscht.
--> Ergebnis in Session 2
  COUNT(*)
----------
   1000000

Abgelaufen: 00:00:09.48

SQL> select count(*) from test;
select count(*) from test
                     *
FEHLER in Zeile 1:
ORA-00942: Tabelle oder View nicht vorhanden

-- Session 2:
select count(*) from test;
-- Session 1:
truncate table test;
--> liefert ohne längere Wartezeit:
Tabelle mit TRUNCATE geleert.
-- Session 2:
FEHLER in Zeile 1:
ORA-08103: Dieses Objekt ist nicht mehr vorhanden


	 
	 
