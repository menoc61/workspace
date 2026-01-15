# TP Oracle & MySQL - Guide d'Utilisation

## Configuration utilisee

### MySQL
- **Hote**: localhost
- **Port**: 3306
- **Utilisateur**: root
- **Mot de passe**: (aucun - vide)
- **Nombre d'enregistrements**: 25

### Oracle
- **Utilisateur**: sys as sysdba
- **Mot de passe**: momenic61

## Structure des fichiers

```
/workspace/
├── TP_Oracle_MySQL_Solutions.md    # Document complet avec toutes les commandes
├── README.md                        # Ce fichier
├── EXECUTION_RAPIDE.sh             # Script d'information
├── comparaison_performances.png    # Graphique de comparaison
├── scripts_mysql/
│   ├── 01_creation_base.sql        # Creation de la base de donnees
│   ├── 02_creation_tables.sql      # Creation des tables (avec/sans index)
│   ├── 03_procedures_insertion.sql # Procedures d'insertion
│   ├── 04_execution_insertions.sql # Execution avec mesure du temps
│   ├── 05_comparaison_performances.sql # Tests de performance
│   ├── 06_analyse_et_plan.sql      # Analyse et plans d'execution
│   └── 07_script_rapide.sh         # Script bash pour execution automatique
└── scripts_oracle/
    ├── 01_creation_schema.sql      # Creation du schema approvisionnement
    └── 02_manipulation_donnees.sql # Manipulation des donnees Oracle
```

---

## PARTIE 1: ORACLE (Schema Approvisionnement)

### Methode 1: Ligne de commande SQL*Plus

```bash
# 1. Lancer SQL*Plus avec connexion sysdba
sqlplus sys/momenic61 as sysdba

# 2. Executer le script de creation du schema
@/workspace/scripts_oracle/01_creation_schema.sql

# 3. Se deconnecter et se reconnecter avec le nouveau schema
CONNECT approvisionnement/approvisionnementeam

# 4. Executer le script de manipulation des donnees
@/workspace/scripts_oracle/02_manipulation_donnees.sql
```

### Methode 2: Connexion avec TNS

```bash
# Si vous avez un fichier tnsnames.ora configure
sqlplus sys/momenic61@//localhost:1521/xe as sysdba
```

---

## PARTIE 2: MYSQL (Comparaison Index)

### Methode 1: Execution automatique (Recommande)

```bash
# Rendre le script executable
chmod +x /workspace/scripts_mysql/07_script_rapide.sh

# Executer le script automatique
./workspace/scripts_mysql/07_script_rapide.sh
```

### Methode 2: Execution manuelle ligne de commande

```bash
# Connexion MySQL
mysql -h localhost -P 3306 -u root

# Puis executer les scripts dans l'ordre:
source /workspace/scripts_mysql/01_creation_base.sql
source /workspace/scripts_mysql/02_creation_tables.sql
source /workspace/scripts_mysql/03_procedures_insertion.sql
source /workspace/scripts_mysql/04_execution_insertions.sql
source /workspace/scripts_mysql/05_comparaison_performances.sql
source /workspace/scripts_mysql/06_analyse_et_plan.sql
```

### Methode 3: Execution depuis le repertoire scripts_mysql

```bash
cd /workspace/scripts_mysql
mysql -h localhost -P 3306 -u root < 01_creation_base.sql
mysql -h localhost -P 3306 -u root < 02_creation_tables.sql
mysql -h localhost -P 3306 -u root < 03_procedures_insertion.sql
mysql -h localhost -P 3306 -u root < 04_execution_insertions.sql
mysql -h localhost -P 3306 -u root < 05_comparaison_performances.sql
mysql -h localhost -P 3306 -u root < 06_analyse_et_plan.sql
```

### Methode 4: Copier-Coller

Ouvrir le fichier `/workspace/TP_Oracle_MySQL_Solutions.md` et copier-coller les commandes directement dans MySQL.

---

## Resultats attendus

### Oracle
- Schema `approvisionnement` cree
- Donnees du schema `vente` importees (si disponible)
- Vues et procedures crees

### MySQL
- Base de donnees `tp_comparaison_index` creee
- 6 tables creees (3 avec index, 3 sans)
- 75 enregistrements inseres (25 clients, 25 produits, 25 commandes)
- 8 tests de performance executes
- Tableau comparatif genere

---

## Tests de performance MySQL

Les tests comparent les operations suivantes:

1. **SELECT simple avec WHERE** - Recherche par nom
2. **Recherche par ville** - Count avec condition sur ville
3. **Jointure clients-commandes** - JOIN avec agregation
4. **Aggregation par categorie** - GROUP BY avec COUNT et AVG
5. **Requete complexe avec sous-requete** - EXISTS et sous-requete correlee
6. **Tri sur plusieurs colonnes** - ORDER BY multi-colonnes
7. **Mise a jour massive** - UPDATE avec condition range
8. **Suppression avec condition** - DELETE avec condition

---

## Interpretation des resultats

### Les index ameliorent:
- **SELECT**: Recherche optimisee (souvent 50-90% plus rapide)
- **JOIN**: Performance significative sur les jointures
- **WHERE**: Condition de recherche acceleree
- **ORDER BY**: Tri accelere

### Les index ralentissent legerement:
- **INSERT**: Verification des index
- **UPDATE**: Mise a jour des index
- **DELETE**: Suppression dans les index

**Note**: Avec seulement 25 enregistrements, les differences seront minimes car les tables sont trop petites pour que les index demontrent leur efficacite complete.

---

## Commandes utiles

### MySQL
```bash
# Connexion
mysql -h localhost -P 3306 -u root

# Voir les bases
SHOW DATABASES;

# Utiliser une base
USE tp_comparaison_index;

# Voir les tables
SHOW TABLES;

# Voir la structure
DESCRIBE nom_table;

# Voir les index
SHOW INDEX FROM nom_table;

# Plan d'execution
EXPLAIN SELECT ...;

# Profiling
SET profiling = 1;
SHOW PROFILES;

# Quitter
EXIT;
```

### Oracle SQL*Plus
```bash
# Lancer
sqlplus sys/momenic61 as sysdba

# Connexion standard
CONNECT approvisionnement/approvisionnementeam

# Executer un script
@/workspace/scripts_oracle/02_manipulation_donnees.sql

# Voir les tables
SELECT table_name FROM user_tables;

# Quitter
EXIT;
```

---

## Depannage

### MySQL
```bash
# Verifier si le service est demarre (Linux)
sudo systemctl status mysql

# Demarrer le service (Linux)
sudo systemctl start mysql

# Verifier le port
netstat -tlnp | grep 3306

# Erreur de connexion
# Verifier les identifiants et le service
mysql -h localhost -P 3306 -u root -e "SELECT 1"

# Si erreur "Access denied"
# Verifier les privileges
sudo mysql -u root
```

### Oracle
```bash
# Verifier le listener (si installe)
lsnrctl status

# Connexion sans listener (Oracle Express)
sqlplus sys/momenic61 as sysdba

# ORA-12541: TNS:no listener
# Le listener n'est peut-etre pas necessaire pour Oracle Express

# ORA-01034: ORACLE not available
sqlplus / as sysdba
STARTUP

# ORA-01017: invalid username/password
# Verifier les identifiants: sys/momenic61 as sysdba
```

---

## Notes importantes

1. **MySQL**: Avec root sans mot de passe, assurez-vous que l'acces est autorise
2. **Oracle**: Utilisez `sys/momenic61 as sysdba` pour la connexion admin
3. **Donnees**: Avec 25 enregistrements, les tests seront tres rapides
4. **Resultats**: Les gains seront minimes avec peu de donnees (c'est normal)

---

## Pour le rapport TP

Structure suggeree:

1. **Introduction**: Objectif du TP - comparaison des performances avec/sans index
2. **Configuration**: Decrire l'environnement de test (localhost, ports, identifiants)
3. **Partie Oracle**: Creation du schema approvisionnement
4. **Partie MySQL**: Comparaison des performances avec 25 enregistrements
5. **Resultats**: Tableaux comparatifs avec temps d'execution
6. **Analyse**: Interpretation des gains/pertes (meme minimes avec peu de donnees)
7. **Conclusion**: Importance des index pour les bases de donnees volumineuses

---

**Bon courage pour votre TP !**
> on window using *ps1* try : 
powershell```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\EXECUTION_AUTO_WINDOWS.ps1
```

>Note: change and ajust `WORKSPACE="/c/Users/gille/Desktop/workspace/DB_TD/workspace"` in *EXECUTION_RAPIDE.sh*