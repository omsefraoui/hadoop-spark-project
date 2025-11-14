# TP Big Data - Guide de l'Enseignant
## Apache Spark, HBase et Hive

**Niveau :** Master 1/2 - École d'Ingénieurs  
**Durée :** 4 heures  
**Auteur :** Omar Sefraoui - ENSAO

---

## Table des Matières

1. [Vue d'ensemble du TP](#1-vue-densemble-du-tp)
2. [Objectifs pédagogiques](#2-objectifs-pédagogiques)
3. [Prérequis techniques](#3-prérequis-techniques)
4. [Organisation de la séance](#4-organisation-de-la-séance)
5. [Solutions détaillées](#5-solutions-détaillées)
6. [Barèmes de notation](#6-barèmes-de-notation)
7. [Scripts de test automatisés](#7-scripts-de-test-automatisés)
8. [Critères d'évaluation](#8-critères-dévaluation)
9. [Problèmes courants et solutions](#9-problèmes-courants-et-solutions)

---

## 1. Vue d'ensemble du TP

Ce TP pratique permet aux étudiants de manipuler trois technologies Big Data complémentaires :

- **Apache Spark** : Traitement distribué de données (batch)
- **Apache HBase** : Base de données NoSQL orientée colonnes
- **Apache Hive** : Data Warehouse SQL sur Hadoop

### Architecture du cluster

```
┌─────────────────────────────────────────┐
│     Container Docker (All-in-One)       │
├─────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │  Hadoop  │  │  Spark   │  │  Hive  ││
│  │  HDFS    │  │  Engine  │  │  Meta  ││
│  └────┬─────┘  └────┬─────┘  └───┬────┘│
│       │           │            │        │
│       └───────────┴────────────┴────────┘
│                   │                      │
│              ┌────┴─────┐                │
│              │  HBase   │                │
│              │ RegionSvr│                │
│              └──────────┘                │
└─────────────────────────────────────────┘
```

### Scénario pédagogique

Les étudiants travaillent sur un cas d'usage réaliste : **Analyse de données de ventes e-commerce**.

Ils vont :
1. Charger et analyser des logs de ventes avec **Spark**
2. Stocker des profils clients en temps réel avec **HBase**
3. Créer un entrepôt de données analytiques avec **Hive**

---

## 2. Objectifs pédagogiques

### Compétences visées

**Spark (35% du TP)**
- Maîtriser les RDD et DataFrames
- Écrire des transformations et actions
- Effectuer des agrégations complexes
- Optimiser les performances (cache, partitionnement)

**HBase (30% du TP)**
- Comprendre le modèle clé-valeur orienté colonnes
- Concevoir des schémas de tables efficaces
- Manipuler les opérations CRUD
- Utiliser les scans et filtres

**Hive (35% du TP)**
- Créer des tables internes et externes
- Écrire des requêtes SQL complexes (JOIN, GROUP BY, window functions)
- Partitionner et bucketer des tables
- Intégrer Hive avec Spark

### Résultats d'apprentissage attendus

À la fin du TP, l'étudiant doit être capable de :
- ✅ Choisir la technologie adaptée selon le cas d'usage
- ✅ Implémenter un pipeline de traitement de données
- ✅ Optimiser les requêtes et performances
- ✅ Déboguer les erreurs courantes

---

## 3. Prérequis techniques

### Côté étudiant
- **Docker Desktop** installé et fonctionnel
- **Python 3.8+** avec pip
- Éditeur de code (VS Code recommandé)
- 8 GB RAM minimum, 16 GB recommandé
- 20 GB espace disque libre

### Côté enseignant
- Image Docker : `omsefraoui/hadoop-spark-cluster:latest`
- Scripts de test Python fournis
- Accès aux logs des conteneurs
- Barème de notation détaillé

---

## 4. Organisation de la séance

### Timeline recommandée (4h)

| Temps | Activité | Durée |
|-------|----------|-------|
| 0:00 | Introduction + Installation | 30 min |
| 0:30 | **Partie 1 : Spark** | 90 min |
| 2:00 | Pause | 15 min |
| 2:15 | **Partie 2 : HBase** | 60 min |
| 3:15 | **Partie 3 : Hive** | 45 min |

### Démarrage du cluster (à faire ensemble)

**Commande de démarrage :**
```bash
docker run -d --name bigdata-cluster \
  -p 9870:9870 -p 8088:8088 -p 8080:8080 \
  -p 16010:16010 -p 10000:10000 \
  omsefraoui/hadoop-spark-cluster:latest
```

**Vérification des services :**
```bash
docker exec bigdata-cluster jps
```

**Résultat attendu :**
```
NameNode
DataNode
ResourceManager
NodeManager
HMaster
HRegionServer
RunJar (Hive services)
```

**URLs d'accès (à afficher au tableau) :**
- HDFS NameNode : http://localhost:9870
- YARN ResourceManager : http://localhost:8088
- Spark Master : http://localhost:8080
- HBase Master : http://localhost:16010

---

## 5. Solutions détaillées

### PARTIE 1 : Apache Spark (90 minutes)

#### Exercice 1.1 : Premiers pas avec Spark (15 min) - 3 points

**Énoncé :**
> Créez un fichier `ventes.csv` avec 10 transactions et chargez-le dans Spark.

**Solution complète :**

```python
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from pyspark.sql.functions import *

# Initialisation de la session Spark
spark = SparkSession.builder \
    .appName("TP_Ventes") \
    .master("local[*]") \
    .getOrCreate()

# Création des données de test
data = [
    ("TXN001", "2024-01-15", "Laptop", 1200.00, "Paris", "Alice"),
    ("TXN002", "2024-01-15", "Mouse", 25.50, "Lyon", "Bob"),
    ("TXN003", "2024-01-16", "Keyboard", 75.00, "Paris", "Alice"),
    ("TXN004", "2024-01-16", "Monitor", 350.00, "Marseille", "Charlie"),
    ("TXN005", "2024-01-17", "Laptop", 1200.00, "Lyon", "Bob"),
    ("TXN006", "2024-01-17", "Mouse", 25.50, "Paris", "Alice"),
    ("TXN007", "2024-01-18", "Laptop", 1400.00, "Paris", "David"),
    ("TXN008", "2024-01-18", "Keyboard", 75.00, "Lyon", "Bob"),
    ("TXN009", "2024-01-19", "Monitor", 350.00, "Paris", "Alice"),
    ("TXN010", "2024-01-19", "Mouse", 30.00, "Marseille", "Charlie")
]

# Schéma explicite (BONNE PRATIQUE)
schema = StructType([
    StructField("transaction_id", StringType(), False),
    StructField("date", StringType(), False),
    StructField("produit", StringType(), False),
    StructField("montant", DoubleType(), False),
    StructField("ville", StringType(), False),
    StructField("client", StringType(), False)
])

# Création du DataFrame
df = spark.createDataFrame(data, schema)

# Affichage
df.show()
df.printSchema()

# Sauvegarde en CSV
df.write.mode("overwrite").csv("/tmp/ventes.csv", header=True)

print("✅ Données chargées avec succès !")
print(f"Nombre de lignes : {df.count()}")
```

**Barème détaillé (3 points) :**
- 0.5 pt : Session Spark correctement initialisée
- 1.0 pt : Données créées avec au moins 10 lignes
- 0.5 pt : Schéma explicite défini
- 0.5 pt : Affichage correct (show + printSchema)
- 0.5 pt : Code propre et commenté

**Points de vigilance :**
- ⚠️ Vérifier que le schéma est explicite (pas d'inférence)
- ⚠️ Les types de données doivent être corrects (DoubleType pour montant)
- ⚠️ Présence de `header=True` lors de la sauvegarde

---

#### Exercice 1.2 : Analyses statistiques (20 min) - 4 points

**Énoncé :**
> Calculez les statistiques suivantes :
> 1. Chiffre d'affaires total
> 2. Ventes par ville
> 3. Top 3 des produits
> 4. Client avec le plus de transactions

**Solution complète :**

```python
from pyspark.sql.functions import sum, count, desc

# 1. Chiffre d'affaires total
ca_total = df.agg(sum("montant").alias("CA_Total")).collect()[0]["CA_Total"]
print(f"📊 Chiffre d'affaires total : {ca_total:.2f} €")

# 2. Ventes par ville
print("\n📍 Ventes par ville :")
df.groupBy("ville") \
    .agg(
        sum("montant").alias("CA"),
        count("*").alias("Nb_Transactions")
    ) \
    .orderBy(desc("CA")) \
    .show()

# 3. Top 3 des produits
print("\n🏆 Top 3 des produits :")
df.groupBy("produit") \
    .agg(
        sum("montant").alias("CA"),
        count("*").alias("Ventes")
    ) \
    .orderBy(desc("CA")) \
    .limit(3) \
    .show()

# 4. Client avec le plus de transactions
print("\n👤 Client le plus actif :")
df.groupBy("client") \
    .agg(
        count("*").alias("Nb_Achats"),
        sum("montant").alias("CA_Total")
    ) \
    .orderBy(desc("Nb_Achats")) \
    .limit(1) \
    .show()
```

**Résultat attendu :**
```
📊 Chiffre d'affaires total : 4506.00 €

📍 Ventes par ville :
+----------+-------+----------------+
|     ville|     CA|Nb_Transactions|
+----------+-------+----------------+
|     Paris|3080.50|               5|
|      Lyon|1326.00|               3|
|Marseille| 380.00|               2|
+----------+-------+----------------+

🏆 Top 3 des produits :
+--------+------+------+
| produit|    CA|Ventes|
+--------+------+------+
|  Laptop|3800.0|     3|
| Monitor| 700.0|     2|
|Keyboard| 150.0|     2|
+--------+------+------+

👤 Client le plus actif :
+------+----------+--------+
|client|Nb_Achats|CA_Total|
+------+----------+--------+
| Alice|         4|  1650.5|
+------+----------+--------+
```

**Barème détaillé (4 points) :**
- 1.0 pt : CA total correct avec `sum()` et `agg()`
- 1.0 pt : Ventes par ville avec `groupBy()` et tri correct
- 1.0 pt : Top 3 produits avec `limit(3)`
- 1.0 pt : Client le plus actif avec bon critère de tri

**Critères de qualité :**
- Utilisation de `alias()` pour renommer les colonnes ✅
- Tri décroissant avec `desc()` ✅
- Format d'affichage lisible ✅

---

#### Exercice 1.3 : Transformations avancées (25 min) - 5 points

**Énoncé :**
> Enrichissez les données :
> 1. Ajoutez une colonne "catégorie" (Informatique/Périphérique)
> 2. Calculez la TVA (20%)
> 3. Filtrez les ventes > 100€
> 4. Créez une colonne "période" (Semaine 1/2/3)

**Solution complète :**

```python
from pyspark.sql.functions import when, col, round, weekofyear, concat, lit

# 1. Ajout de la catégorie
df_enrichi = df.withColumn(
    "categorie",
    when(col("produit") == "Laptop", "Informatique")
    .when(col("produit") == "Monitor", "Informatique")
    .otherwise("Peripherique")
)

# 2. Calcul de la TVA
df_enrichi = df_enrichi.withColumn(
    "montant_ttc",
    round(col("montant") * 1.20, 2)
).withColumn(
    "tva",
    round(col("montant") * 0.20, 2)
)

# 3. Filtre sur les montants > 100€
df_filtered = df_enrichi.filter(col("montant") > 100)

# 4. Ajout de la période (basé sur la date)
df_final = df_filtered.withColumn(
    "periode",
    concat(
        lit("Semaine "),
        weekofyear(col("date"))
    )
)

# Affichage
print("📋 Données enrichies et filtrées :")
df_final.select(
    "transaction_id", "produit", "montant", 
    "montant_ttc", "tva", "categorie", "periode"
).show(truncate=False)

# Statistiques par catégorie
print("\n📊 Statistiques par catégorie :")
df_final.groupBy("categorie") \
    .agg(
        count("*").alias("Nb_Produits"),
        sum("montant").alias("CA_HT"),
        sum("montant_ttc").alias("CA_TTC")
    ) \
    .show()
```

**Résultat attendu :**
```
📋 Données enrichies et filtrées :
+--------------+--------+-------+-----------+------+-------------+---------+
|transaction_id|produit |montant|montant_ttc|tva   |categorie    |periode  |
+--------------+--------+-------+-----------+------+-------------+---------+
|TXN001        |Laptop  |1200.0 |1440.0     |240.0 |Informatique |Semaine 3|
|TXN004        |Monitor |350.0  |420.0      |70.0  |Informatique |Semaine 3|
|TXN005        |Laptop  |1200.0 |1440.0     |240.0 |Informatique |Semaine 3|
|TXN007        |Laptop  |1400.0 |1680.0     |280.0 |Informatique |Semaine 3|
|TXN009        |Monitor |350.0  |420.0      |70.0  |Informatique |Semaine 3|
+--------------+--------+-------+-----------+------+-------------+---------+

📊 Statistiques par catégorie :
+-------------+-----------+------+-------+
|    categorie|Nb_Produits| CA_HT| CA_TTC|
+-------------+-----------+------+-------+
|Informatique|          5|4500.0|5400.0|
+-------------+-----------+------+-------+
```

**Barème détaillé (5 points) :**
- 1.0 pt : Colonne catégorie avec `when().otherwise()`
- 1.5 pt : Calcul TVA et montant TTC (avec `round()`)
- 1.0 pt : Filtre correct avec `filter()`
- 1.0 pt : Colonne période avec `weekofyear()` ou logique équivalente
- 0.5 pt : Affichage clair et statistiques pertinentes

**Erreurs fréquentes :**
- ❌ Oublier `round()` pour la TVA → résultats avec trop de décimales
- ❌ Utiliser `where()` au lieu de `filter()` → acceptable mais moins Spark idiomatique
- ❌ Ne pas chaîner les `withColumn()` → code verbeux

---

### PARTIE 2 : Apache HBase (60 minutes)

#### Exercice 2.1 : Conception du schéma (10 min) - 2 points

**Énoncé :**
> Concevez une table HBase pour stocker des profils clients avec :
> - Informations personnelles (nom, email, téléphone)
> - Historique d'achats (date, montant, produit)
> - Préférences (newsletter, langue, thème)

**Solution et justification :**

```
Table : clients_profiles
Row Key : client_id (ex: "C001", "C002")

Column Families :
├─ info:           (Informations personnelles, rarement modifiées)
│   ├─ nom
│   ├─ email
│   ├─ telephone
│   └─ date_inscription
│
├─ achats:         (Historique transactionnel, fréquemment mis à jour)
│   ├─ 2024-01-15_TXN001
│   ├─ 2024-01-16_TXN002
│   └─ ... (format: date_transaction_id)
│
└─ prefs:          (Préférences, mises à jour occasionnelles)
    ├─ newsletter
    ├─ langue
    └─ theme
```

**Justification du design :**
1. **Row Key = client_id** : Accès direct par client (O(1))
2. **3 Column Families** : Séparation logique et optimisation
3. **Colonnes dynamiques dans "achats:"** : Scalabilité illimitée
4. **Timestamps automatiques** : Historique complet des versions

**Barème (2 points) :**
- 0.5 pt : Row key pertinent (client_id)
- 1.0 pt : Column families logiquement séparées (minimum 2)
- 0.5 pt : Justification des choix

---

#### Exercice 2.2 : Implémentation HBase (25 min) - 5 points

**Énoncé :**
> Créez la table et insérez 5 profils clients avec leur historique.

**Solution complète :**

```python
import happybase

# Connexion à HBase
connection = happybase.Connection('localhost', port=9090)
print("✅ Connexion HBase établie")

# Création de la table
table_name = 'clients_profiles'

# Suppression si existe (pour réinitialiser)
if table_name.encode() in connection.tables():
    print(f"⚠️  Table {table_name} existe déjà, suppression...")
    connection.delete_table(table_name, disable=True)

# Création avec 3 column families
connection.create_table(
    table_name,
    {
        'info': dict(),      # Infos personnelles
        'achats': dict(),    # Historique achats
        'prefs': dict()      # Préférences
    }
)
print(f"✅ Table {table_name} créée")

# Accès à la table
table = connection.table(table_name)

# Insertion de 5 clients avec historique
clients_data = [
    {
        'row_key': 'C001',
        'info:nom': 'Alice Dupont',
        'info:email': 'alice@email.com',
        'info:telephone': '0601020304',
        'info:date_inscription': '2023-06-15',
        'achats:2024-01-15_TXN001': '1200.00|Laptop',
        'achats:2024-01-16_TXN003': '75.00|Keyboard',
        'achats:2024-01-17_TXN006': '25.50|Mouse',
        'prefs:newsletter': 'true',
        'prefs:langue': 'fr',
        'prefs:theme': 'dark'
    },
    {
        'row_key': 'C002',
        'info:nom': 'Bob Martin',
        'info:email': 'bob@email.com',
        'info:telephone': '0602030405',
        'info:date_inscription': '2023-08-20',
        'achats:2024-01-15_TXN002': '25.50|Mouse',
        'achats:2024-01-17_TXN005': '1200.00|Laptop',
        'achats:2024-01-18_TXN008': '75.00|Keyboard',
        'prefs:newsletter': 'false',
        'prefs:langue': 'fr',
        'prefs:theme': 'light'
    },
    {
        'row_key': 'C003',
        'info:nom': 'Charlie Lefebvre',
        'info:email': 'charlie@email.com',
        'info:telephone': '0603040506',
        'info:date_inscription': '2023-09-10',
        'achats:2024-01-16_TXN004': '350.00|Monitor',
        'achats:2024-01-19_TXN010': '30.00|Mouse',
        'prefs:newsletter': 'true',
