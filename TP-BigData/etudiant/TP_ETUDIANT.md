# TP Big Data : Spark, HBase et Hive
## Travaux Pratiques - Manuel Étudiant

**Durée :** 4 heures  
**Objectifs :**
- Maîtriser les opérations de base avec Apache Spark
- Manipuler des données NoSQL avec HBase
- Interroger des données avec Hive et SparkSQL

---

## 📋 Prérequis

### Installation et démarrage du conteneur

1. **Télécharger l'image Docker :**
```bash
docker pull omsefraoui/hadoop-spark-cluster:latest
```

2. **Démarrer le conteneur :**
```bash
docker run -dit --name bigdata-tp \
  -p 9870:9870 -p 8088:8088 -p 8080:8080 \
  -p 18080:18080 -p 16010:16010 -p 10000:10000 \
  omsefraoui/hadoop-spark-cluster:latest
```

3. **Entrer dans le conteneur :**
```bash
docker exec -it bigdata-tp bash
```

4. **Vérifier que les services sont démarrés :**
```bash
# Vérifier HDFS
hdfs dfs -ls /

# Vérifier Spark
spark-shell --version

# Vérifier HBase
hbase shell
> status
> exit

# Vérifier Hive (si erreur, exécuter /fix-hive.sh)
hive -e "SHOW DATABASES;"
```

---

## 🔥 PARTIE 1 : Apache Spark (1h30)

### Exercice 1.1 : Découverte de PySpark (15 min)

**Objectif :** Créer votre premier programme Spark


**Étape 1 : Lancer PySpark**
```bash
pyspark
```

**Étape 2 : Créer un RDD et effectuer des transformations**
```python
# Créer un RDD simple
data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
rdd = sc.parallelize(data)

# Transformation : doubler chaque nombre
rdd_double = rdd.map(lambda x: x * 2)

# Action : afficher les résultats
print(rdd_double.collect())

# Filtrer les nombres pairs
rdd_pairs = rdd.filter(lambda x: x % 2 == 0)
print("Nombres pairs:", rdd_pairs.collect())

# Calculer la somme
total = rdd.reduce(lambda a, b: a + b)
print("Somme:", total)
```

**Questions :**
1. Quelle est la différence entre une transformation et une action ?
2. Pourquoi utilise-t-on `collect()` ?
3. Modifiez le code pour calculer le carré de chaque nombre

---

### Exercice 1.2 : Analyse de fichier texte (20 min)

**Objectif :** Analyser un fichier avec Spark

