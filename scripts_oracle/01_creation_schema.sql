-- ============================================
-- Script 01: Creation du schema APPROVISIONNEMENT
-- TP Oracle & MySQL - Oracle Schema
-- ============================================

-- NOTE: Executer ce script dans SQL*Plus apres connexion SYSDBA
-- connect sys/momenic61 as SYSDBA

-- ============================================
-- ETAPE 1: Creation de l'utilisateur
-- ============================================

-- Supprimer l'utilisateur s'il existe deja (pour reexecution)
BEGIN
    EXECUTE IMMEDIATE 'DROP USER approvisionnement CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN
            RAISE;
        END IF;
END;
/

-- Creer l'utilisateur approvisionnement
CREATE USER approvisionnement IDENTIFIED BY approvisionnementeam
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

-- Attribuer le privilege DBA
GRANT DBA TO approvisionnement;

-- Attribuer les privileges de connexion et de creation
GRANT CONNECT, RESOURCE TO approvisionnement;

-- ============================================
-- ETAPE 2: Creation du repertoire pour Data Pump
-- ============================================

-- Windows (a adapter selon votre installation)
-- CREATE OR REPLACE DIRECTORY dp_dir AS 'C:\oracle\dp_dir';

-- Linux/Unix (a adapter selon votre installation)
-- CREATE OR REPLACE DIRECTORY dp_dir AS '/u01/app/oracle/dp_dir';

-- Attribuer les droits sur le repertoire (decommentez selon votre OS)
-- GRANT READ, WRITE ON DIRECTORY dp_dir TO approvisionnement;

-- ============================================
-- ETAPE 3: Connexion avec le nouvel utilisateur
-- ============================================

-- Connectez-vous avec: CONNECT approvisionnement/approvisionnementeam
-- Puis executez le script 02_manipulation_donnees.sql

-- ============================================
-- ETAPE 4: Verification de la creation
-- ============================================

SELECT '=== Verification de la creation de l''utilisateur ===' AS Message FROM DUAL;

SELECT username, account_status, created, default_tablespace
FROM dba_users
WHERE username = 'APPROVISIONNEMENT';

SELECT 'Schema approvisionnement cree avec succes!' AS Message FROM DUAL;
SELECT 'Pour importer les donnees, suivez les etapes du README.md' AS Message FROM DUAL;
