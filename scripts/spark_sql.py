#!/usr/bin/env python3
"""
TP2 - Partie 3 : Spark SQL et DataFrames
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count, sum as spark_sum, round as spark_round

spark = SparkSession.builder.appName("SparkSQL-TP2").master("yarn").getOrCreate()

try:
    print("=" * 80)
    print("SPARK SQL - Analyse de Données")
    print("=" * 80)
    
    # Lecture des données
    df_employees = spark.read.csv(
        "hdfs://spark-master:9000/user/spark/data/employees.csv",
        header=True, inferSchema=True
    )
    
    df_departments = spark.read.csv(
        "hdfs://spark-master:9000/user/spark/data/departments.csv",
        header=True, inferSchema=True
    )
    
    print("\n📊 Table EMPLOYEES :")
    df_employees.show()
    
    print("\n🏗️ Schéma :")
    df_employees.printSchema()
    
    # Filtrage
    print("\n🔍 Employés avec salaire > 70000 :")
    df_employees.filter(col("salary") > 70000).show()
    
    # Agrégations
    print("\n📊 Statistiques par département :")
    df_employees.groupBy("department_id") \
        .agg(
            count("*").alias("nb_employes"),
            spark_round(avg("salary"), 2).alias("salaire_moyen")
        ).show()
    
    # Jointure
    df_departments_renamed = df_departments.withColumnRenamed("name", "dept_name")
    
    print("\n🔗 Jointure EMPLOYEES ⋈ DEPARTMENTS :")
    df_employees.join(
        df_departments_renamed,
        df_employees.department_id == df_departments_renamed.id,
        "inner"
    ).select(
        df_employees["name"],
        "dept_name",
        "location",
        "salary"
    ).show()
    
    # SQL
    df_employees.createOrReplaceTempView("employees")
    df_departments.createOrReplaceTempView("departments")
    
    print("\n📝 SQL - Top 3 salaires :")
    spark.sql("""
        SELECT e.name, d.name as department, e.salary
        FROM employees e
        JOIN departments d ON e.department_id = d.id
        ORDER BY e.salary DESC
        LIMIT 3
    """).show()
    
    print("\n✅ Analyse terminée !")
    
finally:
    spark.stop()
