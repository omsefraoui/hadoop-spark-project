#!/usr/bin/env python3
"""
TP2 - Partie 4 : Intégration Spark avec Hive
"""

from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("SparkHive-TP2") \
    .master("yarn") \
    .enableHiveSupport() \
    .getOrCreate()

try:
    print("=" * 80)
    print("SPARK + HIVE - Entreposage de Données")
    print("=" * 80)
    
    # Création base de données
    spark.sql("CREATE DATABASE IF NOT EXISTS company")
    spark.sql("USE company")
    print("\n✅ Base 'company' créée/sélectionnée")
    
    # Chargement CSV
    df_employees = spark.read.csv(
        "hdfs://spark-master:9000/user/spark/data/employees.csv",
        header=True, inferSchema=True
    )
    
    # Sauvegarde en table Hive (Parquet)
    print("\n💾 Création table Hive en format Parquet...")
    df_employees.write.mode("overwrite").saveAsTable("employees")
    print("✅ Table 'employees' créée")
    
    # Afficher les tables
    print("\n📋 Tables dans 'company' :")
    spark.sql("SHOW TABLES").show()
    
    # Requête SQL
    print("\n📝 SELECT * FROM employees WHERE salary > 70000 :")
    spark.sql("""
        SELECT name, salary, department_id 
        FROM employees 
        WHERE salary > 70000
        ORDER BY salary DESC
    """).show()
    
    # Création vue
    print("\n🔭 Création vue 'high_earners'...")
    spark.sql("""
        CREATE OR REPLACE VIEW high_earners AS
        SELECT name, salary, department_id
        FROM employees
        WHERE salary > 70000
    """)
    
    spark.sql("SELECT * FROM high_earners").show()
    
    print("\n✅ Intégration Spark-Hive réussie !")
    
finally:
    spark.stop()
