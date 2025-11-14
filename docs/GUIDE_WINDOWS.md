# 🚀 Guide Windows - Hadoop Spark Cluster

## 📋 Prérequis

- ✅ Docker Desktop installé et démarré
- ✅ WSL 2 activé (recommandé)
- ✅ Au moins 8 GB RAM disponibles

## 🏗️ 1. Construction de l'image Docker

### Méthode 1: Build simple
```powershell
cd C:\Users\Minfo\hadoop-spark-project
docker build -t omsefraoui/hadoop-spark-cluster:latest .
```

### Méthode 2: Build avec cache (recommandé pour développement)
```powershell
# Activer BuildKit
$env:DOCKER_BUILDKIT=1

# Build avec cache
docker build `
  --cache-from omsefraoui/hadoop-spark-cluster:latest `
  -t omsefraoui/hadoop-spark-cluster:latest .
```

### Méthode 3: Build script PowerShell (automatisé)
```powershell
.\build.ps1
```

## 🐳 2. Lancement du conteneur

### Option A: Lancement simple
```powershell
docker run -it --name hadoop-cluster `
  -p 9870:9870 `
  -p 8088:8088 `
  -p 18080:18080 `
  -p 16010:16010 `
  -p 10000:10000 `
  -p 4040:4040 `
  omsefraoui/hadoop-spark-cluster:latest
```

### Option B: Avec docker-compose (recommandé)
```powershell
docker-compose up -d
```

## ⏳ 3. Vérifier que les services démarrent

Les services prennent **2-3 minutes** pour démarrer. Attendez avant de tester.

### Vérifier les logs
```powershell
docker logs -f hadoop-cluster
```

Attendez de voir ces messages :
```
>>> Starting HDFS
>>> Starting YARN
>>> Starting HBase
>>> Starting Hive Metastore & HiveServer2
>>> Starting Spark History Server
>>> Services running:
```

### Accéder aux interfaces Web (depuis Windows)
Ouvrez votre navigateur :
- **HDFS NameNode**: http://localhost:9870
- **YARN ResourceManager**: http://localhost:8088
- **Spark History**: http://localhost:18080
- **HBase Master**: http://localhost:16010

## 🧪 4. Exécuter les tests Python

### Se connecter au conteneur
```powershell
docker exec -it hadoop-cluster bash
```

### Dans le conteneur, lancer les tests

#### Test complet (tous les services)
```bash
cd /tests
python3 test_all.py
```

#### Tests individuels
```bash
# Test Spark uniquement
python3 test_spark.py

# Test HBase uniquement
python3 test_hbase.py

# Test Hive uniquement
python3 test_hive.py
```

## 📊 5. Exemples d'utilisation

### Spark - Traitement de données
```bash
cd /scripts
python3 spark_sql.py          # Requêtes SQL
python3 spark_joins.py        # Jointures
python3 spark_hbase.py       # Intégration Spark + HBase
python3 spark_hive.py        # Intégration Spark + Hive
```

### HBase - NoSQL columnar
```bash
# Shell HBase interactif
hbase shell

# Dans le shell HBase:
create 'test_table', 'cf'
put 'test_table', 'row1', 'cf:name', 'Alice'
scan 'test_table'
```

### Hive - Data Warehouse
```bash
# Beeline (client Hive)
beeline -u "jdbc:hive2://localhost:10000"

# Dans Beeline:
SHOW DATABASES;
CREATE TABLE test (id INT, name STRING);
INSERT INTO test VALUES (1, 'Alice');
SELECT * FROM test;
```

## 🛠️ 6. Dépannage Windows

### Problème: Port déjà utilisé
```powershell
# Trouver le processus utilisant un port
netstat -ano | findstr :9870

# Arrêter le processus (remplacer PID)
taskkill /PID <PID> /F
```

### Problème: Conteneur ne démarre pas
```powershell
# Voir les logs
docker logs hadoop-cluster

# Redémarrer avec logs en temps réel
docker restart hadoop-cluster && docker logs -f hadoop-cluster
```

### Problème: Services lents à démarrer
```powershell
# Attendre 3-5 minutes après le démarrage
# Vérifier la mémoire disponible
docker stats hadoop-cluster
```

### Problème: Tests Python échouent
```bash
# Dans le conteneur, vérifier les services
jps  # Doit montrer: NameNode, DataNode, ResourceManager, etc.

# Vérifier HDFS
hdfs dfs -ls /

# Vérifier HBase
echo "status" | hbase shell
```

## 🗑️ 7. Nettoyage

### Arrêter le conteneur
```powershell
docker stop hadoop-cluster
```

### Supprimer le conteneur
```powershell
docker rm hadoop-cluster
```

### Supprimer l'image
```powershell
docker rmi omsefraoui/hadoop-spark-cluster:latest
```

### Nettoyage complet Docker
```powershell
# Attention: supprime TOUT ce qui n'est pas utilisé
docker system prune -a --volumes
```

## 📤 8. Publication sur DockerHub

### Se connecter à DockerHub
```powershell
docker login
# Entrez: omsefraoui
# Mot de passe: votre_token
```

### Publier l'image
```powershell
docker push omsefraoui/hadoop-spark-cluster:latest
```

### Taguer une version spécifique
```powershell
docker tag omsefraoui/hadoop-spark-cluster:latest omsefraoui/hadoop-spark-cluster:v1.0
docker push omsefraoui/hadoop-spark-cluster:v1.0
```

## 🎓 9. Pour les étudiants

### Télécharger l'image déjà construite
```powershell
# Pas besoin de builder, téléchargez directement
docker pull omsefraoui/hadoop-spark-cluster:latest

# Lancer
docker run -it --name hadoop-tp `
  -p 9870:9870 -p 8088:8088 -p 18080:18080 `
  -p 16010:16010 -p 10000:10000 `
  omsefraoui/hadoop-spark-cluster:latest
```

### Workflow TP classique
1. **Démarrer** le conteneur
2. **Attendre 3 minutes** que les services démarrent
3. **Tester les interfaces Web**
4. **Exécuter** `python3 /tests/test_all.py`
5. **Faire** vos exercices dans `/scripts`
6. **Arrêter** proprement avec `Ctrl+C` puis `docker stop hadoop-tp`

## 📞 Support

- **Documentation**: Voir `/docs` dans le conteneur
- **Logs**: `docker logs -f hadoop-cluster`
- **Issues**: https://github.com/omsefraoui/hadoop-spark-project

---
**Auteur**: Omar Sefraoui - ENSAO  
**Version**: 1.0  
**Date**: 2025
