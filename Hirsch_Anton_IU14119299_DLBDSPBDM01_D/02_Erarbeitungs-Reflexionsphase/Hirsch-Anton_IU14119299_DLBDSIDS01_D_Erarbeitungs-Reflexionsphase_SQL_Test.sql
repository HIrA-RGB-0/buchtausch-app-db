-- ========================================================
-- Datei: 02_test_queries.sql
-- Zweck: Testabfragen & Views (mind. 1 SELECT je Tabelle)
--        + WHERE, GROUP BY, ORDER BY
--        + NATURAL JOIN, INNER JOIN, LEFT JOIN, RIGHT JOIN
-- DB: buchtausch_app
-- ========================================================

USE buchtausch_app;

-- ========================================================
-- VIEWS (praktisch für Folien & Wiederverwendung)
-- ========================================================

-- View 1: Ausleihen mit Werk, Verleiher (aus buch_exemplar) und Ausleiher
CREATE OR REPLACE VIEW v_ausleihe_detail AS
SELECT a.ausleihe_id,
       a.exemplar_id,
       w.titel,
       be.verleiher_id,
       vb.benutzername AS verleiher_name,
       a.ausleiher_id,
       ab.benutzername AS ausleiher_name,
       a.startdatum, a.enddatum, a.status
FROM ausleihe a
JOIN buch_exemplar be ON be.exemplar_id = a.exemplar_id
JOIN verleiher v      ON v.verleiher_id = be.verleiher_id
JOIN benutzer vb      ON vb.benutzer_id = v.verleiher_id
JOIN ausleiher au     ON au.ausleiher_id = a.ausleiher_id
JOIN benutzer ab      ON ab.benutzer_id = au.ausleiher_id
JOIN buch_werk w      ON w.werk_id = be.werk_id;

-- View 2: Ø-Bewertung je Werk (inkl. Anzahl)
CREATE OR REPLACE VIEW v_werk_bewertung AS
SELECT w.werk_id, w.titel,
       ROUND(AVG(bw.sterne),2) AS avg_sterne,
       COUNT(bw.bewertung_id) AS anzahl_bewertungen
FROM buch_werk w
LEFT JOIN bewertung bw ON bw.werk_id = w.werk_id
GROUP BY w.werk_id, w.titel;

-- ========================================================
-- BLOCK A: BASIS
-- ========================================================

-- adresse: einfache Ausgabe (ORDER BY)
SELECT * FROM adresse ORDER BY ort, plz LIMIT 10;

-- benutzer: WHERE + JOIN
SELECT b.benutzer_id, b.benutzername, a.ort
FROM benutzer b
LEFT JOIN adresse a ON a.adresse_id = b.adresse_id
WHERE b.status = 'aktiv'
ORDER BY b.benutzer_id
LIMIT 10;

-- admin: INNER JOIN (klassisch)
SELECT ad.admin_id, b.benutzername
FROM admin ad
INNER JOIN benutzer b ON b.benutzer_id = ad.admin_id
ORDER BY ad.admin_id;

-- verleiher: einfache Liste
SELECT v.verleiher_id, b.benutzername
FROM verleiher v
JOIN benutzer b ON b.benutzer_id = v.verleiher_id
ORDER BY v.verleiher_id;

-- ausleiher: einfache Liste
SELECT a.ausleiher_id, b.benutzername
FROM ausleiher a
JOIN benutzer b ON b.benutzer_id = a.ausleiher_id
ORDER BY a.ausleiher_id;

-- ========================================================
-- BLOCK B: BIBLIOGRAPHIE
-- ========================================================

-- verlag: LEFT JOIN auf adresse (manche Verlage evtl. ohne Adresse)
SELECT v.verlag_id, v.name, a.ort
FROM verlag v
LEFT JOIN adresse a ON a.adresse_id = v.adresse_id
ORDER BY v.name;

-- autor: NATURAL JOIN Beispiel mit werk_autor (gemeinsame Spalte: autor_id)
-- Zeigt pro Werk seine Autoren (ohne explizites ON – NATURAL JOIN nutzt gleich benannte Spalten)
SELECT w.titel, CONCAT(a.vorname,' ',a.nachname) AS autor
FROM werk_autor
NATURAL JOIN autor a
JOIN buch_werk w ON w.werk_id = werk_autor.werk_id
ORDER BY w.titel;

-- genre: RIGHT JOIN Beispiel – alle Genres, auch ohne zugeordnetes Werk
SELECT g.genre_id, g.name AS genre, COUNT(wg.werk_id) AS anzahl_werke
FROM werk_genre wg
RIGHT JOIN genre g ON g.genre_id = wg.genre_id
GROUP BY g.genre_id, g.name
ORDER BY anzahl_werke DESC, g.name;

-- buch_werk: WHERE + ORDER BY
SELECT werk_id, titel, isbn
FROM buch_werk
WHERE erscheinungsjahr >= 2000
ORDER BY erscheinungsjahr DESC, titel;

-- werk_autor: INNER JOIN (klassisch)
SELECT wa.werk_id, w.titel, a.nachname
FROM werk_autor wa
INNER JOIN buch_werk w ON w.werk_id = wa.werk_id
INNER JOIN autor a     ON a.autor_id = wa.autor_id
ORDER BY w.titel, a.nachname;

-- werk_genre: NATURAL JOIN (gemeinsame Spalte: genre_id)
SELECT w.titel, g.name AS genre
FROM werk_genre
NATURAL JOIN genre g
JOIN buch_werk w ON w.werk_id = werk_genre.werk_id
ORDER BY w.titel, g.name;

-- ========================================================
-- BLOCK C: EXEMPLARE & LOGISTIK
-- ========================================================

-- zustand: einfache Liste
SELECT * FROM zustand ORDER BY stufe;

-- abholort: Verleiher + Ort (INNER JOIN-Kette)
SELECT ab.abholort_id, b.benutzername AS verleiher, a.ort, ab.bezeichnung
FROM abholort ab
JOIN verleiher v ON v.verleiher_id = ab.verleiher_id
JOIN benutzer b ON b.benutzer_id = v.verleiher_id
JOIN adresse a  ON a.adresse_id = ab.adresse_id
ORDER BY a.ort, ab.bezeichnung;

-- zeitfenster: WHERE + ORDER BY (nur werktags Mo–Fr)
SELECT z.zeitfenster_id, ab.bezeichnung, z.wochentag, z.von_uhrzeit, z.bis_uhrzeit
FROM zeitfenster z
JOIN abholort ab ON ab.abholort_id = z.abholort_id
WHERE z.wochentag BETWEEN 1 AND 5
ORDER BY z.wochentag, z.von_uhrzeit;

-- buch_exemplar: LEFT JOIN (zeige auch Exemplare ohne Zustand/Abholort)
SELECT e.exemplar_id, w.titel, b.benutzername AS verleiher,
       COALESCE(z.stufe, 'unbekannt') AS zustand,
       e.verleihstatus
FROM buch_exemplar e
JOIN buch_werk w  ON w.werk_id = e.werk_id
JOIN verleiher v  ON v.verleiher_id = e.verleiher_id
JOIN benutzer b   ON b.benutzer_id = v.verleiher_id
LEFT JOIN zustand z ON z.zustand_id = e.zustand_id
LEFT JOIN abholort ab ON ab.abholort_id = e.abholort_id
ORDER BY w.titel, e.exemplar_id;

-- ========================================================
-- BLOCK D: PROZESSE
-- ========================================================

-- ausleihe: Nutzung der View + WHERE + ORDER BY
SELECT ausleihe_id, titel, verleiher_name, ausleiher_name, status
FROM v_ausleihe_detail
WHERE status IN ('aktiv','abgeschlossen')
ORDER BY ausleihe_id;

-- reservierung: INNER JOIN + WHERE Zeitraum
SELECT r.reservierung_id, w.titel, bu.benutzername AS ausleiher,
       r.von_datum, r.bis_datum, r.status
FROM reservierung r
JOIN buch_exemplar e ON e.exemplar_id = r.exemplar_id
JOIN buch_werk w     ON w.werk_id = e.werk_id
JOIN ausleiher au    ON au.ausleiher_id = r.ausleiher_id
JOIN benutzer bu     ON bu.benutzer_id = au.ausleiher_id
WHERE r.von_datum >= '2025-09-01'
ORDER BY r.von_datum, w.titel;

-- bewertung: GROUP BY + ORDER BY (Ø Sterne je Werk)
SELECT w.titel, ROUND(AVG(bw.sterne),2) AS avg_sterne, COUNT(*) AS anzahl
FROM bewertung bw
JOIN buch_werk w ON w.werk_id = bw.werk_id
GROUP BY w.werk_id, w.titel
ORDER BY avg_sterne DESC, anzahl DESC, w.titel;

-- ========================================================
-- BLOCK E: KOMMUNIKATION & SUPPORT
-- ========================================================

-- chat_thread: einfache Liste (LIMIT für screenshot)
SELECT thread_id, thema, erstellt_am
FROM chat_thread
ORDER BY erstellt_am DESC
LIMIT 10;

-- chat_nachricht: LEFT JOIN (zeige Threads mit/ohne gelesene Nachrichten)
SELECT t.thread_id, t.thema, n.nachricht_id, u.benutzername AS sender,
       n.text, n.gelesen
FROM chat_thread t
LEFT JOIN chat_nachricht n ON n.thread_id = t.thread_id
LEFT JOIN benutzer u       ON u.benutzer_id = n.sender_id
ORDER BY t.thread_id, n.nachricht_id;

-- hilfe_ticket: WHERE + ORDER BY (offene/in Bearbeitung zuerst)
SELECT h.ticket_id, u.benutzername, h.betreff, h.status, h.erstellt_am
FROM hilfe_ticket h
JOIN benutzer u ON u.benutzer_id = h.ersteller_id
WHERE h.status IN ('offen','in Bearbeitung','geschlossen')
ORDER BY FIELD(h.status,'offen','in Bearbeitung','geschlossen'), h.erstellt_am DESC;

-- ========================================================
-- EXTRA: Nutzung der View v_werk_bewertung (LEFT JOIN + GROUP BY steckt in der View)
-- ========================================================

-- Alle Werke mit Ø-Bewertung und Anzahl (auch Werke ohne Bewertung)
SELECT * FROM v_werk_bewertung
ORDER BY (avg_sterne IS NULL) ASC, avg_sterne DESC, anzahl_bewertungen DESC, titel ASC;

