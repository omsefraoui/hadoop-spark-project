# Dockerfile v4.0 - Optimisé pour Connexions Lentes
# Téléchargement automatique avec retry et miroirs multiples

FROM ubuntu:20.04

LABEL maintainer="Omar Sefraoui"
LABEL description="Hadoop 3.3.6 + Spark 3.5.0 + Hive 3.1.3 + HBase 2.5.5"
LABEL version="4.0"

ENV DEBIAN_FRONTEND=noninteractive

# Versions
ENV HADOOP_VERSION=3.3.6
ENV SPARK_VERSION=3.5.0
ENV HIVE_VERSION=3.1.3
ENV HBASE_VERSION=2.5.5

# Chemins
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV HIVE_HOME=/opt/hive
ENV HBASE_HOME=/opt/hbase

ENV PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$HIVE_HOME/bin:$HBASE_HOME/bin:$PATH

ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

# ============================================
# PACKAGES SYSTÈME + ARIA2 (téléchargeur rapide)
# ============================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    wget \
    aria2 \
    ssh \
    rsync \
    python3 \
    python3-pip \
    procps \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# PYTHON
# ============================================

RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    pyspark==3.5.0 \
    pandas \
    numpy \
    py4j

# ============================================
# Netcat
# ============================================


RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    openssh-server \
    curl wget vim \
    netcat-openbsd \
    # ... le reste de tes paquets ...
 && rm -rf /var/lib/apt/lists/*


# ============================================
# FONCTION DE TÉLÉCHARGEMENT OPTIMISÉE
# ============================================

# Créer un script de téléchargement intelligent
RUN echo '#!/bin/bash\n\
URL=$1\n\
OUTPUT=$2\n\
echo "Téléchargement: $OUTPUT..."\n\
\n\
# Essayer aria2c dabord (16 connexions parallèles)\n\
if command -v aria2c &> /dev/null; then\n\
    aria2c --max-connection-per-server=16 --split=16 --min-split-size=1M \\\n\
           --max-tries=10 --retry-wait=3 --timeout=60 \\\n\
           --continue=true --allow-overwrite=true \\\n\
           -o "$OUTPUT" "$URL" && echo "✓ Téléchargé avec aria2c" && exit 0\n\
fi\n\
\n\
# Fallback wget avec options optimales\n\
wget --tries=10 --waitretry=5 --retry-connrefused \\\n\
     --read-timeout=60 --timeout=30 --continue \\\n\
     -O "$OUTPUT" "$URL" && echo "✓ Téléchargé avec wget" && exit 0\n\
\n\
echo "❌ Échec téléchargement" && exit 1\n\
' > /usr/local/bin/download.sh && chmod +x /usr/local/bin/download.sh

# ============================================
# TÉLÉCHARGEMENT HADOOP (avec miroirs multiples)
# ============================================

RUN echo "=== HADOOP ${HADOOP_VERSION} ===" && \
    (/usr/local/bin/download.sh \
        "https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
        "/tmp/hadoop.tar.gz" || \
     /usr/local/bin/download.sh \
        "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
        "/tmp/hadoop.tar.gz") && \
    echo "Extraction..." && \
    tar -xzf /tmp/hadoop.tar.gz -C /tmp && \
    mv /tmp/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm /tmp/hadoop.tar.gz && \
    echo "✓ Hadoop installé avec succès"

# ============================================
# TÉLÉCHARGEMENT SPARK (avec miroirs multiples)
# ============================================

RUN echo "=== SPARK ${SPARK_VERSION} ===" && \
    (/usr/local/bin/download.sh \
        "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" \
        "/tmp/spark.tgz" || \
     /usr/local/bin/download.sh \
        "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" \
        "/tmp/spark.tgz") && \
    echo "Extraction..." && \
    tar -xzf /tmp/spark.tgz -C /tmp && \
    mv /tmp/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} && \
    rm /tmp/spark.tgz && \
    echo "✓ Spark installé avec succès"

# ============================================
# TÉLÉCHARGEMENT HIVE (avec miroirs multiples)
# ============================================

RUN echo "=== HIVE ${HIVE_VERSION} ===" && \
    (/usr/local/bin/download.sh \
        "https://dlcdn.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
        "/tmp/hive.tar.gz" || \
     /usr/local/bin/download.sh \
        "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
        "/tmp/hive.tar.gz") && \
    echo "Extraction..." && \
    tar -xzf /tmp/hive.tar.gz -C /tmp && \
    mv /tmp/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} && \
    rm /tmp/hive.tar.gz && \
    echo "✓ Hive installé avec succès"

# ============================================
# TÉLÉCHARGEMENT HBASE (avec miroirs multiples)
# ============================================

RUN echo "=== HBASE ${HBASE_VERSION} ===" && \
    (/usr/local/bin/download.sh \
        "https://dlcdn.apache.org/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz" \
        "/tmp/hbase.tar.gz" || \
     /usr/local/bin/download.sh \
        "https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz" \
        "/tmp/hbase.tar.gz") && \
    echo "Extraction..." && \
    tar -xzf /tmp/hbase.tar.gz -C /tmp && \
    mv /tmp/hbase-${HBASE_VERSION} ${HBASE_HOME} && \
    rm /tmp/hbase.tar.gz && \
    echo "✓ HBase installé avec succès"

# ============================================
# CONFIGURATION SSH
# ============================================

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    echo "UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config

# ============================================
# CONFIGURATION JAVA
# ============================================

RUN echo "export JAVA_HOME=${JAVA_HOME}" >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    echo "export JAVA_HOME=${JAVA_HOME}" >> ${SPARK_HOME}/conf/spark-env.sh

# ============================================
# COPIE DES CONFIGURATIONS
# ============================================

COPY config/hadoop/core-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY config/hadoop/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY config/hadoop/mapred-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY config/hadoop/yarn-site.xml ${HADOOP_HOME}/etc/hadoop/
COPY config/hadoop/workers ${HADOOP_HOME}/etc/hadoop/

COPY config/spark/spark-defaults.conf ${SPARK_HOME}/conf/
COPY config/spark/spark-env.sh ${SPARK_HOME}/conf/
RUN chmod +x ${SPARK_HOME}/conf/spark-env.sh

COPY config/hive/hive-site.xml ${HIVE_HOME}/conf/
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> ${HIVE_HOME}/conf/hive-env.sh

COPY config/hbase/hbase-site.xml ${HBASE_HOME}/conf/
COPY config/hbase/regionservers ${HBASE_HOME}/conf/
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> ${HBASE_HOME}/conf/hbase-env.sh

# ============================================
# SCRIPTS ET DONNÉES
# ============================================

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.py

COPY data/ /data/
RUN chmod 644 /data/*

COPY start-master.sh /start-master.sh
COPY start-worker.sh /start-worker.sh
RUN chmod +x /start-master.sh /start-worker.sh

# ============================================
# RÉPERTOIRES
# ============================================

RUN mkdir -p /opt/hadoop/dfs/name && \
    mkdir -p /opt/hadoop/dfs/data && \
    mkdir -p /opt/hive/warehouse && \
    mkdir -p /opt/spark/logs && \
    mkdir -p /tmp/hive && \
    chmod -R 777 /opt/hadoop/dfs && \
    chmod -R 777 /opt/hive/warehouse && \
    chmod -R 777 /opt/spark/logs && \
    chmod -R 777 /tmp/hive

# ============================================
# DRIVER JDBC
# ============================================

RUN wget -q --tries=5 --timeout=30 \
    https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.24/postgresql-42.2.24.jar \
    -O ${HIVE_HOME}/lib/postgresql-jdbc.jar || echo "Warning: JDBC driver download failed"

# ============================================
# RÉSOLUTION CONFLITS
# ============================================

RUN rm -f ${HIVE_HOME}/lib/guava-*.jar && \
    cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-*.jar ${HIVE_HOME}/lib/

# ============================================
# PORTS
# ============================================

EXPOSE 9870 9000 9864 9866
EXPOSE 8088 8042 8030 8031 8032 8033
EXPOSE 8080 7077 8081 4040 18080
EXPOSE 10000 10002 9083
EXPOSE 16010 16020 16030 2181
EXPOSE 22

# ============================================
# ENVIRONNEMENT
# ============================================

RUN echo "export JAVA_HOME=${JAVA_HOME}" >> ~/.bashrc && \
    echo "export HADOOP_HOME=${HADOOP_HOME}" >> ~/.bashrc && \
    echo "export SPARK_HOME=${SPARK_HOME}" >> ~/.bashrc && \
    echo "export HIVE_HOME=${HIVE_HOME}" >> ~/.bashrc && \
    echo "export HBASE_HOME=${HBASE_HOME}" >> ~/.bashrc && \
    echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$HIVE_HOME/bin:$HBASE_HOME/bin' >> ~/.bashrc

# ============================================
# HIVE METASTORE
# ============================================

RUN ${HIVE_HOME}/bin/schematool -initSchema -dbType derby || true

# ============================================
# NETTOYAGE
# ============================================

RUN rm -f /usr/local/bin/download.sh

WORKDIR /opt

CMD ["/bin/bash"]
