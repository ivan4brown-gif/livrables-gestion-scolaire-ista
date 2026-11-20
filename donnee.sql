-- ============================================================================
-- DONNEE.SQL
-- Jeu de données de démonstration pour gestion_scolaire
-- Toutes les données ci-dessous sont fictives.
-- À exécuter après schema.sql.
-- ============================================================================

USE gestion_scolaire;

-- Comptes : les mots de passe sont des chaînes de démonstration.
-- En production, remplacer par de vrais hash sécurisés (bcrypt/Argon2).
INSERT INTO utilisateur
(id_utilisateur, nom_utilisateur, mot_de_passe_hash, role, actif)
VALUES
(1, 'admin', '$2y$10$EXEMPLE_HASH_A_REMPLACER', 'ADMIN', 1),
(2, 'directeur', '$2y$10$EXEMPLE_HASH_A_REMPLACER', 'DIRECTEUR', 1),
(3, 'secretaire', '$2y$10$EXEMPLE_HASH_A_REMPLACER', 'SECRETAIRE', 1),
(4, 'comptable1', '$2y$10$EXEMPLE_HASH_A_REMPLACER', 'COMPTABLE', 1),
(5, 'enseignant1', '$2y$10$EXEMPLE_HASH_A_REMPLACER', 'ENSEIGNANT', 1),
(6, 'enseignant2', '$2y$10$EXEMPLE_HASH_A_REMPLACER', 'ENSEIGNANT', 1);

INSERT INTO classe
(id_classe, code_classe, libelle_classe, annee_scolaire)
VALUES
(1, 'L1-INFO', 'Licence 1 Informatique', '2026-2027'),
(2, 'L2-INFO', 'Licence 2 Informatique', '2026-2027'),
(3, 'L1-GEST', 'Licence 1 Gestion', '2026-2027');

INSERT INTO enseignant
(id_enseignant, matricule_ens, nom, prenom, telephone_ens, id_utilisateur)
VALUES
(1, 'ENS-001', 'Traore', 'Moussa', '70000001', 5),
(2, 'ENS-002', 'Diallo', 'Aminata', '70000002', 6);

INSERT INTO matiere
(id_matiere, code_matiere, libelle_matiere, coefficient)
VALUES
(1, 'ALGO101', 'Algorithmique', 3),
(2, 'BDD101', 'Base de donnees', 3),
(3, 'WEB101', 'Developpement Web', 2),
(4, 'MATH101', 'Mathematiques', 2);

INSERT INTO affectation
(id_enseignant, id_classe, id_matiere, annee_scolaire)
VALUES
(1, 1, 1, '2026-2027'),
(1, 1, 2, '2026-2027'),
(2, 1, 3, '2026-2027'),
(2, 2, 3, '2026-2027'),
(1, 3, 4, '2026-2027');

INSERT INTO eleve
(id_eleve, matricule, nom, prenom, date_naissance, sexe, contact_tuteur, id_classe, id_utilisateur)
VALUES
(1, 'EL-2026-001', 'Diallo', 'Amadou', '2006-04-12', 'M', '76000001', 1, NULL),
(2, 'EL-2026-002', 'Traore', 'Fatou', '2005-09-23', 'F', '76000002', 1, NULL),
(3, 'EL-2026-003', 'Coulibaly', 'Aicha', '2006-01-18', 'F', '76000003', 2, NULL),
(4, 'EL-2026-004', 'Keita', 'Mamadou', '2005-12-02', 'M', '76000004', 3, NULL);

INSERT INTO note
(id_note, valeur_note, type_evaluation, periode, date_saisie, id_eleve, id_matiere, id_enseignant)
VALUES
(1, 15.50, 'DEVOIR', 'TRIMESTRE_1', '2026-11-10 10:00:00', 1, 1, 1),
(2, 16.00, 'COMPOSITION', 'TRIMESTRE_1', '2026-11-12 11:00:00', 1, 2, 1),
(3, 14.00, 'DEVOIR', 'TRIMESTRE_1', '2026-11-10 10:30:00', 2, 1, 1),
(4, 17.00, 'COMPOSITION', 'TRIMESTRE_1', '2026-11-12 11:30:00', 2, 3, 2),
(5, 12.50, 'INTERROGATION', 'TRIMESTRE_1', '2026-11-14 09:00:00', 3, 3, 2),
(6, 13.00, 'DEVOIR', 'TRIMESTRE_1', '2026-11-15 09:00:00', 4, 4, 1);

INSERT INTO absence_retard
(id_absence, date_absence, type_event, justifiee, motif, id_eleve)
VALUES
(1, '2026-11-05', 'ABSENCE', 1, 'Raison familiale', 1),
(2, '2026-11-08', 'RETARD', 0, NULL, 2),
(3, '2026-11-13', 'ABSENCE', 0, NULL, 3);

INSERT INTO paiement
(id_paiement, date_paiement, montant, mode_paiement, reference_recu, id_eleve, id_comptable)
VALUES
(1, '2026-11-15 09:30:00', 50000.00, 'ESPECES', 'REC-2026-001', 1, 4),
(2, '2026-11-16 10:15:00', 75000.00, 'ORANGE_MONEY', 'REC-2026-002', 2, 4);

INSERT INTO bulletin
(id_bulletin, periode, moyenne_generale, date_edition, id_eleve)
VALUES
(1, 'TRIMESTRE_1', 15.75, '2026-11-18 14:00:00', 1),
(2, 'TRIMESTRE_1', 15.50, '2026-11-18 14:10:00', 2);
