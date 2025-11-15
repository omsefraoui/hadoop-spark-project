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
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERREUR]${NC} $1"; }

# Vérifier les variables d'environnement
if [ -z "$HADOOP_HOME" ] || [ ! -d "$HADOOP_HOME" ]; then
    log_error "HADOOP_HOME non défini ou invalide. Êtes-vous dans le conteneur spark-master ?"
    exit 1
fi

# Répertoires HDFS locaux
NAME_DIR="$HADOOP_HOME/tmp/dfs/name/current"
DATA_DIR="$HADOOP_HOME/tmp/dfs/data/current"

log_info "HADOOP_HOME = $HADOOP_HOME"
[ -n "$HBASE_HOME" ] && log_info "HBASE_HOME  = $HBASE_HOME" || log_warn "HBASE_HOME non défini"
[ -n "$HIVE_HOME" ]  && log_info "HIVE_HOME   = $HIVE_HOME"  || log_warn "HIVE_HOME non défini"
[ -n "$SPARK_HOME" ] && log_info "SPARK_HOME  = $SPARK_HOME" || log_warn "SPARK_HOME non défini"

echo ""

############################
# 1. SSH
############################
log_info "1️⃣  Démarrage SSH..."
service ssh start >/dev/null 2>&1 || log_warn "SSH déjà démarré ?"
sleep 2

############################
# 2. Formatage NameNode si nécessaire
############################
if [ ! -d "$NAME_DIR" ]; then
    log_info "2️⃣  Formatage NameNode (première utilisation)..."
    "$HADOOP_HOME/bin/hdfs" namenode -format -force -nonInteractive
else
    log_info "2️⃣  NameNode déjà formaté, on continue..."
fi

############################
# 3. HDFS (NameNode + DataNode)
############################
log_info "3️⃣  Démarrage Hadoop HDFS (NameNode + DataNode)..."
"$HADOOP_HOME/sbin/start-dfs.sh"
sleep 5

# Vérifications HDFS
if jps | grep -q "NameNode"; then
    log_info "   ✅ NameNode démarré"
else
    log_warn "   ⚠️  NameNode non détecté"
fi

if jps | grep -q "DataNode"; then
    log_info "   ✅ DataNode démarré"
else
    log_warn "   ⚠️  DataNode non détecté – vérifier les logs dans $HADOOP_HOME/logs/*datanode*.log"
fi

############################
# 4. YARN (ResourceManager + NodeManagers distants)
############################
log_info "4️⃣  Démarrage YARN (ResourceManager + NodeManagers)..."
"$HADOOP_HOME/sbin/start-yarn.sh"
sleep 5

if jps | grep -q "ResourceManager"; then
    log_info "   ✅ ResourceManager démarré"
else
    log_warn "   ⚠️  ResourceManager non détecté"
fi

# 4bis. NodeManager local sur spark-master (important pour Spark/YARN)
log_info "4️⃣bis  Démarrage NodeManager local sur le master..."
"$HADOOP_HOME/bin/yarn" --daemon start nodemanager || \
  log_warn "   ⚠️  NodeManager local déjà démarré ?"
sleep 3

# Afficher la liste des nœuds YARN
log_info "   🔎 Nœuds YARN enregistrés :"
yarn node -list || log_warn "   ⚠️  Impossible de lister les nœuds YARN (vérifier ResourceManager)."

############################
# 5. Préparation HDFS (Hive + Spark logs)
############################
log_info "5️⃣  Création des répertoires HDFS nécessaires (Hive + Spark)..."
# Répertoires Hive
"$HADOOP_HOME/bin/hdfs" dfs -mkdir -p /tmp                || true
"$HADOOP_HOME/bin/hdfs" dfs -mkdir -p /user/hive/warehouse || true
"$HADOOP_HOME/bin/hdfs" dfs -chmod g+w /tmp                || true
"$HADOOP_HOME/bin/hdfs" dfs -chmod g+w /user/hive/warehouse || true
log_info "   ✅ Répertoires Hive créés / vérifiés"

# Répertoire Spark logs (pour spark.eventLog.dir = hdfs://spark-master:9000/spark-logs)
"$HADOOP_HOME/bin/hdfs" dfs -mkdir -p /spark-logs || true
"$HADOOP_HOME/bin/hdfs" dfs -chmod 1777 /spark-logs || true
log_info "   ✅ Répertoire /spark-logs créé / vérifié dans HDFS"

############################
# 6. ZooKeeper (option HBase embarqué)
############################
if [ -n "$HBASE_HOME" ] && [ -d "$HBASE_HOME" ]; then
    log_info "6️⃣  Démarrage ZooKeeper (via HBase)..."
    "$HBASE_HOME/bin/hbase-daemon.sh" start zookeeper || \
      log_warn "   ⚠️  ZooKeeper déjà démarré ou non disponible via HBase."
    sleep 3
else
    log_warn "6️⃣  HBASE_HOME non défini : ZooKeeper non démarré."
fi

############################
# 7. HBase (Master + RegionServer)
############################
if [ -n "$HBASE_HOME" ] && [ -d "$HBASE_HOME" ]; then
    log_info "7️⃣  Démarrage HBase..."
    "$HBASE_HOME/bin/start-hbase.sh"
    sleep 5

    if jps | grep -q "HMaster"; then
        log_info "   ✅ HBase Master démarré"
    else
        log_warn "   ⚠️  HBase Master non détecté"
    fi

    ############################
    # 8. Thrift HBase (pour Python, etc.)
    ############################
    log_info "8️⃣  Démarrage HBase Thrift Server..."
    "$HBASE_HOME/bin/hbase-daemon.sh" start thrift || \
      log_warn "   ⚠️  Thrift déjà démarré ?"
    sleep 3
    log_info "   ✅ Thrift Server démarré (port 9090)"
else
    log_warn "7️⃣  HBase/Thrift non démarrés (HBASE_HOME non défini)."
fi

############################
# 9. Hive (Metastore + HiveServer2)
############################
if [ -n "$HIVE_HOME" ] && [ -d "$HIVE_HOME" ]; then
    log_info "9️⃣  Initialisation Metastore Hive (si nécessaire)..."
    if [ ! -d "$HIVE_HOME/metastore_db" ]; then
        cd "$HIVE_HOME"
        "$HIVE_HOME/bin/schematool" -dbType derby -initSchema
        log_info "   ✅ Schema Hive initialisé"
    else
        log_info "   ✅ Schema Hive déjà existant"
    fi

    log_info "🔟 Démarrage Hive Metastore..."
    nohup "$HIVE_HOME/bin/hive" --service metastore > /var/log/hive-metastore.log 2>&1 &
    sleep 5
    log_info "   ✅ Metastore démarré"

    log_info "1️⃣1️⃣  Démarrage HiveServer2..."
    nohup "$HIVE_HOME/bin/hive" --service hiveserver2 > /var/log/hive-server2.log 2>&1 &
    sleep 5
    log_info "   ✅ HiveServer2 démarré (port 10000)"
else
    log_warn "9️⃣  Hive non démarré (HIVE_HOME non défini)."
fi

############################
# 10. Spark (Master + HistoryServer)
############################
if [ -n "$SPARK_HOME" ] && [ -d "$SPARK_HOME" ]; then
    log_info "1️⃣2️⃣  Démarrage Spark Master..."
    "$SPARK_HOME/sbin/start-master.sh"
    sleep 3

    if jps | grep -q "Master"; then
        log_info "   ✅ Spark Master démarré (web UI 8080, port 7077)"
    else
        log_warn "   ⚠️  Spark Master non détecté"
    fi

    log_info "1️⃣3️⃣  Démarrage Spark History Server..."
    "$SPARK_HOME/sbin/start-history-server.sh" || \
      log_warn "   ⚠️  History Server déjà démarré ?"
    sleep 3
    log_info "   ✅ History Server démarré (port 18080)"
else
    log_warn "1️⃣2️⃣  Spark non démarré (SPARK_HOME non défini)."
fi

############################
# Récapitulatif
############################
echo ""
echo "=========================================="
echo "✅ TOUS LES SERVICES ONT ÉTÉ LANCÉS (dans la mesure du possible)"
echo "=========================================="
echo ""

log_info "Services Java actifs (jps) :"
jps
echo ""

log_info "🌐 Interfaces Web (depuis la machine hôte, avec le bon port mappé Docker) :"
echo "   Hadoop NameNode:    http://localhost:9870"
echo "   YARN ResourceMgr:   http://localhost:8088"
echo "   NodeManager:        http://localhost:8042"
echo "   Spark Master:       http://localhost:8080"
echo "   Spark History:      http://localhost:18080"
echo "   HBase Master:       http://localhost:16010"
echo ""

log_info "🔌 Ports principaux des services :"
echo "   HDFS NameNode:      9000"
echo "   HBase Thrift:       9090"
echo "   HiveServer2:        10000"
echo "   Spark Master:       7077"
echo ""

log_info "📝 Pour tester Spark sur YARN :"
echo "   hdfs dfs -ls /"
echo "   spark-submit --master yarn /scripts/wordcount.py"
echo ""
