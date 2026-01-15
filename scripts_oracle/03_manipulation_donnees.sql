-- ============================================
-- Script 03: Manipulation des donnees
-- TP Oracle & MySQL - Oracle Schema (Based on Boutique ERD)
-- ============================================

-- NOTE: Executer ce script APRES avoir execute 02_creation_tables.sql

-- ============================================
-- PARTIE 1: Requetes de base sur le schema
-- ============================================

SELECT '========================================' AS Message FROM DUAL;
SELECT '  REQUETES SUR LA BOUTIQUE' AS Message FROM DUAL;
SELECT '========================================' AS Message FROM DUAL;

-- ============================================
-- 1. Liste des clients avec leurs adresses
-- ============================================

SELECT '=== Clients et leurs adresses ===' AS Requete FROM DUAL;

SELECT c.num AS num_client, c.nom, c.prenom, c.tel, a.rue, a.cp, a.ville
FROM client c
LEFT JOIN adresse a ON c.num = a.num
ORDER BY c.num;

-- ============================================
-- 2. Produits avec stock faible (moins de 30)
-- ============================================

SELECT '=== Produits avec stock faible (< 30) ===' AS Requete FROM DUAL;

SELECT num, designation, prix, stock,
       CASE
           WHEN stock < 10 THEN 'CRITIQUE'
           WHEN stock < 30 THEN 'FAIBLE'
           ELSE 'NORMAL'
       END AS statut_stock
FROM produit
WHERE stock < 30
ORDER BY stock;

-- ============================================
-- 3. Total des achats par client
-- ============================================

SELECT '=== Total des achats par client ===' AS Requete FROM DUAL;

SELECT c.num AS num_client, c.nom, c.prenom,
       COUNT(f.num) AS nb_factures,
       SUM(f.qte) AS total_produits,
       SUM(f.qte * p.prix) AS total_achats
FROM client c
JOIN facture f ON c.num = f.num_client
JOIN produit p ON f.num_produit = p.num
GROUP BY c.num, c.nom, c.prenom
ORDER BY total_achats DESC;

-- ============================================
-- 4. Details des factures (avec produits)
-- ============================================

SELECT '=== Details des factures ===' AS Requete FROM DUAL;

SELECT f.num AS num_facture, c.nom || ' ' || c.prenom AS client,
       p.designation AS produit, f.qte, p.prix,
       f.qte * p.prix AS sous_total
FROM facture f
JOIN client c ON f.num_client = c.num
JOIN produit p ON f.num_produit = p.num
ORDER BY f.num;

-- ============================================
-- 5. Chiffre d'affaires total
-- ============================================

SELECT '=== Chiffre d''affaires ===' AS Requete FROM DUAL;

SELECT COUNT(DISTINCT f.num) AS nb_factures,
       SUM(f.qte) AS total_produits_vendus,
       SUM(f.qte * p.prix) AS chiffre_affaires
FROM facture f
JOIN produit p ON f.num_produit = p.num;

-- ============================================
-- 6. Produits les plus vendus
-- ============================================

SELECT '=== Top 5 des produits les plus vendus ===' AS Requete FROM DUAL;

SELECT p.num, p.designation, SUM(f.qte) AS quantite_vendue, SUM(f.qte * p.prix) AS revenus
FROM produit p
JOIN facture f ON p.num = f.num_produit
GROUP BY p.num, p.designation
ORDER BY quantite_vendue DESC
FETCH FIRST 5 ROWS ONLY;

-- ============================================
-- PARTIE 2: Vues et procedures
-- ============================================

SELECT '' AS Message FROM DUAL;
SELECT '========================================' AS Message FROM DUAL;
SELECT '  VUES ET PROCEDURES' AS Message FROM DUAL;
SELECT '========================================' AS Message FROM DUAL;

-- ============================================
-- Vue: Resume des stocks
-- ============================================

CREATE OR REPLACE VIEW vue_resume_stock AS
SELECT
    num,
    designation,
    prix,
    stock,
    CASE
        WHEN stock < 10 THEN 'CRITIQUE'
        WHEN stock < 30 THEN 'FAIBLE'
        ELSE 'OK'
    END AS etat_stock,
    stock * prix AS valeur_stock
FROM produit;

SELECT '=== Vue vue_resume_stock creee ===' AS Action FROM DUAL;
SELECT * FROM vue_resume_stock ORDER BY stock;

-- ============================================
-- Procedure: Augmenter le stock
-- ============================================

CREATE OR REPLACE PROCEDURE augmenter_stock(
    p_num_produit IN NUMBER,
    p_quantite IN NUMBER
) AS
BEGIN
    UPDATE produit SET stock = stock + p_quantite WHERE num = p_num_produit;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Stock du produit ' || p_num_produit || ' augmente de ' || p_quantite);
END;
/

SELECT '=== Procedure augmenter_stock creee ===' AS Action FROM DUAL;

-- Tester la procedure
EXEC augmenter_stock(1, 10);

-- Verifier le resultat
SELECT * FROM produit WHERE num = 1;

-- ============================================
-- Procedure: Nouvelle facture
-- ============================================

CREATE OR REPLACE PROCEDURE nouvelle_facture(
    p_num_client IN NUMBER,
    p_num_produit IN NUMBER,
    p_quantite IN NUMBER
) AS
    v_num_facture NUMBER;
    v_prix NUMBER;
BEGIN
    -- Generer un nouveau numero de facture
    SELECT NVL(MAX(num), 0) + 1 INTO v_num_facture FROM facture;
    
    -- Verifier le prix du produit
    SELECT prix INTO v_prix FROM produit WHERE num = p_num_produit;
    
    -- Verifier le stock disponible
    IF v_prix IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: Produit non trouve');
        RETURN;
    END IF;
    
    -- Inserer la facture
    INSERT INTO facture (num, num_client, num_produit, qte)
    VALUES (v_num_facture, p_num_client, p_num_produit, p_quantite);
    
    -- Mettre a jour le stock
    UPDATE produit SET stock = stock - p_quantite WHERE num = p_num_produit;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Facture ' || v_num_facture || ' creee pour le client ' || p_num_client);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: Produit ou client non trouve');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
        ROLLBACK;
END;
/

SELECT '=== Procedure nouvelle_facture creee ===' AS Action FROM DUAL;

-- Tester la procedure (creer une nouvelle facture pour le client 1)
EXEC nouvelle_facture(1, 3, 1);

-- Verifier le resultat
SELECT * FROM produit WHERE num = 3;
SELECT * FROM facture ORDER BY num;

-- ============================================
-- Trigger: Alerte stock bas
-- ============================================

CREATE OR REPLACE TRIGGER trg_alerte_stock
AFTER UPDATE OF stock ON produit
FOR EACH ROW
WHEN (NEW.stock < 10)
BEGIN
    DBMS_OUTPUT.PUT_LINE('ALERTE: Le produit ' || :NEW.num || ' (' || :NEW.designation || ') a un stock bas (' || :NEW.stock || ')');
END;
/

SELECT '=== Trigger trg_alerte_stock cree ===' AS Action FROM DUAL;

-- Tester le trigger
UPDATE produit SET stock = 5 WHERE num = 10;

-- Restaurer le stock
UPDATE produit SET stock = 200 WHERE num = 10;

-- ============================================
-- PARTIE 3: Requetes avancees
-- ============================================

SELECT '' AS Message FROM DUAL;
SELECT '========================================' AS Message FROM DUAL;
SELECT '  REQUETES AVANCEES' AS Message FROM DUAL;
SELECT '========================================' AS Message FROM DUAL;

-- ============================================
-- 7. Clients avec plusieurs adresses
-- ============================================

SELECT '=== Clients avec plusieurs adresses ===' AS Requete FROM DUAL;

SELECT c.num, c.nom, c.prenom, COUNT(a.num) AS nb_adresses
FROM client c
JOIN adresse a ON c.num = a.num
GROUP BY c.num, c.nom, c.prenom
HAVING COUNT(a.num) > 1;

-- ============================================
-- 8. Produits jamais achetes
-- ============================================

SELECT '=== Produits jamais achetes ===' AS Requete FROM DUAL;

SELECT p.num, p.designation, p.prix, p.stock
FROM produit p
LEFT JOIN facture f ON p.num = f.num_produit
WHERE f.num_produit IS NULL;

-- ============================================
-- 9. Valeur totale du stock
-- ============================================

SELECT '=== Valeur totale du stock ===' AS Requete FROM DUAL;

SELECT SUM(stock * prix) AS valeur_totale_stock,
       COUNT(*) AS nb_produits,
       AVG(stock * prix) AS valeur_moyenne
FROM produit;

-- ============================================
-- FIN
-- ============================================

SELECT '' AS Message FROM DUAL;
SELECT '========================================' AS Message FROM DUAL;
SELECT '  MANIPULATION TERMINEE' AS Message FROM DUAL;
SELECT '========================================' AS Message FROM DUAL;
SELECT '' AS Message FROM DUAL;
SELECT 'Tables: CLIENT, ADRESSE, PRODUIT, FACTURE' AS Resume FROM DUAL;
SELECT 'Vues: VUE_RESUME_STOCK' AS Resume FROM DUAL;
SELECT 'Procedures: AUGMENTER_STOCK, NOUVELLE_FACTURE' AS Resume FROM DUAL;
SELECT 'Trigger: TRG_ALERTE_STOCK' AS Resume FROM DUAL;
