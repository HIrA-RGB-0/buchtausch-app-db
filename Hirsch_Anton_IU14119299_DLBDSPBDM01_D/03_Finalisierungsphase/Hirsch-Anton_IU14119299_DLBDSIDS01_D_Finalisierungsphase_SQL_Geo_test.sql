-- ===========================================================
-- Projekt: Buchtausch-App – Phase 3 (Geo-Funktionalität)
-- Datei: Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Geo_test.sql
-- Autor: Anton Hirsch | IU14119299
-- Zweck: Geo-Funktionalität prüfen + Screenshots erzeugen
-- Voraussetzung: Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Create.sql, Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Insert.sql,
--                Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Geo
-- DB: buchtausch_app (MariaDB/MySQL)
-- ===========================================================

USE buchtausch_app;

-- Session-Encoding/Kollation absichern (vermeidet #1267)
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';

-- -----------------------------------------------------------
-- 1) Textsuche: Straße-Teilstring (liefert i. d. R. mehrere Treffer)
-- -----------------------------------------------------------
SELECT exemplar_id, titel, verleiher_name, strasse, plz, ort
FROM v_exemplar_geo
WHERE strasse COLLATE utf8mb4_unicode_ci LIKE '%straße%' COLLATE utf8mb4_unicode_ci
ORDER BY ort, titel, exemplar_id;

-- -----------------------------------------------------------
-- 2) Textsuche: mehrere Städte (nur 'verfügbar')
-- -----------------------------------------------------------
SELECT exemplar_id, titel, verleiher_name, plz, ort
FROM v_exemplar_geo
WHERE verleihstatus COLLATE utf8mb4_unicode_ci = 'verfügbar' COLLATE utf8mb4_unicode_ci
  AND ort COLLATE utf8mb4_unicode_ci IN ('Köln','München','Frankfurt am Main')
ORDER BY ort, titel, exemplar_id;

-- -----------------------------------------------------------
-- 3) Radius-Suche: 200 km um Frankfurt (liefert mehrere)
-- -----------------------------------------------------------
SELECT exemplar_id, titel, verleiher_name, ort, plz,
       haversine_km(50.1109, 8.6821, lat, lon) AS dist_km
FROM v_exemplar_geo
WHERE lat BETWEEN (50.1109 - 200*(1/111.045)) AND (50.1109 + 200*(1/111.045))
  AND lon BETWEEN (8.6821  - 200*(1/111.045)/COS(RADIANS(50.1109)))
              AND (8.6821  + 200*(1/111.045)/COS(RADIANS(50.1109)))
  AND verleihstatus COLLATE utf8mb4_unicode_ci = 'verfügbar' COLLATE utf8mb4_unicode_ci
HAVING dist_km <= 200
ORDER BY dist_km, titel, exemplar_id;

-- -----------------------------------------------------------
-- 4) Bounding-Box: West-/Mitte-Deutschland (nur 'verfügbar')
--    (weiter gefasst als zuvor, damit mehrere Zeilen zurückkommen)
-- -----------------------------------------------------------
SELECT exemplar_id, titel, verleiher_name, ort, plz, lat, lon
FROM v_exemplar_geo
WHERE verleihstatus COLLATE utf8mb4_unicode_ci = 'verfügbar' COLLATE utf8mb4_unicode_ci
  AND lat BETWEEN 46.0 AND 54.8
  AND lon BETWEEN 4.0  AND 13.6
ORDER BY ort, titel, exemplar_id;

-- -----------------------------------------------------------
-- 5) Kombiniert: Ort LIKE 'Mün%' + 6 km Radius um München
-- -----------------------------------------------------------
SELECT exemplar_id, titel, verleiher_name, ort, plz,
       haversine_km(48.1372, 11.5756, lat, lon) AS dist_km
FROM v_exemplar_geo
WHERE ort COLLATE utf8mb4_unicode_ci LIKE 'Mün%' COLLATE utf8mb4_unicode_ci
  AND lat BETWEEN (48.1372 - 6*(1/111.045)) AND (48.1372 + 6*(1/111.045))
  AND lon BETWEEN (11.5756 - 6*(1/111.045)/COS(RADIANS(48.1372)))
              AND (11.5756 + 6*(1/111.045)/COS(RADIANS(48.1372)))
  AND verleihstatus COLLATE utf8mb4_unicode_ci = 'verfügbar' COLLATE utf8mb4_unicode_ci
HAVING dist_km <= 6
ORDER BY dist_km, titel, exemplar_id;

-- -----------------------------------------------------------
-- 6) Deutschlandweite Bounding-Box (zeigt viele, aber flott dank Index)
-- -----------------------------------------------------------
SELECT exemplar_id, titel, verleiher_name, ort, plz
FROM v_exemplar_geo
WHERE lat BETWEEN 47.0 AND 55.0
  AND lon BETWEEN 5.5  AND 14.5
ORDER BY ort, titel, exemplar_id
LIMIT 50;

-- ===========================================================
-- Ende
-- ===========================================================



