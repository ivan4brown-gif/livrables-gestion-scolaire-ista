-- ============================================================================
-- REQUETE.SQL
-- Projet : Application de gestion scolaire
-- Auteurs : Magnim Ghislain Kobara & Daniel Diarra
-- ============================================================================

USE gestion_scolaire;

-- REQUETE 1 (Jointure 1) : Eleves avec leur classe et annee scolaire
SELECT
    e.matricule, e.nom, e.prenom, e.sexe,
    c.code_classe, c.libelle_classe, c.annee_scolaire
FROM eleve e
INNER JOIN classe c ON e.id_classe = c.id_classe
ORDER BY c.code_classe, e.nom, e.prenom;

-- REQUETE 2 (Jointure 2) : Affectations pedagogiques
SELECT
    a.annee_scolaire, c.code_classe, m.code_matiere,
    m.libelle_matiere, m.coefficient,
    CONCAT(ens.nom, ' ', ens.prenom) AS enseignant
FROM affectation a
INNER JOIN classe c ON a.id_classe = c.id_classe
INNER JOIN matiere m ON a.id_matiere = m.id_matiere
INNER JOIN enseignant ens ON a.id_enseignant = ens.id_enseignant
WHERE a.annee_scolaire = '2026-2027';

-- REQUETE 3 (Jointure 3) : Historique des paiements avec eleve et comptable
SELECT
    p.reference_recu, p.date_paiement, p.montant, p.mode_paiement,
    CONCAT(e.matricule, ' - ', e.nom, ' ', e.prenom) AS eleve,
    u.nom_utilisateur AS comptable
FROM paiement p
INNER JOIN eleve e ON p.id_eleve = e.id_eleve
INNER JOIN utilisateur u ON p.id_comptable = u.id_utilisateur
ORDER BY p.date_paiement DESC;

-- REQUETE 4 (Agregation 1) : Effectif d'eleves par classe
SELECT
    c.code_classe, c.libelle_classe,
    COUNT(e.id_eleve) AS effectif_eleves
FROM classe c
LEFT JOIN eleve e ON c.id_classe = e.id_classe
GROUP BY c.id_classe, c.code_classe, c.libelle_classe
ORDER BY c.code_classe;

-- REQUETE 5 (Agregation 2) : Total encaisse par mode de paiement
SELECT
    mode_paiement,
    COUNT(id_paiement) AS nombre_paiements,
    SUM(montant) AS total_encaisse
FROM paiement
GROUP BY mode_paiement
ORDER BY total_encaisse DESC;

-- REQUETE 6 (Sous-requete) : Eleves ayant une note >= moyenne globale
SELECT DISTINCT
    e.matricule, e.nom, e.prenom, n.valeur_note,
    m.libelle_matiere, n.periode
FROM eleve e
INNER JOIN note n ON e.id_eleve = n.id_eleve
INNER JOIN matiere m ON n.id_matiere = m.id_matiere
WHERE n.valeur_note >= (SELECT AVG(valeur_note) FROM note);

-- REQUETE 7 (Vue) : Notes detaillees par eleve
CREATE OR REPLACE VIEW v_notes_detaillees AS
SELECT
    e.id_eleve, e.matricule, e.nom, e.prenom,
    c.code_classe, m.libelle_matiere, m.coefficient,
    n.type_evaluation, n.periode, n.valeur_note, n.date_saisie
FROM note n
INNER JOIN eleve e ON n.id_eleve = e.id_eleve
INNER JOIN classe c ON e.id_classe = c.id_classe
INNER JOIN matiere m ON n.id_matiere = m.id_matiere;

-- Verification de la vue
SELECT * FROM v_notes_detaillees WHERE periode = 'TRIMESTRE_1';

-- REQUETE 8 (Controle qualite) : Contacts tuteur manquants et notes hors bareme
-- Remarque : contact_tuteur est NOT NULL dans schema.sql ; cette requete detecte
-- les chaines vides. Pour detecter les valeurs NULL, la condition reste utile
-- si la contrainte est modifiee ou si des donnees historiques existent.
SELECT
    'ELEVE_CONTACT_MANQUANT' AS type_anomalie,
    CAST(id_eleve AS CHAR) AS reference_id,
    CONCAT(matricule, ' - ', nom, ' ', prenom) AS detail
FROM eleve
WHERE contact_tuteur IS NULL OR TRIM(contact_tuteur) = ''

UNION ALL

SELECT
    'NOTE_HORS_BAREME' AS type_anomalie,
    CAST(id_note AS CHAR) AS reference_id,
    CONCAT('Note = ', valeur_note, ' (eleve_id=', id_eleve, ')') AS detail
FROM note
WHERE valeur_note < 0 OR valeur_note > 20;

-- TRANSACTION A : enregistrement valide puis COMMIT
-- Attention : REC-2026-003 doit ne pas exister avant execution.
START TRANSACTION;

INSERT INTO paiement
(montant, mode_paiement, reference_recu, id_eleve, id_comptable)
VALUES
(25000.00, 'ESPECES', 'REC-2026-003', 1, 4);

SELECT * FROM paiement WHERE reference_recu = 'REC-2026-003';

COMMIT;

-- TRANSACTION B : insertion de test puis annulation avec ROLLBACK
-- REC-2026-004 ne doit pas exister avant execution.
START TRANSACTION;

INSERT INTO paiement
(montant, mode_paiement, reference_recu, id_eleve, id_comptable)
VALUES
(15000.00, 'MOOV_MONEY', 'REC-2026-004', 2, 4);

ROLLBACK;

-- Verification : cette requete ne doit retourner aucune ligne.
SELECT * FROM paiement WHERE reference_recu = 'REC-2026-004';
