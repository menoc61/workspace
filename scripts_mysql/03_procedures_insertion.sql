-- ============================================
-- Script 03: Procédures d'insertion
-- TP Oracle & MySQL - Comparaison Index
-- ============================================

USE tp_comparaison_index;

-- Activer les logs pour voir les temps d'exécution (optionnel)
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';

-- ============================================
-- Procédure stockée pour insérer des clients
-- ============================================
DELIMITER //

CREATE PROCEDURE inserer_clients()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_nom VARCHAR(50);
    DECLARE v_prenom VARCHAR(50);
    DECLARE v_email VARCHAR(100);
    DECLARE v_ville VARCHAR(50);
    DECLARE v_adresse TEXT;
    DECLARE v_code_postal VARCHAR(10);
    DECLARE v_date_inscription DATE;

    -- Désactiver les contraintes temporaires pour accélérer l'insertion
    SET FOREIGN_KEY_CHECKS = 0;

    WHILE i <= 25 DO
        SET v_nom = CONCAT('Nom', i);
        SET v_prenom = CONCAT('Prenom', i);
        SET v_email = CONCAT('client', i, '@email.com');
        SET v_ville = ELT(FLOOR(1 + RAND() * 10), 'Paris', 'Lyon', 'Marseille', 'Toulouse', 'Nice', 'Nantes', 'Strasbourg', 'Bordeaux', 'Lille', 'Rennes');
        SET v_adresse = CONCAT('Adresse ', i);
        SET v_code_postal = CONCAT('75', FLOOR(100 + RAND() * 900));
        SET v_date_inscription = DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY);

        -- Insertion dans la table SANS index
        INSERT INTO clients_sans_index VALUES (
            i, v_nom, v_prenom, v_email,
            CONCAT('0', FLOOR(100000000 + RAND() * 899999999)),
            v_adresse, v_ville,
            v_code_postal, v_date_inscription
        );

        -- Insertion dans la table AVEC index
        INSERT INTO clients_avec_index VALUES (
            i, v_nom, v_prenom, v_email,
            CONCAT('0', FLOOR(100000000 + RAND() * 899999999)),
            v_adresse, v_ville,
            v_code_postal, v_date_inscription
        );

        SET i = i + 1;

        -- Afficher la progression
        IF i MOD 5 = 0 THEN
            SELECT CONCAT('Clients insérés: ', i) AS Progression;
        END IF;
    END WHILE;

    -- Réactiver les contraintes
    SET FOREIGN_KEY_CHECKS = 1;
END //

-- ============================================
-- Procédure pour insérer des produits
-- ============================================
CREATE PROCEDURE inserer_produits()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_nom VARCHAR(100);
    DECLARE v_description TEXT;
    DECLARE v_prix DECIMAL(10,2);
    DECLARE v_quantite INT;
    DECLARE v_categorie VARCHAR(50);
    DECLARE v_date_ajout DATE;

    SET FOREIGN_KEY_CHECKS = 0;

    WHILE i <= 25 DO
        SET v_nom = CONCAT('Produit ', i);
        SET v_description = CONCAT('Description du produit ', i);
        SET v_prix = ROUND(5 + RAND() * 500, 2);
        SET v_quantite = FLOOR(1 + RAND() * 100);
        SET v_categorie = ELT(FLOOR(1 + RAND() * 8), 'Electronique', 'Vetements', 'Alimentation', 'Maison', 'Sport', 'Livres', 'Jouets', 'Beaute');
        SET v_date_ajout = DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY);

        -- Insertion dans la table SANS index
        INSERT INTO produits_sans_index VALUES (
            i, v_nom, v_description, v_prix, v_quantite, v_categorie, v_date_ajout
        );

        -- Insertion dans la table AVEC index
        INSERT INTO produits_avec_index VALUES (
            i, v_nom, v_description, v_prix, v_quantite, v_categorie, v_date_ajout
        );

        SET i = i + 1;

        -- Afficher la progression
        IF i MOD 5 = 0 THEN
            SELECT CONCAT('Produits insérés: ', i) AS Progression;
        END IF;
    END WHILE;

    SET FOREIGN_KEY_CHECKS = 1;
END //

-- ============================================
-- Procédure pour insérer des commandes
-- ============================================
CREATE PROCEDURE inserer_commandes()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_id_client INT;
    DECLARE v_id_produit INT;
    DECLARE v_quantite INT;
    DECLARE v_prix DECIMAL(10,2);
    DECLARE v_prix_total DECIMAL(10,2);
    DECLARE v_date_commande DATE;
    DECLARE v_statut VARCHAR(20);

    SET FOREIGN_KEY_CHECKS = 0;

    WHILE i <= 25 DO
        SET v_id_client = FLOOR(1 + RAND() * 25);
        SET v_id_produit = FLOOR(1 + RAND() * 50000);
        SET v_quantite = FLOOR(1 + RAND() * 10);

        -- Récupérer le prix du produit
        SELECT prix INTO v_prix FROM produits_sans_index WHERE id_produit = v_id_produit LIMIT 1;
        SET v_prix_total = ROUND(v_prix * v_quantite, 2);
        SET v_date_commande = DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY);
        SET v_statut = ELT(FLOOR(1 + RAND() * 4), 'En cours', 'Livre', 'Annule', 'Retour');

        -- Insertion dans la table SANS index
        INSERT INTO commandes_sans_index VALUES (
            i, v_id_client, v_id_produit, v_quantite, v_prix_total, v_date_commande, v_statut
        );

        -- Insertion dans la table AVEC index
        INSERT INTO commandes_avec_index VALUES (
            i, v_id_client, v_id_produit, v_quantite, v_prix_total, v_date_commande, v_statut
        );

        SET i = i + 1;

        -- Afficher la progression
        IF i MOD 5 = 0 THEN
            SELECT CONCAT('Commandes insérées: ', i) AS Progression;
        END IF;
    END WHILE;

    SET FOREIGN_KEY_CHECKS = 1;
END //

DELIMITER ;

-- ============================================
-- Vérification des procédures créées
-- ============================================
SELECT '=== Procédures créées avec succès ===' AS Message;

-- Lister les procédures
SHOW PROCEDURE STATUS WHERE Db = 'tp_comparaison_index';
