# Buchtausch-App – Datenbankprojekt (IU14119299)

## Überblick
Dieses Projekt entstand im Rahmen des Moduls „Datenbankdesign“. 
Es bildet die Kernprozesse einer Buchtauschplattform in einer relationalen Datenbank ab.

**Phasen:**
- **Phase 1:** Konzeption (Anforderungsspezifikation, ER-Modell, Datenwörterbuch)
- **Phase 2:** Umsetzung (21 Tabellen, Dummy-Daten, Testabfragen)
- **Phase 3:** Finalisierung (Optimierungen, Geo-Suche, Abgabe)

## Installation
1. MariaDB/MySQL starten.
2. SQL-Skripte in folgender Reihenfolge ausführen:
   - `sql/00_create.sql`
   - `sql/01_insert.sql`
   - `sql/02_geo.sql`
   - optional: `sql/03_geo_test.sql`

## Inhalte
- `/sql/` – alle SQL-Dateien (Schema, Inserts, Geo, Tests)
- `/docs/` – Dokumente (Phase 1–3, Abstract, ER-Diagramm)
- `/screenshots/` – Screenshots (Geo-Test, Metadaten, Testabfragen)
- `README.md` – Projektübersicht
- `INSTALL.md` – detaillierte Installationsanleitung

## Lizenz
Dieses Repository dient als Studienabgabe. Alle Rechte vorbehalten.

## Autor
Anton Hirsch | Matrikelnummer IU14119299
