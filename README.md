#!/bin/bash

# ============================================
# TP Oracle & MySQL - EXECUTION AUTOMATIQUE
# ============================================

set -e  # Stop on any error

echo "========================================"
echo "  TP ORACLE & MYSQL - EXECUTION AUTO"
echo "========================================"
echo ""

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables de configuration
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_PWD=""  # Pas de mot de passe
ORACLE_USER="sys"
ORACLE_PWD="momenic61"
WORKSPACE="/c/Users/gille/Desktop/workspace/DB_TD/workspace"

# Fonctions utilitaires
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# ============================================
# PARTIE 1: ORACLE
# ============================================

echo ""
log_info "=== PARTIE 1: ORACLE ==="
echo ""

# Script 1: Creation du schema
log_info "Création du schema approvisionnement..."
log_info "Exécution: sqlplus sys/momenic61 as sysdba"

# Create a temporary SQL file for Oracle commands
cat > /tmp/oracle_script1.sql << 'EOF'
@${WORKSPACE}/scripts_oracle/01_creation_schema.sql
EXIT;
EOF

# Replace variable in the temp file
sed -i "s|\${WORKSPACE}|${WORKSPACE}|g" /tmp/oracle_script1.sql

# Execute Oracle script 1
echo "exit" | sqlplus sys/momenic61 as sysdba @/tmp/oracle_script1.sql

if [ $? -eq 0 ]; then
    log_info "Schema Oracle créé avec succès!"
else
    log_error "Erreur lors de la création du schema Oracle"
    exit 1
fi

# Script 2: Manipulation des données
log_info "Manipulation des données Oracle..."

cat > /tmp/oracle_script2.sql << 'EOF'
CONNECT approvisionnement/approvisionnementeam
@${WORKSPACE}/scripts_oracle/02_manipulation_donnees.sql
EXIT;
EOF

sed -i "s|\${WORKSPACE}|${WORKSPACE}|g" /tmp/oracle_script2.sql

echo "exit" | sqlplus approvisionnement/approvisionnementeam @/tmp/oracle_script2.sql

if [ $? -eq 0 ]; then
    log_info "Données Oracle manipulées avec succès!"
else
    log_warning "Erreur lors de la manipulation des données Oracle"
fi

# ============================================
# PARTIE 2: MYSQL (si disponible)
# ============================================

echo ""
log_info "=== PARTIE 2: MYSQL ==="
echo ""

# Vérifier si MySQL est disponible
if command -v mysql &> /dev/null; then
    log_info "MySQL trouvé, exécution des scripts..."
    
    # Fonction pour exécuter un script MySQL
    execute_mysql_script() {
        local script_name=$1
        local script_path="${WORKSPACE}/scripts_mysql/${script_name}"
        
        log_info "Exécution de ${script_name}..."
        
        if mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} < "${script_path}"; then
            log_info "${script_name} exécuté avec succès!"
        else
            log_error "Erreur lors de l'exécution de ${script_name}"
            exit 1
        fi
    }
    
    # Exécution des scripts MySQL dans l'ordre
    MYSQL_SCRIPTS=(
        "01_creation_base.sql"
        "02_creation_tables.sql"
        "03_procedures_insertion.sql"
        "04_execution_insertions.sql"
        "05_comparaison_performances.sql"
        "06_analyse_et_plan.sql"
    )
    
    for script in "${MYSQL_SCRIPTS[@]}"; do
        execute_mysql_script "$script"
    done
    
    # Vérification MySQL
    log_info "Vérification MySQL:"
    mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -e "
    USE tp_comparaison_index;
    SHOW TABLES;
    SELECT '=== CLIENTS ===' as info; SELECT COUNT(*) as total_clients FROM clients_avec_index;
    SELECT '=== PRODUITS ===' as info; SELECT COUNT(*) as total_produits FROM produits_avec_index;
    SELECT '=== COMMANDES ===' as info; SELECT COUNT(*) as total_commandes FROM commandes_avec_index;
    "
    
else
    log_warning "MySQL n'est pas installé ou non accessible"
    log_info "Seule la partie Oracle a été exécutée"
fi

# ============================================
# VERIFICATION ORACLE
# ============================================

echo ""
log_info "=== VERIFICATION ORACLE ==="
echo ""

cat > /tmp/oracle_verif.sql << 'EOF'
CONNECT approvisionnement/approvisionnementeam
SELECT '=== TABLES ORACLE ===' as info FROM dual;
SELECT table_name FROM user_tables;
SELECT '=== VERIFICATION TERMINEE ===' as info FROM dual;
EXIT;
EOF

echo "exit" | sqlplus approvisionnement/approvisionnementeam @/tmp/oracle_verif.sql

# ============================================
# RAPPORT
# ============================================

echo ""
log_info "=== GENERATION DU RAPPORT ==="
echo ""

# Créer un résumé des résultats
cat > ${WORKSPACE}/rapport_execution.txt << EOF
========================================
RAPPORT D'EXECUTION TP ORACLE & MYSQL
========================================
Date: $(date)
Heure: $(date +%H:%M:%S)
Workspace: ${WORKSPACE}

PARTIE 1: ORACLE
----------------
- Schema 'approvisionnement' créé
- Scripts Oracle exécutés avec succès

PARTIE 2: MYSQL
---------------
$(if command -v mysql &> /dev/null; then echo "- Base créée et scripts exécutés"; else echo "- MySQL non disponible"; fi)

EOF

log_info "Rapport généré: ${WORKSPACE}/rapport_execution.txt"

# ============================================
# NETTOYAGE
# ============================================

rm -f /tmp/oracle_script1.sql /tmp/oracle_script2.sql /tmp/oracle_verif.sql

# ============================================
# RESUME
# ============================================

echo ""
echo "========================================"
log_info "EXECUTION TERMINEE!"
echo "========================================"
echo ""
echo "Résultats:"
echo "✅ Schema Oracle 'approvisionnement' créé et configuré"
if command -v mysql &> /dev/null; then
    echo "✅ Scripts MySQL exécutés"
else
    echo "⚠️  MySQL non disponible"
fi
echo "✅ Rapport d'exécution généré"
echo ""
echo "Fichiers importants:"
echo "  - ${WORKSPACE}/rapport_execution.txt (Résumé)"
echo "  - ${WORKSPACE}/TP_Oracle_MySQL_Solutions.md (Analyse complète)"
echo ""
log_info "Bonne chance pour votre TP!"

# Rendre le script exécutable
chmod +x "${BASH_SOURCE[0]}"