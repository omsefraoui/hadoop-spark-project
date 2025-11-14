# Guide Enseignant - TP Big Data
## Spark, HBase et Hive

---

**École Nationale des Sciences Appliquées d'Oujda (ENSAO)**  
**Filière** : Génie Informatique - Big Data  
**Durée** : 4 heures  
**Niveau** : Master 1/2

---

## 📋 Table des Matières

1. [Vue d'ensemble du TP](#vue-densemble)
2. [Objectifs pédagogiques](#objectifs-pédagogiques)
3. [Prérequis et préparation](#prérequis)
4. [Organisation du TP](#organisation)
5. [Barème de notation](#barème)
6. [Solutions détaillées](#solutions)
7. [Scripts de test automatisés](#tests)
8. [Critères d'évaluation](#critères)
9. [Dépannage et FAQ](#dépannage)

---

## 🎯 Vue d'ensemble du TP {#vue-densemble}

Ce TP permet aux étudiants de manipuler les trois technologies fondamentales de l'écosystème Big Data :

- **Apache Spark** : Traitement distribué en mémoire (PySpark)
- **Apache HBase** : Base de données NoSQL orientée colonnes sur HDFS
- **Apache Hive** : Data warehouse SQL sur Hadoop

### Architecture du TP

```
┌─────────────────────────────────────────────┐
│         Conteneur Docker Unique             │
│  ┌─────────┐  ┌────────┐  ┌──────────┐    │
│  │  Spark  │  │ HBase  │  │   Hive   │    │
│  └────┬────┘  └───┬────┘  └────┬─────┘    │
│       │           │            │           │
│       └───────────┴────────────┘           │
│                   │                        │
│            ┌──────▼──────┐                │
│            │    HDFS     │                │
│            └─────────────┘                │
└─────────────────────────────────────────────┘
```

### Dataset utilisé

**Thème** : Données de ventes e-commerce  
**Volume** : ~10,000 transactions  
**Format** : CSV, JSON, Parquet

---

## 🎓 Objectifs pédagogiques {#objectifs-pédagogiques}

### Compétences visées

**1. Apache Spark (40% du barème)**
- Maîtriser l'API PySpark (RDD et DataFrame)
- Effectuer des transformations et actions distribuées
- Optimiser les requêtes avec Spark SQL
- Comprendre le lazy evaluation et les DAG

**2. Apache HBase (30% du barème)**
- Concevoir un schéma HBase (Column Families)
- Manipuler des données avec l'API HappyBase (Python)
- Comprendre le modèle clé-valeur orienté colonnes
- Effectuer des scans et filtres efficaces

**3. Apache Hive (30% du barème)**
- Créer des tables externes et managées
- Écrire des requêtes HiveQL complexes
- Utiliser les partitions et buckets
- Intégrer Hive avec Spark

### Résultats d'apprentissage

À la fin du TP, l'étudiant sera capable de :
✅ Choisir la technologie appropriée selon le cas d'usage
✅ Implémenter des pipelines de traitement de données
✅ Optimiser les performances des requêtes Big Data
✅ Diagnostiquer et corriger les erreurs courantes

---

## 🔧 Prérequis et préparation {#prérequis}

### Avant le TP

**1. Infrastructure**
```bash
# Vérifier que Docker est installé
docker --version

# Lancer le conteneur
docker run -it --name bigdata-tp \
  -p 9870:9870 -p 8088:8088 -p 8080:8080 -p 16010:16010 -p 10000:10000 \
  omsefraoui/hadoop-spark-cluster:latest
```

**2. Matériel à distribuer aux étudiants**
- [ ] Énoncé du TP (ENONCE_ETUDIANT.md)
- [ ] Dataset de ventes (sales_data.csv)
- [ ] Templates de code Python
- [ ] Accès au conteneur Docker

**3. Vérification des services**

Exécuter dans le conteneur :
```bash
# Vérifier HDFS
hdfs dfs -ls /

# Vérifier Spark
spark-submit --version

# Vérifier HBase
hbase shell <<< "status"

# Vérifier Hive
hive -e "SHOW DATABASES;"
```

### Temps de préparation estimé

- Installation : 15 minutes
- Vérification : 10 minutes
- Distribution du matériel : 5 minutes

**Total : 30 minutes avant l'arrivée des étudiants**

---

## 📅 Organisation du TP {#organisation}

### Déroulement (4 heures)

| Temps | Activité | Description |
|-------|----------|-------------|
| 0h00-0h15 | **Introduction** | Présentation des objectifs, architecture, dataset |
| 0h15-1h30 | **Partie 1 : Spark** | Exercices 1-5 sur PySpark |
| 1h30-2h30 | **Partie 2 : HBase** | Exercices 6-9 sur HBase |
| 2h30-2h45 | **Pause** | ☕ |
| 2h45-3h45 | **Partie 3 : Hive** | Exercices 10-13 sur Hive |
| 3h45-4h00 | **Synthèse** | Questions, démo des solutions bonus |

### Mode de travail

- **Individuel** ou **Binômes** (selon effectif)
- **Rendu** : Scripts Python + Rapport PDF
- **Deadline** : Fin de séance + 24h pour finaliser le rapport

---

## 📊 Barème de notation {#barème}

### Note globale : /20

#### Partie 1 : Apache Spark (8 points)

| Exercice | Tâche | Points | Critères |
|----------|-------|--------|----------|
| **Ex1** | Chargement données + RDD de base | 1.5 | - Lecture CSV correcte (0.5)<br>- Affichage échantillon (0.5)<br>- Count précis (0.5) |
| **Ex2** | Transformations RDD (map, filter) | 1.5 | - Extraction prix (0.5)<br>- Filtre > 100€ (0.5)<br>- Résultat correct (0.5) |
| **Ex3** | Agrégations (reduceByKey) | 2.0 | - GroupBy catégorie (0.7)<br>- Calcul CA par catégorie (0.7)<br>- Top 3 catégories (0.6) |
| **Ex4** | DataFrame API + Spark SQL | 2.0 | - Conversion DataFrame (0.5)<br>- Requête SQL correcte (1.0)<br>- Résultats justes (0.5) |
| **Ex5** | Optimisation + Cache | 1.0 | - Utilisation de cache() (0.5)<br>- Explication pertinente (0.5) |

**Bonus Spark** : +0.5 pour utilisation de fenêtres (window functions)

#### Partie 2 : Apache HBase (6 points)

| Exercice | Tâche | Points | Critères |
|----------|-------|--------|----------|
| **Ex6** | Création table + Column Families | 1.5 | - Schéma pertinent (0.7)<br>- CFs bien définies (0.5)<br>- Table créée (0.3) |
| **Ex7** | Insertion de données | 1.5 | - 100+ lignes insérées (0.7)<br>- Format row key correct (0.5)<br>- Données cohérentes (0.3) |
| **Ex8** | Lecture et scan | 1.5 | - Get by key (0.5)<br>- Scan avec filtre (0.7)<br>- Résultats corrects (0.3) |
| **Ex9** | Requêtes avancées | 1.5 | - Scan avec préfixe (0.5)<br>- Filtre temporel (0.5)<br>- Agrégation (0.5) |

**Bonus HBase** : +0.5 pour implémentation de compteurs (increment)

#### Partie 3 : Apache Hive (6 points)

| Exercice | Tâche | Points | Critères |
|----------|-------|--------|----------|
| **Ex10** | Création table externe | 1.5 | - DDL correct (0.7)<br>- Partition définie (0.5)<br>- Chargement données (0.3) |
| **Ex11** | Requêtes HiveQL | 2.0 | - SELECT avec JOIN (0.7)<br>- Agrégations (0.7)<br>- Résultats justes (0.6) |
| **Ex12** | Partitionnement | 1.5 | - Partition dynamique (0.7)<br>- Requête sur partition (0.5)<br>- Performance améliorée (0.3) |
| **Ex13** | Intégration Spark-Hive | 1.0 | - Lecture table Hive via Spark (0.5)<br>- Transformation + Écriture (0.5) |

**Bonus Hive** : +0.5 pour utilisation de buckets

### Rapport et qualité du code (/20)

- **Clarté du code** : 2 points (commentaires, nommage)
- **Rapport technique** : 2 points (explications, schémas)
- **Gestion des erreurs** : 1 point (try-except, validation)
- **Originalité** : 1 point (approches créatives)

**Total maximum : 20 points + 1.5 bonus = 21.5 → ramené à 20/20**

---

## ✅ Solutions détaillées {#solutions}

### PARTIE 1 : Apache Spark

#### Exercice 1 : Chargement et exploration des données (1.5 pts)

**Énoncé** :  
Charger le fichier `sales_data.csv` dans un RDD Spark, afficher les 5 premières lignes et compter le nombre total de transactions.

**Solution complète** :

```python
from pyspark.sql import SparkSession

# Initialisation Spark
spark = SparkSession.builder \
    .appName("TP BigData - Spark") \
    .master("local[*]") \
    .getOrCreate()

sc = spark.sparkContext

# Chargement du fichier CSV en RDD
rdd = sc.textFile("hdfs:///data/sales_data.csv")

# Afficher les 5 premières lignes
print("=== 5 premières lignes ===")
for ligne in rdd.take(5):
    print(ligne)

# Compter le nombre total de lignes (- 1 pour l'en-tête)
header = rdd.first()
rdd_sans_header = rdd.filter(lambda ligne: ligne != header)
nb_transactions = rdd_sans_header.count()

print(f"\nNombre total de transactions : {nb_transactions}")
```

**Résultat attendu** :
```
=== 5 premières lignes ===
transaction_id,date,customer_id,product_id,category,quantity,price,payment_method
TX001,2024-01-15,CUST123,PROD456,Electronics,2,599.99,credit_card
TX002,2024-01-15,CUST124,PROD789,Clothing,1,49.99,paypal
...

Nombre total de transactions : 9842
```

**Points d'évaluation** :
- ✅ 0.5 pt : Lecture CSV correcte avec `textFile()`
- ✅ 0.5 pt : Affichage des 5 premières lignes avec `take()`
- ✅ 0.5 pt : Count précis (exclusion de l'en-tête)


**Erreurs courantes des étudiants** :
- ❌ Ne pas supprimer l'en-tête avant le count
- ❌ Utiliser `collect()` au lieu de `take()` (problème mémoire)
- ❌ Ne pas gérer le séparateur CSV

---

#### Exercice 2 : Transformations RDD (1.5 pts)

**Énoncé** :  
Extraire les prix des transactions et filtrer celles dont le montant est supérieur à 100€. Calculer le prix moyen.

**Solution complète** :

```python
# Parser une ligne CSV
def parse_ligne(ligne):
    """Parse une ligne CSV et retourne un dictionnaire"""
    champs = ligne.split(',')
    return {
        'transaction_id': champs[0],
        'date': champs[1],
        'customer_id': champs[2],
        'product_id': champs[3],
        'category': champs[4],
        'quantity': int(champs[5]),
        'price': float(champs[6]),
        'payment_method': champs[7]
    }

# RDD sans header
rdd_data = rdd_sans_header.map(parse_ligne)

# Extraire les prix
rdd_prix = rdd_data.map(lambda x: x['price'])

print("=== 5 premiers prix ===")
for prix in rdd_prix.take(5):
    print(f"{prix}€")

# Filtrer les transactions > 100€
rdd_prix_eleves = rdd_prix.filter(lambda prix: prix > 100)

nb_transactions_elevees = rdd_prix_eleves.count()
prix_moyen = rdd_prix_eleves.mean()

print(f"\nTransactions > 100€ : {nb_transactions_elevees}")
print(f"Prix moyen de ces transactions : {prix_moyen:.2f}€")
```

**Résultat attendu** :
```
=== 5 premiers prix ===
599.99€
49.99€
1299.99€
...

Transactions > 100€ : 3542
Prix moyen de ces transactions : 487.63€
```

**Points d'évaluation** :
- ✅ 0.5 pt : Extraction correcte des prix avec `map()`
- ✅ 0.5 pt : Filtre `> 100` avec `filter()`
- ✅ 0.5 pt : Calcul du prix moyen avec `mean()`

---

#### Exercice 3 : Agrégations par clé (2.0 pts)

**Énoncé** :  
Calculer le chiffre d'affaires (CA) par catégorie de produits et afficher le top 3 des catégories les plus rentables.

**Solution complète** :

```python
# RDD de paires (catégorie, montant_total)
# montant_total = quantity * price
rdd_ca = rdd_data.map(lambda x: (x['category'], x['quantity'] * x['price']))

# Agrégation par catégorie
ca_par_categorie = rdd_ca.reduceByKey(lambda a, b: a + b)

print("=== Chiffre d'affaires par catégorie ===")
for categorie, ca in ca_par_categorie.collect():
    print(f"{categorie}: {ca:.2f}€")

# Top 3 catégories
top3_categories = ca_par_categorie.sortBy(lambda x: x[1], ascending=False).take(3)

print("\n=== TOP 3 Catégories par CA ===")
for i, (categorie, ca) in enumerate(top3_categories, 1):
    print(f"{i}. {categorie}: {ca:.2f}€")
```

**Résultat attendu** :
```
=== Chiffre d'affaires par catégorie ===
Electronics: 1245789.50€
Clothing: 543210.30€
Books: 234567.80€
Home: 678901.20€
Sports: 345678.90€

=== TOP 3 Catégories par CA ===
1. Electronics: 1245789.50€
2. Home: 678901.20€
3. Clothing: 543210.30€
```

**Points d'évaluation** :
- ✅ 0.7 pt : Création paires (catégorie, montant) avec map()
- ✅ 0.7 pt : Agrégation correcte avec reduceByKey()
- ✅ 0.6 pt : Top 3 avec sortBy() et take()

**Erreurs courantes** :
- ❌ Utiliser `groupByKey()` au lieu de `reduceByKey()` (moins performant)
- ❌ Oublier de multiplier quantity × price
- ❌ Tri dans le mauvais ordre (ascending au lieu de descending)

---

#### Exercice 4 : DataFrame API et Spark SQL (2.0 pts)

**Énoncé** :  
Convertir le RDD en DataFrame et utiliser Spark SQL pour trouver le client ayant dépensé le plus.

**Solution complète** :

```python
from pyspark.sql import Row

# Conversion RDD → DataFrame
df = rdd_data.map(lambda x: Row(**x)).toDF()

# Afficher le schéma
df.printSchema()
df.show(5)

# Créer une vue temporaire pour SQL
df.createOrReplaceTempView("sales")

# Requête SQL : client ayant le plus dépensé
query = """
SELECT 
    customer_id,
    SUM(quantity * price) as total_depense,
    COUNT(*) as nb_transactions
FROM sales
GROUP BY customer_id
ORDER BY total_depense DESC
LIMIT 1
"""

meilleur_client = spark.sql(query)
meilleur_client.show()

# Alternative avec DataFrame API
from pyspark.sql.functions import sum, count, col

meilleur_client_df = df \
    .withColumn("montant", col("quantity") * col("price")) \
    .groupBy("customer_id") \
    .agg(
        sum("montant").alias("total_depense"),
        count("*").alias("nb_transactions")
    ) \
    .orderBy(col("total_depense").desc()) \
    .limit(1)

meilleur_client_df.show()
```

**Résultat attendu** :
```
+-----------+--------------+----------------+
|customer_id|total_depense |nb_transactions |
+-----------+--------------+----------------+
|CUST742    |15789.45      |47              |
+-----------+--------------+----------------+
```

**Points d'évaluation** :
- ✅ 0.5 pt : Conversion RDD → DataFrame correcte
- ✅ 1.0 pt : Requête SQL fonctionnelle (GROUP BY, SUM, ORDER BY)
- ✅ 0.5 pt : Résultat correct (meilleur client identifié)

---

#### Exercice 5 : Optimisation avec Cache (1.0 pt)

**Énoncé** :  
Démontrer l'utilisation du cache pour optimiser les requêtes répétées sur le même DataFrame.

**Solution complète** :

```python
import time

# Sans cache
start = time.time()
count1 = df.filter(df.price > 500).count()
count2 = df.filter(df.price > 500).count()
temps_sans_cache = time.time() - start

print(f"Temps sans cache : {temps_sans_cache:.2f}s")

# Avec cache
df_cache = df.cache()

start = time.time()
count1 = df_cache.filter(df_cache.price > 500).count()
count2 = df_cache.filter(df_cache.price > 500).count()
temps_avec_cache = time.time() - start

print(f"Temps avec cache : {temps_avec_cache:.2f}s")
print(f"Gain de performance : {(temps_sans_cache - temps_avec_cache) / temps_sans_cache * 100:.1f}%")

# Libérer le cache
df_cache.unpersist()
```

**Résultat attendu** :
```
Temps sans cache : 2.45s
Temps avec cache : 1.12s
Gain de performance : 54.3%
```

**Points d'évaluation** :
- ✅ 0.5 pt : Utilisation correcte de `cache()`
- ✅ 0.5 pt : Explication pertinente du gain de performance

**Explication attendue** :  
Le cache stocke le DataFrame en mémoire après la première exécution. Les requêtes suivantes n'ont pas besoin de relire le fichier source, d'où le gain de performance notable (~50%).

---

### PARTIE 2 : Apache HBase

#### Exercice 6 : Création de table et Column Families (1.5 pts)

**Énoncé** :  
Créer une table HBase pour stocker les ventes avec un schéma orienté colonnes optimisé.

**Solution complète** :

```python
import happybase

# Connexion à HBase
connection = happybase.Connection('localhost', port=9090)
print("Connexion HBase établie")

# Créer la table avec Column Families
table_name = 'sales'

# Supprimer la table si elle existe déjà
if table_name.encode() in connection.tables():
    connection.delete_table(table_name, disable=True)
    print(f"Table {table_name} supprimée")

# Définir les Column Families
families = {
    'info': dict(),           # Informations générales (date, customer_id)
    'product': dict(),        # Détails produit (product_id, category)
    'transaction': dict()     # Détails transaction (quantity, price, payment)
}

# Créer la table
connection.create_table(table_name, families)
print(f"Table {table_name} créée avec succès")

# Vérifier que la table existe
tables = [t.decode() for t in connection.tables()]
print(f"\nTables disponibles : {tables}")

# Afficher le descripteur de la table
table = connection.table(table_name)
print(f"\nColumn Families de '{table_name}' : {list(table.families())}")
```

**Résultat attendu** :
```
Connexion HBase établie
Table sales supprimée
Table sales créée avec succès

Tables disponibles : ['sales']

Column Families de 'sales' : [b'info', b'product', b'transaction']
```

**Points d'évaluation** :
- ✅ 0.7 pt : Schéma pertinent (3 CF logiquement séparées)
- ✅ 0.5 pt : Column Families bien définies (info, product, transaction)
- ✅ 0.3 pt : Table créée sans erreur

**Justification du schéma** :
- `info:` données temporelles et client (faible volumétrie)
- `product:` informations produit (modérée volumétrie)
- `transaction:` détails transactionnels (haute fréquence d'accès)

---

#### Exercice 7 : Insertion de données (1.5 pts)

**Énoncé** :  
Insérer au moins 100 transactions dans la table HBase avec des row keys optimisées.

**Solution complète** :

```python
import csv
from datetime import datetime

# Fonction pour générer une row key optimisée
def generate_row_key(transaction_id, date):
    """
    Row Key format: YYYYMMDD_TransactionID
    Permet un bon équilibrage et des scans efficaces par date
    """
    date_str = date.replace('-', '')  # 2024-01-15 → 20240115
    return f"{date_str}_{transaction_id}"

# Charger les données CSV
with open('/data/sales_data.csv', 'r') as f:
    reader = csv.DictReader(f)
    data = list(reader)

# Insertion batch
table = connection.table('sales')
batch = table.batch(batch_size=100)

print("Insertion des données...")
count = 0

for row in data[:100]:  # Insérer les 100 premières
    row_key = generate_row_key(row['transaction_id'], row['date'])
    
    batch.put(row_key.encode(), {
        b'info:date': row['date'].encode(),
        b'info:customer_id': row['customer_id'].encode(),
        b'product:product_id': row['product_id'].encode(),
        b'product:category': row['category'].encode(),
        b'transaction:quantity': row['quantity'].encode(),
        b'transaction:price': row['price'].encode(),
        b'transaction:payment_method': row['payment_method'].encode()
    })
    
    count += 1
    if count % 20 == 0:
        print(f"  {count} lignes insérées...")

batch.send()
print(f"\n✓ Total : {count} transactions insérées")

# Vérification
nb_lignes = sum(1 for _ in table.scan())
print(f"Nombre de lignes dans la table : {nb_lignes}")
```

**Résultat attendu** :
```
Insertion des données...
  20 lignes insérées...
  40 lignes insérées...
  60 lignes insérées...
  80 lignes insérées...
  100 lignes insérées...

✓ Total : 100 transactions insérées
Nombre de lignes dans la table : 100
```

**Points d'évaluation** :
- ✅ 0.7 pt : 100+ lignes insérées avec batch
- ✅ 0.5 pt : Format row key optimisé (date_transaction_id)
- ✅ 0.3 pt : Données cohérentes dans les 3 CF

**Row Key Design - Bonnes pratiques** :
- ✅ Préfixer par date pour scans temporels efficaces
- ✅ Éviter les hotspots (pas de timestamp monotone)
- ✅ Inclure un identifiant unique

---

#### Exercice 8 : Lecture et scan (1.5 pts)

**Énoncé** :  
Récupérer une transaction par sa clé, puis scanner toutes les transactions d'une catégorie spécifique.

**Solution complète** :

```python
# 1. Get by row key
print("=== Lecture d'une transaction spécifique ===")
row_key = b'20240115_TX001'
row = table.row(row_key)

if row:
    print(f"Transaction {row_key.decode()} :")
    for key, value in row.items():
        print(f"  {key.decode()}: {value.decode()}")
else:
    print("Transaction non trouvée")


# 2. Scan avec filtre par catégorie
print("\n=== Scan des transactions 'Electronics' ===")
categorie = b'Electronics'
count_electronics = 0

for key, data in table.scan():
    if data.get(b'product:category') == categorie:
        count_electronics += 1
        if count_electronics <= 5:  # Afficher les 5 premières
            print(f"{key.decode()}: {data[b'transaction:price'].decode()}€")

print(f"\nTotal transactions Electronics : {count_electronics}")
```

**Résultat attendu** :
```
=== Lecture d'une transaction spécifique ===
Transaction 20240115_TX001 :
  info:date: 2024-01-15
  info:customer_id: CUST123
  product:product_id: PROD456
  product:category: Electronics
  transaction:quantity: 2
  transaction:price: 599.99
  transaction:payment_method: credit_card

=== Scan des transactions 'Electronics' ===
20240115_TX001: 599.99€
20240115_TX005: 1299.99€
20240116_TX012: 799.00€
20240117_TX023: 449.50€
20240118_TX034: 899.99€

Total transactions Electronics : 28
```

**Points d'évaluation** :
- ✅ 0.5 pt : Get by key avec `table.row()`
- ✅ 0.7 pt : Scan avec filtre sur category
- ✅ 0.3 pt : Résultats corrects affichés

---

#### Exercice 9 : Requêtes avancées (1.5 pts)

**Énoncé** :  
Scanner les transactions d'une période donnée et calculer le total des ventes.


**Solution complète** :

```python
# Scanner les transactions du 15 au 20 janvier 2024
print("=== Transactions du 15 au 20 janvier 2024 ===")

start_row = b'20240115'  # Début de période
stop_row = b'20240121'   # Fin de période (exclusif)

total_ventes = 0
total_quantite = 0
count = 0

for key, data in table.scan(row_start=start_row, row_stop=stop_row):
    prix = float(data[b'transaction:price'].decode())
    quantite = int(data[b'transaction:quantity'].decode())
    montant = prix * quantite
    
    total_ventes += montant
    total_quantite += quantite
    count += 1
    
    if count <= 3:  # Afficher les 3 premières
        date = data[b'info:date'].decode()
        print(f"{date} - {key.decode()}: {quantite} × {prix}€ = {montant}€")

print(f"\n📊 Statistiques période 15-20 janvier :")
print(f"  - Transactions : {count}")
print(f"  - Quantité totale : {total_quantite}")
print(f"  - CA total : {total_ventes:.2f}€")
print(f"  - Panier moyen : {total_ventes/count:.2f}€")
```

**Résultat attendu** :
```
=== Transactions du 15 au 20 janvier 2024 ===
2024-01-15 - 20240115_TX001: 2 × 599.99€ = 1199.98€
2024-01-15 - 20240115_TX002: 1 × 49.99€ = 49.99€
2024-01-16 - 20240116_TX010: 3 × 29.99€ = 89.97€

📊 Statistiques période 15-20 janvier :
  - Transactions : 42
  - Quantité totale : 87
  - CA total : 18745.63€
  - Panier moyen : 446.32€
```

**Points d'évaluation** :
- ✅ 0.5 pt : Scan avec row_start et row_stop
- ✅ 0.5 pt : Calcul du CA (quantity × price)
- ✅ 0.5 pt : Agrégations correctes (sum, count, avg)

**Optimisation HBase** :
Le préfixage des row keys par date (YYYYMMDD) permet des scans temporels très efficaces sans nécessiter de filtre côté application.

---

### PARTIE 3 : Apache Hive

#### Exercice 10 : Création de table externe (1.5 pts)

**Énoncé** :  
Créer une table externe Hive pointant vers les données CSV sur HDFS, avec partitionnement par date.

**Solution complète** :

```python
from pyhive import hive

# Connexion à Hive
conn = hive.Connection(host='localhost', port=10000, username='hadoop')
cursor = conn.cursor()

print("Connexion à Hive établie")

# 1. Créer une base de données
cursor.execute("CREATE DATABASE IF NOT EXISTS sales_db")
cursor.execute("USE sales_db")
print("Base de données 'sales_db' créée/sélectionnée")


# 2. Créer une table externe (non partitionnée)
create_table_sql = """
CREATE EXTERNAL TABLE IF NOT EXISTS sales_raw (
    transaction_id STRING,
    date STRING,
    customer_id STRING,
    product_id STRING,
    category STRING,
    quantity INT,
    price DOUBLE,
    payment_method STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/sales/'
TBLPROPERTIES ('skip.header.line.count'='1')
"""

cursor.execute(create_table_sql)
print("Table 'sales_raw' créée")

# 3. Créer une table partitionnée
create_partitioned_sql = """
CREATE TABLE IF NOT EXISTS sales_partitioned (
    transaction_id STRING,
    customer_id STRING,
    product_id STRING,
    category STRING,
    quantity INT,
    price DOUBLE,
    payment_method STRING
)
PARTITIONED BY (date STRING)
STORED AS PARQUET
"""

cursor.execute(create_partitioned_sql)
print("Table 'sales_partitioned' créée")


# 4. Charger les données avec partition dynamique
cursor.execute("SET hive.exec.dynamic.partition = true")
cursor.execute("SET hive.exec.dynamic.partition.mode = nonstrict")

insert_sql = """
INSERT OVERWRITE TABLE sales_partitioned PARTITION(date)
SELECT 
    transaction_id,
    customer_id,
    product_id,
    category,
    quantity,
    price,
    payment_method,
    date
FROM sales_raw
"""

cursor.execute(insert_sql)
print("Données chargées dans la table partitionnée")

# Vérification
cursor.execute("SHOW PARTITIONS sales_partitioned")
partitions = cursor.fetchall()
print(f"\nPartitions créées : {len(partitions)}")
for p in partitions[:5]:
    print(f"  - {p[0]}")
```

**Résultat attendu** :
```
Connexion à Hive établie
Base de données 'sales_db' créée/sélectionnée
Table 'sales_raw' créée
Table 'sales_partitioned' créée
Données chargées dans la table partitionnée

Partitions créées : 15
  - date=2024-01-15
  - date=2024-01-16
  - date=2024-01-17
  - date=2024-01-18
  - date=2024-01-19
```

**Points d'évaluation** :
- ✅ 0.7 pt : DDL correct (CREATE EXTERNAL TABLE)
- ✅ 0.5 pt : Partition définie (PARTITIONED BY)
- ✅ 0.3 pt : Chargement données réussi

---

#### Exercice 11 : Requêtes HiveQL complexes (2.0 pts)

**Énoncé** :  
Écrire une requête HiveQL pour analyser les ventes par catégorie et méthode de paiement.

**Solution complète** :

```python
# Requête 1 : CA par catégorie et méthode de paiement
query1 = """
SELECT 
    category,
    payment_method,
    COUNT(*) as nb_transactions,
    SUM(quantity * price) as ca_total,
    AVG(quantity * price) as panier_moyen
FROM sales_partitioned
WHERE date BETWEEN '2024-01-15' AND '2024-01-20'
GROUP BY category, payment_method
ORDER BY ca_total DESC
LIMIT 10
"""

cursor.execute(query1)
results = cursor.fetchall()

print("=== CA par catégorie et méthode de paiement ===")
print(f"{'Catégorie':<15} {'Paiement':<15} {'Nb Trans':<10} {'CA Total':<15} {'Panier Moy':<15}")
print("-" * 75)
for row in results:
    print(f"{row[0]:<15} {row[1]:<15} {row[2]:<10} {row[3]:<15.2f} {row[4]:<15.2f}")
