# 🚀 Hadoop Spark Project - TP2

## 📦 Structure du Projet

```
hadoop-spark-project/
├── docker-compose.yml          ✅ Mis à jour (sans 'version')
├── Dockerfile                  
├── start-master.sh            
├── start-worker.sh            
├── config/
│   ├── hadoop/                
│   ├── spark/                 
│   ├── hive/                  
│   └── hbase/                 
├── data/
│   ├── employees.csv          ✅ Créé
│   ├── departments.csv        ✅ Créé
│   ├── sales.json             ✅ Créé
│   └── spark_data.txt         ✅ Créé
└── scripts/
    ├── wordcount.py           ✅ Créé (Partie 2)
    ├── spark_sql.py           ⏳ À créer (Partie 3)
    ├── spark_hive.py          ⏳ À créer (Partie 4)
    ├── spark_joins.py         ⏳ À créer (Complément)
    └── etl_pipeline.py        ⏳ À créer (Partie 6)
```

## 🎯 Prochaines Étapes

### 1. Compléter les Scripts Python

Les scripts suivants sont disponibles dans `outputs/scripts_updated/` et doivent être copiés :

- `spark_sql.py` - Partie 3 du TP (DataFrames et SQL)
- `spark_hive.py` - Partie 4 du TP (Intégration Hive)
- `spark_joins.py` - Jointures avancées
- `etl_pipeline.py` - Pipeline ETL complet (Partie 6)

### 2. Construire l'Image Docker

```powershell
cd C:\Users\Minfo\hadoop-spark-project
docker build -t omsefraoui/hadoop-spark-cluster:latest .
```

### 3. Tester Localement

```powershell
docker-compose up -d
# Attendre 2-3 minutes
docker ps
# Ouvrir http://localhost:8080
docker-compose down
```

### 4. Publier sur Docker Hub

```powershell
docker login
docker push omsefraoui/hadoop-spark-cluster:latest
```

## 📝 Notes

- docker-compose.yml a été mis à jour (attribut 'version' supprimé)
- Tous les fichiers de données sont prêts
- Script wordcount.py est complet et fonctionnel

## 📚 Documentation

Consultez les guides dans le dossier outputs/ :
- PACKAGE_COMPLET_README.md
- GUIDE_ENSEIGNANT_BUILD_IMAGE.md
- COMMANDES_RAPIDES.md
