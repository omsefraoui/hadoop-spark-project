#!/usr/bin/env python3
"""
TP2 - Complément : Types de Jointures
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, coalesce, lit

spark = SparkSession.builder.appName("SparkJoins-TP2").master("yarn").getOrCreate()

try:
    print("=" * 80)
    print("TYPES DE JOINTURES SPARK")
    print("=" * 80)
    
    # Chargement données
    df_emp = spark.read.csv(
        "hdfs://spark-master:9000/user/spark/data/employees.csv",
        header=True, inferSchema=True
    )
    
    df_dept = spark.read.csv(
        "hdfs://spark-master:9000/user/spark/data/departments.csv",
        header=True, inferSchema=True
    ).withColumnRenamed("name", "dept_name")
    
    # INNER JOIN
    print("\n🔗 INNER JOIN :")
    inner = df_emp.join(df_dept, df_emp.department_id == df_dept.id, "inner") \
        .select(df_emp["name"], "dept_name", "location", "salary")
    inner.show()
    print(f"Lignes : {inner.count()}")
    
    # LEFT JOIN
    print("\n🔗 LEFT JOIN :")
    left = df_emp.join(df_dept, df_emp.department_id == df_dept.id, "left") \
        .select(df_emp["name"], coalesce("dept_name", lit("N/A")).alias("dept"), "salary")
    left.show()
    print(f"Lignes : {left.count()}")
    
    # RIGHT JOIN
    print("\n🔗 RIGHT JOIN :")
    right = df_emp.join(df_dept, df_emp.department_id == df_dept.id, "right") \
        .select(coalesce(df_emp["name"], lit("No employee")).alias("employee"), "dept_name")
    right.show()
    print(f"Lignes : {right.count()}")
    
    # FULL OUTER JOIN
    print("\n🔗 FULL OUTER JOIN :")
    full = df_emp.join(df_dept, df_emp.department_id == df_dept.id, "full") \
        .select(
            coalesce(df_emp["name"], lit("No emp")).alias("employee"),
            coalesce("dept_name", lit("No dept")).alias("department")
        )
    full.show()
    print(f"Lignes : {full.count()}")
    
    print("\n✅ Démonstration des jointures terminée !")
    
finally:
    spark.stop()
