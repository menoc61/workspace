-- ============================================
-- Script 02: Manipulation des donnees
-- TP Oracle & MySQL - Oracle Schema
-- ============================================

-- NOTE: Executer ce script APRES avoir importe les donnees du schema vente
-- Connectez-vous d'abord: CONNECT approvisionnement/approvisionnementeam

-- ============================================
-- ETAPE 1: Verification des tables disponibles
-- ============================================

SELECT '=== Tables disponibles dans le schema ===' AS Message FROM DUAL;

SELECT table_name
FROM user_tables
ORDER BY table_name;

SELECT 'Nombre de tables: ' || COUNT(*) AS Nombre_Tables
FROM user_tables;

-- ============================================
-- ETAPE 2: Verification des donnees
-- ============================================

SELECT '=== Comptage des donnees ===' AS Message FROM DUAL;

-- Essayer de compter les tables existantes (si elles existent)
DECLARE
    v_count NUMBER;
BEGIN
    -- Client
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM client' INTO v_count;
    DBMS_OUTPUT.PUT_LINE('Clients: ' || v_count);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Table CLIENT non trouvee ou vide');
END;
/

DECLARE
    v_count NUMBER;
BEGIN
    -- Produit
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM produit' INTO v_count;
    DBMS_OUTPUT.PUT_LINE('Produits: ' || v_count);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Table PRODUIT non trouvee ou vide');
END;
/

DECLARE
    v_count NUMBER;
BEGIN
    -- Commande
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM commande' INTO v_count;
    DBMS_OUTPUT.PUT_LINE('Commandes: ' || v_count);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Table COMMANDE non trouvee ou vide');
END;
/

DECLARE
    v_count NUMBER;
BEGIN
    -- Approvisionnement
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM approvisionnement' INTO v_count;
    DBMS_OUTPUT.PUT_LINE('Enregistrements approvisionnement: ' || v_count);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Table APPROVISIONNEMENT non trouvee ou vide');
END;
/

-- ============================================
-- ETAPE 3: Exemples de requetes
-- ============================================

SELECT '=== Exemples de requetes ===' AS Message FROM DUAL;

-- Tous les clients
SELECT '=== Liste des clients ===' AS Query FROM DUAL;
SELECT * FROM client WHERE ROWNUM <= 10;

-- Produits avec stock faible
SELECT '=== Produits avec stock faible (< 10) ===' AS Query FROM DUAL;
SELECT * FROM produit WHERE quantite < 10;

-- Commandes recentes (30 derniers jours)
SELECT '=== Commandes recentes (30 derniers jours) ===' AS Query FROM DUAL;
SELECT * FROM commande WHERE date_commande >= SYSDATE - 30;

-- ============================================
-- ETAPE 4: Creation d'une vue pour les stocks
-- ============================================

SELECT '=== Creation de la vue vue_stock ===' AS Action FROM DUAL;

CREATE OR REPLACE VIEW vue_stock AS
SELECT
    p.id_produit,
    p.nom_produit,
    p.quantite,
    p.prix,
    CASE
        WHEN p.quantite < 5 THEN 'CRITIQUE'
        WHEN p.quantite < 20 THEN 'FAIBLE'
        ELSE 'NORMAL'
    END AS statut_stock
FROM produit p
WHERE p.quantite < 50;

-- Afficher la vue
SELECT * FROM vue_stock WHERE ROWNUM <= 10;

-- ============================================
-- ETAPE 5: Requetes analytiques
-- ============================================

SELECT '=== Top 10 des produits les plus vendus ===' AS Analyse FROM DUAL;

SELECT p.nom_produit, SUM(c.quantite) AS total_vendu
FROM commande c
JOIN produit p ON c.id_produit = p.id_produit
GROUP BY p.nom_produit
ORDER BY total_vendu DESC
FETCH FIRST 10 ROWS ONLY;

SELECT '=== Chiffre d''affaires par mois ===' AS Analyse FROM DUAL;

SELECT
    TO_CHAR(date_commande, 'YYYY-MM') AS mois,
    COUNT(*) AS nb_commandes,
    SUM(montant) AS chiffre_affaires
FROM commande
GROUP BY TO_CHAR(date_commande, 'YYYY-MM')
ORDER BY mois DESC;

SELECT '=== Fournisseurs et leurs produits ===' AS Analyse FROM DUAL;

SELECT
    f.nom_fournisseur,
    p.nom_produit,
    p.quantite,
    p.prix
FROM approvisionnement a
JOIN produit p ON a.id_produit = p.id_produit
JOIN fournisseur f ON a.id_fournisseur = f.id_fournisseur
WHERE ROWNUM <= 20;

-- ============================================
-- ETAPE 6: Statistiques
-- ============================================

SELECT '=== Statistiques du schema ===' AS Statistiques FROM DUAL;

SELECT
    'Tables' AS Element,
    COUNT(*) AS Nombre
FROM user_tables
UNION ALL
SELECT
    'Vues' AS Element,
    COUNT(*) AS Nombre
FROM user_views
UNION ALL
SELECT
    'Procedures' AS Element,
    COUNT(*) AS Nombre
FROM user_procedures;

SELECT ' Manipulation des donnees terminee!' AS Message FROM DUAL;
