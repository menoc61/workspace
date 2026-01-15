# TP Oracle & MySQL - Solutions Complètes

## 📋 PARTIE 1 : ORACLE - SCHÉMA APPROVISIONNEMENT

### ÉTAPE 1 : Connexion et préparation

```bash
# 1. Lancer l'invite de commande en tant qu'administrateur
# Windows : Click droit -> "Exécuter en tant qu'administrateur"

# 2. Lancer SQL*Plus sans connexion
sqlplus /nolog

# 3. Connexion en tant que SYSDBA
connect sys/mul3net@restov20 as SYSDBA
```

### ÉTAPE 2 : Création du schéma approvisionnement

```sql
-- 1. Créer l'utilisateur approvisionnement
CREATE USER approvisionnement IDENTIFIED BY approvisionnementeam;

-- 2. Attribuer le privilège DBA
GRANT DBA TO approvisionnement;

-- 3. Créer un répertoire pour les imports/exports (si nécessaire)
-- Windows
CREATE DIRECTORY dp_dir AS 'C:\oracle\dp_dir';
-- Linux
-- CREATE DIRECTORY dp_dir AS '/u01/app/oracle/dp_dir';

-- 4. Attribuer les droits sur le répertoire
GRANT READ, WRITE ON DIRECTORY dp_dir TO approvisionnement;

-- 5. Vérifier la création
SELECT username, account_status FROM dba_users WHERE username = 'APPROVISIONNEMENT';
```

### ÉTAPE 3 : Export des données du schéma VENTE

```bash
# Depuis l'invite de commande Windows (PAS dans sqlplus)
# Option 1 : Export complet du schéma vente
expdp vente/venteteam@bou3que SCHEMAS=vente DIRECTORY=dp_dir DUMPFILE=vente_export.dmp LOGFILE=vente_export.log

# Option 2 : Export des tables spécifiques
expdp vente/venteteam@bou3que TABLES=CLIENT,PRODUIT,COMMANDE,APPROVISIONNEMENT DIRECTORY=dp_dir DUMPFILE=vente_tables.dmp LOGFILE=vente_tables.log
```

### ÉTAPE 4 : Import dans le schéma approvisionnement

```bash
# Importer toutes les données du schéma vente dans approvisionnement
impdp approvisionnement/approvisionnementeam@bou3que SCHEMAS=vente REMAP_SCHEMA=vente:approvisionnement DIRECTORY=dp_dir DUMPFILE=vente_export.dmp LOGFILE=import_approvisionnement.log

# Si vous avez exporté des tables spécifiques
impdp approvisionnement/approvisionnementeam@bou3que TABLES=CLIENT,PRODUIT,COMMANDE,APPROVISIONNEMENT REMAP_SCHEMA=vente:approvisionnement DIRECTORY=dp_dir DUMPFILE=vente_tables.dmp LOGFILE=import_tables.log
```

### ÉTAPE 5 : Vérification et manipulation

```sql
-- 1. Connexion avec le nouveau schéma
CONNECT approvisionnement/approvisionnementeam@bou3que

-- 2. Voir les tables disponibles
SELECT table_name FROM user_tables;

-- 3. Voir les données
SELECT COUNT(*) FROM client;
SELECT COUNT(*) FROM produit;
SELECT COUNT(*) FROM commande;
SELECT COUNT(*) FROM approvisionnement;

-- 4. Exemples de requêtes
-- Tous les clients
SELECT * FROM client;

-- Produits avec stock faible
SELECT * FROM produit WHERE quantite < 10;

-- Commandes récentes
SELECT * FROM commande WHERE date_commande >= SYSDATE - 30;

-- Fournisseurs et leurs produits
SELECT f.nom_fournisseur, p.nom_produit, p.quantite 
FROM approvisionnement a 
JOIN produit p ON a.id_produit = p.id_produit 
JOIN fournisseur f ON a.id_fournisseur = f.id_fournisseur;
```

### ÉTAPE 6 : Scripts SQL pour manipulations avancées

```sql
-- 1. Créer une vue pour les stocks
CREATE OR REPLACE VIEW vue_stock_faible AS
SELECT p.id_produit, p.nom_produit, p.quantite, p.prix,
       CASE 
           WHEN p.quantite < 5 THEN 'CRITIQUE'
           WHEN p.quantite < 20 THEN 'FAIBLE'
           ELSE 'NORMAL'
       END AS statut_stock
FROM produit p
WHERE p.quantite < 20;

-- 2. Créer une procédure pour réapprovisionner
CREATE OR REPLACE PROCEDURE reapprovisionner_produit(
    p_id_produit IN NUMBER,
    p_quantite IN NUMBER
) AS
BEGIN
    UPDATE produit SET quantite = quantite + p_quantite 
    WHERE id_produit = p_id_produit;
    
    INSERT INTO historique_approvisionnement (id_produit, quantite_ajoutee, date_operation)
    VALUES (p_id_produit, p_quantite, SYSDATE);
    
    COMMIT;
END;
/

-- 3. Créer un trigger pour alerte stock
CREATE OR REPLACE TRIGGER trg_stock_faible
AFTER UPDATE OF quantite ON produit
FOR EACH ROW
WHEN (NEW.quantite < 10)
BEGIN
    INSERT INTO alerte_stock (id_produit, quantite_actuelle, date_alerte, traite)
    VALUES (:NEW.id_produit, :NEW.quantite, SYSDATE, 'N');
END;
/

-- 4. Requêtes analytiques
-- Top 10 des produits les plus vendus
SELECT p.nom_produit, SUM(c.quantite) AS total_vendu
FROM commande c
JOIN produit p ON c.id_produit = p.id_produit
GROUP BY p.nom_produit
ORDER BY total_vendu DESC
FETCH FIRST 10 ROWS ONLY;

-- Chiffre d'affaires par mois
SELECT TO_CHAR(date_commande, 'YYYY-MM') AS mois,
       SUM(montant) AS chiffre_affaires
FROM commande
GROUP BY TO_CHAR(date_commande, 'YYYY-MM')
ORDER BY mois;
```

---

## 🗄️ PARTIE 2 : MYSQL - COMPARAISON AVEC ET SANS INDEX

### ÉTAPE 1 : Installation et connexion MySQL

```bash
# Linux (Ubuntu/Debian)
sudo apt update
sudo apt install mysql-server mysql-client

# Démarrer MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Connexion
mysql -u root -p

# Windows
# Télécharger depuis https://dev.mysql.com/downloads/mysql/
# Installer MySQL Server et MySQL Workbench
# Se connecter avec MySQL Workbench ou ligne de commande
mysql -u root -p
```

### ÉTAPE 2 : Création de la base de données

```sql
-- Créer la base de données
CREATE DATABASE IF NOT EXISTS tp_comparaison_index 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Utiliser la base
USE tp_comparaison_index;

-- Voir les tables existantes
SHOW TABLES;
```

### ÉTAPE 3 : Création des tables (sans index d'abord)

```sql
-- Table CLIENTS sans index
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

-- Table CLIENTS avec index
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

-- Table PRODUITS sans index
CREATE TABLE IF NOT EXISTS produits_sans_index (
    id_produit INT PRIMARY KEY,
    nom_produit VARCHAR(100),
    description TEXT,
    prix DECIMAL(10,2),
    quantite INT,
    categorie VARCHAR(50),
    date_ajout DATE
) ENGINE=InnoDB;

-- Table PRODUITS avec index
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

-- Table COMMANDES sans index
CREATE TABLE IF NOT EXISTS commandes_sans_index (
    id_commande INT PRIMARY KEY,
    id_client INT,
    id_produit INT,
    quantite INT,
    prix_total DECIMAL(10,2),
    date_commande DATE,
    statut VARCHAR(20)
) ENGINE=InnoDB;

-- Table COMMANDES avec index
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

-- Vérifier les structures
DESCRIBE clients_sans_index;
DESCRIBE clients_avec_index;
SHOW INDEX FROM clients_avec_index;
SHOW INDEX FROM clients_sans_index;
```

### ÉTAPE 4 : Insertion massive de données de test

```sql
-- Activer les logs pour voir les temps d'exécution
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';

-- Procédure stockée pour insérer des clients
DELIMITER //

CREATE PROCEDURE inserer_clients()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_nom VARCHAR(50);
    DECLARE v_prenom VARCHAR(50);
    DECLARE v_email VARCHAR(100);
    DECLARE v_ville VARCHAR(50);
    
    WHILE i <= 100000 DO
        SET v_nom = CONCAT('Nom', i);
        SET v_prenom = CONCAT('Prenom', i);
        SET v_email = CONCAT('client', i, '@email.com');
        SET v_ville = ELT(FLOOR(1 + RAND() * 10), 'Paris', 'Lyon', 'Marseille', 'Toulouse', 'Nice', 'Nantes', 'Strasbourg', 'Bordeaux', 'Lille', 'Rennes');
        
        INSERT INTO clients_sans_index VALUES (
            i, v_nom, v_prenom, v_email,
            CONCAT('0', FLOOR(100000000 + RAND() * 899999999)),
            CONCAT('Adresse ', i), v_ville,
            CONCAT('75', FLOOR(100 + RAND() * 900)),
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY)
        );
        
        INSERT INTO clients_avec_index VALUES (
            i, v_nom, v_prenom, v_email,
            CONCAT('0', FLOOR(100000000 + RAND() * 899999999)),
            CONCAT('Adresse ', i), v_ville,
            CONCAT('75', FLOOR(100 + RAND() * 900)),
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY)
        );
        
        SET i = i + 1;
    END WHILE;
END //

-- Procédure pour insérer des produits
CREATE PROCEDURE inserer_produits()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_nom VARCHAR(100);
    DECLARE v_categorie VARCHAR(50);
    
    WHILE i <= 50000 DO
        SET v_nom = CONCAT('Produit ', i);
        SET v_categorie = ELT(FLOOR(1 + RAND() * 8), 'Electronique', 'Vetements', 'Alimentation', 'Maison', 'Sport', 'Livres', 'Jouets', 'Beaute');
        
        INSERT INTO produits_sans_index VALUES (
            i, v_nom, CONCAT('Description du produit ', i),
            ROUND(5 + RAND() * 500, 2),
            FLOOR(1 + RAND() * 100),
            v_categorie,
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY)
        );
        
        INSERT INTO produits_avec_index VALUES (
            i, v_nom, CONCAT('Description du produit ', i),
            ROUND(5 + RAND() * 500, 2),
            FLOOR(1 + RAND() * 100),
            v_categorie,
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY)
        );
        
        SET i = i + 1;
    END WHILE;
END //

-- Procédure pour insérer des commandes
CREATE PROCEDURE inserer_commandes()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_id_client INT;
    DECLARE v_id_produit INT;
    DECLARE v_quantite INT;
    DECLARE v_prix DECIMAL(10,2);
    
    WHILE i <= 500000 DO
        SET v_id_client = FLOOR(1 + RAND() * 100000);
        SET v_id_produit = FLOOR(1 + RAND() * 50000);
        SET v_quantite = FLOOR(1 + RAND() * 10);
        
        -- Récupérer le prix du produit
        SELECT prix INTO v_prix FROM produits_sans_index WHERE id_produit = v_id_produit;
        
        INSERT INTO commandes_sans_index VALUES (
            i, v_id_client, v_id_produit, v_quantite,
            ROUND(v_prix * v_quantite, 2),
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY),
            ELT(FLOOR(1 + RAND() * 4), 'En cours', 'Livre', 'Annule', 'Retour')
        );
        
        INSERT INTO commandes_avec_index VALUES (
            i, v_id_client, v_id_produit, v_quantite,
            ROUND(v_prix * v_quantite, 2),
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1460) DAY),
            ELT(FLOOR(1 + RAND() * 4), 'En cours', 'Livre', 'Annule', 'Retour')
        );
        
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;
```

### ÉTAPE 5 : Exécuter les insertions avec mesure du temps

```sql
-- Activer le profiling
SET profiling = 1;

-- Insérer les clients
SELECT 'Insertion clients SANS index - Début' AS Info;
SET @debut1 = NOW(3);

CALL inserer_clients();

SET @fin1 = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut1, @fin1)/1000 AS 'Temps insertion clients SANS index (ms)';

-- Insérer les produits
SELECT 'Insertion produits SANS index - Début' AS Info;
SET @debut2 = NOW(3);

CALL inserer_produits();

SET @fin2 = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut2, @fin2)/1000 AS 'Temps insertion produits SANS index (ms)';

-- Insérer les commandes
SELECT 'Insertion commandes SANS index - Début' AS Info;
SET @debut3 = NOW(3);

CALL inserer_commandes();

SET @fin3 = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut3, @fin3)/1000 AS 'Temps insertion commandes SANS index (ms)';

-- Vérifier les comptages
SELECT '--- Vérification des données ---' AS Info;
SELECT COUNT(*) AS 'Total clients' FROM clients_sans_index;
SELECT COUNT(*) AS 'Total produits' FROM produits_sans_index;
SELECT COUNT(*) AS 'Total commandes' FROM commandes_sans_index;
```

### ÉTAPE 6 : Scripts de comparaison des performances

```sql
-- Script complet de comparaison
-- =================================

-- 1. COMPARAISON DES SELECT SIMPLES
-- =================================

SELECT '=== TEST 1: SELECT simple avec WHERE sur nom ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT * FROM clients_sans_index WHERE nom = 'Nom50000';
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps SANS index (ms)';

-- Avec index
SET @debut = NOW(3);
SELECT * FROM clients_avec_index WHERE nom = 'Nom50000';
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps AVEC index (ms)';

-- 2. COMPARAISON DES RECHERCHES PAR VILLE
-- ========================================

SELECT '=== TEST 2: SELECT avec WHERE sur ville ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT COUNT(*) FROM clients_sans_index WHERE ville = 'Paris';
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps SANS index (ms)';

-- Avec index
SET @debut = NOW(3);
SELECT COUNT(*) FROM clients_avec_index WHERE ville = 'Paris';
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps AVEC index (ms)';

-- 3. COMPARAISON DES JOINTURES
-- ============================

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
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps SANS index (ms)';

-- Avec index
SET @debut = NOW(3);
SELECT c.nom, c.prenom, COUNT(cmd.id_commande) AS nb_commandes
FROM clients_avec_index c
JOIN commandes_avec_index cmd ON c.id_client = cmd.id_client
WHERE cmd.date_commande >= '2023-01-01'
GROUP BY c.id_client, c.nom, c.prenom
LIMIT 100;
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps AVEC index (ms)';

-- 4. COMPARAISON DES AGGRÉGATIONS
-- =================================

SELECT '=== TEST 4: Agrégation par catégorie ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT categorie, COUNT(*) AS nb_produits, AVG(prix) AS prix_moyen
FROM produits_sans_index
GROUP BY categorie;
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps SANS index (ms)';

-- Avec index
SET @debut = NOW(3);
SELECT categorie, COUNT(*) AS nb_produits, AVG(prix) AS prix_moyen
FROM produits_avec_index
GROUP BY categorie;
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps AVEC index (ms)';

-- 5. COMPARAISON DES REQUÊTES COMPLEXES
-- =======================================

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
            AND cmd2.date_commande >= '2023-06-01');
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps SANS index (ms)';

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
            AND cmd2.date_commande >= '2023-06-01');
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps AVEC index (ms)';

-- 6. TEST DE TRI
-- ==============

SELECT '=== TEST 6: Tri sur plusieurs colonnes ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
SELECT nom, prenom, ville, date_inscription
FROM clients_sans_index
ORDER BY ville DESC, nom ASC, date_inscription DESC
LIMIT 1000;
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps SANS index (ms)';

-- Avec index
SET @debut = NOW(3);
SELECT nom, prenom, ville, date_inscription
FROM clients_avec_index
ORDER BY ville DESC, nom ASC, date_inscription DESC
LIMIT 1000;
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps AVEC index (ms)';

-- 7. TEST DE MISE À JOUR
-- ======================

SELECT '=== TEST 7: Mise à jour massive ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
UPDATE clients_sans_index 
SET ville = 'NOUVELLE_VILLE'
WHERE id_client BETWEEN 1000 AND 5000;
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps SANS index (ms)';
-- Annuler pour pouvoir répéter
ROLLBACK;

-- Avec index
SET @debut = NOW(3);
UPDATE clients_avec_index 
SET ville = 'NOUVELLE_VILLE'
WHERE id_client BETWEEN 1000 AND 5000;
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps AVEC index (ms)';
-- Annuler pour pouvoir répéter
ROLLBACK;

-- 8. TEST DE SUPPRESSION
-- ======================

SELECT '=== TEST 8: Suppression avec condition ===' AS Test_Name;

-- Sans index
SET @debut = NOW(3);
DELETE FROM clients_sans_index WHERE ville = 'Lyon';
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps SANS index (ms)';
-- Annuler
ROLLBACK;

-- Avec index
SET @debut = NOW(3);
DELETE FROM clients_avec_index WHERE ville = 'Lyon';
SET @fin = NOW(3);
SELECT TIMESTAMPDIFF(MICROSECOND, @debut, @fin)/1000 AS 'Temps AVEC index (ms)';
-- Annuler
ROLLBACK;
```

### ÉTAPE 7 : Analyse et interprétation des résultats

```sql
-- Voir les plans d'exécution
EXPLAIN SELECT * FROM clients_sans_index WHERE nom = 'Nom50000';
EXPLAIN SELECT * FROM clients_avec_index WHERE nom = 'Nom50000';

-- Statistiques des tables
SELECT 
    table_name,
    table_rows,
    CONCAT(ROUND(data_length / 1024 / 1024, 2), ' MB') AS data_size,
    CONCAT(ROUND(index_length / 1024 / 1024, 2), ' MB') AS index_size
FROM 
    information_schema.tables
WHERE 
    table_schema = 'tp_comparaison_index'
ORDER BY 
    data_length DESC;

-- Temps d'exécution des requêtes (depuis le profiling)
SELECT 
    query_id,
    seq,
    state,
    CONCAT(ROUND(duration * 1000, 3), ' ms') AS duration_ms,
    CONVERT(stmt USING utf8) AS statement
FROM 
    mysql.general_log
WHERE 
    command_type = 'Query'
ORDER BY 
    query_id DESC, seq
LIMIT 100;

-- Résumé des performances
SELECT 
    '=== RÉSUMÉ DES PERFORMANCES ===' AS '';

SELECT 
    'Opération' AS 'Type',
    'Temps sans index (ms)' AS 'Sans_Index',
    'Temps avec index (ms)' AS 'Avec_Index',
    'Gain (%)' AS 'Amelioration';

-- Exemple de résumé (à remplir avec vos résultats)
SELECT 
    'SELECT simple' AS Opération,
    'X.XX' AS Sans_Index,
    'X.XX' AS Avec_Index,
    'XX%' AS Gain;
```

### ÉTAPE 8 : Script de nettoyage

```sql
-- Supprimer les procédures
DROP PROCEDURE IF EXISTS inserer_clients;
DROP PROCEDURE IF EXISTS inserer_produits;
DROP PROCEDURE IF EXISTS inserer_commandes;

-- Supprimer les tables
DROP TABLE IF EXISTS commandes_sans_index;
DROP TABLE IF EXISTS commandes_avec_index;
DROP TABLE IF EXISTS produits_sans_index;
DROP TABLE IF EXISTS produits_avec_index;
DROP TABLE IF EXISTS clients_sans_index;
DROP TABLE IF EXISTS clients_avec_index;

-- Supprimer la base de données
DROP DATABASE IF EXISTS tp_comparaison_index;

-- Désactiver le profiling
SET profiling = 0;
SET GLOBAL general_log = 'OFF';
```

---

## 📊 RAPPORT DE COMPARAISON ATTENDU

### Structure du rapport

```markdown
# Rapport de Comparaison: MySQL avec et sans Index

## 1. Environnement de test
- Système: [Votre OS]
- Version MySQL: [SELECT VERSION();]
- RAM: [X GB]
- CPU: [X cœurs]
- Nombre de données: 100 000 clients, 50 000 produits, 500 000 commandes

## 2. Résultats des tests

| Test | Sans Index (ms) | Avec Index (ms) | Gain (%) |
|------|-----------------|-----------------|----------|
| SELECT simple | XXX | XXX | XX% |
| Recherche par ville | XXX | XXX | XX% |
| Jointure | XXX | XXX | XX% |
| Agrégation | XXX | XXX | XX% |
| Requête complexe | XXX | XXX | XX% |
| Tri | XXX | XXX | XX% |
| UPDATE | XXX | XXX | XX% |
| DELETE | XXX | XXX | XX% |

## 3. Analyse
- Les index améliorent significativement les performances des SELECT
- Les opérations INSERT/UPDATE/DELETE sont légèrement plus lentes avec index
- Recommandations sur quand créer des index

## 4. Conclusion
- Importance des index pour les bases de données volumineuses
- Équilibre entre performance en lecture et écriture
```

---

## 🚀 COMMANDES RAPIDES - RÉFÉRENCE

### MySQL
```bash
# Connexion
mysql -u root -p

# Voir les bases
SHOW DATABASES;

# Voir les tables
SHOW TABLES;

# Voir la structure d'une table
DESCRIBE nom_table;

# Voir les index
SHOW INDEX FROM nom_table;

# Voir le plan d'exécution
EXPLAIN SELECT ...;

# Profiling
SET profiling = 1;
SHOW PROFILES;
```

### Oracle SQL*Plus
```bash
# Lancer
sqlplus /nolog

# Connexion
connect user/password@service

# Voir les tables
SELECT table_name FROM user_tables;

# Exécuter un script
@chemin/vers/script.sql
```

---

## 💡 CONSEILS ET BONNES PRATIQUES

### Index MySQL
1. **Créer des index sur:**
   - Colonnes fréquemment utilisées dans WHERE
   - Colonnes de jointure (JOIN)
   - Colonnes de tri fréquent (ORDER BY)

2. **Éviter les index sur:**
   - Petites tables (< 1000 lignes)
   - Colonnes avec beaucoup de NULL
   - Colonnes fréquemment mises à jour

3. **Types d'index:**
   - INDEX : index standard
   - UNIQUE : index avec unicité
   - PRIMARY KEY : clé primaire
   - FULLTEXT : recherche textuelle

### Oracle
1. Toujours attribuer les bons privilèges
2. Utiliser des tablespaces appropriés
3. Sauvegarder régulièrement avec expdp
4. Monitorer avec Enterprise Manager

---

## 🔧 DÉPANNAGE

### Problèmes courants MySQL
```sql
-- Erreur de connexion
-- Vérifier le service: sudo systemctl status mysql

-- Table pleine
-- Augmenter la taille max: SET GLOBAL max_allowed_packet=1073741824;

-- Requête lente
-- Activer le slow query log: SET GLOBAL slow_query_log = 'ON';
```

### Problèmes courants Oracle
```bash
# ORA-12541: TNS:no listener
lsnrctl start

# ORA-01034: ORACLE not available
sqlplus / as sysdba
startup

# ORA-12154: TNS:could not resolve service name
# Vérifier tnsnames.ora
```

---

**Bon courage pour votre TP ! 🎓**
