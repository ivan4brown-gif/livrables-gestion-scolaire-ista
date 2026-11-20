-- ============================================================================
-- SCHEMA.SQL
-- Projet : Application de gestion scolaire
-- TECHNOLAB-ISTA - L3 Genie Logiciel
-- ============================================================================

CREATE DATABASE IF NOT EXISTS gestion_scolaire
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gestion_scolaire;

CREATE TABLE utilisateur (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    nom_utilisateur VARCHAR(50) NOT NULL UNIQUE,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'DIRECTEUR', 'SECRETAIRE', 'COMPTABLE',
              'ENSEIGNANT', 'ELEVE', 'PARENT') NOT NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE classe (
    id_classe INT AUTO_INCREMENT PRIMARY KEY,
    code_classe VARCHAR(15) NOT NULL,
    libelle_classe VARCHAR(60) NOT NULL,
    annee_scolaire VARCHAR(9) NOT NULL,
    UNIQUE KEY uk_classe_annee (code_classe, annee_scolaire)
) ENGINE=InnoDB;

CREATE TABLE enseignant (
    id_enseignant INT AUTO_INCREMENT PRIMARY KEY,
    matricule_ens VARCHAR(20) NOT NULL UNIQUE,
    nom VARCHAR(60) NOT NULL,
    prenom VARCHAR(80) NOT NULL,
    telephone_ens VARCHAR(20) NOT NULL,
    id_utilisateur INT NULL UNIQUE,
    CONSTRAINT fk_ens_user FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur(id_utilisateur)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE matiere (
    id_matiere INT AUTO_INCREMENT PRIMARY KEY,
    code_matiere VARCHAR(15) NOT NULL UNIQUE,
    libelle_matiere VARCHAR(80) NOT NULL UNIQUE,
    coefficient TINYINT UNSIGNED NOT NULL
        CHECK (coefficient BETWEEN 1 AND 10)
) ENGINE=InnoDB;

CREATE TABLE affectation (
    id_enseignant INT NOT NULL,
    id_classe INT NOT NULL,
    id_matiere INT NOT NULL,
    annee_scolaire VARCHAR(9) NOT NULL,
    PRIMARY KEY (id_enseignant, id_classe, id_matiere, annee_scolaire),
    CONSTRAINT fk_aff_ens FOREIGN KEY (id_enseignant)
        REFERENCES enseignant(id_enseignant) ON DELETE CASCADE,
    CONSTRAINT fk_aff_cls FOREIGN KEY (id_classe)
        REFERENCES classe(id_classe) ON DELETE CASCADE,
    CONSTRAINT fk_aff_mat FOREIGN KEY (id_matiere)
        REFERENCES matiere(id_matiere) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE eleve (
    id_eleve INT AUTO_INCREMENT PRIMARY KEY,
    matricule VARCHAR(20) NOT NULL UNIQUE,
    nom VARCHAR(60) NOT NULL,
    prenom VARCHAR(80) NOT NULL,
    date_naissance DATE NOT NULL,
    sexe ENUM('M', 'F') NOT NULL,
    contact_tuteur VARCHAR(20) NOT NULL,
    id_classe INT NOT NULL,
    id_utilisateur INT NULL UNIQUE,
    CONSTRAINT fk_eleve_classe FOREIGN KEY (id_classe)
        REFERENCES classe(id_classe)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_eleve_user FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur(id_utilisateur)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE note (
    id_note INT AUTO_INCREMENT PRIMARY KEY,
    valeur_note DECIMAL(4,2) NOT NULL
        CHECK (valeur_note >= 0.00 AND valeur_note <= 20.00),
    type_evaluation ENUM('DEVOIR', 'COMPOSITION', 'INTERROGATION') NOT NULL,
    periode ENUM('TRIMESTRE_1', 'TRIMESTRE_2', 'TRIMESTRE_3') NOT NULL,
    date_saisie DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_eleve INT NOT NULL,
    id_matiere INT NOT NULL,
    id_enseignant INT NOT NULL,
    CONSTRAINT fk_note_eleve FOREIGN KEY (id_eleve)
        REFERENCES eleve(id_eleve) ON DELETE CASCADE,
    CONSTRAINT fk_note_matiere FOREIGN KEY (id_matiere)
        REFERENCES matiere(id_matiere) ON DELETE RESTRICT,
    CONSTRAINT fk_note_ens FOREIGN KEY (id_enseignant)
        REFERENCES enseignant(id_enseignant) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE absence_retard (
    id_absence INT AUTO_INCREMENT PRIMARY KEY,
    date_absence DATE NOT NULL,
    type_event ENUM('ABSENCE', 'RETARD') NOT NULL,
    justifiee TINYINT(1) NOT NULL DEFAULT 0,
    motif VARCHAR(255) NULL,
    id_eleve INT NOT NULL,
    CONSTRAINT fk_abs_eleve FOREIGN KEY (id_eleve)
        REFERENCES eleve(id_eleve) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE paiement (
    id_paiement INT AUTO_INCREMENT PRIMARY KEY,
    date_paiement DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    montant DECIMAL(10,2) NOT NULL CHECK (montant > 0),
    mode_paiement ENUM('ESPECES', 'ORANGE_MONEY', 'MOOV_MONEY', 'VIREMENT') NOT NULL,
    reference_recu VARCHAR(30) NOT NULL UNIQUE,
    id_eleve INT NOT NULL,
    id_comptable INT NOT NULL,
    CONSTRAINT fk_paie_eleve FOREIGN KEY (id_eleve)
        REFERENCES eleve(id_eleve) ON DELETE RESTRICT,
    CONSTRAINT fk_paie_comptable FOREIGN KEY (id_comptable)
        REFERENCES utilisateur(id_utilisateur) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE bulletin (
    id_bulletin INT AUTO_INCREMENT PRIMARY KEY,
    periode ENUM('TRIMESTRE_1', 'TRIMESTRE_2', 'TRIMESTRE_3') NOT NULL,
    moyenne_generale DECIMAL(4,2) NOT NULL
        CHECK (moyenne_generale BETWEEN 0.00 AND 20.00),
    date_edition DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_eleve INT NOT NULL,
    UNIQUE KEY uk_bulletin_eleve_periode (id_eleve, periode),
    CONSTRAINT fk_bul_eleve FOREIGN KEY (id_eleve)
        REFERENCES eleve(id_eleve) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_eleve_nom_matricule ON eleve(nom, matricule);
CREATE INDEX idx_note_eleve_periode ON note(id_eleve, periode);
CREATE INDEX idx_paiement_eleve ON paiement(id_eleve);
