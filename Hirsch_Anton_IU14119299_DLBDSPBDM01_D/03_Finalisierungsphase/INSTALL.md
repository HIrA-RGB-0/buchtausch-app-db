# Installationsanleitung – Buchtausch-App Datenbank

## Voraussetzungen
- MariaDB oder MySQL (getestet mit MariaDB)
- SQL-Client (z. B. MySQL Workbench, HeidiSQL, phpMyAdmin oder CLI)

## Schritte zur Installation
1. Repository clonen oder ZIP-Datei entpacken.
2. MariaDB/MySQL starten.
3. SQL-Skripte in folgender Reihenfolge ausführen:

   ```sql
   SOURCE sql/00_create.sql;
   SOURCE sql/01_insert.sql;
   SOURCE sql/02_geo.sql;
   SOURCE sql/03_geo_test.sql; -- optional für Geo-Testfälle
   ```

4. Überprüfen der Datenbank mit Beispielabfragen:
   - `SELECT COUNT(*) FROM benutzer;`
   - `SELECT * FROM v_exemplar_geo;`
   - `CALL search_exemplare_nearby(NULL, 'Köln', NULL, NULL, NULL, NULL, TRUE);`

## Hinweise
- Alle Screenshots zu Testabfragen, Geo-Funktionen und Metadaten befinden sich im Ordner `/screenshots/`.
- Das ER-Modell und die Dokumentation sind im Ordner `/docs/` abgelegt.
