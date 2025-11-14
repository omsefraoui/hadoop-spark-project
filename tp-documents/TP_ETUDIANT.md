# TP2 : Big Data avec Spark, HBase et Hive
## Guide Étudiant

**École Nationale des Sciences Appliquées d'Oujda (ENSAO)**  
**Durée** : 3 heures  
**Objectifs** : Maîtriser les opérations de base sur Spark, HBase et Hive

---

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Démarrage de l'environnement](#démarrage)
3. [Partie 1 : Apache Spark (1h)](#partie-1-spark)
4. [Partie 2 : Apache HBase (1h)](#partie-2-hbase)
5. [Partie 3 : Apache Hive (1h)](#partie-3-hive)
6. [Rendu](#rendu)

---

## 🎯 Prérequis

### Connaissances requises
- Programmation Python de base
- Concepts SQL
- Notions de Big Data (vu en cours)

### Installation

**Sous Windows :**
```powershell
# 1. Cloner le dépôt
git clone https://github.com/omsefraoui/hadoop-spark-project.git
cd hadoop-spark-project

# 2. Démarrer le conteneur
docker-compose up -d

# 3. Accéder au conteneur
docker exec -it hadoop-master bash
```

**Sous Linux/Mac :**
```bash
# Même chose
docker-compose up -d
docker exec -it hadoop-master bash
```

---

## 🚀 Démarrage de l'environnement {#démarrage}

Une fois dans le conteneur, vérifiez que tous les services sont démarrés :

```bash
# Vérifier les services
jps

# Vous devriez voir : NameNode, DataNode, HMaster, HRegionServer, etc.
```

**URLs des interfaces Web :**
- HDFS NameNode : http://localhost:9870
- YARN ResourceManager : http://localhost:8088
- Spark History : http://localhost:18080
- HBase Master : http://localhost:16010

---

## 📊 Partie 1 : Apache Spark (1h) {#partie-1-spark}

### Objectifs
- Manipuler des RDDs
- Utiliser les DataFrames
- Exécuter des requêtes Spark SQL
- Intégrer Spark avec HDFS

### Exercice 1.1 : Premier programme Spark (15 min)

**Contexte :** Vous allez créer votre premier programme PySpark pour analyser des données.

**Créez le fichier** `ex1_spark_intro.py` :

```python
from pyspark.sql import SparkSession

# Créer une session Spark
spark = SparkSession.builder \
    .appName("Exercice 1.1") \
    .master("local[*]") \
    .getOrCreate()

# Créer un RDD simple
data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
rdd = spark.sparkContext.parallelize(data)

# TODO 1: Calculer la somme de tous les nombres
total = rdd.reduce(lambda a, b: a + b)
print(f"Somme : {total}")

# TODO 2: Filtrer les nombres pairs
pairs = rdd.filter(lambda x: x % 2 == 0)
print(f"Nombres pairs : {pairs.collect()}")

# TODO 3: Calculer le carré de chaque nombre
squares = rdd.map(lambda x: x ** 2)
print(f"Carrés : {squares.collect()}")

# TODO 4: Calculer la moyenne
count = rdd.count()
average = total / count
print(f"Moyenne : {average}")

spark.stop()
```

**Exécutez :**
```bash
python3 ex1_spark_intro.py
```

**Questions (à inclure dans votre rapport) :**
1. Quelle est la différence entre `map()` et `filter()` ?
2. Pourquoi utilise-t-on `collect()` ?
3. Que fait la fonction `reduce()` ?

---

### Exercice 1.2 : DataFrames et Analyse de Données (25 min)

**Contexte :** Analyse des ventes d'une entreprise.

**Créez le fichier de données** `ventes.csv` :
```csv
produit,quantite,prix,region
Ordinateur,10,800,Nord
Telephone,25,300,Sud
Tablette,15,400,Est
Ordinateur,8,800,Sud
Telephone,30,300,Nord
Tablette,20,400,Ouest
Ordinateur,12,800,Est
```

**Créez** `ex2_spark_dataframe.py` :

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sum, avg

spark = SparkSession.builder.appName("Ventes").getOrCreate()
df = spark.read.csv("ventes.csv", header=True, inferSchema=True)

# TODO 1: Afficher le schéma
df.printSchema()
df.show()

# TODO 2: CA par produit
ca_produit = df.groupBy("produit").agg(sum(col("quantite") * col("prix")).alias("CA"))
ca_produit.show()

# TODO 3: Meilleure région
df.groupBy("region").agg(sum("quantite").alias("total")).orderBy(col("total").desc()).show()

spark.stop()
```

**Questions :**
1. Quel produit génère le plus de CA ?
2. Quelle région achète le plus ?

---

### Exercice 1.3 : Spark SQL (20 min)

**Créez** `ex3_spark_sql.py` :

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("SQL").getOrCreate()
df = spark.read.csv("ventes.csv", header=True, inferSchema=True)

# Créer une vue temporaire
df.createOrReplaceTempView("ventes")

# TODO 1: Requête SQL - CA total
