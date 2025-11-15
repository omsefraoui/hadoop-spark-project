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

# Fonctions de log
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Vérifier que nous sommes dans le conteneur (Hadoop présent)
if [ -z "$HADOOP_HOME" ] || [ ! -d "$HADOOP_HOME" ]; then
    echo "❌ Erreur: HADOOP_HOME non défini ou invalide. Êtes-vous dans le conteneur ?"
    exit 1
fi

# Répertoire du NameNode (aligné avec les logs Hadoop)
NAME_DIR="$HADOOP_HOME/tmp/dfs/name/current"

# Fonction utilitaire : tester si un NameNode tourne déjà
is_namenode_running() {
    jps | grep -q "NameNode"
}

echo ""
log_info "Configuration détectée :"
echo "   HADOOP_HOME = $HADOOP_HOME"
echo "   HBASE_HOME  = ${HBASE_HOME:-<non défini>}"
echo "   HIVE_HOME   = ${HIVE_HOME:-<non défini>}"
echo "   SPARK_HOME  = ${SPARK_HOME:-<non défini>}"
echo ""

# 1️⃣  Démarrer SSH
log_info "1️⃣  Démarrage SSH..."
service ssh start || log_warn "   ⚠️  Impossible de démarrer SSH (peut-être déjà lancé)."
sleep 2

# 2️⃣  Formatage NameNode si nécessaire (UNE SEULE FOIS)
if is_namenode_running; then
    log_warn "2️⃣  NameNode déjà en cours d'exécution, on saute le formatage."
elif [ ! -d "$NAME_DIR" ]; then
    log_info "2️⃣  Formatage NameNode (première utilisation)..."
    "$HADOOP_HOME/bin/hdfs" namenode -format -force -nonInteractive
else
    log_info "2️⃣  NameNode déjà formaté, on continue..."
fi


# Préparer les répertoires locaux HDFS (NameNode / DataNode)
DATA_DIR="$HADOOP_HOME/tmp/dfs/data"
NAME_DIR="$HADOOP_HOME/tmp/dfs/name"

log_info "   Préparation des répertoires HDFS locaux..."
mkdir -p "$DATA_DIR" "$NAME_DIR"
chown -R root:root "$HADOOP_HOME/tmp" || true
log_info "   ✅ Répertoires HDFS locaux prêts"


# 3️⃣  Démarrage Hadoop HDFS
log_info "3️⃣  Démarrage Hadoop HDFS (NameNode + DataNode)..."
"$HADOOP_HOME/sbin/start-dfs.sh"

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

# 4️⃣  Démarrage YARN
log_info "4️⃣  Démarrage YARN..."
"$HADOOP_HOME/sbin/start-yarn.sh"
sleep 5

if jps | grep -q "ResourceManager"; then
    log_info "   ✅ ResourceManager démarré"
else
    log_warn "   ⚠️  ResourceManager non détecté"
fi

if jps | grep -q "NodeManager"; then
    log_info "   ✅ NodeManager démarré"
else
    log_warn "   ⚠️  NodeManager non détecté"
fi

# 5️⃣  Création des répertoires HDFS pour Hive et Spark...
log_info "5️⃣  Création des répertoires HDFS pour Hive et Spark..."

# Chemins simples (fs.defaultFS)
"$HADOOP_HOME/bin/hdfs" dfs -mkdir -p /tmp || true
"$HADOOP_HOME/bin/hdfs" dfs -mkdir -p /user/hive/warehouse || true
"$HADOOP_HOME/bin/hdfs" dfs -mkdir -p /spark-logs || true

"$HADOOP_HOME/bin/hdfs" dfs -chmod g+w /tmp || true
"$HADOOP_HOME/bin/hdfs" dfs -chmod g+w /user/hive/warehouse || true
"$HADOOP_HOME/bin/hdfs" dfs -chmod 777 /spark-logs || true

# Chemin complet utilisé par Spark pour les event logs
"$HADOOP_HOME/bin/hdfs" dfs -mkdir -p "hdfs://spark-master:9000/spark-logs" || true
"$HADOOP_HOME/bin/hdfs" dfs -chmod 777 "hdfs://spark-master:9000/spark-logs" || true

log_info "   ✅ Répertoires Hive et Spark créés / vérifiés"

# 6️⃣  ZooKeeper + HBase
if [ -z "$HBASE_HOME" ] || [ ! -d "$HBASE_HOME" ]; then
    log_warn "6️⃣  HBASE_HOME non défini, ZooKeeper/HBase ne seront pas démarrés."
else
    HBASE_ENV="$HBASE_HOME/conf/hbase-env.sh"

    # 6.1 Démarrage ZooKeeper si non géré automatiquement par HBase
    if [ -f "$HBASE_ENV" ] && grep -q "^[[:space:]]*export[[:space:]]\+HBASE_MANAGES_ZK *= *true" "$HBASE_ENV" 2>/dev/null; then
        log_info "6️⃣  HBASE_MANAGES_ZK=true : ZooKeeper sera démarré par HBase."
    else
        log_info "6️⃣  Démarrage ZooKeeper pour HBase..."
        "$HBASE_HOME/bin/hbase-daemon.sh" start zookeeper || log_warn "   ⚠️  Problème au démarrage de ZooKeeper (peut-être déjà lancé)."
        sleep 3
    fi

    # 7️⃣  Démarrage HBase (HMaster + RegionServer)
    log_info "7️⃣  Démarrage HBase..."
    "$HBASE_HOME/bin/start-hbase.sh"
    sleep 5

    if jps | grep -q "HMaster"; then
        log_info "   ✅ HBase Master démarré"
    else
        log_warn "   ⚠️  HBase Master non détecté"
    fi

    if jps | grep -q "HRegionServer"; then
        log_info "   ✅ HBase RegionServer démarré"
    else
        log_warn "   ⚠️  HBase RegionServer non détecté"
    fi

    # 8️⃣  Démarrage HBase Thrift Server (pour les clients Python, etc.)
    log_info "8️⃣  Démarrage HBase Thrift Server..."
    "$HBASE_HOME/bin/hbase-daemon.sh" start thrift || log_warn "   ⚠️  Échec (ou déjà démarré) pour Thrift."
    sleep 3
    log_info "   ✅ Thrift Server supposé démarré (port 9090)"
fi

# 9️⃣  Initialisation et services Hive
if [ -z "$HIVE_HOME" ] || [ ! -d "$HIVE_HOME" ]; then
    log_warn "9️⃣  HIVE_HOME non défini, Hive ne sera pas initialisé."
else
    log_info "9️⃣  Initialisation du Metastore Hive (si nécessaire)..."
    if [ ! -d "$HIVE_HOME/metastore_db" ]; then
        cd "$HIVE_HOME"
        "$HIVE_HOME/bin/schematool" -dbType derby -initSchema
        log_info "   ✅ Schéma Hive initialisé"
    else
        log_info "   ✅ Schéma Hive déjà existant"
    fi

    # 🔟 Démarrage Hive Metastore
    log_info "🔟 Démarrage Hive Metastore..."
    nohup "$HIVE_HOME/bin/hive" --service metastore > /var/log/hive-metastore.log 2>&1 &
    sleep 5
    log_info "   ✅ Metastore démarré"

    # 1️⃣1️⃣  Démarrage HiveServer2
    log_info "1️⃣1️⃣  Démarrage HiveServer2..."
    nohup "$HIVE_HOME/bin/hive" --service hiveserver2 > /var/log/hive-server2.log 2>&1 &
    sleep 5
    log_info "   ✅ HiveServer2 démarré (port 10000)"
fi

# 1️⃣2️⃣  Démarrage Spark (Master + History Server)
# Si SPARK_HOME n'est pas défini, essayer de le déduire à partir de spark-shell
if [ -z "$SPARK_HOME" ] || [ ! -d "$SPARK_HOME" ]; then
    if command -v spark-shell >/dev/null 2>&1; then
        SPARK_BIN="$(command -v spark-shell)"
        SPARK_HOME="$(dirname "$(dirname "$SPARK_BIN")")"
        log_info "1️⃣2️⃣  SPARK_HOME déduit automatiquement : $SPARK_HOME"
    else
        log_warn "1️⃣2️⃣  SPARK_HOME non défini et spark-shell introuvable, Spark ne sera pas démarré."
    fi
fi

if [ -n "$SPARK_HOME" ] && [ -d "$SPARK_HOME" ]; then
    log_info "1️⃣2️⃣  Démarrage Spark Master..."
    "$SPARK_HOME/sbin/start-master.sh" || log_warn "   ⚠️  Échec au démarrage du Spark Master."
    sleep 3

    if jps | grep -q "Master"; then
        log_info "   ✅ Spark Master démarré (port 8080)"
    else
        log_warn "   ⚠️  Spark Master non détecté"
    fi

    log_info "1️⃣3️⃣  Démarrage Spark History Server..."
    "$SPARK_HOME/sbin/start-history-server.sh" || log_warn "   ⚠️  History Server non démarré (vérifier les logs)."
    sleep 2
    log_info "   ✅ History Server demandé (port 18080)"
else
    log_warn "1️⃣2️⃣  SPARK_HOME invalide, Spark ne sera pas démarré."
fi

echo ""
echo "=========================================="
echo "✅ TOUS LES SERVICES ONT ÉTÉ LANCÉS"
echo "=========================================="
echo ""

# Afficher les services actifs
log_info "Services Java actifs (jps) :"
jps

echo ""
log_info "🌐 URLs des interfaces Web (dans le conteneur) :"
echo "   Hadoop NameNode:    http://localhost:9870"
echo "   YARN ResourceMgr:   http://localhost:8088"
echo "   Spark Master:       http://localhost:8080"
echo "   Spark History:      http://localhost:18080"
echo "   HBase Master:       http://localhost:16010"
echo ""

log_info "🔌 Ports des services :"
echo "   HDFS NameNode:      9000"
echo "   HBase Thrift:       9090"
echo "   HiveServer2:        10000"
echo "   Spark Master:       7077"
echo ""

log_info "📝 Pour tester rapidement :"
echo "   - hdfs dfs -ls /"
echo "   - hive          (CREATE TABLE / SELECT)"
echo "   - hbase shell   (create/get)"
echo "   - spark-shell   (RDD simple)"
echo ""
