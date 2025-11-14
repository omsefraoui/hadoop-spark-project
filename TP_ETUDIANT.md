# TP Big Data : Apache Spark, HBase et Hive
## École Nationale des Sciences Appliquées - Oujda (ENSAO)

---

## 📋 Informations Générales

**Durée** : 4 heures  
**Objectifs pédagogiques** :
- Maîtriser les opérations de base sur Apache Spark (RDD, DataFrame, SQL)
- Manipuler des bases de données NoSQL avec HBase
- Créer et interroger des entrepôts de données avec Hive
- Intégrer plusieurs technologies Big Data dans un workflow complet

**Prérequis** :
- Connaissances en Python
- Notions de SQL
- Docker installé sur votre machine

---

## 🚀 Installation et Démarrage

### Étape 1 : Récupérer le conteneur Docker

```bash
# Télécharger l'image
docker pull omsefraoui/hadoop-spark-cluster:latest

# Démarrer le conteneur
docker run -it --name bigdata-tp \
  -p 9870:9870 -p 8088:8088 -p 4040:4040 \
  -p 16010:16010 -p 10000:10000 -p 18080:18080 \
  omsefraoui/hadoop-spark-cluster:latest
```

### Étape 2 : Vérification des services

Attendez environ 2-3 minutes que tous les services démarrent. Vérifiez ensuite :

- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **Spark UI** : http://localhost:4040 (après lancement d'une application)
- **HBase Master** : http://localhost:16010
- **Spark History Server** : http://localhost:18080

### Étape 3 : Ouvrir un terminal interactif

```bash
# Dans un nouveau terminal Windows
docker exec -it bigdata-tp bash
```

---

## 📊 PARTIE 1 : Apache Spark (40 points)


### Exercice 1.1 : Manipulation de RDD (10 points)

**Contexte** : Vous disposez d'un fichier de logs web contenant des visites de sites.

**Données** : Créez le fichier `/data/web_logs.txt`

```bash
cd /data
cat > web_logs.txt << 'EOF'
2024-01-15 10:23:45,192.168.1.10,GET,/home,200
2024-01-15 10:24:12,192.168.1.20,GET,/products,200
2024-01-15 10:25:33,192.168.1.10,POST,/login,200
2024-01-15 10:26:01,192.168.1.30,GET,/about,404
2024-01-15 10:27:15,192.168.1.20,GET,/home,200
2024-01-15 10:28:40,192.168.1.40,GET,/products,500
2024-01-15 10:29:12,192.168.1.10,GET,/contact,200
2024-01-15 10:30:55,192.168.1.50,POST,/checkout,200
2024-01-15 10:31:20,192.168.1.30,GET,/home,200
2024-01-15 10:32:45,192.168.1.60,GET,/products,200
EOF
```

**Questions** :

1. Chargez le fichier dans un RDD et affichez les 3 premières lignes (2 pts)
2. Comptez le nombre total de requêtes (2 pts)
3. Filtrez les requêtes avec le code de statut 200 (2 pts)
4. Calculez le nombre de requêtes par page visitée (3 pts)
5. Trouvez l'adresse IP la plus active (1 pt)

**Code à compléter** :

```python
from pyspark import SparkContext

# Initialiser SparkContext
sc = SparkContext("local[*]", "WebLogsAnalysis")

# Question 1 : Charger et afficher
logs_rdd = sc.textFile("/data/web_logs.txt")
# VOTRE CODE ICI

# Question 2 : Compter
# VOTRE CODE ICI

# Question 3 : Filtrer les codes 200
# VOTRE CODE ICI

# Question 4 : Compter par page
# VOTRE CODE ICI

# Question 5 : IP la plus active
# VOTRE CODE ICI

sc.stop()
```

---

### Exercice 1.2 : DataFrame et Spark SQL (15 points)


**Contexte** : Simulation de streaming avec Spark Structured Streaming

**Questions** :

1. Créez un générateur de données simulant des capteurs IoT (3 pts)
2. Lisez les données en streaming depuis un répertoire (3 pts)
3. Calculez la température moyenne par capteur en temps réel (4 pts)
4. Détectez les alertes (température > 80°C) (3 pts)
5. Sauvegardez les résultats dans HDFS (2 pts)

**Code à compléter** :

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, window
from pyspark.sql.types import StructType, StructField, StringType, FloatType, TimestampType

spark = SparkSession.builder.appName("IoTStreaming").getOrCreate()

# Schéma des données IoT
schema = StructType([
    StructField("sensor_id", StringType(), True),
    StructField("temperature", FloatType(), True),
    StructField("timestamp", TimestampType(), True)
])

# Question 2 : Lire en streaming
# VOTRE CODE ICI

# Question 3 : Température moyenne
# VOTRE CODE ICI

# Question 4 : Alertes
# VOTRE CODE ICI

spark.stop()
```

---

## 🗄️ PARTIE 2 : Apache HBase (30 points)


### Exercice 2.1 : Création et manipulation de tables (15 points)

**Contexte** : Système de gestion d'utilisateurs d'un réseau social

**Questions** :

1. Créez une table `users` avec deux column families : `info` et `stats` (3 pts)
2. Insérez 5 utilisateurs avec leurs informations (nom, email, ville, âge) (4 pts)
3. Ajoutez les statistiques (nb_posts, nb_followers) pour chaque utilisateur (3 pts)
4. Récupérez toutes les informations d'un utilisateur spécifique (2 pts)
5. Scannez tous les utilisateurs d'une ville donnée (3 pts)

**Code à compléter (Python avec HappyBase)** :

```python
import happybase

# Connexion à HBase
connection = happybase.Connection('localhost')

# Question 1 : Créer la table
# VOTRE CODE ICI

# Question 2 : Insérer des utilisateurs
table = connection.table('users')
# VOTRE CODE ICI

# Question 3 : Ajouter les statistiques
# VOTRE CODE ICI

# Question 4 : Récupérer un utilisateur
# VOTRE CODE ICI

# Question 5 : Scanner par ville
# VOTRE CODE ICI

connection.close()
```

**Alternative Shell HBase** :

```bash
# Lancer le shell HBase
hbase shell

# Question 1 : Créer la table
# VOTRE CODE ICI

# Question 2 : Insérer des données
# VOTRE CODE ICI

# Lister toutes les tables
list

# Scanner la table
scan 'users'

# Quitter
exit
```

---

### Exercice 2.2 : Opérations avancées (15 points)


**Contexte** : Gestion des versions et filtres dans HBase

**Questions** :

1. Activez le versioning (3 versions max) sur la column family `stats` (3 pts)
2. Mettez à jour `nb_posts` plusieurs fois pour un utilisateur (2 pts)
3. Récupérez toutes les versions de `nb_posts` (3 pts)
4. Utilisez un filtre pour trouver les utilisateurs avec > 100 followers (4 pts)
5. Supprimez un utilisateur spécifique (3 pts)

**Code à compléter** :

```python
import happybase

connection = happybase.Connection('localhost')
table = connection.table('users')

# Question 1 : Configurer les versions (via shell HBase)
# alter 'users', {NAME => 'stats', VERSIONS => 3}

# Question 2 : Mettre à jour plusieurs fois
# VOTRE CODE ICI

# Question 3 : Récupérer les versions
# VOTRE CODE ICI

# Question 4 : Filtrer par nb_followers
# VOTRE CODE ICI

# Question 5 : Supprimer un utilisateur
# VOTRE CODE ICI

connection.close()
```

---

## 📊 PARTIE 3 : Apache Hive (30 points)

### Exercice 3.1 : Création d'entrepôt de données (15 points)

**Contexte** : Analyse des données de commandes e-commerce

**Questions** :

1. Créez une base de données `ecommerce` (2 pts)
2. Créez une table externe `orders` pointant vers `/data/sales.csv` (4 pts)
3. Créez une table partitionnée `orders_by_date` (par année et mois) (4 pts)
4. Chargez les données depuis la table externe vers la table partitionnée (3 pts)
5. Calculez le revenu total par partition (2 pts)

**Code à compléter (Beeline)** :

```bash
# Lancer Beeline
beeline -u jdbc:hive2://localhost:10000

# Question 1 : Créer la base de données
# VOTRE CODE ICI

# Question 2 : Créer la table externe
