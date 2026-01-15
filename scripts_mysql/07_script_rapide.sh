#!/bin/bash

# ============================================
# Script d'execution automatique - MySQL
# TP Oracle & MySQL - Comparaison Index
# ============================================

echo "========================================"
echo "  TP MYSQL - EXECUTION AUTOMATIQUE"
echo "========================================"
echo ""
echo "Configuration:"
echo "  - Hote: localhost"
echo "  - Port: 3306"
echo "  - Utilisateur: root"
echo "  - Mot de passe: (aucun)"
echo "  - Enregistrements: 25"
echo ""

# Verifier si MySQL est installe
if ! command -v mysql &> /dev/null; then
    echo "ERREUR: MySQL n'est pas installe ou n'est pas dans le PATH"
    echo "Veuillez installer MySQL ou ajouter le repertoire bin au PATH"
    exit 1
fi

# Verifier si le service MySQL est demarre
echo "Verification du service MySQL..."
if ! pgrep -x "mysqld" > /dev/null; then
    echo "Le service MySQL n'est pas demarre."
    echo "Tentative de demarrage..."
    sudo systemctl start mysql 2>/dev/null || sudo service mysql start 2>/dev/null || {
        echo "ATTENTION: Impossible de demarrer MySQL automatiquement"
        echo "Veuillez demarrer le service MySQL manuellement:"
        echo "  Linux: sudo systemctl start mysql"
        echo "  Windows: net start mysql"
    }
fi

# Petit delai pour laisser le service demarrer
sleep 2

echo ""
echo "========================================"
echo "  DEBUT DE L'EXECUTION"
echo "========================================"
echo ""

# Change to the scripts directory
cd "$(dirname "$0")"

# Fonction pour executer un script SQL
executer_script() {
    local script=$1
    local description=$2
    
    echo "[$description] Execution de $script..."
    if mysql -h localhost -P 3306 -u root < "$script" 2>/dev/null; then
        echo "  [OK] $script execute avec succes"
        return 0
    else
        echo "  [ERREUR] Echec de l'execution de $script"
        echo "  Verifiez que:"
        echo "    1. Le service MySQL est demarre"
        echo "    2. L'utilisateur root peut se connecter sans mot de passe"
        echo "    3. Le port 3306 est correct"
        return 1
    fi
}

# Variable pour suivre le succes
SUCCES=0
ECHEC=0

# Script 1: Creation de la base
if executer_script "01_creation_base.sql" "1/6"; then ((SUCCES++)); else ((ECHEC++)); fi
echo ""

# Script 2: Creation des tables
if executer_script "02_creation_tables.sql" "2/6"; then ((SUCCES++)); else ((ECHEC++)); fi
echo ""

# Script 3: Creation des procedures
if executer_script "03_procedures_insertion.sql" "3/6"; then ((SUCCES++)); else ((ECHEC++)); fi
echo ""

# Script 4: Insertion des donnees
if executer_script "04_execution_insertions.sql" "4/6"; then ((SUCCES++)); else ((ECHEC++)); fi
echo ""

# Script 5: Tests de performance
if executer_script "05_comparaison_performances.sql" "5/6"; then ((SUCCES++)); else ((ECHEC++)); fi
echo ""

# Script 6: Analyse
if executer_script "06_analyse_et_plan.sql" "6/6"; then ((SUCCES++)); else ((ECHEC++)); fi
echo ""

# Resultats finaux
echo "========================================"
echo "  RESULTATS DE L'EXECUTION"
echo "========================================"
echo ""
echo "Scripts reussis: $SUCCES/6"
echo "Scripts echoues: $ECHEC/6"
echo ""

if [ $ECHEC -eq 0 ]; then
    echo "========================================"
    echo "  EXECUTION TERMINEE AVEC SUCCES!"
    echo "========================================"
    echo ""
    echo "RESULTATS:"
    echo "  [OK] Base de donnees tp_comparaison_index creee"
    echo "  [OK] 6 tables creees (avec et sans index)"
    echo "  [OK] 75 enregistrements inseres (25 de chaque)"
    echo "  [OK] 8 tests de performance executes"
    echo "  [OK] Resultats sauvegardes dans resultats_performance"
    echo ""
    echo "POUR VOIR LES RESULTATS:"
    echo "  mysql -h localhost -P 3306 -u root"
    echo "  USE tp_comparaison_index;"
    echo "  SELECT * FROM resultats_performance;"
    echo "  SELECT * FROM clients_avec_index;"
    echo "  SELECT * FROM produits_avec_index;"
    echo "  SELECT * FROM commandes_avec_index;"
    echo ""
    echo "POUR VOIR LES INDEX:"
    echo "  SHOW INDEX FROM clients_avec_index;"
    echo "  SHOW INDEX FROM produits_avec_index;"
    echo ""
    echo "POUR VOIR LES PLANS D'EXECUTION:"
    echo "  EXPLAIN SELECT * FROM clients_avec_index WHERE nom = 'Nom1';"
    echo ""
else
    echo "========================================"
    echo "  ATTENTION: CERTAINS SCRIPTS ONT ECHOUE"
    echo "========================================"
    echo ""
    echo "Conseils de depannage:"
    echo "  1. Verifiez que le service MySQL est demarre"
    echo "  2. Verifiez les identifiants de connexion"
    echo "  3. Verifiez que le port 3306 est correct"
    echo "  4. Executez les scripts manuellement pour voir les erreurs"
    echo ""
fi

echo "========================================"
