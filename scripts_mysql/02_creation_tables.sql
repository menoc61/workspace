-- ============================================
-- Script 02: Création des tables
-- TP Oracle & MySQL - Comparaison Index
-- ============================================

USE tp_comparaison_index;

-- ============================================
-- Table CLIENTS SANS index
-- ============================================
CREATE TABLE IF NOT EXISTS clients_sans_index (
    id_client INT PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    email VARCHAR(100),
    telephone VARCHAR(20),
    adresse TEXT,
    ville VARCHAR(50),
    code_postal VARCHAR(10),
    date_inscription DATE
) ENGINE=InnoDB;

-- ============================================
-- Table CLIENTS AVEC index
-- ============================================
CREATE TABLE IF NOT EXISTS clients_avec_index (
    id_client INT PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    email VARCHAR(100),
    telephone VARCHAR(20),
    adresse TEXT,
    ville VARCHAR(50),
    code_postal VARCHAR(10),
    date_inscription DATE,
    INDEX idx_nom (nom),
    INDEX idx_ville (ville),
    INDEX idx_email (email),
    INDEX idx_date_inscription (date_inscription)
) ENGINE=InnoDB;

-- ============================================
-- Table PRODUITS SANS index
-- ============================================
CREATE TABLE IF NOT EXISTS produits_sans_index (
    id_produit INT PRIMARY KEY,
    nom_produit VARCHAR(100),
    description TEXT,
    prix DECIMAL(10,2),
    quantite INT,
    categorie VARCHAR(50),
    date_ajout DATE
) ENGINE=InnoDB;

-- ============================================
-- Table PRODUITS AVEC index
-- ============================================
CREATE TABLE IF NOT EXISTS produits_avec_index (
    id_produit INT PRIMARY KEY,
    nom_produit VARCHAR(100),
    description TEXT,
    prix DECIMAL(10,2),
    quantite INT,
    categorie VARCHAR(50),
    date_ajout DATE,
    INDEX idx_nom_produit (nom_produit),
    INDEX idx_categorie (categorie),
    INDEX idx_prix (prix),
    INDEX idx_quantite (quantite),
    INDEX idx_date_ajout (date_ajout)
) ENGINE=InnoDB;

-- ============================================
-- Table COMMANDES SANS index
-- ============================================
CREATE TABLE IF NOT EXISTS commandes_sans_index (
    id_commande INT PRIMARY KEY,
    id_client INT,
    id_produit INT,
    quantite INT,
    prix_total DECIMAL(10,2),
    date_commande DATE,
    statut VARCHAR(20)
) ENGINE=InnoDB;

-- ============================================
-- Table COMMANDES AVEC index
-- ============================================
CREATE TABLE IF NOT EXISTS commandes_avec_index (
    id_commande INT PRIMARY KEY,
    id_client INT,
    id_produit INT,
    quantite INT,
    prix_total DECIMAL(10,2),
    date_commande DATE,
    statut VARCHAR(20),
    INDEX idx_id_client (id_client),
    INDEX idx_id_produit (id_produit),
    INDEX idx_date_commande (date_commande),
    INDEX idx_statut (statut),
    INDEX idx_prix_total (prix_total)
) ENGINE=InnoDB;

-- ============================================
-- Vérification des structures
-- ============================================
SELECT '=== Vérification des tables créées ===' AS Message;

-- Afficher les tables
SHOW TABLES;

-- Vérifier la structure des tables clients
SELECT '=== Structure des tables clients ===' AS Message;
DESCRIBE clients_sans_index;
DESCRIBE clients_avec_index;

-- Vérifier les index
SELECT '=== Index sur clients_avec_index ===' AS Message;
SHOW INDEX FROM clients_avec_index;

SELECT '=== Index sur clients_sans_index (devrait être vide) ===' AS Message;
SHOW INDEX FROM clients_sans_index;
