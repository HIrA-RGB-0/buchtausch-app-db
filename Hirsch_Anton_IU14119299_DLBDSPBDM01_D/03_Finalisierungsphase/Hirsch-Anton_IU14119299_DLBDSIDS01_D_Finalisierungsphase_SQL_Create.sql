
-- ======================================================================
-- ABGABEVERSION (Phase 3) – mit Kommentaren zu Änderungen ggü. Phase 2
--
-- Zusammenfassung der Änderungen gegenüber Phase 2:
--   • benutzer:    CHECK auf status ('aktiv','gesperrt') ergänzt.
--   • autor:       UNIQUE (vorname, nachname) ergänzt (Dubletten vermeiden).
--   • zustand:     UNIQUE (stufe) ergänzt (eindeutige Zustandsstufen).
--   • buch_werk:   CHECK auf erscheinungsjahr (1400..2100) ergänzt.
--   • abholort:    UNIQUE (verleiher_id, adresse_id, bezeichnung) ergänzt.
--   • zeitfenster: CHECK (von_uhrzeit < bis_uhrzeit) + UNIQUE Slot ergänzt.
--   • buch_exemplar:
--       - FK verleiher: ON DELETE CASCADE (statt RESTRICT).
--       - CHECK auf verleihstatus + CHECK auf max_ausleihdauer>0 ergänzt.
--       - verleihstatus jetzt NOT NULL mit DEFAULT 'verfügbar'.
--       - versandoption jetzt NOT NULL mit DEFAULT FALSE.
--   • ausleihe:    Spalte verleiher_id entfernt (Redundanz); status jetzt NOT NULL;
--                  CHECK auf status + CHECK auf konsistente Datumsbereiche ergänzt.
--   • reservierung: status jetzt NOT NULL; CHECK auf konsistente Datumsbereiche ergänzt.
--   • bewertung:   erstellt_am mit DEFAULT CURRENT_TIMESTAMP ergänzt.
--   • chat_thread/chat_nachricht/hilfe_ticket: Default-Timestamps (und gelesen-Default) ergänzt.
--
-- Hinweis: Die SQL-Statements selbst sind inhaltlich unverändert; es wurden nur erläuternde
--          Kommentare ergänzt, damit die Unterschiede zur Phase 2 klar nachvollziehbar sind.
-- ======================================================================
-- ========================================================
-- Projekt: Buchtausch-App – FINAL (Phase 3)
-- Datei: Hirsch-Anton_IU14119299_DLBDSIDS01-01_D_Finalisierungsphase_SQL_Create.sql
-- Autor: Anton Hirsch | Matrikel: IU14119299
-- Beschreibung: Vollständiges Schema inkl. Optimierungen
--   * Redundanz entfernt: ausleihe.verleiher_id gestrichen
--   * Status-Checks (CHECK) auf allen Statusfeldern
--   * FK-Aktion: buch_exemplar.verleiher_id → ON DELETE CASCADE
--   * Daten-Checks: erscheinungsjahr, max_ausleihdauer, Zeitfenster-Zeit
--   * UNIQUEs: zeitfenster-Slot, abholort je (verleiher, adresse, bezeichnung)
--   * Defaults: Timestamps in Chat/Ticket (+ optional in Bewertung)
-- DB: MariaDB/InnoDB, Zeichensatz: utf8mb4
-- ========================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS buchtausch_app;
CREATE DATABASE buchtausch_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE buchtausch_app;

-- ========================================================
-- Block A: Basis-Tabellen
-- ========================================================

-- adresse
CREATE TABLE adresse (
    adresse_id INT AUTO_INCREMENT PRIMARY KEY,
    strasse    VARCHAR(120),
    hausnummer VARCHAR(10),
    plz        VARCHAR(10),
    ort        VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- benutzer
CREATE TABLE benutzer (
    benutzer_id   INT AUTO_INCREMENT PRIMARY KEY,
    benutzername  VARCHAR(50)  NOT NULL UNIQUE,
    vorname       VARCHAR(100) NOT NULL,
    nachname      VARCHAR(100) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    passwort_hash VARCHAR(255) NOT NULL,
    adresse_id    INT,
    status        VARCHAR(10)  NOT NULL,     -- 'aktiv' | 'gesperrt'
    CONSTRAINT fk_benutzer_adresse
        FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_benutzer_status -- [NEU ggü. Phase 2: Status per CHECK abgesichert]
        CHECK (status IN ('aktiv','gesperrt'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- admin (Spezialisierung)
CREATE TABLE admin (
    admin_id INT PRIMARY KEY,
    CONSTRAINT fk_admin_benutzer
        FOREIGN KEY (admin_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- verleiher (Spezialisierung)
CREATE TABLE verleiher (
    verleiher_id INT PRIMARY KEY,
    CONSTRAINT fk_verleiher_benutzer
        FOREIGN KEY (verleiher_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ausleiher (Spezialisierung)
CREATE TABLE ausleiher (
    ausleiher_id INT PRIMARY KEY,
    CONSTRAINT fk_ausleiher_benutzer
        FOREIGN KEY (ausleiher_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================================
-- Block B: Bibliographie
-- ========================================================

CREATE TABLE verlag (
    verlag_id  INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL UNIQUE,
    adresse_id INT,
    CONSTRAINT fk_verlag_adresse
        FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE autor (
    autor_id INT AUTO_INCREMENT PRIMARY KEY,
    vorname  VARCHAR(100),
    nachname VARCHAR(100)
,
    CONSTRAINT uq_autor_name UNIQUE (vorname, nachname) -- [NEU ggü. Phase 2: Autorenname jetzt eindeutig]
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE genre (
    genre_id     INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(80) UNIQUE,
    beschreibung TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE buch_werk (
    werk_id         INT AUTO_INCREMENT PRIMARY KEY,
    titel           VARCHAR(255) NOT NULL,
    isbn            CHAR(13)     NOT NULL UNIQUE,
    erscheinungsjahr INT,
    sprache         VARCHAR(40),
    verlag_id       INT,
    CONSTRAINT fk_werk_verlag
        FOREIGN KEY (verlag_id)
        REFERENCES verlag(verlag_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_werk_jahr -- [NEU ggü. Phase 2: Plausibilitäts-Check fürs Erscheinungsjahr]
        CHECK (erscheinungsjahr IS NULL
               OR (erscheinungsjahr BETWEEN 1400 AND 2100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE werk_autor (
    werk_id  INT NOT NULL,
    autor_id INT NOT NULL,
    rolle    VARCHAR(100),
    PRIMARY KEY (werk_id, autor_id),
    CONSTRAINT fk_wa_werk
        FOREIGN KEY (werk_id)
        REFERENCES buch_werk(werk_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_wa_autor
        FOREIGN KEY (autor_id)
        REFERENCES autor(autor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE werk_genre (
    werk_id  INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (werk_id, genre_id),
    CONSTRAINT fk_wg_werk
        FOREIGN KEY (werk_id)
        REFERENCES buch_werk(werk_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_wg_genre
        FOREIGN KEY (genre_id)
        REFERENCES genre(genre_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================================
-- Block C: Exemplare & Logistik
-- ========================================================

CREATE TABLE zustand (
    zustand_id   INT AUTO_INCREMENT PRIMARY KEY,
    stufe        VARCHAR(30) NOT NULL,
    beschreibung TEXT
,
    CONSTRAINT uq_zustand_stufe UNIQUE (stufe) -- [NEU ggü. Phase 2: Zustandsstufe eindeutig]
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE abholort (
    abholort_id INT AUTO_INCREMENT PRIMARY KEY,
    verleiher_id INT NOT NULL,
    adresse_id   INT NOT NULL,
    bezeichnung  VARCHAR(120) NOT NULL,
    hinweis      TEXT,
    CONSTRAINT fk_abholort_verleiher
        FOREIGN KEY (verleiher_id)
        REFERENCES verleiher(verleiher_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_abholort_adresse
        FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT uq_abholort_pro_ort -- [NEU ggü. Phase 2: Abholort pro Verleiher/Adresse/Bezeichnung eindeutig]
        UNIQUE (verleiher_id, adresse_id, bezeichnung)   -- OPTIMIERUNG
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE zeitfenster (
    zeitfenster_id INT AUTO_INCREMENT PRIMARY KEY,
    abholort_id INT NOT NULL,
    wochentag  INT,                -- 0–6 (So–Sa)
    von_uhrzeit TIME,
    bis_uhrzeit TIME,
    CONSTRAINT fk_zeitfenster_abholort
        FOREIGN KEY (abholort_id)
        REFERENCES abholort(abholort_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_zeitfenster_tag
        CHECK (wochentag BETWEEN 0 AND 6),
    CONSTRAINT chk_zeitfenster_zeit -- [NEU ggü. Phase 2: Zeitbereich muss gültig sein]
        CHECK (von_uhrzeit IS NULL OR bis_uhrzeit IS NULL OR von_uhrzeit < bis_uhrzeit),
    CONSTRAINT uq_zeitfenster_slot -- [NEU ggü. Phase 2: Zeitfenster-Slot ist eindeutig]
        UNIQUE (abholort_id, wochentag, von_uhrzeit, bis_uhrzeit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE buch_exemplar (
    exemplar_id     INT AUTO_INCREMENT PRIMARY KEY,
    werk_id         INT NOT NULL,
    verleiher_id    INT NOT NULL,
    zustand_id      INT,
    verleihstatus   VARCHAR(20) NOT NULL DEFAULT 'verfügbar',        -- 'verfügbar', 'ausgeliehen', 'reserviert' -- [GEÄNDERT ggü. Phase 2: NOT NULL + Default 'verfügbar']
    max_ausleihdauer INT,               -- in Tagen
    abholort_id     INT,
    versandoption   BOOLEAN NOT NULL DEFAULT FALSE, -- [GEÄNDERT ggü. Phase 2: NOT NULL + Default FALSE]
    CONSTRAINT fk_exemplar_werk
        FOREIGN KEY (werk_id)
        REFERENCES buch_werk(werk_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_exemplar_verleiher
        FOREIGN KEY (verleiher_id)
        REFERENCES verleiher(verleiher_id)
        ON DELETE CASCADE             -- [GEÄNDERT ggü. Phase 2: FK-Aktion jetzt CASCADE]
        ON UPDATE CASCADE,
    CONSTRAINT fk_exemplar_zustand
        FOREIGN KEY (zustand_id)
        REFERENCES zustand(zustand_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_exemplar_abholort
        FOREIGN KEY (abholort_id)
        REFERENCES abholort(abholort_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_exemplar_status -- [NEU ggü. Phase 2: Statuswerte per CHECK fixiert]
        CHECK (verleihstatus IN ('verfügbar','ausgeliehen','reserviert')),
    CONSTRAINT chk_exemplar_maxdauer -- [NEU ggü. Phase 2: max_ausleihdauer > 0 falls gesetzt]
        CHECK (max_ausleihdauer IS NULL OR max_ausleihdauer > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================================
-- Block D: Prozesse
-- ========================================================

CREATE TABLE ausleihe (
    -- [GEÄNDERT ggü. Phase 2: Spalte verleiher_id entfernt (Redundanz)]

    ausleihe_id  INT AUTO_INCREMENT PRIMARY KEY,
    exemplar_id  INT NOT NULL,
    ausleiher_id INT NOT NULL,
    startdatum   DATE,
    enddatum     DATE,
    status       VARCHAR(20) NOT NULL,           -- 'aktiv', 'abgeschlossen' -- [GEÄNDERT ggü. Phase 2: jetzt NOT NULL]
    CONSTRAINT fk_ausleihe_exemplar
        FOREIGN KEY (exemplar_id)
        REFERENCES buch_exemplar(exemplar_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ausleihe_ausleiher
        FOREIGN KEY (ausleiher_id)
        REFERENCES ausleiher(ausleiher_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_ausleihe_status
        CHECK (status IN ('aktiv','abgeschlossen'))
,
    CONSTRAINT chk_ausleihe_daterange -- [NEU ggü. Phase 2: Datumsspanne muss konsistent sein]
        CHECK (startdatum IS NULL OR enddatum IS NULL OR startdatum <= enddatum)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- reservierung (+ Status-Check)
CREATE TABLE reservierung (
    reservierung_id INT AUTO_INCREMENT PRIMARY KEY,
    exemplar_id  INT NOT NULL,
    ausleiher_id INT NOT NULL,
    von_datum DATE,
    bis_datum DATE,
    status VARCHAR(20) NOT NULL,                 -- 'aktiv', 'storniert', 'abgelaufen'
    CONSTRAINT fk_reserv_exemplar
        FOREIGN KEY (exemplar_id)
        REFERENCES buch_exemplar(exemplar_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_reserv_ausleiher
        FOREIGN KEY (ausleiher_id)
        REFERENCES ausleiher(ausleiher_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_reservierung_status
        CHECK (status IN ('aktiv','storniert','abgelaufen'))
,
    CONSTRAINT chk_reservierung_daterange
        CHECK (von_datum IS NULL OR bis_datum IS NULL OR von_datum <= bis_datum)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- bewertung (Default-Timestamp optional sinnvoll)
CREATE TABLE bewertung (
    bewertung_id INT AUTO_INCREMENT PRIMARY KEY,
    benutzer_id  INT NOT NULL,
    werk_id      INT NOT NULL,
    sterne       INT,                       -- 1–5
    kommentar    VARCHAR(255),
    erstellt_am  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- [NEU ggü. Phase 2: Default-Zeitstempel gesetzt]
    CONSTRAINT fk_bewertung_benutzer
        FOREIGN KEY (benutzer_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_bewertung_werk
        FOREIGN KEY (werk_id)
        REFERENCES buch_werk(werk_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT uq_bewertung_einmal UNIQUE (benutzer_id, werk_id),
    CONSTRAINT chk_bewertung_sterne CHECK (sterne BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================================
-- Block E: Kommunikation & Support
-- ========================================================

-- chat_thread (Default-Timestamp)
CREATE TABLE chat_thread ( -- [NEU ggü. Phase 2: Standard-Zeitstempel in erstellt_am]
    thread_id   INT AUTO_INCREMENT PRIMARY KEY,
    erstellt_am TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    thema       VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- chat_nachricht (Default-Timestamp)
CREATE TABLE chat_nachricht (
    nachricht_id INT AUTO_INCREMENT PRIMARY KEY,
    thread_id    INT NOT NULL,
    sender_id    INT NOT NULL,
    text         TEXT NOT NULL,
    gesendet_am  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- [NEU ggü. Phase 2: Default-Zeitstempel für Nachrichten]
    gelesen      BOOLEAN DEFAULT FALSE, -- [NEU ggü. Phase 2: Default FALSE für gelesen]
    CONSTRAINT fk_msg_thread
        FOREIGN KEY (thread_id)
        REFERENCES chat_thread(thread_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_msg_sender
        FOREIGN KEY (sender_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- hilfe_ticket (Status-Check + Default-Timestamp)
CREATE TABLE hilfe_ticket ( -- [NEU ggü. Phase 2: Status-Check + Standard-Zeitstempel ergänzt]
    ticket_id      INT AUTO_INCREMENT PRIMARY KEY,
    ersteller_id   INT NOT NULL,
    betreff        VARCHAR(255),
    beschreibung   VARCHAR(2000),
    status         VARCHAR(20),               -- 'offen','in Bearbeitung','geschlossen'
    erstellt_am    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    geschlossen_am TIMESTAMP NULL,
    CONSTRAINT fk_ticket_benutzer
        FOREIGN KEY (ersteller_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_ticket_status
        CHECK (status IN ('offen','in Bearbeitung','geschlossen'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

