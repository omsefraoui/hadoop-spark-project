#!/bin/bash
# Script de démarrage automatique de tous les services Big Data
# Hadoop + Spark + HBase + Hive + Kafka

set -e

echo "=========================================="
echo "  Démarrage des services Big Data"
echo "=========================================="

# Démarrage SSH
echo "[1/6] Démarrage SSH..."
service ssh start
sleep 2

# Formatage et démarrage HDFS (première fois seulement)
if [ ! -d "/data/hadoop/namenode/current" ]; then
    echo "[2/6] Formatage HDFS (première exécution)..."
    $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
fi

echo "[2/6] Démarrage HDFS..."
$HADOOP_HOME/sbin/start-dfs.sh
sleep 5

# Création des répertoires HDFS nécessaires
echo "[3/6] Configuration HDFS..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp/hive
$HADOOP_HOME/bin/hdfs dfs -chmod g+w /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -chmod g+w /tmp/hive
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /hbase

# Démarrage HBase
echo "[4/6] Démarrage HBase..."
$HBASE_HOME/bin/start-hbase.sh
sleep 5

# Initialisation et démarrage Hive
if [ ! -f "/tmp/hive/.initialized" ]; then
    echo "[5/6] Initialisation Hive (première exécution)..."
    $HIVE_HOME/bin/schematool -dbType derby -initSchema
    touch /tmp/hive/.initialized
fi

echo "[5/6] Démarrage HiveServer2..."
nohup $HIVE_HOME/bin/hiveserver2 > /tmp/hiveserver2.log 2>&1 &
sleep 5

# Démarrage Kafka avec Zookeeper
echo "[6/6] Démarrage Zookeeper et Kafka..."
nohup $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > /tmp/zookeeper.log 2>&1 &
sleep 5
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /tmp/kafka.log 2>&1 &
sleep 5

echo ""
echo "=========================================="
echo "  ✅ Tous les services sont démarrés !"
echo "=========================================="
echo ""
echo "Services disponibles:"
echo "  - Hadoop NameNode UI:  http://localhost:9870"
echo "  - Spark Master UI:     http://localhost:8080"
echo "  - HBase Master UI:     http://localhost:16010"
echo "  - Hive Server:         localhost:10000"
echo "  - Hive Web UI:         http://localhost:10002"
echo "  - Kafka Broker:        localhost:9092"
echo ""
echo "Vérification de l'état des services:"
echo ""

# Vérification HDFS
if $HADOOP_HOME/bin/hdfs dfsadmin -report > /dev/null 2>&1; then
    echo "  ✅ HDFS: Opérationnel"
else
    echo "  ❌ HDFS: Problème détecté"
fi

# Vérification HBase
if echo "status" | $HBASE_HOME/bin/hbase shell > /dev/null 2>&1; then
    echo "  ✅ HBase: Opérationnel"
else
    echo "  ❌ HBase: Problème détecté"
fi

# Vérification Kafka
if $KAFKA_HOME/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092 > /dev/null 2>&1; then
    echo "  ✅ Kafka: Opérationnel"
else
    echo "  ❌ Kafka: Problème détecté"
fi

echo ""
echo "Pour tester les services: /usr/local/bin/test-all.sh"
echo ""

# Garder le container actif
tail -f /dev/null
