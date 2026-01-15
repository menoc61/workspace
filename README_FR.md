# TP Oracle & MySQL - Guide d'Utilisation

## 📚 Structure des fichiers

```
/workspace/
├── TP_Oracle_MySQL_Solutions.md    # Document complet avec toutes les commandes
├── README.md                        # Ce fichier
├── EXECUTION_RAPIDE.sh             # Script d'information
├── comparaison_performances.png    # Graphique de comparaison
├── scripts_mysql/
│   ├── 01_creation_base.sql        # Création de la base de données
│   ├── 02_creation_tables.sql      # Création des tables (avec/sans index)
│   ├── 03_procedures_insertion.sql # Procédures d'insertion
│   ├── 04_execution_insertions.sql # Exécution avec mesure du temps
│   ├── 05_comparaison_performances.sql # Tests de performance
│   ├── 06_analyse_et_plan.sql      # Analyse et plans d'exécution
│   └── 07_script_rapide.sh         # Script bash pour exécution automatique
└── scripts_oracle/
    ├── 01_creation_schema.sql      # Création du schéma approvisionnement
    └── 02_manipulation_donnees.sql # Manipulation des données Oracle
```

---

## 🔧 Configuration utilisée

### MySQL
- **Hôte**: localhost
- **Port**: 3306
- **Utilisateur**: root
- **Mot de passe**: (aucun - vide)
- **Nombre d'enregistrements**: 25

### Oracle
- **Utilisateur**: sys as sysdba
- **Mot de passe**: momenic61

---

## 🚀 PARTIE 1: ORACLE (Schéma Approvisionnement)

### Méthode 1: Ligne de commande SQL*Plus

```bash
# 1. Lancer SQL*Plus avec connexion sysdba
sqlplus sys/momenic61 as sysdba

# 2. Exécuter le script de création du schéma
@/workspace/scripts_oracle/01_creation_schema.sql

# 3. Se déconnecter et se reconnecter avec le nouveau schéma
CONNECT approvisionnement/approvisionnementeam

# 4. Exécuter le script de manipulation des données
@/workspace/scripts_oracle/02_manipulation_donnees.sql
```

### Méthode 2: Connexion avec TNS

```bash
# Si vous avez un fichier tnsnames.ora configuré
sqlplus sys/momenic61@//localhost:1521/xe as sysdba
```

---

## 🗄️ PARTIE 2: MYSQL (Comparaison Index)

### Méthode 1: Exécution automatique (Recommandé)

```bash
# Rendre le script exécutable
chmod +x /workspace/scripts_mysql/07_script_rapide.sh

# Exécuter le script automatique
./workspace/scripts_mysql/07_script_rapide.sh
```

### Méthode 2: Exécution manuelle ligne de commande

```bash
# Connexion MySQL
mysql -h localhost -P 3306 -u root

# Puis exécuter les scripts dans l'ordre:
source /workspace/scripts_mysql/01_creation_base.sql
source /workspace/scripts_mysql/02_creation_tables.sql
source /workspace/scripts_mysql/03_procedures_insertion.sql
source /workspace/scripts_mysql/04_execution_insertions.sql
source /workspace/scripts_mysql/05_comparaison_performances.sql
source /workspace/scripts_mysql/06_analyse_et_plan.sql
```

### Méthode 3: Exécution depuis le répertoire scripts_mysql

```bash
cd /workspace/scripts_mysql
mysql -h localhost -P 3306 -u root < 01_creation_base.sql
mysql -h localhost -P 3306 -u root < 02_creation_tables.sql
mysql -h localhost -P 3306 -u root < 03_procedures_insertion.sql
mysql -h localhost -P 3306 -u root < 04_execution_insertions.sql
mysql -h localhost -P 3306 -u root < 05_comparaison_performances.sql
mysql -h localhost -P 3306 -u root < 06_analyse_et_plan.sql
```

### Méthode 4: Copier-Coller

Ouvrir le fichier `/workspace/TP_Oracle_MySQL_Solutions.md` et copier-coller les commandes directement dans MySQL.

---

## 📊 Résultats attendus

### Oracle
- Schéma `approvisionnement` créé
- Données du schéma `vente` importées (si disponible)
- Vues et procédures créées

### MySQL
- Base de données `tp_comparaison_index` créée
- 6 tables créées (3 avec index, 3 sans)
- 75 enregistrements insérés (25 clients, 25 produits, 25 commandes)
- 8 tests de performance exécutés
- Tableau comparatif généré

---

## 🎯 Tests de performance MySQL

Les tests comparent les opérations suivantes:

1. **SELECT simple avec WHERE** - Recherche par nom
2. **Recherche par ville** - Count avec condition sur ville
3. **Jointure clients-commandes** - JOIN avec agrégation
4. **Agrégation par catégorie** - GROUP BY avec COUNT et AVG
5. **Requête complexe avec sous-requête** - EXISTS et sous-requête corrélée
6. **Tri sur plusieurs colonnes** - ORDER BY multi-colonnes
7. **Mise à jour massive** - UPDATE avec condition range
8. **Suppression avec condition** - DELETE avec condition

---

## 📈 Interprétation des résultats

### Les index améliorent:
- **SELECT**: Recherche optimisée (souvent 50-90% plus rapide)
- **JOIN**: Performance significative sur les jointures
- **WHERE**: Condition de recherche accélérée
- **ORDER BY**: Tri accéléré

### Les index ralentissent légèrement:
- **INSERT**: Vérification des index
- **UPDATE**: Mise à jour des index
- **DELETE**: Suppression dans les index

**Note**: Avec seulement 25 enregistrements, les différences seront minimes car les tables sont trop petites pour que les index démontrent leur efficacité complète.

---

## 💡 Commandes utiles

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

# Plan d'exécution
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

# Exécuter un script
@/workspace/scripts_oracle/02_manipulation_donnees.sql

# Voir les tables
SELECT table_name FROM user_tables;

# Quitter
EXIT;
```

---

## 🔧 Dépannage

### MySQL
```bash
# Vérifier si le service est démarré (Linux)
sudo systemctl status mysql

# Démarrer le service (Linux)
sudo systemctl start mysql

# Vérifier le port
netstat -tlnp | grep 3306

# Erreur de connexion
# Vérifier les identifiants et le service
mysql -h localhost -P 3306 -u root -e "SELECT 1"

# Si erreur "Access denied"
# Vérifier les privileges
sudo mysql -u root
```

### Oracle
```bash
# Vérifier le listener (si installé)
lsnrctl status

# Connexion sans listener (Oracle Express)
sqlplus sys/momenic61 as sysdba

# ORA-12541: TNS:no listener
# Le listener n'est peut-être pas nécessaire pour Oracle Express

# ORA-01034: ORACLE not available
sqlplus / as sysdba
STARTUP

# ORA-01017: invalid username/password
# Vérifier les identifiants: sys/momenic61 as sysdba
```

---

## 📝 Notes importantes

1. **MySQL**: Avec root sans mot de passe, assurez-vous que l'accès est autorisé
2. **Oracle**: Utilisez `sys/momenic61 as sysdba` pour la connexion admin
3. **Données**: Avec 25 enregistrements, les tests seront très rapides
4. **Résultats**: Les gains seront minimes avec peu de données (c'est normal)

---

## 🎓 Pour le rapport TP

Structure suggérée:

1. **Introduction**: Objectif du TP - comparaison des performances avec/sans index
2. **Configuration**: Décrire l'environnement de test (localhost, ports, identifiants)
3. **Partie Oracle**: Création du schéma approvisionnement
4. **Partie MySQL**: Comparaison des performances avec 25 enregistrements
5. **Résultats**: Tableaux comparatifs avec temps d'exécution
6. **Analyse**: Interprétation des gains/pertes (même minimes avec peu de données)
7. **Conclusion**: Importance des index pour les bases de données volumineuses

---

**Bon courage pour votre TP ! 🚀**
