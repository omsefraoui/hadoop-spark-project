#!/usr/bin/env python3
"""
TP2 - Partie 2 : Word Count avec Spark
Programme de comptage de mots utilisant les RDD Spark
"""

from pyspark import SparkContext, SparkConf
import sys

def main():
    # Configuration Spark
    conf = SparkConf().setAppName("WordCount-TP2")
    sc = SparkContext(conf=conf)
    
    try:
        print("=" * 60)
        print("WORD COUNT - Traitement Big Data avec Spark")
        print("=" * 60)
        
        # Chemin du fichier dans HDFS
        input_path = "hdfs://spark-master:9000/user/spark/data/spark_data.txt"
        
        print(f"\n📖 Lecture du fichier : {input_path}")
        
        # Lecture du fichier
        lines = sc.textFile(input_path)
        
        # Transformations
        print("\n🔄 Application des transformations...")
        
        # 1. flatMap : Découper chaque ligne en mots
        words = lines.flatMap(lambda line: line.split())
        
        # 2. map : Créer des paires (mot, 1)
        word_pairs = words.map(lambda word: (word, 1))
        
        # 3. reduceByKey : Agréger les comptages
        word_counts = word_pairs.reduceByKey(lambda a, b: a + b)
        
        # Action : Collecter les résultats
        print("\n📊 Collecte des résultats...")
        results = word_counts.collect()
        
        # Trier par fréquence décroissante
        sorted_results = sorted(results, key=lambda x: -x[1])
        
        # Affichage des résultats
        print("\n" + "=" * 60)
        print("RÉSULTATS DU COMPTAGE")
        print("=" * 60)
        print(f"{'Mot':<30} | {'Fréquence':>10}")
        print("-" * 60)
        
        for word, count in sorted_results:
            print(f"{word:<30} | {count:>10}")
        
        print("-" * 60)
        print(f"Total de mots uniques : {len(results)}")
        print(f"Total d'occurrences : {sum(count for _, count in results)}")
        print("=" * 60)
        
        # Sauvegarder les résultats dans HDFS
        output_path = "hdfs://spark-master:9000/user/spark/output/wordcount"
        print(f"\n💾 Sauvegarde des résultats dans : {output_path}")
        
        # Supprimer le répertoire de sortie s'il existe
        import subprocess
        subprocess.run(["hdfs", "dfs", "-rm", "-r", output_path], 
                      stderr=subprocess.DEVNULL)
        
        # Sauvegarder
        word_counts.saveAsTextFile(output_path)
        print("✅ Résultats sauvegardés avec succès !")
        
    except Exception as e:
        print(f"\n❌ ERREUR : {str(e)}", file=sys.stderr)
        sys.exit(1)
    finally:
        # Arrêt du SparkContext
        sc.stop()
        print("\n🏁 Fin du traitement\n")

if __name__ == "__main__":
    main()
