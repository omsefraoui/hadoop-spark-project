#!/usr/bin/env python3
"""
TP2 - Partie 6 : Pipeline ETL Complet
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date, when, sum as spark_sum, count, round as spark_round

spark = SparkSession.builder.appName("ETL-Pipeline").master("yarn").enableHiveSupport().getOrCreate()

try:
    print("=" * 80)
    print("PIPELINE ETL - Extract Transform Load")
    print("=" * 80)
    
    # EXTRACT
    print("\n📖 EXTRACT - Lecture JSON...")
    df_raw = spark.read.json("hdfs://spark-master:9000/user/spark/data/sales.json")
    print(f"✅ {df_raw.count()} transactions chargées")
    df_raw.show()
    
    # TRANSFORM
    print("\n🔄 TRANSFORM - Enrichissement...")
    df = df_raw.withColumn("total_amount", col("quantity") * col("price"))
    df = df.withColumn("date", to_date(col("date")))
    df = df.withColumn("category",
        when(col("product") == "Laptop", "Electronics")
        .when(col("product").isin(["Mouse", "Keyboard"]), "Accessories")
        .when(col("product") == "Monitor", "Peripherals")
        .otherwise("Other")
    )
    df = df.withColumn("discount", 
        when(col("quantity") >= 3, col("total_amount") * 0.05).otherwise(0))
    df = df.withColumn("final_amount", col("total_amount") - col("discount"))
    
    print("✅ Transformations appliquées")
    df.show()
    
    # LOAD
    print("\n💾 LOAD - Sauvegarde dans Hive...")
    spark.sql("CREATE DATABASE IF NOT EXISTS sales_db")
    spark.sql("USE sales_db")
    df.write.mode("overwrite").saveAsTable("transactions")
    print("✅ Table 'transactions' créée")
    
    # Vues analytiques
    print("\n🔭 Création vues analytiques...")
    
    spark.sql("""
        CREATE OR REPLACE VIEW sales_by_region AS
        SELECT region, COUNT(*) as num_transactions,
               SUM(quantity) as total_quantity,
               ROUND(SUM(final_amount), 2) as total_revenue
        FROM transactions
        GROUP BY region
        ORDER BY total_revenue DESC
    """)
    
    spark.sql("""
        CREATE OR REPLACE VIEW sales_by_product AS
        SELECT product, category,
               COUNT(*) as num_sales,
               SUM(quantity) as total_units,
               ROUND(SUM(final_amount), 2) as total_revenue
        FROM transactions
        GROUP BY product, category
        ORDER BY total_revenue DESC
    """)
    
    print("✅ Vues créées")
    
    # Analyse
    print("\n📊 VENTES PAR RÉGION :")
    spark.sql("SELECT * FROM sales_by_region").show()
    
    print("\n📊 VENTES PAR PRODUIT :")
    spark.sql("SELECT * FROM sales_by_product").show()
    
    print("\n✅ Pipeline ETL terminé avec succès !")
    
finally:
    spark.stop()
