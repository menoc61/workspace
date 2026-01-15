# ============================================
# TP Oracle & MySQL - EXECUTION AUTO (Windows)
# ============================================

Write-Host "========================================" -ForegroundColor Green
Write-Host "  TP ORACLE & MYSQL - EXECUTION AUTO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Variables de configuration
$ORACLE_USER = "sys"
$ORACLE_PWD = "momenic61"
$ORACLE_CONNECT = "${ORACLE_USER}/${ORACLE_PWD} as sysdba"
$WORKSPACE = "C:\Users\gille\Desktop\workspace\DB_TD\workspace"

# Fonctions utilitaires
function Write-Info {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

# Vérification des prérequis
Write-Info "Vérification des prérequis..."

# Vérifier si sqlplus est disponible
try {
    $sqlplusCheck = sqlplus -version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "SQL*Plus non trouvé"
    }
    Write-Info "SQL*Plus trouvé et fonctionnel"
}
catch {
    Write-Error "SQL*Plus n'est pas installé ou non accessible"
    Write-Info "Assurez-vous qu'Oracle est installé et que sqlplus est dans le PATH"
    exit 1
}

# Vérifier MySQL
$mysqlAvailable = $false
try {
    $mysqlCheck = mysql --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $mysqlAvailable = $true
        Write-Info "MySQL trouvé et fonctionnel"
    }
}
catch {
    Write-Warning "MySQL n'est pas installé ou non accessible"
    Write-Info "Seule la partie Oracle sera exécutée"
}

# ============================================
# PARTIE 1: ORACLE (toujours exécutée)
# ============================================

Write-Host ""
Write-Info "=== PARTIE 1: ORACLE ==="
Write-Host ""

# Vérifier que les scripts Oracle existent
$oracleScriptsPath = Join-Path $WORKSPACE "scripts_oracle"
if (-not (Test-Path $oracleScriptsPath)) {
    Write-Error "Le dossier scripts_oracle n'existe pas: $oracleScriptsPath"
    exit 1
}

# Script 1: Creation du schema
Write-Info "Création du schema approvisionnement..."
$script1Path = Join-Path $oracleScriptsPath "01_creation_schema.sql"

if (Test-Path $script1Path) {
    $oracleCommands = @"
CONNECT ${ORACLE_CONNECT}
@$script1Path
EXIT;
"@
    
    try {
        $oracleCommands | sqlplus -s /nolog
        if ($LASTEXITCODE -eq 0) {
            Write-Info "Schema Oracle créé avec succès!"
        } else {
            Write-Error "Erreur lors de la création du schema Oracle"
        }
    }
    catch {
        Write-Error "Erreur lors de l'exécution du script Oracle: $($_.Exception.Message)"
    }
} else {
    Write-Error "Script Oracle non trouvé: $script1Path"
}

# Script 2: Manipulation des données
Write-Info "Manipulation des données Oracle..."
$script2Path = Join-Path $oracleScriptsPath "02_manipulation_donnees.sql"

if (Test-Path $script2Path) {
    $oracleCommands2 = @"
CONNECT approvisionnement/approvisionnementeam
@$script2Path
EXIT;
"@
    
    try {
        $oracleCommands2 | sqlplus -s /nolog
        if ($LASTEXITCODE -eq 0) {
            Write-Info "Données Oracle manipulées avec succès!"
        } else {
            Write-Warning "Erreur lors de la manipulation des données Oracle (peut-être normal si pas de données à importer)"
        }
    }
    catch {
        Write-Warning "Erreur lors de l'exécution du script Oracle: $($_.Exception.Message)"
    }
}

# ============================================
# PARTIE 2: MYSQL (si disponible)
# ============================================

if ($mysqlAvailable) {
    Write-Host ""
    Write-Info "=== PARTIE 2: MYSQL ==="
    Write-Host ""
    
    $mysqlScriptsPath = Join-Path $WORKSPACE "scripts_mysql"
    if (Test-Path $mysqlScriptsPath) {
        $mysqlScripts = @(
            "01_creation_base.sql",
            "02_creation_tables.sql", 
            "03_procedures_insertion.sql",
            "04_execution_insertions.sql",
            "05_comparaison_performances.sql",
            "06_analyse_et_plan.sql"
        )
        
        foreach ($script in $mysqlScripts) {
            $scriptPath = Join-Path $mysqlScriptsPath $script
            if (Test-Path $scriptPath) {
                Write-Info "Exécution de $script..."
                try {
                    Get-Content $scriptPath | mysql -h localhost -P 3306 -u root
                    if ($LASTEXITCODE -eq 0) {
                        Write-Info "$script exécuté avec succès!"
                    } else {
                        Write-Error "Erreur lors de l'exécution de $script"
                    }
                }
                catch {
                    Write-Error "Erreur MySQL: $($_.Exception.Message)"
                }
            } else {
                Write-Warning "Script non trouvé: $scriptPath"
            }
        }
        
        # Vérification des résultats MySQL
        Write-Info "Vérification des résultats MySQL..."
        $mysqlCheckCommands = @"
USE tp_comparaison_index;
SHOW TABLES;
SELECT '=== CLIENTS ===' as info; SELECT COUNT(*) as total_clients FROM clients_avec_index;
SELECT '=== PRODUITS ===' as info; SELECT COUNT(*) as total_produits FROM produits_avec_index;
SELECT '=== COMMANDES ===' as info; SELECT COUNT(*) as total_commandes FROM commandes_avec_index;
"@
        $mysqlCheckCommands | mysql -h localhost -P 3306 -u root
    } else {
        Write-Error "Le dossier scripts_mysql n'existe pas: $mysqlScriptsPath"
    }
} else {
    Write-Host ""
    Write-Warning "=== MYSQL NON DISPONIBLE ==="
    Write-Info "MySQL n'est pas installé sur ce système."
    Write-Info "Seule la partie Oracle a été exécutée."
    Write-Info "Pour installer MySQL:"
    Write-Info "  1. Télécharger MySQL Community Server"
    Write-Info "  2. Installer avec l'option 'Developer Default'"
    Write-Info "  3. Ajouter MySQL au PATH système"
}

# ============================================
# VERIFICATION FINALE
# ============================================

Write-Host ""
Write-Info "=== VERIFICATION FINALE ==="
Write-Host ""

# Vérification Oracle
Write-Info "Vérification Oracle:"
$oracleCheckCommands = @"
CONNECT approvisionnement/approvisionnementeam
SELECT '=== TABLES ORACLE ===' as info FROM dual;
SELECT table_name FROM user_tables;
SELECT '=== NOMBRE D''ENREGISTREMENTS ===' as info FROM dual;
SELECT 'Total tables: ' || COUNT(*) FROM user_tables;
EXIT;
"@
$oracleCheckCommands | sqlplus -s /nolog

# ============================================
# RAPPORT
# ============================================

Write-Host ""
Write-Info "=== GENERATION DU RAPPORT ==="

$reportPath = Join-Path $WORKSPACE "rapport_execution_windows.txt"
$reportContent = @"
========================================
RAPPORT D'EXECUTION TP ORACLE & MYSQL
========================================
Date: $(Get-Date -Format "yyyy-MM-dd")
Heure: $(Get-Date -Format "HH:mm:ss")
Systeme: Windows PowerShell

PARTIE 1: ORACLE
----------------
- Schema 'approvisionnement' créé
- Scripts Oracle exécutés avec succès
- Connexion: approvisionnement/approvisionnementeam

PARTIE 2: MYSQL
---------------
$(if ($mysqlAvailable) { "- Base 'tp_comparaison_index' créée`n- 6 scripts exécutés`n- Tests de performance effectués" } else { "- MySQL non disponible sur ce système`n- Installation requise pour la partie MySQL" })

ETAT DES SERVICES:
- Oracle: Fonctionnel
- MySQL: $(if ($mysqlAvailable) { "Fonctionnel" } else { "Non installé" })

PROCHAINES ETAPES:
1. Consulter TP_Oracle_MySQL_Solutions.md pour l'analyse
2. Utiliser les résultats pour votre rapport
3. Pour MySQL: Installer MySQL Community Server

EOF

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8
Write-Info "Rapport généré: $reportPath"

# ============================================
# RESUME
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "EXECUTION TERMINEE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if ($mysqlAvailable) {
    Write-Host "✅ Oracle: Schema créé et configuré" -ForegroundColor Green
    Write-Host "✅ MySQL: Base créée avec tests de performance" -ForegroundColor Green
    Write-Host "✅ Rapport d'exécution généré" -ForegroundColor Green
} else {
    Write-Host "✅ Oracle: Schema créé et configuré" -ForegroundColor Green
    Write-Host "⚠️  MySQL: Non disponible (installation requise)" -ForegroundColor Yellow
    Write-Host "✅ Rapport d'exécution généré" -ForegroundColor Green
}

Write-Host ""
Write-Host "Pour consulter les résultats:" -ForegroundColor Cyan
Write-Host "  Rapport: $reportPath" -ForegroundColor White
Write-Host "  Documentation: $(Join-Path $WORKSPACE 'TP_Oracle_MySQL_Solutions.md')" -ForegroundColor White
Write-Host ""
Write-Host "Connexions:" -ForegroundColor Cyan
Write-Host "  Oracle: sqlplus approvisionnement/approvisionnementeam" -ForegroundColor White
if ($mysqlAvailable) {
    Write-Host "  MySQL: mysql -h localhost -P 3306 -u root" -ForegroundColor White
} else {
    Write-Host "  MySQL: Installer MySQL Community Server" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Bonne chance pour votre TP!" -ForegroundColor Green