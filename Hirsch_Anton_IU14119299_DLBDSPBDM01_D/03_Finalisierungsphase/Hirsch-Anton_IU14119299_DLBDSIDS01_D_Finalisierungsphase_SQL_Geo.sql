-- ===========================================================
-- Projekt: Buchtausch-App – Phase 3 (Geo-Funktionalität)
-- Datei: Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Geo
-- Autor: Anton Hirsch | IU14119299
-- Voraussetzung: 00_create_schema_FINAL.sql + 01_insert_dummy_FINAL.sql
-- DB: buchtausch_app (MariaDB/MySQL, InnoDB, utf8mb4)
-- Ziel:
--   1) lat/lon an ADRESSE + Checks + Indizes
--   2) Views: Abholorte/Exemplare inkl. Geo
--   3) Haversine-Funktion (Radius-Suche, optional)
--   4) Stored Procedure: Textsuche (PLZ/Ort/Straße) + optional Radius
--   5) Demo-Koordinaten passend zu deinen Dummy-Adressen (IDs siehe Inserts)
-- Hinweis:
--   * Keine externen Geocoding-Funktionen – Koordinaten werden hier gesetzt.
--   * „Aktueller Standort“ kommt später aus der App (Browser/Handy-GPS).
-- ===========================================================

USE buchtausch_app;

-- -----------------------------------------------------------
-- 1) ADRESSE um Koordinaten erweitern (zentral, wiederverwendbar)
--    abholort -> adresse existiert bereits in deinem Schema.
-- -----------------------------------------------------------
ALTER TABLE adresse
  ADD COLUMN lat DECIMAL(9,6) NULL,
  ADD COLUMN lon DECIMAL(9,6) NULL;

-- Plausibilitäts-Checks für Koordinaten (keine Funktionen, nur Konstanten)
ALTER TABLE adresse
  ADD CONSTRAINT chk_adresse_lat CHECK (lat BETWEEN -90  AND 90),
  ADD CONSTRAINT chk_adresse_lon CHECK (lon BETWEEN -180 AND 180);

-- Indizes:
--   a) für BETWEEN-Filter (Bounding-Box)
--   b) für Textsuche nach PLZ/Ort/Straße
CREATE INDEX idx_adresse_lat_lon ON adresse(lat, lon);
CREATE INDEX idx_adresse_plz     ON adresse(plz);
CREATE INDEX idx_adresse_ort     ON adresse(ort);
CREATE INDEX idx_adresse_strasse ON adresse(strasse);

-- -----------------------------------------------------------
-- 2) Komfort-Views (Geo in einem Blick)
-- -----------------------------------------------------------
DROP VIEW IF EXISTS v_exemplar_geo;
DROP VIEW IF EXISTS v_abholort_geo;

-- Abholorte inkl. Adresse/Koordinaten
CREATE VIEW v_abholort_geo AS
SELECT
  ab.abholort_id,
  ab.verleiher_id,
  ab.bezeichnung,
  a.adresse_id,
  a.strasse, a.hausnummer, a.plz, a.ort,
  a.lat, a.lon
FROM abholort ab
JOIN adresse a ON a.adresse_id = ab.adresse_id;

-- Exemplar + Werk + Verleiher + Geo (für Suchen)
CREATE VIEW v_exemplar_geo AS
SELECT
  e.exemplar_id,
  w.werk_id,
  w.titel,
  e.verleihstatus,
  e.max_ausleihdauer,
  ab.abholort_id,
  ab.bezeichnung AS abhol_bez,
  b.benutzer_id  AS verleiher_benutzer_id,
  b.benutzername AS verleiher_name,
  a.adresse_id,
  a.strasse, a.hausnummer, a.plz, a.ort,
  a.lat, a.lon
FROM buch_exemplar e
JOIN buch_werk     w  ON w.werk_id     = e.werk_id
JOIN verleiher     v  ON v.verleiher_id = e.verleiher_id
JOIN benutzer      b  ON b.benutzer_id  = v.verleiher_id
JOIN abholort      ab ON ab.abholort_id = e.abholort_id
JOIN adresse       a  ON a.adresse_id   = ab.adresse_id;

-- -----------------------------------------------------------
-- 3) Haversine-Funktion (Entfernung in km; für echte Radius-Suche)
--    Für reine Rechtecksuche genügt BETWEEN auf lat/lon (Index!).
-- -----------------------------------------------------------
DROP FUNCTION IF EXISTS haversine_km;

DELIMITER //
CREATE FUNCTION haversine_km(
  lat1 DECIMAL(9,6), lon1 DECIMAL(9,6),
  lat2 DECIMAL(9,6), lon2 DECIMAL(9,6)
) RETURNS DOUBLE DETERMINISTIC
BEGIN
  RETURN 6371 * 2 * ASIN(
    SQRT(
      POWER(SIN(RADIANS(lat2 - lat1) / 2), 2) +
      COS(RADIANS(lat1)) * COS(RADIANS(lat2)) *
      POWER(SIN(RADIANS(lon2 - lon1) / 2), 2)
    )
  );
END//
DELIMITER ;

-- -----------------------------------------------------------
-- 4) Stored Procedure: Suche nach Exemplaren
--    Eingaben:
--      IN p_plz VARCHAR(10)      -- optional: genaue PLZ
--      IN p_ort VARCHAR(120)     -- optional: Ort (LIKE)
--      IN p_strasse VARCHAR(120) -- optional: Straße (LIKE)
--      IN p_lat DECIMAL(9,6)     -- optional: Mittelpunkt-Breitengrad
--      IN p_lon DECIMAL(9,6)     -- optional: Mittelpunkt-Längengrad
--      IN p_radius_km DOUBLE     -- optional: Radius in km (z. B. 5)
--      IN p_nur_verfuegbar BOOL  -- TRUE: nur 'verfügbar', sonst alle
--    Verhalten:
--      - Wenn p_lat/p_lon/p_radius_km gesetzt: Bounding-Box (Index) + Haversine
--      - Sonst: reine Textsuche (PLZ/Ort/Straße)
-- -----------------------------------------------------------
DROP PROCEDURE IF EXISTS search_exemplare_nearby;

DELIMITER //
CREATE PROCEDURE search_exemplare_nearby(
  IN p_plz        VARCHAR(10),
  IN p_ort        VARCHAR(120),
  IN p_strasse    VARCHAR(120),
  IN p_lat        DECIMAL(9,6),
  IN p_lon        DECIMAL(9,6),
  IN p_radius_km  DOUBLE,
  IN p_nur_verfuegbar BOOLEAN
)
BEGIN
  SET @use_radius := (p_lat IS NOT NULL AND p_lon IS NOT NULL AND p_radius_km IS NOT NULL AND p_radius_km > 0);
  SET @status_sql := CASE WHEN p_nur_verfuegbar THEN "AND e.verleihstatus = 'verfügbar'" ELSE "" END;

  IF @use_radius THEN
    -- Grad/Box berechnen (~1° ≈ 111.045 km; Längengrad skaliert mit Breitengrad)
    SET @deg_per_km = 1.0 / 111.045;
    SET @lat_min = p_lat - p_radius_km * @deg_per_km;
    SET @lat_max = p_lat + p_radius_km * @deg_per_km;
    SET @lon_span = p_radius_km * @deg_per_km / COS(RADIANS(p_lat));
    SET @lon_min = p_lon - @lon_span;
    SET @lon_max = p_lon + @lon_span;

    SET @plz_filter  = IFNULL(CONCAT(" AND a.plz = '", REPLACE(p_plz,"'","''"), "'"), '');
    SET @ort_filter  = IFNULL(CONCAT(" AND a.ort LIKE '%", REPLACE(p_ort,"'","''"), "%'"), '');
    SET @str_filter  = IFNULL(CONCAT(" AND a.strasse LIKE '%", REPLACE(p_strasse,"'","''"), "%'"), '');

    SET @sql = CONCAT(
      "SELECT e.exemplar_id, w.titel, b.benutzername AS verleiher_name,
              a.plz, a.ort, a.lat, a.lon,
              haversine_km(", p_lat, ", ", p_lon, ", a.lat, a.lon) AS dist_km
       FROM buch_exemplar e
       JOIN buch_werk w  ON w.werk_id = e.werk_id
       JOIN verleiher v  ON v.verleiher_id = e.verleiher_id
       JOIN benutzer b   ON b.benutzer_id = v.verleiher_id
       JOIN abholort ab  ON ab.abholort_id = e.abholort_id
       JOIN adresse a    ON a.adresse_id = ab.adresse_id
       WHERE a.lat IS NOT NULL AND a.lon IS NOT NULL ", @status_sql, "
         AND a.lat BETWEEN ", @lat_min, " AND ", @lat_max, "
         AND a.lon BETWEEN ", @lon_min, " AND ", @lon_max,
         @plz_filter, @ort_filter, @str_filter,
      " HAVING dist_km <= ", p_radius_km, "
        ORDER BY dist_km, w.titel, e.exemplar_id"
    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

  ELSE
    -- Reine Textsuche (nutzt Text-Indizes)
    SELECT
      e.exemplar_id, w.titel, b.benutzername AS verleiher_name,
      a.plz, a.ort, a.lat, a.lon
    FROM buch_exemplar e
    JOIN buch_werk w  ON w.werk_id = e.werk_id
    JOIN verleiher v  ON v.verleiher_id = e.verleiher_id
    JOIN benutzer b   ON b.benutzer_id = v.verleiher_id
    JOIN abholort ab  ON ab.abholort_id = e.abholort_id
    JOIN adresse a    ON a.adresse_id = ab.adresse_id
    WHERE (p_nur_verfuegbar = FALSE OR e.verleihstatus = 'verfügbar')
      AND (p_plz     IS NULL OR a.plz = p_plz)
      AND (p_ort     IS NULL OR a.ort LIKE CONCAT('%', p_ort, '%'))
      AND (p_strasse IS NULL OR a.strasse LIKE CONCAT('%', p_strasse, '%'))
    ORDER BY a.ort, w.titel, e.exemplar_id;
  END IF;
END//
DELIMITER ;

-- -----------------------------------------------------------
-- 5) DEMO-KOORDINATEN (angepasst an DEINE Dummy-Adressen)
--    Es werden nur die Adressen gesetzt, die über Abholorte referenziert werden:
--    1 (Berlin), 2 (München), 3 (Köln), 4 (Hamburg), 5 (Stuttgart), 6 (Dresden),
--    7 (Nürnberg), 8 (Kiel), 10 (Frankfurt am Main), 12 (Leipzig),
--    14 (Potsdam), 16 (Magdeburg)
-- -----------------------------------------------------------
UPDATE adresse SET lat=52.520000, lon=13.405000 WHERE adresse_id=1;   -- Berlin
UPDATE adresse SET lat=48.137200, lon=11.575600 WHERE adresse_id=2;   -- München
UPDATE adresse SET lat=50.937500, lon=6.960300  WHERE adresse_id=3;   -- Köln
UPDATE adresse SET lat=53.551100, lon=9.993700  WHERE adresse_id=4;   -- Hamburg
UPDATE adresse SET lat=48.778400, lon=9.180000  WHERE adresse_id=5;   -- Stuttgart
UPDATE adresse SET lat=51.050400, lon=13.737300 WHERE adresse_id=6;   -- Dresden
UPDATE adresse SET lat=49.452100, lon=11.076700 WHERE adresse_id=7;   -- Nürnberg
UPDATE adresse SET lat=54.323300, lon=10.122800 WHERE adresse_id=8;   -- Kiel
UPDATE adresse SET lat=50.110900, lon=8.682100  WHERE adresse_id=10;  -- Frankfurt a. M.
UPDATE adresse SET lat=51.339700, lon=12.373100 WHERE adresse_id=12;  -- Leipzig
UPDATE adresse SET lat=52.400900, lon=13.059100 WHERE adresse_id=14;  -- Potsdam
UPDATE adresse SET lat=52.120500, lon=11.627600 WHERE adresse_id=16;  -- Magdeburg

-- ===========================================================
-- NUTZUNG (DEMO)
-- ===========================================================
-- A) Reine Textsuche: nur 'verfügbar' in Köln
-- CALL search_exemplare_nearby(NULL, 'Köln', NULL, NULL, NULL, NULL, TRUE);

-- B) Textsuche mit exakter PLZ (z. B. 50667 aus deiner Kölner Adresse)
-- CALL search_exemplare_nearby('50667', NULL, NULL, NULL, NULL, NULL, TRUE);

-- C) Umkreissuche 5 km um Köln-Zentrum (50.9375, 6.9603), nur 'verfügbar'
-- CALL search_exemplare_nearby(NULL, NULL, NULL, 50.9375, 6.9603, 5, TRUE);

-- D) Kombiniert: Ort LIKE 'München' + Radius 6 km (48.1372, 11.5756)
-- CALL search_exemplare_nearby(NULL, 'München', NULL, 48.1372, 11.5756, 6, TRUE);

-- E) Bounding-Box ohne Haversine (nur BETWEEN; nutzt den lat/lon-Index)
--    Beispiel-Box um Köln:
--    SET @lat_min = 50.90; SET @lat_max = 50.97;
--    SET @lon_min = 6.90;  SET @lon_max = 6.99;
--    SELECT exemplar_id, titel, ort, plz, lat, lon
--    FROM v_exemplar_geo
--    WHERE verleihstatus = 'verfügbar'
--      AND lat BETWEEN @lat_min AND @lat_max
--      AND lon BETWEEN @lon_min AND @lon_max
--    ORDER BY ort, titel, exemplar_id;
