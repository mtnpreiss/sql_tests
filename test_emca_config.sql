-- 16.05.2011
-- http://martinpreiss.blogspot.de/2007/04/oracledbconsole-dienst-neu-erzeugen.html

C:\Windows\system32>emca -config dbcontrol db -repos recreate

STARTED EMCA um 16.05.2011 22:22:24
EM-Konfigurationsassistent, Version 11.2.0.0.2 Production
Copyright (c) 2003, 2005, Oracle.  All rights reserved. Alle Rechte vorbehalten.

Geben Sie folgende Informationen ein:
Datenbank-SID: TESTDB
Database Control ist schon f�r die Datenbank TESTDB konfiguriert
Sie haben beschlossen, Database Control zur Verwaltung der Datenbank TESTDB zu konfigurieren
Dadurch werden die bestehende Konfiguration und die Standardeinstellungen entfernt und wird eine neue Konfiguration vorgenommen.
M�chten Sie fortfahren? [ja(Y)/nein(N)]: Y
Listener ORACLE_HOME [ C:\app\product\11.2.0\dbhome_1 ]:
Kennwort f�r SYS-Benutzer:
Kennwort f�r DBSNMP-Benutzer:
Kennwort f�r SYSMAN-Benutzer:
Kennwort f�r SYSMAN-Benutzer: E-Mail-Adresse f�r Benachrichtigungen (optional):
Server f�r ausgehende Mails (SMTP-Server) f�r Benachrichtigungen (optional):
-----------------------------------------------------------------

Sie haben die folgenden Einstellungen angegeben

ORACLE_HOME von Datenbank ................ C:\app\product\11.2.0\dbhome_1

Lokaler Host-Name ................ MPr-PC
Listener ORACLE_HOME ................ C:\app\product\11.2.0\dbhome_1
Listener-Port-Nummer ................ 1521
Datenbank-SID ................ TESTDB
E-Mail-Adresse f�r Benachrichtigungen ...............
Server f�r ausgehende Mails (SMTP-Server) f�r Benachrichtigungen ...............

-----------------------------------------------------------------
M�chten Sie fortfahren? [ja(Y)/nein(N)]: Y
16.05.2011 22:23:22 oracle.sysman.emcp.EMConfig perform
INFO: Dieser Vorgang wird in C:\app\cfgtoollogs\emca\testdb\emca_2011_05_16_22_22_24.log protokolliert.
16.05.2011 22:23:22 oracle.sysman.emcp.util.DBControlUtil stopOMS
INFO: Database Control wird gestoppt (dies kann etwas l�nger dauern) ...
16.05.2011 22:23:23 oracle.sysman.emcp.EMReposConfig invoke
INFO: Das EM-Repository wird gel�scht (dies kann etwas l�nger dauern)...
16.05.2011 22:24:26 oracle.sysman.emcp.EMReposConfig invoke
INFO: Repository erfolgreich gel�scht
16.05.2011 22:24:26 oracle.sysman.emcp.EMReposConfig createRepository
INFO: Das EM-Repository wird erstellt (dies kann etwas l�nger dauern)...
16.05.2011 22:27:46 oracle.sysman.emcp.EMReposConfig invoke
INFO: Repository erfolgreich erstellt
16.05.2011 22:27:49 oracle.sysman.emcp.EMReposConfig uploadConfigDataToRepository
INFO: Konfigurationsdaten werden in das EM-Repository hochgeladen (dies kann etwas l�nger dauern) ...
16.05.2011 22:28:20 oracle.sysman.emcp.EMReposConfig invoke
INFO: Konfigurationsdaten wurden erfolgreich hochgeladen
16.05.2011 22:28:27 oracle.sysman.emcp.util.DBControlUtil configureSoftwareLib
INFO: Software-Library erfolgreich konfiguriert.
16.05.2011 22:28:27 oracle.sysman.emcp.EMDBPostConfig configureSoftwareLibrary
INFO: Provisioning-Archive werden bereitgestellt ...
16.05.2011 22:28:50 oracle.sysman.emcp.EMDBPostConfig configureSoftwareLibrary
INFO: Provisioning-Archive wurden erfolgreich bereitgestellt.
16.05.2011 22:28:50 oracle.sysman.emcp.util.DBControlUtil secureDBConsole
INFO: Database Control wird gesichert (dies kann etwas l�nger dauern) ...
16.05.2011 22:29:02 oracle.sysman.emcp.util.DBControlUtil secureDBConsole
INFO: Database Control erfolgreich gesichert
16.05.2011 22:29:02 oracle.sysman.emcp.util.DBControlUtil startOMS
INFO: Database Control wird gestartet  (dies kann etwas l�nger dauern) ...
16.05.2011 22:30:18 oracle.sysman.emcp.EMDBPostConfig performConfiguration
INFO: Database Control erfolgreich gestartet
16.05.2011 22:30:18 oracle.sysman.emcp.EMDBPostConfig performConfiguration
INFO: >>>>>>>>>>> Der Database Control-URL ist https://MPr-PC:1158/em <<<<<<<<<<<
16.05.2011 22:30:23 oracle.sysman.emcp.EMDBPostConfig invoke
WARNUNG:
************************  WARNING  ************************

Das Management-Repository wurde in den sicheren Modus versetzt, in dem Enterprise Manager-Daten verschl�sselt werden. Der Verschl�sselungsschl�ssel wurde in der Datei C:/app/product/11.2.0/dbhome_1/MPr-PC_testdb/sysman/config/emkey.ora gespeichert. Erstellen Sie ein Backup dieser Datei, da die verschl�sselten Daten nicht mehr benutzt werden k�nnen, wenn diese Datei verloren geht.

***********************************************************
Konfiguration von Enterprise Manager erfolgreich abgeschlossen
FINISHED EMCA um 16.05.2011 22:30:23

C:\Windows\system32>



