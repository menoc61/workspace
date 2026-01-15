-- ============================================
-- Script 04: Exécution des insertions avec mesure du temps
-- TP Oracle & MySQL - Comparaison Index
-- ============================================

USE tp_comparaison_index;

-- Activer le profiling
SET profiling = 1;

SELECT '========================================' AS Message;
SELECT '  INSERTION DES DONNÉES DE TEST' AS Message;
SELECT '========================================' AS Message;
SELECT '' AS Message;

-- ============================================
-- Insertion des clients (25 enregistrements)
-- ============================================
SELECT '=== Insertion des 25 clients ===' AS Operation;

SELECT 'Début insertion clients' AS Info;
SET @debut1 = NOW(3);

CALL inserer_clients();

SET @fin1 = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut1, @fin1)/1000 AS 'Temps insertion clients (ms)';

-- ============================================
-- Insertion des produits (25 enregistrements)
-- ============================================
SELECT '' AS Message;
SELECT '=== Insertion des 25 produits ===' AS Operation;

SELECT 'Début insertion produits' AS Info;
SET @debut2 = NOW(3);

CALL inserer_produits();

SET @fin2 = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut2, @fin2)/1000 AS 'Temps insertion produits (ms)';

-- ============================================
-- Insertion des commandes (25 enregistrements)
-- ============================================
SELECT '' AS Message;
SELECT '=== Insertion des 25 commandes ===' AS Operation;

SELECT 'Début insertion commandes' AS Info;
SET @debut3 = NOW(3);

CALL inserer_commandes();

SET @fin3 = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut3, @fin3)/1000 AS 'Temps insertion commandes (ms)';

-- ============================================
-- Vérification des comptages (25 de chaque)
-- ============================================
SELECT '' AS Message;
SELECT '=== Vérification des données insérées ===' AS Message;
SELECT COUNT(*) AS 'Total clients' FROM clients_sans_index;
SELECT COUNT(*) AS 'Total clients avec index' FROM clients_avec_index;
SELECT COUNT(*) AS 'Total produits' FROM produits_sans_index;
SELECT COUNT(*) AS 'Total produits avec index' FROM produits_avec_index;
SELECT COUNT(*) AS 'Total commandes' FROM commandes_sans_index;
SELECT COUNT(*) AS 'Total commandes avec index' FROM commandes_avec_index;

-- ============================================
-- Statistiques des tables
-- ============================================
SELECT '' AS Message;
SELECT '=== Taille des tables ===' AS Message;

SELECT
    table_name,
    table_rows,
    CONCAT(ROUND(data_length / 1024 / 1024, 2), ' MB') AS data_size,
    CONCAT(ROUND(index_length / 1024 / 1024, 2), ' MB') AS index_size,
    CONCAT(ROUND((index_length / data_length) * 100, 2), '%') AS overhead_percent
FROM
    information_schema.tables
WHERE
    table_schema = 'tp_comparaison_index'
ORDER BY
    table_name;

SELECT '' AS Message;
SELECT 'Données insérées avec succès!' AS Message;
