#!/bin/bash
echo "=== Démarrage MASTER ==="
service ssh start
sleep 10
for node in spark-worker1 spark-worker2; do ssh-keyscan -H $node >> ~/.ssh/known_hosts 2>/dev/null; done
if [ ! -d "/opt/hadoop/dfs/name/current" ]; then $HADOOP_HOME/bin/hdfs namenode -format -force; fi
$HADOOP_HOME/sbin/start-dfs.sh
sleep 15
$HADOOP_HOME/sbin/start-yarn.sh
sleep 10
hdfs dfs -mkdir -p /spark-event-logs /user/hive/warehouse
hdfs dfs -chmod 777 /spark-event-logs /user/hive/warehouse
$SPARK_HOME/sbin/start-master.sh
$SPARK_HOME/sbin/start-history-server.sh
cd $HIVE_HOME && schematool -dbType derby -initSchema 2>/dev/null || true
nohup hive --service metastore &
$HBASE_HOME/bin/start-hbase.sh
echo "=== CLUSTER PRÊT ==="
tail -f /dev/null
