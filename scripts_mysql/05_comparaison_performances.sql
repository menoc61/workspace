-- ============================================
-- Script 05: Comparaison des performances
-- TP Oracle & MySQL - Comparaison Index
-- ============================================

USE tp_comparaison_index;

-- Activer le profiling
SET profiling = 1;

SELECT '========================================' AS Message;
SELECT '  TESTS DE PERFORMANCE - INDEX' AS Message;
SELECT '========================================' AS Message;
SELECT '' AS Message;

-- ============================================
-- Variables pour les résultats
-- ============================================
DROP TABLE IF EXISTS resultats_performance;
CREATE TABLE resultats_performance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    test_name VARCHAR(100),
    temps_sans_index_ms DECIMAL(10,3),
    temps_avec_index_ms DECIMAL(10,3),
    gain_percent DECIMAL(10,2),
    date_test TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TEST 1: SELECT simple avec WHERE sur nom
-- ============================================
SELECT '' AS Message;
SELECT '=== TEST 1: SELECT simple avec WHERE sur nom ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT * FROM clients_sans_index WHERE nom = 'Nom50000' LIMIT 1;
SET @fin = NOW(3);
SET @temps1_sans = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps SANS index: ', ROUND(@temps1_sans, 3), ' ms') AS Resultat;

-- Avec index
SET @debut = NOW(3);
SELECT * FROM clients_avec_index WHERE nom = 'Nom50000' LIMIT 1;
SET @fin = NOW(3);
SET @temps1_avec = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps AVEC index: ', ROUND(@temps1_avec, 3), ' ms') AS Resultat;

-- Sauvegarder le résultat
INSERT INTO resultats_performance (test_name, temps_sans_index_ms, temps_avec_index_ms, gain_percent)
VALUES ('SELECT simple sur nom', @temps1_sans, @temps1_avec,
        CASE WHEN @temps1_sans > @temps1_avec THEN ROUND(((@temps1_sans - @temps1_avec) / @temps1_sans) * 100, 2) ELSE 0 END);

-- ============================================
-- TEST 2: Recherche par ville
-- ============================================
SELECT '' AS Message;
SELECT '=== TEST 2: SELECT avec WHERE sur ville ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT COUNT(*) FROM clients_sans_index WHERE ville = 'Paris';
SET @fin = NOW(3);
SET @temps2_sans = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps SANS index: ', ROUND(@temps2_sans, 3), ' ms') AS Resultat;

-- Avec index
SET @debut = NOW(3);
SELECT COUNT(*) FROM clients_avec_index WHERE ville = 'Paris';
SET @fin = NOW(3);
SET @temps2_avec = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps AVEC index: ', ROUND(@temps2_avec, 3), ' ms') AS Resultat;

INSERT INTO resultats_performance (test_name, temps_sans_index_ms, temps_avec_index_ms, gain_percent)
VALUES ('Recherche par ville', @temps2_sans, @temps2_avec,
        CASE WHEN @temps2_sans > @temps2_avec THEN ROUND(((@temps2_sans - @temps2_avec) / @temps2_sans) * 100, 2) ELSE 0 END);

-- ============================================
-- TEST 3: Jointure clients-commandes
-- ============================================
SELECT '' AS Message;
SELECT '=== TEST 3: Jointure clients-commandes ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT c.nom, c.prenom, COUNT(cmd.id_commande) AS nb_commandes
FROM clients_sans_index c
JOIN commandes_sans_index cmd ON c.id_client = cmd.id_client
WHERE cmd.date_commande >= '2023-01-01'
GROUP BY c.id_client, c.nom, c.prenom
LIMIT 100;
SET @fin = NOW(3);
SET @temps3_sans = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps SANS index: ', ROUND(@temps3_sans, 3), ' ms') AS Resultat;

-- Avec index
SET @debut = NOW(3);
SELECT c.nom, c.prenom, COUNT(cmd.id_commande) AS nb_commandes
FROM clients_avec_index c
JOIN commandes_avec_index cmd ON c.id_client = cmd.id_client
WHERE cmd.date_commande >= '2023-01-01'
GROUP BY c.id_client, c.nom, c.prenom
LIMIT 100;
SET @fin = NOW(3);
SET @temps3_avec = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps AVEC index: ', ROUND(@temps3_avec, 3), ' ms') AS Resultat;

INSERT INTO resultats_performance (test_name, temps_sans_index_ms, temps_avec_index_ms, gain_percent)
VALUES ('Jointure clients-commandes', @temps3_sans, @temps3_avec,
        CASE WHEN @temps3_sans > @temps3_avec THEN ROUND(((@temps3_sans - @temps3_avec) / @temps3_sans) * 100, 2) ELSE 0 END);

-- ============================================
-- TEST 4: Agrégation par catégorie
-- ============================================
SELECT '' AS Message;
SELECT '=== TEST 4: Agrégation par catégorie ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT categorie, COUNT(*) AS nb_produits, AVG(prix) AS prix_moyen
FROM produits_sans_index
GROUP BY categorie;
SET @fin = NOW(3);
SET @temps4_sans = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps SANS index: ', ROUND(@temps4_sans, 3), ' ms') AS Resultat;

-- Avec index
SET @debut = NOW(3);
SELECT categorie, COUNT(*) AS nb_produits, AVG(prix) AS prix_moyen
FROM produits_avec_index
GROUP BY categorie;
SET @fin = NOW(3);
SET @temps4_avec = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps AVEC index: ', ROUND(@temps4_avec, 3), ' ms') AS Resultat;

INSERT INTO resultats_performance (test_name, temps_sans_index_ms, temps_avec_index_ms, gain_percent)
VALUES ('Agrégation par catégorie', @temps4_sans, @temps4_avec,
        CASE WHEN @temps4_sans > @temps4_avec THEN ROUND(((@temps4_sans - @temps4_avec) / @temps4_sans) * 100, 2) ELSE 0 END);

-- ============================================
-- TEST 5: Requête complexe avec sous-requête
-- ============================================
SELECT '' AS Message;
SELECT '=== TEST 5: Requête complexe avec sous-requête ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT c.nom, c.prenom, c.ville,
       (SELECT SUM(cmd.prix_total)
        FROM commandes_sans_index cmd
        WHERE cmd.id_client = c.id_client) AS total_achats
FROM clients_sans_index c
WHERE c.ville = 'Paris'
AND EXISTS (SELECT 1 FROM commandes_sans_index cmd2
            WHERE cmd2.id_client = c.id_client
            AND cmd2.date_commande >= '2023-06-01')
LIMIT 100;
SET @fin = NOW(3);
SET @temps5_sans = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps SANS index: ', ROUND(@temps5_sans, 3), ' ms') AS Resultat;

-- Avec index
SET @debut = NOW(3);
SELECT c.nom, c.prenom, c.ville,
       (SELECT SUM(cmd.prix_total)
        FROM commandes_avec_index cmd
        WHERE cmd.id_client = c.id_client) AS total_achats
FROM clients_avec_index c
WHERE c.ville = 'Paris'
AND EXISTS (SELECT 1 FROM commandes_avec_index cmd2
            WHERE cmd2.id_client = c.id_client
            AND cmd2.date_commande >= '2023-06-01')
LIMIT 100;
SET @fin = NOW(3);
SET @temps5_avec = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps AVEC index: ', ROUND(@temps5_avec, 3), ' ms') AS Resultat;

INSERT INTO resultats_performance (test_name, temps_sans_index_ms, temps_avec_index_ms, gain_percent)
VALUES ('Requête complexe sous-requête', @temps5_sans, @temps5_avec,
        CASE WHEN @temps5_sans > @temps5_avec THEN ROUND(((@temps5_sans - @temps5_avec) / @temps5_sans) * 100, 2) ELSE 0 END);

-- ============================================
-- TEST 6: Tri sur plusieurs colonnes
-- ============================================
SELECT '' AS Message;
SELECT '=== TEST 6: Tri sur plusieurs colonnes ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT nom, prenom, ville, date_inscription
FROM clients_sans_index
ORDER BY ville DESC, nom ASC, date_inscription DESC
LIMIT 1000;
SET @fin = NOW(3);
SET @temps6_sans = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps SANS index: ', ROUND(@temps6_sans, 3), ' ms') AS Resultat;

-- Avec index
SET @debut = NOW(3);
SELECT nom, prenom, ville, date_inscription
FROM clients_avec_index
ORDER BY ville DESC, nom ASC, date_inscription DESC
LIMIT 1000;
SET @fin = NOW(3);
SET @temps6_avec = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps AVEC index: ', ROUND(@temps6_avec, 3), ' ms') AS Resultat;

INSERT INTO resultats_performance (test_name, temps_sans_index_ms, temps_avec_index_ms, gain_percent)
VALUES ('Tri multi-colonnes', @temps6_sans, @temps6_avec,
        CASE WHEN @temps6_sans > @temps6_avec THEN ROUND(((@temps6_sans - @temps6_avec) / @temps6_sans) * 100, 2) ELSE 0 END);

-- ============================================
-- TEST 7: Mise à jour massive
-- ============================================
SELECT '' AS Message;
SELECT '=== TEST 7: Mise à jour massive ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
UPDATE clients_sans_index
SET ville = 'NOUVELLE_VILLE'
WHERE id_client BETWEEN 1000 AND 5000;
SET @fin = NOW(3);
SET @temps7_sans = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps SANS index: ', ROUND(@temps7_sans, 3), ' ms') AS Resultat;
-- Annuler pour pouvoir répéter
ROLLBACK;

-- Avec index
SET @debut = NOW(3);
UPDATE clients_avec_index
SET ville = 'NOUVELLE_VILLE'
WHERE id_client BETWEEN 1000 AND 5000;
SET @fin = NOW(3);
SET @temps7_avec = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps AVEC index: ', ROUND(@temps7_avec, 3), ' ms') AS Resultat;
ROLLBACK;

INSERT INTO resultats_performance (test_name, temps_sans_index_ms, temps_avec_index_ms, gain_percent)
VALUES ('UPDATE massif', @temps7_sans, @temps7_avec,
        CASE WHEN @temps7_sans > @temps7_avec THEN ROUND(((@temps7_sans - @temps7_avec) / @temps7_sans) * 100, 2)
        WHEN @temps7_avec > @temps7_sans THEN -ROUND(((@temps7_avec - @temps7_sans) / @temps7_sans) * 100, 2) ELSE 0 END);

-- ============================================
-- TEST 8: Suppression avec condition
-- ============================================
SELECT '' AS Message;
SELECT '=== TEST 8: Suppression avec condition ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
DELETE FROM clients_sans_index WHERE ville = 'Lyon';
SET @fin = NOW(3);
SET @temps8_sans = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps SANS index: ', ROUND(@temps8_sans, 3), ' ms') AS Resultat;
ROLLBACK;

-- Avec index
SET @debut = NOW(3);
DELETE FROM clients_avec_index WHERE ville = 'Lyon';
SET @fin = NOW(3);
SET @temps8_avec = TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000;
SELECT CONCAT('Temps AVEC index: ', ROUND(@temps8_avec, 3), ' ms') AS Resultat;
ROLLBACK;

INSERT INTO resultats_performance (test_name, temps_sans_index_ms, temps_avec_index_ms, gain_percent)
VALUES ('DELETE avec condition', @temps8_sans, @temps8_avec,
        CASE WHEN @temps8_sans > @temps8_avec THEN ROUND(((@temps8_sans - @temps8_avec) / @temps8_sans) * 100, 2)
        WHEN @temps8_avec > @temps8_sans THEN -ROUND(((@temps8_avec - @temps8_sans) / @temps8_sans) * 100, 2) ELSE 0 END);

-- ============================================
-- Affichage des résultats consolidés
-- ============================================
SELECT '' AS Message;
SELECT '========================================' AS Message;
SELECT '  RÉSUMÉ DES PERFORMANCES' AS Message;
SELECT '========================================' AS Message;

SELECT
    test_name AS 'Test',
    temps_sans_index_ms AS 'Sans Index (ms)',
    temps_avec_index_ms AS 'Avec Index (ms)',
    CONCAT(gain_percent, '%') AS 'Gain/Amélioration'
FROM resultats_performance
ORDER BY id;

SELECT '' AS Message;
SELECT 'Tests de performance terminés!' AS Message;
