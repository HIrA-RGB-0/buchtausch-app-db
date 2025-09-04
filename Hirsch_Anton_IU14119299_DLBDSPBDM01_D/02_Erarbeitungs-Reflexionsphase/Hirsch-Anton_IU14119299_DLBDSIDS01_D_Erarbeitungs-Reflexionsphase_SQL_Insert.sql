-- ========================================================
-- Datei: 01_insert_dummy.sql
-- Zweck: Dummy-Daten für alle 21 Tabellen (≥10 Einträge je Tabelle)
-- DB: buchtausch_app (MariaDB/InnoDB, utf8mb4)
-- ========================================================

USE buchtausch_app;

-- Reset: Child → Parent (FK-sicher), IDs zurücksetzen
-- Kommunikation & Support
DELETE FROM chat_nachricht;
ALTER TABLE chat_nachricht AUTO_INCREMENT = 1;

DELETE FROM chat_thread;
ALTER TABLE chat_thread AUTO_INCREMENT = 1;

DELETE FROM hilfe_ticket;
ALTER TABLE hilfe_ticket AUTO_INCREMENT = 1;

-- Bewertungen/Prozesse
DELETE FROM bewertung;
ALTER TABLE bewertung AUTO_INCREMENT = 1;

DELETE FROM reservierung;
ALTER TABLE reservierung AUTO_INCREMENT = 1;

DELETE FROM ausleihe;
ALTER TABLE ausleihe AUTO_INCREMENT = 1;

-- Exemplare & Logistik
DELETE FROM zeitfenster;
ALTER TABLE zeitfenster AUTO_INCREMENT = 1;

DELETE FROM buch_exemplar;
ALTER TABLE buch_exemplar AUTO_INCREMENT = 1;

DELETE FROM abholort;
ALTER TABLE abholort AUTO_INCREMENT = 1;

DELETE FROM zustand;
ALTER TABLE zustand AUTO_INCREMENT = 1;

-- Bibliographie (M:N zuerst)
DELETE FROM werk_genre;
ALTER TABLE werk_genre AUTO_INCREMENT = 1;

DELETE FROM werk_autor;
ALTER TABLE werk_autor AUTO_INCREMENT = 1;

DELETE FROM buch_werk;
ALTER TABLE buch_werk AUTO_INCREMENT = 1;

DELETE FROM genre;
ALTER TABLE genre AUTO_INCREMENT = 1;

DELETE FROM autor;
ALTER TABLE autor AUTO_INCREMENT = 1;

DELETE FROM verlag;
ALTER TABLE verlag AUTO_INCREMENT = 1;

-- Basis (Rollen vor Benutzer)
DELETE FROM admin;
ALTER TABLE admin AUTO_INCREMENT = 1;

DELETE FROM verleiher;
ALTER TABLE verleiher AUTO_INCREMENT = 1;

DELETE FROM ausleiher;
ALTER TABLE ausleiher AUTO_INCREMENT = 1;

DELETE FROM benutzer;
ALTER TABLE benutzer AUTO_INCREMENT = 1;

-- Ganz zuletzt: Adresse (Parent)
DELETE FROM adresse;
ALTER TABLE adresse AUTO_INCREMENT = 1;

-- ========================================================
-- Block A: Basis (adresse, benutzer, admin, verleiher, ausleiher)
-- ========================================================

-- adresse (20)
INSERT INTO adresse (strasse, hausnummer, plz, ort) VALUES
('Hauptstraße', '12', '10115', 'Berlin'),
('Bahnhofstraße', '7A', '80331', 'München'),
('Musterweg', '5', '50667', 'Köln'),
('Lindenallee', '23', '20095', 'Hamburg'),
('Goethestraße', '44', '70173', 'Stuttgart'),
('Schillerplatz', '1', '01067', 'Dresden'),
('Brunnenweg', '19', '90402', 'Nürnberg'),
('Seestraße', '8', '24103', 'Kiel'),
('Parkallee', '3', '28195', 'Bremen'),
('Ringstraße', '27', '60311', 'Frankfurt am Main'),
('Wiesenweg', '14', '49074', 'Osnabrück'),
('Am Markt', '2', '04109', 'Leipzig'),
('Bergstraße', '9', '34117', 'Kassel'),
('Uferweg', '6', '14467', 'Potsdam'),
('Nordallee', '11', '48143', 'Münster'),
('Südstraße', '33', '39104', 'Magdeburg'),
('Ostring', '21', '86150', 'Augsburg'),
('Westweg', '4', '89073', 'Ulm'),
('Feldstraße', '18', '28195', 'Bremen'),
('Rosenweg', '15', '18055', 'Rostock');

-- benutzer (20)
INSERT INTO benutzer (benutzername, vorname, nachname, email, passwort_hash, adresse_id, status) VALUES
('anna.k',   'Anna',   'Klein',     'anna.k@example.com',   'hash_anna',   1,  'aktiv'),
('max.m',    'Max',    'Müller',    'max.m@example.com',    'hash_max',    2,  'aktiv'),
('sara.s',   'Sara',   'Schmidt',   'sara.s@example.com',   'hash_sara',   3,  'aktiv'),
('timo.b',   'Timo',   'Becker',    'timo.b@example.com',   'hash_timo',   4,  'aktiv'),
('lena.h',   'Lena',   'Hofmann',   'lena.h@example.com',   'hash_lena',   5,  'aktiv'),
('paul.w',   'Paul',   'Wagner',    'paul.w@example.com',   'hash_paul',   6,  'aktiv'),
('mia.f',    'Mia',    'Fischer',   'mia.f@example.com',    'hash_mia',    7,  'aktiv'),
('jonas.r',  'Jonas',  'Richter',   'jonas.r@example.com',  'hash_jonas',  8,  'aktiv'),
('klara.s',  'Klara',  'Schäfer',   'klara.s@example.com',  'hash_klara',  9,  'aktiv'),
('felix.w',  'Felix',  'Weber',     'felix.w@example.com',  'hash_felix',  10, 'aktiv'),
('admin.1',  'Admin',  'Eins',      'admin1@example.com',   'hash_admin1', 11, 'aktiv'),
('mod.1',    'Mod',    'Eins',      'mod1@example.com',     'hash_mod1',   12, 'gesperrt'),
('nils.k',   'Nils',   'Keller',    'nils.k@example.com',   'hash_nils',   13, 'aktiv'),
('eva.l',    'Eva',    'Lehmann',   'eva.l@example.com',    'hash_eva',    14, 'aktiv'),
('ole.p',    'Ole',    'Peters',    'ole.p@example.com',    'hash_ole',    15, 'aktiv'),
('luis.g',   'Luis',   'Graf',      'luis.g@example.com',   'hash_luis',   16, 'aktiv'),
('nina.b',   'Nina',   'Brandt',    'nina.b@example.com',   'hash_nina',   17, 'aktiv'),
('yara.o',   'Yara',   'Otto',      'yara.o@example.com',   'hash_yara',   18, 'aktiv'),
('tim.s',    'Tim',    'Schulz',    'tim.s@example.com',    'hash_tim',    19, 'aktiv'),
('zoe.h',    'Zoe',    'Hansen',    'zoe.h@example.com',    'hash_zoe',    20, 'aktiv');

-- admin (3)
INSERT INTO admin (admin_id) VALUES (11), (2), (5);

-- verleiher (10)
INSERT INTO verleiher (verleiher_id) VALUES (1), (2), (4), (5), (7), (8), (10), (12), (14), (16);

-- ausleiher (16)
INSERT INTO ausleiher (ausleiher_id) VALUES
(1), (3), (4), (6), (7), (8), (9), (10), (11), (12), (13), (15), (17), (18), (19), (20);

-- ========================================================
-- Block B: Bibliographie (verlag, autor, genre, buch_werk, werk_autor, werk_genre)
-- ========================================================

-- verlag (10)
INSERT INTO verlag (name, adresse_id) VALUES
('Verlag Morgenstern', 3),
('Nordlicht Verlag', 4),
('Südwind Press', 5),
('Ostsee Bücher', 8),
('Westpark Medien', 9),
('Hauptstadt Verlag', 1),
('Alpenblick Verlag', 2),
('Rheinland Books', 3),
('Elbstrand Print', 4),
('Donau Edition', 5);

-- autor (15)
INSERT INTO autor (vorname, nachname) VALUES
('Thomas', 'Mann'),
('Franz', 'Kafka'),
('Hermann', 'Hesse'),
('Ingeborg', 'Bachmann'),
('Heinrich', 'Böll'),
('Günter', 'Grass'),
('Siegfried', 'Lenz'),
('Jenny', 'Erpenbeck'),
('Juli', 'Zeh'),
('Daniel', 'Kehlmann'),
('Cornelia', 'Funke'),
('Patrick', 'Süskind'),
('Theodor', 'Fontane'),
('Friedrich', 'Dürrenmatt'),
('Pascal', 'Mercier');

-- genre (12)
INSERT INTO genre (name, beschreibung) VALUES
('Roman', 'Erzählende Prosa'),
('Novelle', 'Kürzere Erzählform'),
('Fantasy', 'Fantastische Welten'),
('Krimi', 'Spannung & Ermittlungen'),
('Sachbuch', 'Fach- und Sachthemen'),
('Biografie', 'Leben einer Person'),
('Science Fiction', 'Zukünftige/technische Welten'),
('Lyrik', 'Gedichte/Poetik'),
('Historisch', 'Geschichtlicher Kontext'),
('Drama', 'Bühnen-/Konfliktstoffe'),
('Jugendbuch', 'Für junge Leser'),
('Essay', 'Reflexion/Abhandlung');

-- buch_werk (12) – fiktive ISBNs (13-stellig)
INSERT INTO buch_werk (titel, isbn, erscheinungsjahr, sprache, verlag_id) VALUES
('Buddenbrooks',          '9780000000001', 1901, 'Deutsch', 1),
('Der Prozess',           '9780000000002', 1925, 'Deutsch', 2),
('Der Steppenwolf',       '9780000000003', 1927, 'Deutsch', 3),
('Die Blechtrommel',      '9780000000004', 1959, 'Deutsch', 6),
('Das Parfum',            '9780000000005', 1985, 'Deutsch', 9),
('Tyll',                  '9780000000006', 2017, 'Deutsch', 10),
('Effi Briest',           '9780000000007', 1895, 'Deutsch', 6),
('Die Vermessung der Welt','9780000000008', 2005, 'Deutsch', 10),
('Unterleuten',           '9780000000009', 2016, 'Deutsch', 5),
('Nachtzug nach Lissabon','9780000000010', 2004, 'Deutsch', 8),
('Die Physiker',          '9780000000011', 1962, 'Deutsch', 7),
('Tintenherz',            '9780000000012', 2003, 'Deutsch', 4);

-- werk_autor (mind. 12, teils 2 je Werk) 
INSERT INTO werk_autor (werk_id, autor_id, rolle) VALUES
(1,  (SELECT autor_id FROM autor WHERE vorname='Thomas'    AND nachname='Mann'       LIMIT 1), 'Autor'),
(2,  (SELECT autor_id FROM autor WHERE vorname='Franz'     AND nachname='Kafka'      LIMIT 1), 'Autor'),
(3,  (SELECT autor_id FROM autor WHERE vorname='Hermann'   AND nachname='Hesse'      LIMIT 1), 'Autor'),
(4,  (SELECT autor_id FROM autor WHERE vorname='Günter'    AND nachname='Grass'      LIMIT 1), 'Autor'),
(5,  (SELECT autor_id FROM autor WHERE vorname='Patrick'   AND nachname='Süskind'    LIMIT 1), 'Autor'),
(6,  (SELECT autor_id FROM autor WHERE vorname='Daniel'    AND nachname='Kehlmann'   LIMIT 1), 'Autor'),
(7,  (SELECT autor_id FROM autor WHERE vorname='Theodor'   AND nachname='Fontane'    LIMIT 1), 'Autor'),
(8,  (SELECT autor_id FROM autor WHERE vorname='Daniel'    AND nachname='Kehlmann'   LIMIT 1), 'Autor'),
(9,  (SELECT autor_id FROM autor WHERE vorname='Juli'      AND nachname='Zeh'        LIMIT 1), 'Autor'),
(10, (SELECT autor_id FROM autor WHERE vorname='Pascal'    AND nachname='Mercier'    LIMIT 1), 'Autor'),
(11, (SELECT autor_id FROM autor WHERE vorname='Friedrich' AND nachname='Dürrenmatt' LIMIT 1), 'Autor'),
(12, (SELECT autor_id FROM autor WHERE vorname='Cornelia'  AND nachname='Funke'      LIMIT 1), 'Autor');

-- werk_genre (mind. 12, teils 2 je Werk)
INSERT INTO werk_genre (werk_id, genre_id) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1), (4, 9),
(5, 1), (5, 4),
(6, 1), (6, 9),
(7, 1),
(8, 1), (8, 9),
(9, 1),
(10, 1),
(11, 10),
(12, 3), (12, 11);

-- ========================================================
-- Block C: Exemplare & Logistik (zustand, abholort, zeitfenster, buch_exemplar)
-- ========================================================

-- zustand (10)
INSERT INTO zustand (stufe, beschreibung) VALUES
('neu', 'Wie frisch aus dem Laden'),
('sehr gut', 'Minimale Gebrauchsspuren'),
('gut', 'Leichte Gebrauchsspuren'),
('ordentlich', 'Einige Knicke oder Markierungen'),
('gebraucht', 'Gut lesbar, sichtbare Nutzung'),
('abgenutzt', 'Stärker beansprucht, voll lesbar'),
('mit Notizen', 'Eintragungen vorhanden'),
('bibliotheksex', 'Stempel/Signatur vorhanden'),
('sammelwürdig', 'Besonders gepflegt'),
('antik', 'Sehr alt, empfindlich');

-- abholort (12) – gehört Verleihern; nutzt vorhandene Adressen
INSERT INTO abholort (verleiher_id, adresse_id, bezeichnung, hinweis) VALUES
(1,  1,  'Haustür',     'Bitte klingeln'),
(2,  2,  'Packstation', 'DHL-Box 102'),
(4,  4,  'Haustür',     'Nach 18 Uhr'),
(5,  5,  'Arbeitsplatz', 'Rezeption fragen'),
(7,  7,  'Garage',      'Tor rechts'),
(8,  8,  'Nachbar',     'Bei Familie Meier'),
(10, 10, 'Haustür',     'Hund bellt, ist lieb'),
(12, 12, 'Packstation', 'Box 55'),
(14, 14, 'Haustür',     '2. Etage'),
(16, 16, 'Haustür',     'Bitte anrufen'),
(2,  3,  'Nachbar',     'Hausnummer 7B'),
(5,  6,  'Garage',      'Hinterhof');

-- zeitfenster (12)
INSERT INTO zeitfenster (abholort_id, wochentag, von_uhrzeit, bis_uhrzeit) VALUES
(1,  1, '17:00:00', '20:00:00'),
(2,  2, '08:00:00', '12:00:00'),
(3,  3, '18:00:00', '21:00:00'),
(4,  4, '09:00:00', '11:00:00'),
(5,  5, '16:00:00', '19:00:00'),
(6,  6, '10:00:00', '13:00:00'),
(7,  0, '14:00:00', '16:00:00'),
(8,  1, '19:00:00', '21:00:00'),
(9,  2, '07:30:00', '09:00:00'),
(10, 3, '12:00:00', '14:00:00'),
(11, 4, '15:00:00', '18:00:00'),
(12, 5, '17:30:00', '19:30:00');

-- buch_exemplar (20) – verweist auf werk, verleiher, zustand, abholort
INSERT INTO buch_exemplar (werk_id, verleiher_id, zustand_id, verleihstatus, max_ausleihdauer, abholort_id, versandoption) VALUES
(1,  1,  1, 'verfügbar', 21, 1,  TRUE),
(2,  2,  3, 'verfügbar', 14, 2,  FALSE),
(3,  4,  2, 'ausgeliehen', 28, 3, TRUE),
(4,  5,  5, 'verfügbar', 14, 4,  TRUE),
(5,  7,  4, 'reserviert', 21, 5, TRUE),
(6,  8,  2, 'verfügbar', 7,  6,  FALSE),
(7,  10, 6, 'verfügbar', 14, 7,  TRUE),
(8,  12, 7, 'verfügbar', 21, 8,  FALSE),
(9,  14, 8, 'ausgeliehen', 14, 9, TRUE),
(10, 16, 3, 'verfügbar', 21, 10, TRUE),
(11, 2,  9, 'verfügbar', 14, 11, TRUE),
(12, 5,  2, 'verfügbar', 21, 12, FALSE),
(1,  4,  4, 'verfügbar', 30, 3,  TRUE),
(2,  5,  1, 'ausgeliehen', 14, 4, TRUE),
(3,  7,  5, 'verfügbar', 21, 5, TRUE),
(4,  8,  2, 'reserviert', 7,  6, FALSE),
(5,  10, 3, 'verfügbar', 14, 7, TRUE),
(6,  12, 6, 'verfügbar', 21, 8, TRUE),
(7,  14, 7, 'verfügbar', 21, 9, TRUE),
(8,  16, 2, 'verfügbar', 21, 10, TRUE);

-- ========================================================
-- Block D: Prozesse (ausleihe, reservierung, bewertung)
-- Hinweis: verleiher_id in ausleihe muss zu exemplar passen
-- ========================================================

-- ausleihe (12) – nutzt exemplar_id 1..12 passend zu deren verleiher_id
-- exemplar_id:    1  2  3   4   5   6   7    8    9    10   11  12
-- verleiher_id:   1  2  4   5   7   8   10   12   14   16   2   5
INSERT INTO ausleihe (exemplar_id, verleiher_id, ausleiher_id, startdatum, enddatum, status) VALUES
(1,  1,  3,  '2025-07-01', '2025-07-20', 'abgeschlossen'),
(2,  2,  4,  '2025-07-10', '2025-07-24', 'abgeschlossen'),
(3,  4,  6,  '2025-08-01', '2025-08-22', 'aktiv'),
(4,  5,  7,  '2025-07-15', '2025-07-29', 'abgeschlossen'),
(5,  7,  8,  '2025-08-05', '2025-08-19', 'aktiv'),
(6,  8,  9,  '2025-08-10', '2025-08-24', 'aktiv'),
(7,  10, 11, '2025-07-05', '2025-07-19', 'abgeschlossen'),
(8,  12, 12, '2025-08-12', '2025-08-26', 'aktiv'),
(9,  14, 13, '2025-07-20', '2025-08-03', 'abgeschlossen'),
(10, 16, 15, '2025-08-01', '2025-08-15', 'abgeschlossen'),
(11, 2,  17, '2025-08-18', '2025-09-01', 'aktiv'),
(12, 5,  18, '2025-08-22', '2025-09-05', 'aktiv');

-- reservierung (12)
INSERT INTO reservierung (exemplar_id, ausleiher_id, von_datum, bis_datum, status) VALUES
(1,  19, '2025-09-10', '2025-09-20', 'aktiv'),
(2,  20, '2025-09-05', '2025-09-12', 'aktiv'),
(4,  3,  '2025-09-15', '2025-09-25', 'aktiv'),
(5,  4,  '2025-09-02', '2025-09-09', 'storniert'),
(6,  6,  '2025-09-01', '2025-09-08', 'aktiv'),
(7,  7,  '2025-09-18', '2025-09-28', 'aktiv'),
(8,  8,  '2025-09-07', '2025-09-14', 'aktiv'),
(9,  9,  '2025-09-03', '2025-09-13', 'abgelaufen'),
(10, 10, '2025-09-11', '2025-09-18', 'aktiv'),
(11, 11, '2025-09-20', '2025-09-30', 'aktiv'),
(12, 12, '2025-09-25', '2025-10-02', 'aktiv'),
(3,  15, '2025-09-06', '2025-09-16', 'aktiv');

-- bewertung (12) – Unique (benutzer_id, werk_id) beachten, sterne 1–5
INSERT INTO bewertung (benutzer_id, werk_id, sterne, kommentar, erstellt_am) VALUES
(1,  1, 5, 'Großer Klassiker.',        '2025-08-01 10:00:00'),
(3,  2, 4, 'Fesselnd und klug.',       '2025-08-02 11:20:00'),
(4,  3, 3, 'Teilweise sperrig.',       '2025-08-03 09:15:00'),
(6,  4, 5, 'Meisterhaft erzählt.',     '2025-08-04 14:00:00'),
(7,  5, 4, 'Tolle Atmosphäre.',        '2025-08-05 16:45:00'),
(8,  6, 4, 'Sehr originell.',          '2025-08-06 12:30:00'),
(9,  7, 3, 'Klassisch, aber lang.',    '2025-08-07 10:10:00'),
(10, 8, 5, 'Großartige Figuren.',      '2025-08-08 18:50:00'),
(11, 9, 4, 'Aktuell und spannend.',    '2025-08-09 08:00:00'),
(12, 10,5, 'Philosophisch anregend.',  '2025-08-10 19:25:00'),
(13, 11,4, 'Cleveres Stück.',          '2025-08-11 21:10:00'),
(15, 12,5, 'Magisch!',                 '2025-08-12 13:35:00');

-- ========================================================
-- Block E: Kommunikation & Support (chat_thread, chat_nachricht, hilfe_ticket)
-- ========================================================

-- chat_thread (10)
INSERT INTO chat_thread (erstellt_am, thema) VALUES
('2025-08-01 09:00:00', 'Abholung Buddenbrooks'),
('2025-08-02 10:30:00', 'Reservierung Der Prozess'),
('2025-08-03 12:00:00', 'Zustand Die Blechtrommel'),
('2025-08-04 14:15:00', 'Versandoptionen'),
('2025-08-05 16:40:00', 'Rückgabe Tyll'),
('2025-08-06 18:10:00', 'Abholzeit anpassen'),
('2025-08-07 08:55:00', 'Bewertung diskutieren'),
('2025-08-08 11:20:00', 'Suche nach Klassikern'),
('2025-08-09 13:05:00', 'Chat-Test'),
('2025-08-10 15:45:00', 'Allgemeine Fragen');

-- chat_nachricht (12)
INSERT INTO chat_nachricht (thread_id, sender_id, text, gesendet_am, gelesen) VALUES
(1, 1,  'Hallo, kann ich heute um 19 Uhr abholen?',        '2025-08-01 09:10:00', FALSE),
(1, 2,  'Ja, passt. Bitte klingeln.',                      '2025-08-01 09:15:00', TRUE),
(2, 3,  'Ist die Reservierung noch aktiv?',                '2025-08-02 10:40:00', FALSE),
(3, 5,  'Das Buch ist in gutem Zustand.',                  '2025-08-03 12:10:00', TRUE),
(4, 7,  'Bietet ihr Versand an?',                          '2025-08-04 14:20:00', FALSE),
(4, 8,  'Ja, gegen Portoübernahme.',                       '2025-08-04 14:25:00', TRUE),
(5, 10, 'Ich bringe es morgen zurück.',                    '2025-08-05 16:50:00', TRUE),
(6, 12, 'Können wir auf 20 Uhr verschieben?',              '2025-08-06 18:20:00', FALSE),
(7, 9,  'Warum nur 3 Sterne?',                             '2025-08-07 09:05:00', FALSE),
(8, 11, 'Suche Empfehlungen für Klassiker.',               '2025-08-08 11:30:00', TRUE),
(9, 13, 'Testnachricht 1',                                 '2025-08-09 13:10:00', TRUE),
(10,15, 'Wie funktioniert die App?',                       '2025-08-10 15:50:00', TRUE);

-- hilfe_ticket (10)
INSERT INTO hilfe_ticket (ersteller_id, betreff, beschreibung, status, erstellt_am, geschlossen_am) VALUES
(1,  'Login-Problem',        'Passwort zurücksetzen schlägt fehl.',             'geschlossen', '2025-08-01 08:00:00', '2025-08-01 10:00:00'),
(3,  'Datenkorrektur',       'Falscher Nachname in meinem Profil.',             'in Bearbeitung', '2025-08-02 09:30:00', NULL),
(4,  'Spam-Nachrichten',     'Erhalte viele Nachrichten von Unbekannten.',      'offen', '2025-08-03 10:45:00', NULL),
(6,  'Reservierung hängt',   'Status wechselt nicht auf aktiv.',                'geschlossen', '2025-08-04 11:20:00', '2025-08-04 15:00:00'),
(7,  'Ausleihe-Fehler',      'Fehlermeldung beim Bestätigen.',                  'offen', '2025-08-05 12:10:00', NULL),
(8,  'Adresse ändern',       'Neue Adresse eintragen bitte.',                    'in Bearbeitung', '2025-08-06 13:55:00', NULL),
(10, 'Bewertung löschen',    'Möchte Kommentar korrigieren.',                   'geschlossen', '2025-08-07 14:40:00', '2025-08-07 16:10:00'),
(11, 'Chat lädt nicht',      'Thread öffnet sich nicht mehr.',                   'in Bearbeitung', '2025-08-08 15:25:00', NULL),
(12, 'Rolle anpassen',       'Ich möchte auch verleihen.',                       'geschlossen', '2025-08-09 16:05:00', '2025-08-09 17:20:00'),
(15, 'Allgemeine Frage',     'Wie ändere ich die Sprache?',                      'offen', '2025-08-10 17:45:00', NULL);

-- Ende aller Inserts
