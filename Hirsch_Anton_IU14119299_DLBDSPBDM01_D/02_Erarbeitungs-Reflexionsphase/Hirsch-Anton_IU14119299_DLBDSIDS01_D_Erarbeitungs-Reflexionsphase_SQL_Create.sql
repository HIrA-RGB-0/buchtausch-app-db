-- ========================================================
-- Projekt: Buchtausch-App – Phase 2 (Erarbeitungs-/Reflexionsphase)
-- Datei: 00_create_schema.sql
-- Autor: Anton Hirsch | Matrikel: IU14119299
-- Beschreibung: Vollständiges relationales Schema (21 Entitäten)
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

-- Tabelle: adresse
-- Speichert Adressdaten (wiederverwendbar)
CREATE TABLE adresse (
    adresse_id INT AUTO_INCREMENT PRIMARY KEY,
    strasse VARCHAR(120),
    hausnummer VARCHAR(10),
    plz VARCHAR(10),
    ort VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: benutzer
-- Stammdaten der App-Benutzer (Passwort als Hash)
CREATE TABLE benutzer (
    benutzer_id INT AUTO_INCREMENT PRIMARY KEY,
    benutzername VARCHAR(50) NOT NULL UNIQUE,
    vorname VARCHAR(100) NOT NULL,
    nachname VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    passwort_hash VARCHAR(255) NOT NULL,
    adresse_id INT,
    status VARCHAR(10) NOT NULL,          -- z. B. 'aktiv', 'gesperrt'
    CONSTRAINT fk_benutzer_adresse
        FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: admin
-- Spezialisierung von Benutzer (Administrationsrechte)
CREATE TABLE admin (
    admin_id INT PRIMARY KEY,
    CONSTRAINT fk_admin_benutzer
        FOREIGN KEY (admin_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: verleiher
-- Spezialisierung von Benutzer (kann Exemplare verleihen)
CREATE TABLE verleiher (
    verleiher_id INT PRIMARY KEY,
    CONSTRAINT fk_verleiher_benutzer
        FOREIGN KEY (verleiher_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: ausleiher
-- Spezialisierung von Benutzer (kann Exemplare ausleihen)
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

-- Tabelle: verlag
-- Verlage (optional mit Adresse verknüpft)
CREATE TABLE verlag (
    verlag_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    adresse_id INT,
    CONSTRAINT fk_verlag_adresse
        FOREIGN KEY (adresse_id)
        REFERENCES adresse(adresse_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: autor
-- Autoren eines Werkes
CREATE TABLE autor (
    autor_id INT AUTO_INCREMENT PRIMARY KEY,
    vorname VARCHAR(100),
    nachname VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: genre
-- Genres (eindeutiger Name)
CREATE TABLE genre (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) UNIQUE,
    beschreibung TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: buch_werk
-- Bibliographische Einheit (nicht das Exemplar)
CREATE TABLE buch_werk (
    werk_id INT AUTO_INCREMENT PRIMARY KEY,
    titel VARCHAR(255) NOT NULL,
    isbn CHAR(13) NOT NULL UNIQUE,
    erscheinungsjahr INT,
    sprache VARCHAR(40),
    verlag_id INT,
    CONSTRAINT fk_werk_verlag
        FOREIGN KEY (verlag_id)
        REFERENCES verlag(verlag_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: werk_autor (m:n)
-- Ordnet Werke ihren Autoren zu (inkl. optionaler Rolle)
CREATE TABLE werk_autor (
    werk_id  INT NOT NULL,
    autor_id INT NOT NULL,
    rolle VARCHAR(100),
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

-- Tabelle: werk_genre (m:n)
-- Ordnet Werke ihren Genres zu
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

-- Tabelle: zustand
-- Zustandsskala (z. B. 'neu', 'gut', 'gebraucht')
CREATE TABLE zustand (
    zustand_id INT AUTO_INCREMENT PRIMARY KEY,
    stufe VARCHAR(30) NOT NULL,
    beschreibung TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: abholort
-- Konkreter Abholort, gehört einem Verleiher und hat eine Adresse
CREATE TABLE abholort (
    abholort_id INT AUTO_INCREMENT PRIMARY KEY,
    verleiher_id INT NOT NULL,
    adresse_id   INT NOT NULL,
    bezeichnung  VARCHAR(120) NOT NULL,  -- z. B. 'Haustür', 'Packstation'
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
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: zeitfenster
-- Verfügbare Zeitfenster für Abholorte (0=So … 6=Sa)
CREATE TABLE zeitfenster (
    zeitfenster_id INT AUTO_INCREMENT PRIMARY KEY,
    abholort_id INT NOT NULL,
    wochentag INT,                -- 0–6 (So–Sa)
    von_uhrzeit TIME,
    bis_uhrzeit TIME,
    CONSTRAINT fk_zeitfenster_abholort
        FOREIGN KEY (abholort_id)
        REFERENCES abholort(abholort_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_zeitfenster_tag CHECK (wochentag BETWEEN 0 AND 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: buch_exemplar
-- Konkretes Exemplar eines Werkes
CREATE TABLE buch_exemplar (
    exemplar_id INT AUTO_INCREMENT PRIMARY KEY,
    werk_id INT NOT NULL,
    verleiher_id INT NOT NULL,
    zustand_id INT,
    verleihstatus VARCHAR(20),        -- 'verfügbar', 'ausgeliehen', 'reserviert'
    max_ausleihdauer INT,             -- in Tagen
    abholort_id INT,
    versandoption BOOLEAN,
    CONSTRAINT fk_exemplar_werk
        FOREIGN KEY (werk_id)
        REFERENCES buch_werk(werk_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_exemplar_verleiher
        FOREIGN KEY (verleiher_id)
        REFERENCES verleiher(verleiher_id)
        ON DELETE RESTRICT
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
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================================
-- Block D: Prozesse
-- ========================================================

-- Tabelle: ausleihe
-- Verknüpft Ausleiher, Verleiher und ein konkretes Exemplar
CREATE TABLE ausleihe (
    ausleihe_id INT AUTO_INCREMENT PRIMARY KEY,
    exemplar_id  INT NOT NULL,
    verleiher_id INT NOT NULL,
    ausleiher_id INT NOT NULL,
    startdatum DATE,
    enddatum   DATE,
    status VARCHAR(20),               -- z. B. 'aktiv', 'abgeschlossen'
    CONSTRAINT fk_ausleihe_exemplar
        FOREIGN KEY (exemplar_id)
        REFERENCES buch_exemplar(exemplar_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ausleihe_verleiher
        FOREIGN KEY (verleiher_id)
        REFERENCES verleiher(verleiher_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ausleihe_ausleiher
        FOREIGN KEY (ausleiher_id)
        REFERENCES ausleiher(ausleiher_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: reservierung
-- Verknüpft Ausleiher und Exemplar mit einem Zeitraum
CREATE TABLE reservierung (
    reservierung_id INT AUTO_INCREMENT PRIMARY KEY,
    exemplar_id  INT NOT NULL,
    ausleiher_id INT NOT NULL,
    von_datum DATE,
    bis_datum DATE,
    status VARCHAR(20),               -- z. B. 'aktiv', 'storniert', 'abgelaufen'
    CONSTRAINT fk_reserv_exemplar
        FOREIGN KEY (exemplar_id)
        REFERENCES buch_exemplar(exemplar_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_reserv_ausleiher
        FOREIGN KEY (ausleiher_id)
        REFERENCES ausleiher(ausleiher_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: bewertung
-- Eine Bewertung pro Benutzer pro Werk
CREATE TABLE bewertung (
    bewertung_id INT AUTO_INCREMENT PRIMARY KEY,
    benutzer_id INT NOT NULL,
    werk_id INT NOT NULL,
    sterne INT,                       -- 1–5
    kommentar VARCHAR(255),
    erstellt_am TIMESTAMP,
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

-- Tabelle: chat_thread
-- Gesprächs-Threads (themenbasiert)
CREATE TABLE chat_thread (
    thread_id INT AUTO_INCREMENT PRIMARY KEY,
    erstellt_am TIMESTAMP,
    thema VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabelle: chat_nachricht
-- Nachrichten eines Threads mit Sender-Bezug
CREATE TABLE chat_nachricht (
    nachricht_id INT AUTO_INCREMENT PRIMARY KEY,
    thread_id INT NOT NULL,
    sender_id INT NOT NULL,
    text TEXT NOT NULL,
    gesendet_am TIMESTAMP,
    gelesen BOOLEAN DEFAULT FALSE,
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

-- Tabelle: hilfe_ticket
-- Support-Tickets
CREATE TABLE hilfe_ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    ersteller_id INT NOT NULL,
    betreff VARCHAR(255),
    beschreibung VARCHAR(2000),
    status VARCHAR(20),               -- 'offen', 'in Bearbeitung', 'geschlossen'
    erstellt_am TIMESTAMP,
    geschlossen_am TIMESTAMP,
    CONSTRAINT fk_ticket_benutzer
        FOREIGN KEY (ersteller_id)
        REFERENCES benutzer(benutzer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
