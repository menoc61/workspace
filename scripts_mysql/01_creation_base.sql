-- ============================================
-- Script 01: Création de la base de données
-- TP Oracle & MySQL - Comparaison Index
-- ============================================

-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS tp_comparaison_index
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Utiliser la base de données
USE tp_comparaison_index;

-- Afficher un message de confirmation
SELECT 'Base de données tp_comparaison_index créée avec succès!' AS Message;

-- Vérifier les bases de données
SHOW DATABASES;

-- Vérifier que nous sommes sur la bonne base
SELECT DATABASE() AS Base_Courante;
