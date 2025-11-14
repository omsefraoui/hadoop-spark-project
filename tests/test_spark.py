#!/usr/bin/env python3
"""
Test PySpark - Hadoop TP2
Teste les fonctionnalités de base de Spark avec HDFS
"""

from pyspark.sql import SparkSession
import sys

def test_spark_basic():
    """Test 1: Création de SparkSession et opérations de base"""
    print("\n" + "="*60)
    print("TEST 1: Spark Session et RDD de base")
    print("="*60)
    
    spark = SparkSession.builder \
        .appName("Test Spark Basic") \
        .master("local[*]") \
        .getOrCreate()
    
    print(f"✓ Spark Session créée: {spark.version}")
    
    # Test RDD
    data = [1, 2, 3, 4, 5]
    rdd = spark.sparkContext.parallelize(data)
    result = rdd.map(lambda x: x * 2).collect()
    print(f"✓ RDD map test: {result}")
    assert result == [2, 4, 6, 8, 10], "RDD map failed"
    
    spark.stop()
    print("✓ Test 1 réussi\n")

def test_spark_dataframe():
    """Test 2: DataFrame operations"""
    print("="*60)
    print("TEST 2: Spark DataFrame")
    print("="*60)
    
    spark = SparkSession.builder \
        .appName("Test Spark DataFrame") \
        .master("local[*]") \
        .getOrCreate()
    
    # Créer un DataFrame
    data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
    df = spark.createDataFrame(data, ["name", "age"])
    
    print("✓ DataFrame créé:")
    df.show()
    
    # Filtrer
    filtered = df.filter(df.age > 25)
    print("✓ Filtrage (age > 25):")
    filtered.show()
    
    # Agréger
    avg_age = df.agg({"age": "avg"}).collect()[0][0]
    print(f"✓ Age moyen: {avg_age}")
    assert avg_age == 30.0, "Average calculation failed"
    
    spark.stop()
    print("✓ Test 2 réussi\n")

def test_spark_sql():
    """Test 3: Spark SQL"""
    print("="*60)
    print("TEST 3: Spark SQL")
    print("="*60)
