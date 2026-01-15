#!/bin/bash

# ============================================
# Script d'exécution rapide - MySQL
# TP Oracle & MySQL - Comparaison Index
# ============================================

echo "========================================"
echo "  TP MYSQL - EXECUTION RAPIDE"
echo "========================================"
echo ""
echo "Configuration:"
echo "  - Hote: localhost"
echo "  - Port: 3306"
echo "  - Utilisateur: root"
echo "  - Mot de passe: (aucun)"
echo "  - Nombre d'enregistrements: 25"
echo ""

# Verifier si MySQL est installe
if ! command -v mysql &> /dev/null; then
    echo "ERREUR: MySQL n'est pas installe ou n'est pas dans le PATH"
    exit 1
fi

# Verifier si le service MySQL est demarre
echo "Verification du service MySQL..."
if ! pgrep -x "mysqld" > /dev/null; then
    echo "Le service MySQL n'est pas demarre. Tentative de demarrage..."
    sudo systemctl start mysql 2>/dev/null || sudo service mysql start 2>/dev/null || echo "Attention: Impossible de demarrer MySQL automatiquement"
fi

echo ""
echo "Execution des scripts SQL..."
echo ""

# Script 1: Creation de la base
echo "[1/6] Creation de la base de donnees..."
mysql -h localhost -P 3306 -u root < 01_creation_base.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Base creee avec succes"
else
    echo "  ✗ Erreur lors de la creation de la base"
    exit 1
fi

# Script 2: Creation des tables
echo "[2/6] Creation des tables..."
mysql -h localhost -P 3306 -u root < 02_creation_tables.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Tables creees avec succes"
else
    echo "  ✗ Erreur lors de la creation des tables"
    exit 1
fi

# Script 3: Creation des procedures
echo "[3/6] Creation des procedures d'insertion..."
mysql -h localhost -P 3306 -u root < 03_procedures_insertion.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Procedures creees avec succes"
else
    echo "  ✗ Erreur lors de la creation des procedures"
    exit 1
fi

# Script 4: Insertion des donnees
echo "[4/6] Insertion des donnees de test (25 de chaque)..."
mysql -h localhost -P 3306 -u root < 04_execution_insertions.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Donnees inserees avec succes"
else
    echo "  ✗ Erreur lors de l'insertion des donnees"
    exit 1
fi

# Script 5: Tests de performance
echo "[5/6] Execution des tests de performance..."
mysql -h localhost -P 3306 -u root < 05_comparaison_performances.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Tests de performance termines"
else
    echo "  ✗ Erreur lors des tests de performance"
    exit 1
fi

# Script 6: Analyse
echo "[6/6] Analyse et plans d'execution..."
mysql -h localhost -P 3306 -u root < 06_analyse_et_plan.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Analyse terminee"
else
    echo "  ✗ Erreur lors de l'analyse"
    exit 1
fi

echo ""
echo "========================================"
echo "  EXECUTION TERMINEE AVEC SUCCES!"
echo "========================================"
echo ""
echo "RESULTATS:"
echo "  ✓ Base de donnees tp_comparaison_index creee"
echo "  ✓ 6 tables creees (avec et sans index)"
echo "  ✓ 75 enregistrements inseres (25 de chaque)"
echo "  ✓ 8 tests de performance executes"
echo "  ✓ Resultats sauvegardes dans resultats_performance"
echo ""
echo "Pour voir les resultats:"
echo "  mysql -h localhost -P 3306 -u root"
echo "  USE tp_comparaison_index;"
echo "  SELECT * FROM resultats_performance;"
echo "  SELECT * FROM clients_avec_index;"
echo "  SELECT * FROM produits_avec_index;"
echo "  SELECT * FROM commandes_avec_index;"
echo ""
echo "========================================"
