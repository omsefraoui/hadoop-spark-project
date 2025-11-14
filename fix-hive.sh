#!/bin/bash
# Script de correction du metastore Hive
set -e

echo "==================================="
echo "  FIX HIVE METASTORE"
echo "==================================="

# 1. Arrêter Hive s'il tourne
echo ">>> Arrêt de Hive..."
pkill -f HiveMetaStore || true
pkill -f HiveServer2 || true
sleep 3

# 2. Supprimer l'ancien metastore Derby
echo ">>> Nettoyage de l'ancien metastore..."
rm -rf /opt/hive/metastore_db
rm -rf /home/hadoop/metastore_db
rm -f derby.log

# 3. Créer les répertoires HDFS pour Hive
echo ">>> Création des répertoires HDFS..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp/hive
$HADOOP_HOME/bin/hdfs dfs -chmod 1777 /tmp
$HADOOP_HOME/bin/hdfs dfs -chmod 777 /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -chmod 777 /tmp/hive

# 4. Réinitialiser le schéma Derby
echo ">>> Initialisation du schéma Derby..."
cd /opt/hive
$HIVE_HOME/bin/schematool -dbType derby -initSchema

# 5. Démarrer le metastore
echo ">>> Démarrage du Metastore..."
nohup $HIVE_HOME/bin/hive --service metastore > /opt/hive/logs/metastore.log 2>&1 &
sleep 5

# 6. Démarrer HiveServer2
echo ">>> Démarrage de HiveServer2..."
nohup $HIVE_HOME/bin/hive --service hiveserver2 > /opt/hive/logs/hiveserver2.log 2>&1 &
sleep 5

echo ""
echo "✅ Hive corrigé et démarré !"
echo ""
echo "Vérifiez les logs :"
echo "  - tail -f /opt/hive/logs/metastore.log"
echo "  - tail -f /opt/hive/logs/hiveserver2.log"
echo ""
echo "Testez avec : hive -e 'SHOW DATABASES;'"
