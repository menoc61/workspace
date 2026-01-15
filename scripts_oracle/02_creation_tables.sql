-- ============================================
-- Script 02: Creation des tables (Based on Boutique ERD)
-- TP Oracle & MySQL - Oracle Schema
-- ============================================

-- NOTE: Executer ce script APRES s'etre connecte avec le schema approvisionnement
-- CONNECT approvisionnement/approvisionnementeam

-- ============================================
-- ETAPE 1: Creation de la table CLIENT
-- ============================================

CREATE TABLE client (
    num     NUMBER(10) PRIMARY KEY,
    nom     VARCHAR2(50) NOT NULL,
    prenom  VARCHAR2(50),
    ddn     DATE,
    tel     VARCHAR2(20),
    genre   CHAR(1) CHECK (genre IN ('m', 'f'))
);

-- Commentaire sur la table
COMMENT ON TABLE client IS 'Table des clients de la boutique';
COMMENT ON COLUMN client.num IS 'Numero unique du client (cle primaire)';
COMMENT ON COLUMN client.nom IS 'Nom de famille du client';
COMMENT ON COLUMN client.prenom IS 'Prenom du client';
COMMENT ON COLUMN client.ddn IS 'Date de naissance du client';
COMMENT ON COLUMN client.tel IS 'Numero de telephone du client';
COMMENT ON COLUMN client.genre IS 'Genre du client (m ou f)';

-- ============================================
-- ETAPE 2: Creation de la table ADRESSE
-- ============================================

CREATE TABLE adresse (
    num     NUMBER(10) NOT NULL,
    rue     VARCHAR2(100),
    cp      NUMBER(10),
    ville   VARCHAR2(50),
    CONSTRAINT pk_adresse PRIMARY KEY (num),
    CONSTRAINT fk_client_adresse FOREIGN KEY (num) REFERENCES client(num) ON DELETE CASCADE
);

COMMENT ON TABLE adresse IS 'Table des adresses des clients';
COMMENT ON COLUMN adresse.num IS 'Numero du client (cle etrangere vers client)';
COMMENT ON COLUMN adresse.rue IS 'Nom de la rue';
COMMENT ON COLUMN adresse.cp IS 'Code postal';
COMMENT ON COLUMN adresse.ville IS 'Nom de la ville';

-- ============================================
-- ETAPE 3: Creation de la table PRODUIT
-- ============================================

CREATE TABLE produit (
    num         NUMBER(10) PRIMARY KEY,
    designation VARCHAR2(100) NOT NULL,
    prix        NUMBER(10,2) CHECK (prix >= 0),
    stock       NUMBER(10) CHECK (stock >= 0)
);

COMMENT ON TABLE produit IS 'Table des produits de la boutique';
COMMENT ON COLUMN produit.num IS 'Numero unique du produit (cle primaire)';
COMMENT ON COLUMN produit.designation IS 'Designation/nom du produit';
COMMENT ON COLUMN produit.prix IS 'Prix du produit';
COMMENT ON COLUMN produit.stock IS 'Quantite en stock';

-- ============================================
-- ETAPE 4: Creation de la table FACTURE
-- (Association class entre CLIENT et PRODUIT)
-- ============================================

CREATE TABLE facture (
    num         NUMBER(10) NOT NULL,
    num_client  NUMBER(10) NOT NULL,
    num_produit NUMBER(10) NOT NULL,
    qte         NUMBER(10) CHECK (qte > 0),
    CONSTRAINT pk_facture PRIMARY KEY (num, num_client, num_produit),
    CONSTRAINT fk_facture_client FOREIGN KEY (num_client) REFERENCES client(num),
    CONSTRAINT fk_facture_produit FOREIGN KEY (num_produit) REFERENCES produit(num)
);

COMMENT ON TABLE facture IS 'Table des factures (liaison client-produit avec quantite)';
COMMENT ON COLUMN facture.num IS 'Numero de la facture (cle locale)';
COMMENT ON COLUMN facture.num_client IS 'Numero du client (cle etrangere)';
COMMENT ON COLUMN facture.num_produit IS 'Numero du produit (cle etrangere)';
COMMENT ON COLUMN facture.qte IS 'Quantite achetee';

-- ============================================
-- ETAPE 5: Insertion des donnees de test
-- ============================================

-- Insérer des clients
INSERT INTO client (num, nom, prenom, ddn, tel, genre) VALUES (1, 'Dupont', 'Jean', TO_DATE('1985-03-15', 'YYYY-MM-DD'), '0612345678', 'm');
INSERT INTO client (num, nom, prenom, ddn, tel, genre) VALUES (2, 'Martin', 'Marie', TO_DATE('1990-07-22', 'YYYY-MM-DD'), '0687654321', 'f');
INSERT INTO client (num, nom, prenom, ddn, tel, genre) VALUES (3, ' Durand', 'Pierre', TO_DATE('1978-11-08', 'YYYY-MM-DD'), '0611223344', 'm');
INSERT INTO client (num, nom, prenom, ddn, tel, genre) VALUES (4, 'Bernard', 'Sophie', TO_DATE('1995-02-14', 'YYYY-MM-DD'), '0655443322', 'f');
INSERT INTO client (num, nom, prenom, ddn, tel, genre) VALUES (5, 'Petit', 'Thomas', TO_DATE('1982-09-30', 'YYYY-MM-DD'), '0633445566', 'm');

-- Insérer des adresses (chaque client peut avoir plusieurs adresses)
INSERT INTO adresse (num, rue, cp, ville) VALUES (1, 'Rue de la Paix', 75001, 'Paris');
INSERT INTO adresse (num, rue, cp, ville) VALUES (1, 'Avenue des Champs', 69002, 'Lyon');
INSERT INTO adresse (num, rue, cp, ville) VALUES (2, 'Boulevard Saint-Michel', 13001, 'Marseille');
INSERT INTO adresse (num, rue, cp, ville) VALUES (3, 'Place de la Republique', 31000, 'Toulouse');
INSERT INTO adresse (num, rue, cp, ville) VALUES (4, 'Rue Saint-Catherine', 33000, 'Bordeaux');
INSERT INTO adresse (num, rue, cp, ville) VALUES (5, 'Avenue de la Mer', 06000, 'Nice');

-- Insérer des produits
INSERT INTO produit (num, designation, prix, stock) VALUES (1, 'Ordinateur portable', 899.99, 25);
INSERT INTO produit (num, designation, prix, stock) VALUES (2, 'Smartphone', 599.99, 50);
INSERT INTO produit (num, designation, prix, stock) VALUES (3, 'Tablette', 349.99, 30);
INSERT INTO produit (num, designation, prix, stock) VALUES (4, 'Casque audio', 149.99, 100);
INSERT INTO produit (num, designation, prix, stock) VALUES (5, 'Clavier sans fil', 79.99, 75);
INSERT INTO produit (num, designation, prix, stock) VALUES (6, 'Souris sans fil', 49.99, 80);
INSERT INTO produit (num, designation, prix, stock) VALUES (7, 'Ecran 27 pouces', 399.99, 15);
INSERT INTO produit (num, designation, prix, stock) VALUES (8, 'Imprimante', 199.99, 20);
INSERT INTO produit (num, designation, prix, stock) VALUES (9, 'Disque SSD 1To', 109.99, 60);
INSERT INTO produit (num, designation, prix, stock) VALUES (10, 'Cle USB 64Go', 19.99, 200);

-- Insérer des factures (liaison client-produit)
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (1, 1, 1, 1);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (1, 1, 4, 2);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (2, 2, 2, 1);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (3, 3, 7, 1);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (4, 4, 3, 2);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (5, 5, 5, 1);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (5, 5, 6, 2);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (6, 1, 9, 3);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (7, 2, 10, 5);
INSERT INTO facture (num, num_client, num_produit, qte) VALUES (8, 3, 8, 1);

-- Valider les insertions
COMMIT;

-- ============================================
-- ETAPE 6: Verification des donnees
-- ============================================

SELECT '=== Tables creees et peuplees avec succes ===' AS Message FROM DUAL;

-- Afficher le contenu des tables
SELECT '=== Liste des clients ===' AS Section FROM DUAL;
SELECT * FROM client ORDER BY num;

SELECT '=== Liste des adresses ===' AS Section FROM DUAL;
SELECT * FROM adresse ORDER BY num;

SELECT '=== Liste des produits ===' AS Section FROM DUAL;
SELECT * FROM produit ORDER BY num;

SELECT '=== Liste des factures ===' AS Section FROM DUAL;
SELECT * FROM facture ORDER BY num;

-- Statistiques
SELECT '=== Statistiques ===' AS Section FROM DUAL;
SELECT 'Clients: ' || COUNT(*) AS Nb FROM client;
SELECT 'Adresses: ' || COUNT(*) AS Nb FROM adresse;
SELECT 'Produits: ' || COUNT(*) AS Nb FROM produit;
SELECT 'Lignes de facture: ' || COUNT(*) AS Nb FROM facture;
