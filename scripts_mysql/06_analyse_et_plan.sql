-- ============================================
-- Script 06: Analyse et plans d'exécution
-- TP Oracle & MySQL - Comparaison Index
-- ============================================

USE tp_comparaison_index;

SELECT '========================================' AS Message;
SELECT '  ANALYSE ET PLANS D\'EXÉCUTION' AS Message;
SELECT '========================================' AS Message;
SELECT '' AS Message;

-- ============================================
-- Plans d'exécution EXPLAIN
-- ============================================
SELECT '=== PLANS D\'EXÉCUTION - TEST 1: SELECT simple ===' AS Analyse;

SELECT '' AS Message;
SELECT 'Plan SANS index:' AS Scenario;
EXPLAIN SELECT * FROM clients_sans_index WHERE nom = 'Nom50000';

SELECT '' AS Message;
SELECT 'Plan AVEC index:' AS Scenario;
EXPLAIN SELECT * FROM clients_avec_index WHERE nom = 'Nom50000';

-- ============================================
SELECT '' AS Message;
SELECT '=== PLANS D\'EXÉCUTION - TEST 2: Recherche par ville ===' AS Analyse;

SELECT '' AS Message;
SELECT 'Plan SANS index:' AS Scenario;
EXPLAIN SELECT COUNT(*) FROM clients_sans_index WHERE ville = 'Paris';

SELECT '' AS Message;
SELECT 'Plan AVEC index:' AS Scenario;
EXPLAIN SELECT COUNT(*) FROM clients_avec_index WHERE ville = 'Paris';

-- ============================================
SELECT '' AS Message;
SELECT '=== PLANS D\'EXÉCUTION - TEST 3: Jointure ===' AS Analyse;

SELECT '' AS Message;
SELECT 'Plan SANS index:' AS Scenario;
EXPLAIN SELECT c.nom, c.prenom, COUNT(cmd.id_commande) AS nb_commandes
FROM clients_sans_index c
JOIN commandes_sans_index cmd ON c.id_client = cmd.id_client
WHERE cmd.date_commande >= '2023-01-01'
GROUP BY c.id_client, c.nom, c.prenom
LIMIT 100;

SELECT '' AS Message;
SELECT 'Plan AVEC index:' AS Scenario;
EXPLAIN SELECT c.nom, c.prenom, COUNT(cmd.id_commande) AS nb_commandes
FROM clients_avec_index c
JOIN commandes_avec_index cmd ON c.id_client = cmd.id_client
WHERE cmd.date_commande >= '2023-01-01'
GROUP BY c.id_client, c.nom, c.prenom
LIMIT 100;

-- ============================================
SELECT '' AS Message;
SELECT '=== PLANS D\'EXÉCUTION - TEST 6: Tri ===' AS Analyse;

SELECT '' AS Message;
SELECT 'Plan SANS index:' AS Scenario;
EXPLAIN SELECT nom, prenom, ville, date_inscription
FROM clients_sans_index
ORDER BY ville DESC, nom ASC, date_inscription DESC
LIMIT 1000;

SELECT '' AS Message;
SELECT 'Plan AVEC index:' AS Scenario;
EXPLAIN SELECT nom, prenom, ville, date_inscription
FROM clients_avec_index
ORDER BY ville DESC, nom ASC, date_inscription DESC
LIMIT 1000;

-- ============================================
-- Statistiques détaillées des tables
-- ============================================
SELECT '' AS Message;
SELECT '=== STATISTIQUES DÉTAILLÉES DES TABLES ===' AS Analyse;

SELECT
    table_name AS 'Table',
    table_rows AS 'Lignes',
    CONCAT(ROUND(data_length / 1024 / 1024, 2), ' MB') AS 'Données',
    CONCAT(ROUND(index_length / 1024 / 1024, 2), ' MB') AS 'Index',
    CONCAT(ROUND((data_length + index_length) / 1024 / 1024, 2), ' MB') AS 'Total',
    ROW_FORMAT AS 'Format'
FROM information_schema.tables
WHERE table_schema = 'tp_comparaison_index'
ORDER BY table_name;

-- ============================================
-- Informations sur les index
-- ============================================
SELECT '' AS Message;
SELECT '=== DÉTAILS DES INDEX ===' AS Analyse;

SELECT
    TABLE_NAME AS 'Table',
    INDEX_NAME AS 'Nom Index',
    COLUMN_NAME AS 'Colonne',
    SEQ_IN_INDEX AS 'Position',
    CARDINALITY AS 'Cardinalité',
    INDEX_TYPE AS 'Type'
FROM information_schema.statistics
WHERE table_schema = 'tp_comparaison_index'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- ============================================
-- Analyse des performances avec profiling
-- ============================================
SELECT '' AS Message;
SELECT '=== PROFILING DES REQUÊTES ===' AS Analyse;

SHOW PROFILES;

SELECT
    query_id,
    ROUND(duration * 1000, 3) AS 'Durée (ms)',
    SUBSTRING(statement, 1, 100) AS 'Requête (tronquée)'
FROM information_schema.profiling
ORDER BY query_id DESC
LIMIT 20;

-- ============================================
-- Recommandations basées sur les résultats
-- ============================================
SELECT '' AS Message;
SELECT '=== RECOMMANDATIONS ===' AS Analyse;

SELECT '1. Les index améliorent significativement les performances des SELECT' AS Recommandation;
SELECT '2. Les index ralentissent légèrement les INSERT/UPDATE/DELETE' AS Recommandation;
SELECT '3. Créer des index sur les colonnes fréquemment utilisées dans WHERE' AS Recommandation;
SELECT '4. Créer des index sur les colonnes de jointure (JOIN)' AS Recommandation;
SELECT '5. Éviter les index sur les colonnes fréquemment mises à jour' AS Recommandation;
SELECT '6. Utiliser EXPLAIN pour analyser les plans d\'exécution' AS Recommandation;

SELECT '' AS Message;
SELECT 'Analyse terminée!' AS Message;
