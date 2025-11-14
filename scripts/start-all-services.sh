#!/bin/bash
# Script de démarrage de tous les services Big Data
# Usage: ./start-all-services.sh

set -e

echo "=========================================="
echo "🚀 DÉMARRAGE CLUSTER BIG DATA"
echo "=========================================="
echo ""

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Vérifier que nous sommes dans le conteneur
if [ ! -d "$HADOOP_HOME" ]; then
    echo "❌ Erreur: HADOOP_HOME non défini. Êtes-vous dans le conteneur?"
    exit 1
fi

# 1. Démarrer SSH
log_info "1️⃣  Démarrage SSH..."
service ssh start
sleep 2

# 2. Formater NameNode si nécessaire
if [ ! -d "/opt/hadoop/dfs/name/current" ]; then
    log_info "2️⃣  Formatage NameNode (première utilisation)..."
    $HADOOP_HOME/bin/hdfs namenode -format -force
else
    log_info "2️⃣  NameNode déjà formaté, on continue..."
fi

# 3. Démarrer Hadoop HDFS
log_info "3️⃣  Démarrage Hadoop HDFS..."
$HADOOP_HOME/sbin/start-dfs.sh
sleep 5

# Vérifier HDFS
if jps | grep -q "NameNode"; then
    log_info "   ✅ NameNode démarré"
else
    log_warn "   ⚠️  NameNode non détecté"
fi

if jps | grep -q "DataNode"; then
    log_info "   ✅ DataNode démarré"
else
    log_warn "   ⚠️  DataNode non détecté"
fi

# 4. Démarrer YARN
log_info "4️⃣  Démarrage YARN..."
$HADOOP_HOME/sbin/start-yarn.sh
sleep 5

if jps | grep -q "ResourceManager"; then
    log_info "   ✅ ResourceManager démarré"
fi

if jps | grep -q "NodeManager"; then
    log_info "   ✅ NodeManager démarré"
fi

# 5. Créer répertoires HDFS pour Hive
log_info "5️⃣  Création répertoires HDFS pour Hive..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -chmod g+w /tmp
$HADOOP_HOME/bin/hdfs dfs -chmod g+w /user/hive/warehouse
log_info "   ✅ Répertoires Hive créés"

# 6. Démarrer HBase
log_info "6️⃣  Démarrage HBase..."
$HBASE_HOME/bin/start-hbase.sh
sleep 5

if jps | grep -q "HMaster"; then
    log_info "   ✅ HBase Master démarré"
else
    log_warn "   ⚠️  HBase Master non détecté"
fi

# 7. Démarrer HBase Thrift Server (pour Python)
log_info "7️⃣  Démarrage HBase Thrift Server..."
$HBASE_HOME/bin/hbase-daemon.sh start thrift
sleep 3
log_info "   ✅ Thrift Server démarré (port 9090)"

# 8. Initialiser schema Hive (si première fois)
log_info "8️⃣  Initialisation Metastore Hive..."
if [ ! -d "$HIVE_HOME/metastore_db" ]; then
    cd $HIVE_HOME
    $HIVE_HOME/bin/schematool -dbType derby -initSchema
    log_info "   ✅ Schema Hive initialisé"
else
    log_info "   ✅ Schema Hive déjà existant"
fi

# 9. Démarrer Hive Metastore
log_info "9️⃣  Démarrage Hive Metastore..."
nohup $HIVE_HOME/bin/hive --service metastore > /var/log/hive-metastore.log 2>&1 &
sleep 5
log_info "   ✅ Metastore démarré"

# 10. Démarrer HiveServer2
log_info "🔟 Démarrage HiveServer2..."
nohup $HIVE_HOME/bin/hive --service hiveserver2 > /var/log/hive-server2.log 2>&1 &
sleep 5
log_info "   ✅ HiveServer2 démarré (port 10000)"

# 11. Démarrer Spark Master
log_info "1️⃣1️⃣  Démarrage Spark Master..."
$SPARK_HOME/sbin/start-master.sh
sleep 3

if jps | grep -q "Master"; then
    log_info "   ✅ Spark Master démarré (port 8080)"
fi

# 12. Démarrer Spark History Server
log_info "1️⃣2️⃣  Démarrage Spark History Server..."
$SPARK_HOME/sbin/start-history-server.sh
sleep 2
log_info "   ✅ History Server démarré (port 18080)"

echo ""
echo "=========================================="
echo "✅ TOUS LES SERVICES SONT DÉMARRÉS"
echo "=========================================="
echo ""

# Afficher les services actifs
log_info "Services Java actifs:"
jps

echo ""
log_info "🌐 URLs des interfaces Web:"
echo "   Hadoop NameNode:    http://localhost:9870"
echo "   YARN ResourceMgr:   http://localhost:8088"
echo "   Spark Master:       http://localhost:8080"
echo "   Spark History:      http://localhost:18080"
echo "   HBase Master:       http://localhost:16010"
echo ""

log_info "🔌 Ports des services:"
echo "   HDFS NameNode:      9000"
echo "   HBase Thrift:       9090"
echo "   HiveServer2:        10000"
echo "   Spark Master:       7077"
echo ""

log_info "📝 Pour tester, exécutez:"
echo "   cd /tests && python3 test_all.py"
echo ""
