-- ============================================
-- Script 01: Creation du schema APPROVISIONNEMENT
-- TP Oracle & MySQL - Oracle Schema (Based on Boutique ERD)
-- ============================================

-- NOTE: Executer ce script dans SQL*Plus apres connexion SYSDBA
-- connect sys/momenic61 as SYSDBA

-- ============================================
-- ETAPE 1: Suppression des objets existants
-- ============================================

-- Supprimer les tables si elles existent (dans l'ordre inverse des dependances)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE facture CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE adresse CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE client CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE produit CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Supprimer l'utilisateur s'il existe deja
BEGIN
    EXECUTE IMMEDIATE 'DROP USER approvisionnement CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN RAISE; END IF;
END;
/

-- ============================================
-- ETAPE 2: Creation de l'utilisateur
-- ============================================

CREATE USER approvisionnement IDENTIFIED BY approvisionnementeam
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

GRANT DBA TO approvisionnement;
GRANT CONNECT, RESOURCE TO approvisionnement;

-- ============================================
-- ETAPE 3: Connexion avec le nouvel utilisateur
-- ============================================

-- Connectez-vous avec: CONNECT approvisionnement/approvisionnementeam
-- Puis executez le script 02_creation_tables.sql pour creer les tables et les donnees

SELECT '========================================' AS Message FROM DUAL;
SELECT 'Schema approvisionnement cree avec succes!' AS Message FROM DUAL;
SELECT '========================================' AS Message FROM DUAL;
SELECT '' AS Message FROM DUAL;
SELECT 'ETAPES SUIVANTES:' AS Message FROM DUAL;
SELECT '1. CONNECT approvisionnement/approvisionnementeam' AS Message FROM DUAL;
SELECT '2. @scripts_oracle/02_creation_tables.sql' AS Message FROM DUAL;
SELECT '3. @scripts_oracle/03_manipulation_donnees.sql' AS Message FROM DUAL;
