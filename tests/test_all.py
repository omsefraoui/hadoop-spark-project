#!/usr/bin/env python3
"""
Script principal pour tester toutes les technologies Big Data
Exécute les tests dans l'ordre : Spark → HBase → Hive
"""
import sys
import time
from datetime import datetime

# Import des modules de test
try:
    from test_spark import test_spark
    from test_hbase import test_hbase
    from test_hive import test_hive
except ImportError:
    print("⚠️  Ajoutez le dossier tests au PYTHONPATH")
    sys.path.insert(0, '/tests')
    from test_spark import test_spark
    from test_hbase import test_hbase
    from test_hive import test_hive

def print_header():
    print("\n" + "=" * 70)
    print(" " * 15 + "🚀 TEST COMPLET CLUSTER BIG DATA 🚀")
    print(" " * 10 + "Hadoop + Spark + HBase + Hive")
    print("=" * 70)
    print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70 + "\n")

def run_test(test_name, test_func):
    """Exécute un test et mesure le temps"""
    print(f"\n{'='*70}")
    print(f"▶️  TEST: {test_name}")
    print(f"{'='*70}")
    
    start_time = time.time()
    try:
        test_func()
        elapsed = time.time() - start_time
        print(f"\n✅ {test_name} terminé avec succès en {elapsed:.2f}s")
        return True, elapsed
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"\n❌ {test_name} a échoué après {elapsed:.2f}s")
        print(f"Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False, elapsed

def main():
    print_header()
    
    # Configuration des tests
    tests = [
        ("Apache Spark", test_spark),
        ("Apache HBase", test_hbase),
        ("Apache Hive", test_hive)
    ]
    
    # Résultats
    results = []
    total_start = time.time()
    
    # Exécuter chaque test
    for test_name, test_func in tests:
        success, elapsed = run_test(test_name, test_func)
        results.append((test_name, success, elapsed))
        
        if not success:
            print(f"\n⚠️  Test {test_name} échoué, mais on continue...")
        
        # Pause entre les tests
        if test_name != tests[-1][0]:
            print("\n⏸️  Pause 2 secondes...")
            time.sleep(2)
    
    # Résumé final
    total_elapsed = time.time() - total_start
    print("\n" + "=" * 70)
    print(" " * 25 + "📊 RÉSUMÉ DES TESTS")
    print("=" * 70)
    
    passed = sum(1 for _, success, _ in results if success)
    failed = len(results) - passed
    
    for test_name, success, elapsed in results:
        status = "✅ RÉUSSI" if success else "❌ ÉCHOUÉ"
        print(f"{status:12s} | {test_name:20s} | {elapsed:6.2f}s")
    
    print("-" * 70)
    print(f"Total: {passed}/{len(results)} tests réussis")
    print(f"Temps total: {total_elapsed:.2f}s")
    print("=" * 70)
    
    # Code de sortie
    if failed > 0:
        print(f"\n❌ {failed} test(s) ont échoué")
        sys.exit(1)
    else:
        print("\n✅ Tous les tests sont passés avec succès!")
        sys.exit(0)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Tests interrompus par l'utilisateur")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ Erreur fatale: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
