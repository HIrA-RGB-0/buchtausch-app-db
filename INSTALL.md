# Installationsanleitung – Buchtausch-App Datenbank

## Voraussetzungen
- MariaDB oder MySQL (getestet mit MariaDB)
- SQL-Client (z. B. MySQL Workbench, HeidiSQL, phpMyAdmin oder CLI)

## Schritte zur Installation
1. Repository clonen oder ZIP-Datei entpacken.
2. MariaDB/MySQL starten.
3. SQL-Skripte in folgender Reihenfolge ausführen:

   ```sql
   SOURCE 03_Finalisierungsphase/Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Create;
   SOURCE 03_Finalisierungsphase/Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Insert;
   SOURCE 03_Finalisierungsphase/Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Geo;
   SOURCE 03_Finalisierungsphase/Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Geo_test; -- optional für Geo-Testfälle
   ```

4. Überprüfen der Datenbank mit Beispielabfragen:
   - `SELECT COUNT(*) FROM benutzer;`
   - `SELECT * FROM v_exemplar_geo;`
   - `CALL search_exemplare_nearby(NULL, 'Köln', NULL, NULL, NULL, NULL, TRUE);`

## Hinweise
- Alle Screenshots zu Testabfragen, Geo-Funktionen und Metadaten befinden sich im Ordner `/alle_screenshots/`.
- Die Anforderungsanalyse, das ER Model und das Datenwörterbuch befinden sich im Ordner `/01_Konzeptionsphase/`.
- Die Dokumentation befindet sich im Ordner `/02_Erarbeitungs-Reflexionsphase/`.
- Das PDF Dokument zur Funktionalität des Datenbankmanagementsystems, den Metadaten, sowie das Abstract befinden sich im Ordner `/03_Finalisierungsphase/`.
