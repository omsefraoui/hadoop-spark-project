# TP Big Data : Apache Spark, HBase et Hive
## Manuel Étudiant

---

### 📋 **Informations Générales**

**Durée :** 4 heures  
**Objectifs :**
- Maîtriser les opérations de base avec Apache Spark (PySpark)
- Manipuler des données NoSQL avec HBase
- Créer et interroger des entrepôts de données avec Hive
- Intégrer les trois technologies dans un workflow Big Data

**Prérequis :**
- Connaissances en Python
- Notions de bases de données
- Docker installé sur votre machine

---

## 🚀 **Partie 0 : Installation et Vérification**

### 0.1 Démarrage du Conteneur

Ouvrez un terminal et exécutez :

```bash
cd C:\Users\Minfo\hadoop-spark-project
docker-compose up -d
```

Attendez 2-3 minutes que tous les services démarrent.

### 0.2 Connexion au Conteneur

```bash
docker exec -it hadoop-master bash
```

### 0.3 Vérification des Services

Vérifiez que tous les services sont actifs :

```bash
# Vérifier HDFS
hdfs dfs -ls /

# Vérifier Spark
spark-submit --version

# Vérifier HBase
echo "status" | hbase shell

# Vérifier Hive
hive --version
```

### 0.4 Interfaces Web

Ouvrez dans votre navigateur :
- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **Spark History Server** : http://localhost:18080
- **HBase Master** : http://localhost:16010

---

## 📊 **Partie 1 : Apache Spark**

### 1.1 Introduction à PySpark

Apache Spark est un moteur de traitement de données distribué ultra-rapide.

#### Exercice 1.1 : Premier Programme PySpark

Créez un fichier `exercice1_spark_intro.py` :

```python
from pyspark.sql import SparkSession

# Créer une session Spark
spark = SparkSession.builder \
    .appName("Exercice1_Intro") \
    .getOrCreate()

# Créer un DataFrame simple
data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
columns = ["nom", "age"]

df = spark.createDataFrame(data, columns)

# Afficher le DataFrame
df.show()

# Afficher le schéma
df.printSchema()

# Arrêter la session
spark.stop()
```

**Exécutez :**
```bash
spark-submit exercice1_spark_intro.py
```

**Questions :**
1. Combien de lignes contient le DataFrame ?
2. Quels sont les types de colonnes ?
3. Modifiez le code pour ajouter une colonne "ville"

---

### 1.2 Chargement de Données depuis HDFS

#### Exercice 1.2 : Lecture de Fichiers CSV

D'abord, créez un fichier CSV et uploadez-le dans HDFS :

```bash
# Créer un fichier employes.csv
cat > /tmp/employes.csv << EOF
id,nom,age,departement,salaire
1,Ahmed,28,IT,45000
2,Fatima,32,RH,42000
3,Mohammed,35,IT,55000
4,Aicha,29,Finance,48000
5,Youssef,40,IT,60000
6,Khadija,27,RH,40000
7,Hassan,33,Finance,52000
8,Nadia,31,IT,50000
EOF

# Copier dans HDFS
hdfs dfs -mkdir -p /data
hdfs dfs -put /tmp/employes.csv /data/
```

Créez `exercice2_spark_csv.py` :

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count

spark = SparkSession.builder \
    .appName("Exercice2_CSV") \
    .getOrCreate()

# Lire le CSV depuis HDFS
df = spark.read.csv("hdfs://localhost:9000/data/employes.csv", 
                    header=True, 
                    inferSchema=True)

print("=== Aperçu des données ===")
df.show()

print("\n=== Statistiques par département ===")
df.groupBy("departement") \
    .agg(
        count("*").alias("nombre_employes"),
        avg("salaire").alias("salaire_moyen")
    ) \
    .show()

spark.stop()
```

**Questions :**
1. Quel département a le salaire moyen le plus élevé ?
2. Combien d'employés travaillent en IT ?
3. Modifiez pour filtrer les employés avec salaire > 45000

---

### 1.3 Transformations et Actions

#### Exercice 1.3 : Analyse Avancée

Créez `exercice3_spark_transformations.py` :

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, avg

spark = SparkSession.builder \
    .appName("Exercice3_Transformations") \
    .getOrCreate()

df = spark.read.csv("hdfs://localhost:9000/data/employes.csv", 
                    header=True, inferSchema=True)

# Transformation 1 : Ajouter une colonne "categorie_salaire"
df_avec_categorie = df.withColumn(
    "categorie_salaire",
    when(col("salaire") < 45000, "Junior")
    .when((col("salaire") >= 45000) & (col("salaire") < 55000), "Confirmé")
    .otherwise("Senior")
)

print("=== Employés avec catégories ===")
df_avec_categorie.show()

# Transformation 2 : Filtrer et trier
df_it_seniors = df_avec_categorie \
    .filter((col("departement") == "IT") & (col("categorie_salaire") == "Senior")) \
    .orderBy(col("salaire").desc())

print("\n=== Seniors IT triés par salaire ===")
df_it_seniors.show()

# Action : Compter
nombre_seniors = df_avec_categorie \
    .filter(col("categorie_salaire") == "Senior") \
    .count()

print(f"\nNombre total de seniors : {nombre_seniors}")

spark.stop()
```

**Questions :**
1. Combien y a-t-il d'employés "Senior" ?
2. Quel est le salaire du Senior IT le mieux payé ?
3. Ajoutez une transformation pour calculer une augmentation de 10%

---

### 1.4 Spark SQL

#### Exercice 1.4 : Requêtes SQL sur DataFrames

Créez `exercice4_spark_sql.py` :

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Exercice4_SparkSQL") \
    .getOrCreate()

df = spark.read.csv("hdfs://localhost:9000/data/employes.csv", 
                    header=True, inferSchema=True)

# Créer une vue temporaire
df.createOrReplaceTempView("employes")

# Requête SQL 1 : Sélection simple
print("=== Employés IT ===")
spark.sql("""
    SELECT nom, age, salaire 
    FROM employes 
    WHERE departement = 'IT'
    ORDER BY salaire DESC
""").show()

# Requête SQL 2 : Agrégation
print("\n=== Statistiques par département ===")
spark.sql("""
    SELECT 
        departement,
        COUNT(*) as nombre,
        AVG(salaire) as salaire_moyen,
        MAX(salaire) as salaire_max,
        MIN(salaire) as salaire_min
    FROM employes
    GROUP BY departement
    ORDER BY salaire_moyen DESC
""").show()

# Requête SQL 3 : Jointure (auto-jointure pour exemple)
print("\n=== Collègues du même département ===")
spark.sql("""
    SELECT DISTINCT e1.nom as employe1, e2.nom as employe2, e1.departement
    FROM employes e1
    JOIN employes e2 ON e1.departement = e2.departement
    WHERE e1.id < e2.id
    LIMIT 5
""").show()

spark.stop()
```

**Questions :**
1. Écrivez une requête SQL pour trouver l'employé le plus jeune
2. Calculez la masse salariale totale par département
3. Trouvez les employés dont le salaire est supérieur à la moyenne

---

## 🗄️ **Partie 2 : HBase**

### 2.1 Introduction à HBase

HBase est une base de données NoSQL orientée colonnes, construite sur HDFS.

#### Exercice 2.1 : Création de Table et Insertion

Ouvrez le shell HBase :

```bash
hbase shell
```

Commandes HBase :

```ruby
# Créer une table 'etudiants' avec 2 familles de colonnes
create 'etudiants', 'info_perso', 'notes'

# Vérifier la création
list

# Insérer des données
put 'etudiants', 'E001', 'info_perso:nom', 'Alami'
put 'etudiants', 'E001', 'info_perso:prenom', 'Sara'
put 'etudiants', 'E001', 'info_perso:age', '22'
put 'etudiants', 'E001', 'notes:math', '16'
put 'etudiants', 'E001', 'notes:info', '18'

put 'etudiants', 'E002', 'info_perso:nom', 'Bennani'
put 'etudiants', 'E002', 'info_perso:prenom', 'Karim'
put 'etudiants', 'E002', 'info_perso:age', '23'
put 'etudiants', 'E002', 'notes:math', '14'
put 'etudiants', 'E002', 'notes:info', '17'

# Récupérer un enregistrement complet
get 'etudiants', 'E001'

# Récupérer une colonne spécifique
get 'etudiants', 'E001', 'notes:math'

# Scanner toute la table
scan 'etudiants'

# Scanner avec filtre
scan 'etudiants', {COLUMNS => 'info_perso:nom'}
```

**Questions :**
1. Ajoutez 3 nouveaux étudiants avec leurs notes
2. Récupérez tous les étudiants ayant plus de 15 en math (indices : utilisez scan avec filter)
3. Quelle est la différence entre `get` et `scan` ?

---

### 2.2 HBase avec Python (HappyBase)

#### Exercice 2.2 : Manipulation via Python

Créez `exercice5_hbase_python.py` :

```python
import happybase

# Connexion à HBase
connection = happybase.Connection('localhost')

print("=== Tables disponibles ===")
print(connection.tables())

# Créer une nouvelle table 'produits'
2. Modifiez le prix du produit P002
3. Récupérez tous les produits de l'entrepôt Casablanca

---

### 2.3 Suppression et Mise à Jour

#### Exercice 2.3 : Opérations Avancées

Créez `exercice6_hbase_avance.py` :

```python
import happybase

connection = happybase.Connection('localhost')
table = connection.table('produits')

# Mise à jour d'un produit
print("=== Mise à jour du stock ===")
table.put(b'P001', {b'stock:quantite': b'20'})
print("Stock P001 mis à jour")

# Récupérer après mise à jour
row = table.row(b'P001')
print(f"Nouvelle quantité: {row[b'stock:quantite'].decode()}")

# Supprimer une colonne
print("\n=== Suppression d'une colonne ===")
table.delete(b'P003', columns=[b'stock:entrepot'])
print("Colonne 'entrepot' supprimée pour P003")

# Supprimer une ligne complète
# table.delete(b'P003')  # Décommentez pour supprimer

# Scanner avec filtre
print("\n=== Produits avec prix > 6000 ===")
for key, data in table.scan():
    prix = int(data.get(b'details:prix', b'0').decode())
    if prix > 6000:
        nom = data[b'details:nom'].decode()
        print(f"{key.decode()}: {nom} - {prix} DH")

connection.close()
```

---

## 📊 **Partie 3 : Apache Hive**

### 3.1 Introduction à Hive

Hive permet de manipuler des données HDFS avec des requêtes SQL.

#### Exercice 3.1 : Création de Tables

Ouvrez le shell Hive :

```bash
hive
```

Commandes Hive :

```sql
-- Créer une base de données
CREATE DATABASE IF NOT EXISTS entreprise;
USE entreprise;

-- Créer une table
CREATE TABLE IF NOT EXISTS employes (
    id INT,
    nom STRING,
    age INT,
    departement STRING,
    salaire DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Charger des données depuis HDFS
LOAD DATA INPATH '/data/employes.csv' INTO TABLE employes;

-- Vérifier les données
SELECT * FROM employes LIMIT 5;

-- Statistiques
SELECT departement, COUNT(*) as nombre, AVG(salaire) as salaire_moyen
FROM employes
GROUP BY departement;
```

**Questions :**
1. Créez une table `departements` avec (id, nom, localisation)
2. Insérez 3 départements
3. Faites une jointure entre employes et departements

---

### 3.2 Requêtes Avancées

#### Exercice 3.2 : Analyse de Données

Continuez dans le shell Hive :

```sql
-- Créer une table de ventes
CREATE TABLE ventes (
    id INT,
    produit STRING,
    quantite INT,
    prix_unitaire DOUBLE,
    date_vente STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Insérer des données de test
INSERT INTO ventes VALUES 
    (1, 'Laptop', 2, 5500.0, '2024-01-15'),
    (2, 'Mouse', 10, 50.0, '2024-01-16'),
    (3, 'Keyboard', 5, 150.0, '2024-01-17'),
    (4, 'Laptop', 1, 5500.0, '2024-01-18'),
    (5, 'Monitor', 3, 1200.0, '2024-01-19');

-- Requête 1 : Total des ventes
SELECT 
    produit,
    SUM(quantite) as total_quantite,
    SUM(quantite * prix_unitaire) as chiffre_affaires
FROM ventes
GROUP BY produit
ORDER BY chiffre_affaires DESC;

-- Requête 2 : Produits les plus vendus
SELECT produit, SUM(quantite) as total
FROM ventes
GROUP BY produit
ORDER BY total DESC
LIMIT 3;

-- Requête 3 : Ventes par période
SELECT 
    SUBSTR(date_vente, 1, 7) as mois,
    COUNT(*) as nombre_ventes,
    SUM(quantite * prix_unitaire) as ca_mensuel
FROM ventes
GROUP BY SUBSTR(date_vente, 1, 7);
```

**Questions :**
1. Quel produit génère le plus de revenus ?
2. Calculez le prix moyen par vente
3. Trouvez les ventes supérieures à 1000 DH

---

### 3.3 Hive avec Python (PyHive)

#### Exercice 3.3 : Connexion Python à Hive

Créez `exercice7_hive_python.py` :

```python
from pyhive import hive
import pandas as pd

# Connexion à Hive
conn = hive.Connection(
    host='localhost',
    port=10000,
    username='hadoop',
    database='entreprise'
)

# Créer un curseur
cursor = conn.cursor()

# Requête 1 : Sélection simple
print("=== Employés par département ===")
cursor.execute("""
    SELECT departement, COUNT(*) as nombre
    FROM employes
    GROUP BY departement
""")

for row in cursor.fetchall():
    print(f"{row[0]}: {row[1]} employés")

# Requête 2 : Avec Pandas
print("\n=== Top 5 salaires ===")
df = pd.read_sql("""
    SELECT nom, departement, salaire
    FROM employes
    ORDER BY salaire DESC
    LIMIT 5
""", conn)
print(df)

# Fermer la connexion
conn.close()
```

---

## 🔗 **Partie 4 : Intégration Spark + HBase + Hive**

### Exercice Final : Workflow Big Data Complet

Créez `exercice8_integration.py` :

```python
from pyspark.sql import SparkSession
import happybase
from pyhive import hive

# 1. SPARK : Charger et traiter les données
spark = SparkSession.builder \
    .appName("Integration_Complete") \
    .enableHiveSupport() \
    .getOrCreate()

# Lire depuis HDFS
df = spark.read.csv("hdfs://localhost:9000/data/employes.csv", 
                    header=True, inferSchema=True)

# Calculer les statistiques
stats = df.groupBy("departement").agg({"salaire": "avg"}).collect()

# 2. HBASE : Stocker les statistiques
hbase_conn = happybase.Connection('localhost')
stats_table = hbase_conn.table('stats_departements')

for row in stats:
    dept = row['departement']
    avg_sal = str(row['avg(salaire)'])
    stats_table.put(
        dept.encode(),
        {b'stats:salaire_moyen': avg_sal.encode()}
    )

print("Statistiques stockées dans HBase")

# 3. HIVE : Créer une vue agrégée
df.createOrReplaceTempView("employes_spark")

spark.sql("""
    CREATE TABLE IF NOT EXISTS entreprise.stats_employes AS
    SELECT 
        departement,
        COUNT(*) as nombre,
        AVG(salaire) as salaire_moyen,
        MAX(salaire) as salaire_max
    FROM employes_spark
    GROUP BY departement
""")

print("Vue créée dans Hive")

# Nettoyage
spark.stop()
hbase_conn.close()

print("\n✅ Workflow complet exécuté avec succès!")
```

**Questions finales :**
1. Expliquez le workflow complet
2. Quels sont les avantages de chaque technologie ?
3. Dans quel cas utiliseriez-vous HBase vs Hive ?

---

## 📝 **Rendu du TP**


**À rendre :**
1. Tous les fichiers Python créés (exercice1 à exercice8)
2. Captures d'écran des résultats d'exécution
3. Réponses aux questions de chaque exercice
4. Un rapport PDF de 3-4 pages expliquant :
   - Votre compréhension des 3 technologies
   - Les difficultés rencontrées
   - Un cas d'usage réel que vous proposez

**Format :** Archive ZIP nommée `TP_BigData_NOM_PRENOM.zip`

**Date limite :** [À définir par l'enseignant]

---

## 🆘 **Aide et Dépannage**

### Problèmes Fréquents

**1. HBase ne démarre pas**
```bash
# Vérifier le statut
hbase master status

# Redémarrer
stop-hbase.sh
start-hbase.sh
```

**2. Hive connexion refusée**
```bash
# Vérifier HiveServer2
ps aux | grep hive

# Redémarrer
nohup hive --service hiveserver2 &
```

**3. HDFS inaccessible**
```bash
# Vérifier HDFS
hdfs dfsadmin -report

# Restart HDFS
stop-dfs.sh && start-dfs.sh
```

### Ressources Utiles

- Documentation Spark : https://spark.apache.org/docs/latest/
- Documentation HBase : https://hbase.apache.org/book.html
- Documentation Hive : https://cwiki.apache.org/confluence/display/Hive/

---

**Bon courage et bon apprentissage ! 🚀**
