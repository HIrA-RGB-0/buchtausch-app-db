-- Anzahl der Tabellen
SELECT COUNT(*) AS anzahl_tabellen
FROM information_schema.tables
WHERE table_schema = 'buchtausch_app'
  AND table_type = 'BASE TABLE';

-- Anzahl der Zeilen pro Tabelle
SELECT 'adresse' AS tabelle, COUNT(*) AS zeilen FROM adresse
UNION ALL
SELECT 'benutzer', COUNT(*) FROM benutzer
UNION ALL
SELECT 'admin', COUNT(*) FROM admin
UNION ALL
SELECT 'verleiher', COUNT(*) FROM verleiher
UNION ALL
SELECT 'ausleiher', COUNT(*) FROM ausleiher
UNION ALL
SELECT 'verlag', COUNT(*) FROM verlag
UNION ALL
SELECT 'autor', COUNT(*) FROM autor
UNION ALL
SELECT 'genre', COUNT(*) FROM genre
UNION ALL
SELECT 'buch_werk', COUNT(*) FROM buch_werk
UNION ALL
SELECT 'werk_autor', COUNT(*) FROM werk_autor
UNION ALL
SELECT 'werk_genre', COUNT(*) FROM werk_genre
UNION ALL
SELECT 'zustand', COUNT(*) FROM zustand
UNION ALL
SELECT 'abholort', COUNT(*) FROM abholort
UNION ALL
SELECT 'zeitfenster', COUNT(*) FROM zeitfenster
UNION ALL
SELECT 'buch_exemplar', COUNT(*) FROM buch_exemplar
UNION ALL
SELECT 'ausleihe', COUNT(*) FROM ausleihe
UNION ALL
SELECT 'reservierung', COUNT(*) FROM reservierung
UNION ALL
SELECT 'bewertung', COUNT(*) FROM bewertung
UNION ALL
SELECT 'chat_thread', COUNT(*) FROM chat_thread
UNION ALL
SELECT 'chat_nachricht', COUNT(*) FROM chat_nachricht
UNION ALL
SELECT 'hilfe_ticket', COUNT(*) FROM hilfe_ticket
ORDER BY tabelle;

-- Speichergröße pro Tabelle
SELECT table_name,
       ROUND(data_length / 1024, 2) AS daten_kb,
       ROUND(index_length / 1024, 2) AS index_kb,
       ROUND((data_length + index_length) / 1024, 2) AS gesamt_kb
FROM information_schema.tables
WHERE table_schema = 'buchtausch_app'
ORDER BY (data_length + index_length) DESC;

-- Gesamte Datenbankgröße
SELECT table_schema,
       ROUND(SUM(data_length + index_length) / 1024, 2) AS db_size_kb
FROM information_schema.tables
WHERE table_schema = 'buchtausch_app'
GROUP BY table_schema;

