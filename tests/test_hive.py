#!/usr/bin/env python3
"""
Test complet pour Apache Hive avec PyHive
Teste : connexion, création database/table, insertion, requêtes SQL
"""
import sys
from pyhive import hive

def test_hive():
    print("=" * 60)
    print("🐝 TEST APACHE HIVE")
    print("=" * 60)
    
    # Connexion Hive
    print("\n1️⃣  Connexion à Hive...")
    try:
        conn = hive.Connection(host='localhost', port=10000, username='root')
        cursor = conn.cursor()
        print("✅ Connexion réussie à HiveServer2")
    except Exception as e:
        print(f"❌ Erreur connexion: {e}")
        print("⚠️  Assurez-vous que HiveServer2 est démarré:")
        print("   hive --service hiveserver2 &")
        sys.exit(1)
    
    # Créer database
    db_name = 'test_db'
    print(f"\n2️⃣  Création database '{db_name}'...")
    cursor.execute(f"DROP DATABASE IF EXISTS {db_name} CASCADE")
    cursor.execute(f"CREATE DATABASE {db_name}")
    cursor.execute(f"USE {db_name}")
    print(f"✅ Database '{db_name}' créée et sélectionnée")
    
    # Créer table
    print("\n3️⃣  Création table 'employees'...")
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS employees (
            id INT,
            name STRING,
            age INT,
            salary DOUBLE,
            department STRING
        )
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
        STORED AS TEXTFILE
    """)
    print("✅ Table 'employees' créée")
    
    # Insertion de données
    print("\n4️⃣  Insertion de données...")
    employees = [
        (1, 'Alice', 25, 5000.0, 'IT'),
        (2, 'Bob', 30, 6000.0, 'Sales'),
        (3, 'Charlie', 35, 7000.0, 'Marketing'),
        (4, 'David', 28, 5500.0, 'IT'),
        (5, 'Eve', 32, 6500.0, 'Finance')
    ]
    
    for emp in employees:
        cursor.execute(f"""
            INSERT INTO employees VALUES 
            ({emp[0]}, '{emp[1]}', {emp[2]}, {emp[3]}, '{emp[4]}')
        """)
        print(f"   ✅ Inséré: {emp[1]}")
    
    # SELECT simple
    print("\n5️⃣  SELECT tous les employés...")
    cursor.execute("SELECT * FROM employees")
    results = cursor.fetchall()
    print("   ID | Nom      | Âge | Salaire | Département")
    print("   " + "-" * 50)
    for row in results:
        print(f"   {row[0]:2d} | {row[1]:8s} | {row[2]:3d} | {row[3]:7.0f} | {row[4]}")
    
    # Agrégation
    print("\n6️⃣  Agrégation - Salaire moyen...")
    cursor.execute("SELECT AVG(salary) as avg_salary FROM employees")
    avg_sal = cursor.fetchone()[0]
    print(f"   Salaire moyen: {avg_sal:.2f}")
    
    # GROUP BY
    print("\n7️⃣  GROUP BY département...")
    cursor.execute("""
        SELECT department, COUNT(*) as count, AVG(salary) as avg_salary
        FROM employees
        GROUP BY department
        ORDER BY count DESC
    """)
    print("   Département  | Nombre | Salaire Moyen")
    print("   " + "-" * 40)
    for row in cursor.fetchall():
        print(f"   {row[0]:12s} | {row[1]:6d} | {row[2]:13.2f}")
    
    # WHERE clause
    print("\n8️⃣  WHERE - Employés avec salaire > 6000...")
    cursor.execute("SELECT name, salary FROM employees WHERE salary > 6000")
    for row in cursor.fetchall():
        print(f"   {row[0]}: {row[1]}")
    
    # JOIN avec table departments (on va la créer)
    print("\n9️⃣  Test JOIN...")
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS departments (
            dept_name STRING,
            location STRING
        )
    """)
    cursor.execute("INSERT INTO departments VALUES ('IT', 'Building A')")
    cursor.execute("INSERT INTO departments VALUES ('Sales', 'Building B')")
    cursor.execute("INSERT INTO departments VALUES ('Marketing', 'Building C')")
    
    cursor.execute("""
        SELECT e.name, e.salary, d.location
        FROM employees e
        JOIN departments d ON e.department = d.dept_name
        WHERE e.salary > 5500
    """)
    print("   Nom      | Salaire | Localisation")
    print("   " + "-" * 40)
    for row in cursor.fetchall():
        print(f"   {row[0]:8s} | {row[1]:7.0f} | {row[2]}")
    
    # Nettoyage
    print("\n🧹 Nettoyage...")
    cursor.execute(f"DROP DATABASE {db_name} CASCADE")
    print(f"   Database '{db_name}' supprimée")
    
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 60)
    print("✅ TOUS LES TESTS HIVE RÉUSSIS!")
    print("=" * 60)
    return True

if __name__ == "__main__":
    try:
        test_hive()
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
