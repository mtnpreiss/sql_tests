-- 13.05.2011
-- http://martinpreiss.blogspot.de/2011/05/datenloschungen-delete-truncate-drop.html

Datenlöschungen (DELETE, TRUNCATE, DROP)

Dieser Tage hat Tim Hall (http://www.oracle-base.com/blog/2011/05/12/oracle-its-not-for-newbies/) seine Meinung geäußert, die Firma Oracle solle endlich mal ihre Marketing-Strategie ändern und aufhören zu behaupten, der Oracle Server sei einsteigerfreundlich. Geeigneter sei ein Slogan wie: "Oracle. It’s f*ckin’ complicated, but it’s really cool!”

Was mich am Oracle Server (und an mir selbst) immer wieder überrascht, ist, dass ich ohne Mühe zu so ziemlich jedem grundlegenden Feature eine lange Liste von einfachen Fragen vorlegen kann, 
deren Antworten ich nicht kenne.

Zum Beispiel das Zusammenspiel von Queries und Datenlöschungen: relativ harmlos sind DELETEs, die außerhalb der ändernden Session natürlich unsichtbar sind. Aber was passiert, wenn eine Tabelle via DROP
gelöscht oder via TRUNCATE geleert wird, während eine Query einer anderen Session darauf zugreift? Dazu - was sonst? - ein kleiner Test:

Zunächst die Voraussetzungen: Oracle 11.2.0.1, ASSM-Tablespace, 8K Blockgröße - was, abgesehen vielleicht von der Version, in diesem Fall vermutlich mäßig relevant ist. Dazu dann eine Test-Tabelle, die so groß ist,
dass ein FTS darauf auf meinem PC ca. 10 sec. dauert, was mir die Möglichkeit gibt, in der Zwischenzeit etwas auszuprobieren:
<pre>
create table test
as
select rownum id
     , lpad('*', 1000, '*') pad
  from dual
connect by level <= 1000000;
</pre>

Fall 1: DELETE in einer Session und Zugriff in einer zweiten Session
<pre>
-- Session 1
delete from test;

10 Zeilen wurden gelöscht.

-- Session 2
select count(*) from test;

COUNT(*)
--------
      10
</pre>
Das ist jetzt erst mal völlig klar und harmlos, da die Änderung transaktional abgeschirmt ist.

Fall 2: Aufbau einer Tabelle in einer Session und gleichzeitiger Zugriff in einer zweiten Session
<pre>
-- Session 1
create table test 
as
select ...

-- Session 2
select count(*) from test;
--> wartet, während die Tabelle in Session 1 aufgebaut wird und liefert anschließend:
COUNT(*)
--------
 1000000
</pre>
Das Verhalten ist ebenfalls verständlich und harmlos (sofern man sich nicht über die Wartezeit in Session 2 wundert).

Fall 3: DROP TABLE in einer Session, während eine zweite Session auf die Tabelle zugreift
<pre>
-- Session 2
select count(*) from test;
-- Session 1
drop table test;
--> Löschung erfolgt unverzüglich
-- Session 2
--> liefert nach Abschluß des FTS
COUNT(*)
--------
 1000000
-- Wiederholung der Query:
select count(*) from test
                     *
FEHLER in Zeile 1:
ORA-00942: Tabelle oder View nicht vorhanden
</pre>
Das überrascht mich, weil ich erwartet hätte, dass das DROP einen Fehler liefert (ressource busy) oder die Query abbricht.

Fall 4: wie 3, aber mit DROP TABLE ... PURGE, um den recyclebin aus der Rechnung zu nehmen
<pre>
-- Session 2
select count(*) from test;
-- Session 1
drop table test purge;
-- Session 2
--> Query bricht ab
ORA-08103: Dieses Objekt ist nicht mehr vorhanden
</pre>
Also ist tatsächlich der recyclebin dafür verantwortlich, dass die Query in Fall 3 noch ein Ergebnis liefern kann.

Fall 5: TRUNCATE TABLE in einer Session, während eine zweite Session auf die Tabelle zugreift
<pre>
-- Session 2
select count(*) from test;
-- Session 1
truncate table test;
--> liefert ohne Verzögerung: Tabelle mit TRUNCATE geleert.
-- Session 2
--> Query bricht ab
ORA-08103: Dieses Objekt ist nicht mehr vorhanden
</pre>
Das Verhalten entspricht dem des DROP TABLE ... PURGE aus Fall 4. Die Fehlermeldung ist ein wenig überraschend, ergibt sich aber offenbar daraus, dass die DataObjectId des Segments durch das Truncate geändert wird,
wie Freek D’Hooge in einem sehr erhellenden Blog-Eintrag erläutert hat (http://freekdhooge.wordpress.com/2007/12/25/can-a-select-block-a-truncate/) - der mir allerdings erst begegnet ist, als ich mit meinen Tests fertig war.
Die Änderung erfolgt übrigens offenbar nur dann, wenn durch das TRUNCATE tatsächlich Daten gelöscht werden:
<pre>
select dataobj# from sys.obj$ where name = 'TEST';

  DATAOBJ#
----------
     72598

truncate table test;

Tabelle mit TRUNCATE geleert.

select dataobj# from sys.obj$ where name = 'TEST';

  DATAOBJ#
----------
     72599  <-- neue Id

truncate table test;

Tabelle mit TRUNCATE geleert.

select dataobj# from sys.obj$ where name = 'TEST';

  DATAOBJ#
----------
     72599  <-- Id bleibt gleich
</pre>

Die Ergebnisse sind völlig einleuchtend, entsprachen aber nicht ganz meinen Annahmen, denn ich hatte in den Fällen 3 bis 5 eher den Fehler 
"ORA-00054: Ressource belegt und Anforderung mit NOWAIT angegeben oder Timeout abgelaufen" 
erwartet, der aber nur erscheint, wenn man DROP oder TRUNCATE ausführen will, während eine andere Session Transaktionen mit DML-Operationen (INSERT, UPDATE, DELETE) durchführt.
Aber eigentlich ist der Fall klar: ein SELECT erzeugt kein LOCK (wie man in v$lock sehen kann), und ohne LOCK gibt es nichts, was die Löschung des Objekts verhindern kann.
Ein SELECT schützt ein Objekt also nicht vor der Vernichtung.

Alles ganz grundlegende Dinge, über die ich sicher schon viel gelesen habe, aber trotzdem Dinge, die nicht zu meinem aktiven Wissensbestand zählen.
Als nächstes sollte ich mal über LOCKs nachdenken.