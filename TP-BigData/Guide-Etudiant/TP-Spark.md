# TP Apache Spark - Guide Étudiant

## 📚 Objectifs du TP
- Comprendre les concepts de base de Spark (RDD, DataFrame, SQL)
- Manipuler des données avec PySpark
- Effectuer des analyses de données distribuées
- Utiliser Spark SQL pour requêter des données

## ⏱️ Durée estimée
2 heures

---

## 🔧 Prérequis

### Lancement du conteneur Docker
```bash
docker run -it --name hadoop-spark \
  -p 9870:9870 -p 8088:8088 -p 8080:8080 -p 4040:4040 \
  omsefraoui/hadoop-spark-cluster:latest
```

### Vérification de Spark
Dans le conteneur, vérifiez que Spark est bien installé :
```bash
spark-shell --version
pyspark --version
```

---

## 📖 Partie 1 : Introduction à PySpark

### Exercice 1.1 : Premier programme Spark
**Objectif** : Créer votre premier RDD et effectuer des transformations de base.

1. Lancez PySpark :
```bash
pyspark
```

2. Créez un RDD simple :
```python
# Créer un RDD à partir d'une liste
data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
rdd = sc.parallelize(data)

# Afficher le contenu
print(rdd.collect())
```

3. **Question 1.1** : Appliquez une transformation pour multiplier chaque élément par 2.

**Indice** : Utilisez la fonction `map()`

4. **Question 1.2** : Filtrez les nombres pairs uniquement.

**Indice** : Utilisez la fonction `filter()`

5. **Question 1.3** : Calculez la somme de tous les éléments.

**Indice** : Utilisez la fonction `reduce()`

### Exercice 1.2 : Analyse de texte
**Objectif** : Compter les mots dans un fichier texte.

1. Créez un fichier texte de test :
```bash
echo "Apache Spark est un framework de traitement de données" > /tmp/test.txt
echo "Spark permet le traitement distribué" >> /tmp/test.txt
echo "Le traitement avec Spark est rapide" >> /tmp/test.txt
```

2. **Question 1.4** : Chargez ce fichier dans un RDD et comptez le nombre total de mots.

```python
# À compléter par l'étudiant
text_rdd = sc.textFile("/tmp/test.txt")
# ... votre code ici
```

3. **Question 1.5** : Comptez le nombre d'occurrences de chaque mot (Word Count classique).

**Indice** : Utilisez `flatMap()`, `map()` et `reduceByKey()`

---

## 📊 Partie 2 : Spark DataFrames et Spark SQL

### Exercice 2.1 : Création et manipulation de DataFrames

**Objectif** : Travailler avec des DataFrames structurés.

1. Lancez PySpark avec support Spark SQL :
```bash
pyspark
```

2. Créez un DataFrame depuis une liste :
```python
from pyspark.sql import SparkSession

# Créer une SparkSession
spark = SparkSession.builder.appName("TP-Spark").getOrCreate()

# Données d'exemple : étudiants
data = [
    (1, "Ahmed", "Informatique", 18),
    (2, "Fatima", "Mathématiques", 19),
    (3, "Hassan", "Informatique", 20),
    (4, "Samira", "Physique", 18),
    (5, "Omar", "Informatique", 21)
]

# Créer le DataFrame
df = spark.createDataFrame(data, ["id", "nom", "filiere", "age"])
df.show()
```

3. **Question 2.1** : Affichez le schéma du DataFrame.

4. **Question 2.2** : Sélectionnez uniquement les colonnes "nom" et "filiere".

5. **Question 2.3** : Filtrez les étudiants de la filière "Informatique".

6. **Question 2.4** : Comptez le nombre d'étudiants par filière.

### Exercice 2.2 : Spark SQL
**Objectif** : Utiliser SQL pour interroger des données.

1. Créez une vue temporaire :

```python
df.createOrReplaceTempView("etudiants")
```

2. **Question 2.5** : Écrivez une requête SQL pour afficher tous les étudiants de plus de 18 ans.

```python
result = spark.sql("SELECT ... FROM etudiants WHERE ...")
result.show()
```

3. **Question 2.6** : Calculez l'âge moyen par filière avec SQL.

---

## 📁 Partie 3 : Analyse de fichier CSV

### Exercice 3.1 : Chargement et analyse de données CSV
**Objectif** : Analyser un fichier de ventes.

Le fichier `ventes.csv` contient les colonnes suivantes :
- date, produit, categorie, quantite, prix_unitaire, ville

1. **Question 3.1** : Chargez le fichier CSV dans un DataFrame.

```python
df_ventes = spark.read.csv("/data/ventes.csv", header=True, inferSchema=True)
```

2. **Question 3.2** : Affichez les 10 premières lignes et le schéma.

3. **Question 3.3** : Calculez le chiffre d'affaires total (quantite × prix_unitaire).

4. **Question 3.4** : Trouvez les 5 produits les plus vendus.

5. **Question 3.5** : Calculez le chiffre d'affaires par catégorie et par ville.

6. **Question 3.6** : Identifiez la ville avec le plus gros chiffre d'affaires.

---

## 🎯 Partie 4 : Projet final - Analyse de logs

### Exercice 4.1 : Analyse de logs serveur

**Objectif** : Analyser des logs de serveur web Apache.

Le fichier `/data/logs.txt` contient des logs au format :
```
IP - - [Date] "METHOD /path HTTP/1.1" STATUS SIZE
```

1. **Question 4.1** : Chargez le fichier de logs et comptez le nombre total de requêtes.

2. **Question 4.2** : Comptez les requêtes par code de statut HTTP (200, 404, 500, etc.).

3. **Question 4.3** : Trouvez les 10 adresses IP les plus actives.

4. **Question 4.4** : Calculez le nombre de requêtes par heure de la journée.

5. **Question 4.5** : Identifiez les pages les plus consultées (path dans l'URL).

---

## 📝 Questions de réflexion

1. Quelle est la différence entre une transformation et une action dans Spark ?

2. Pourquoi utilise-t-on `cache()` ou `persist()` sur un RDD ou DataFrame ?

3. Quels sont les avantages des DataFrames par rapport aux RDDs ?

4. Dans quel cas utiliseriez-vous Spark plutôt que du traitement traditionnel ?

---

## 🎓 Livrable attendu

Créez un notebook Jupyter ou un script Python contenant :
- Toutes vos réponses aux exercices
- Le code commenté
- Les résultats d'exécution
- Vos réponses aux questions de réflexion

**Format** : `TP_Spark_NOM_Prenom.ipynb` ou `TP_Spark_NOM_Prenom.py`

---

**Bon travail !** 🚀
