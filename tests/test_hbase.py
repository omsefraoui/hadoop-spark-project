#!/usr/bin/env python3
"""
Test complet pour Apache HBase avec HappyBase
Teste : connexion, création table, insertion, lecture, scan, suppression
"""
import sys
import time
import happybase

def test_hbase():
    print("=" * 60)
    print("🗄️  TEST APACHE HBASE")
    print("=" * 60)
    
    # Connexion HBase
    print("\n1️⃣  Connexion à HBase...")
    try:
        connection = happybase.Connection('localhost', port=9090)
        print("✅ Connexion réussie à HBase Thrift Server")
    except Exception as e:
        print(f"❌ Erreur connexion: {e}")
        print("⚠️  Assurez-vous que HBase Thrift Server est démarré:")
        print("   hbase-daemon.sh start thrift")
        sys.exit(1)
    
    # Lister les tables existantes
    print("\n2️⃣  Liste des tables existantes...")
    tables = connection.tables()
    print(f"   Tables: {[t.decode() for t in tables]}")
    
    # Créer une table de test
    table_name = 'test_employees'
    print(f"\n3️⃣  Création table '{table_name}'...")
    
    # Supprimer si existe déjà
    if table_name.encode() in tables:
        print(f"   Table '{table_name}' existe déjà, suppression...")
        connection.delete_table(table_name, disable=True)
    
    # Créer nouvelle table
    families = {
        'personal': dict(),
        'professional': dict()
    }
    connection.create_table(table_name, families)
    print(f"✅ Table '{table_name}' créée avec familles: personal, professional")
    
    # Obtenir référence table
    table = connection.table(table_name)
    
    # Insertion de données
    print("\n4️⃣  Insertion de données...")
    employees = [
        ('emp001', {
            b'personal:name': b'Alice',
            b'personal:age': b'25',
            b'professional:salary': b'5000',
            b'professional:department': b'IT'
        }),
        ('emp002', {
            b'personal:name': b'Bob',
            b'personal:age': b'30',
            b'professional:salary': b'6000',
            b'professional:department': b'Sales'
        }),
        ('emp003', {
            b'personal:name': b'Charlie',
            b'personal:age': b'35',
            b'professional:salary': b'7000',
            b'professional:department': b'Marketing'
        })
    ]
    
    for row_key, data in employees:
        table.put(row_key, data)
        print(f"   ✅ Inséré: {row_key}")
    
    # Lecture d'une ligne
    print("\n5️⃣  Lecture d'une ligne (emp001)...")
    row = table.row(b'emp001')
    print("   Données:")
    for key, value in row.items():
        print(f"      {key.decode()}: {value.decode()}")
    
    # Scan de toutes les lignes
    print("\n6️⃣  Scan de toutes les lignes...")
    count = 0
    for key, data in table.scan():
        count += 1
        print(f"   Row: {key.decode()}")
        for col, val in data.items():
            print(f"      {col.decode()}: {val.decode()}")
    print(f"   Total lignes scannées: {count}")
    
    # Scan avec filtre par famille
    print("\n7️⃣  Scan avec filtre (famille 'personal')...")
    for key, data in table.scan(columns=[b'personal']):
        print(f"   Row: {key.decode()}")
        for col, val in data.items():
            print(f"      {col.decode()}: {val.decode()}")
    
    # Mise à jour
    print("\n8️⃣  Mise à jour (emp001 salary)...")
    table.put(b'emp001', {b'professional:salary': b'5500'})
    updated_row = table.row(b'emp001')
    new_salary = updated_row[b'professional:salary'].decode()
    print(f"   Nouveau salaire emp001: {new_salary}")
    assert new_salary == '5500', "Erreur mise à jour"
    
    # Suppression d'une ligne
    print("\n9️⃣  Suppression ligne (emp003)...")
    table.delete(b'emp003')
    remaining = list(table.scan())
    print(f"   Lignes restantes: {len(remaining)}")
    assert len(remaining) == 2, "Erreur suppression"
    
    # Nettoyage
    print("\n🧹 Nettoyage...")
    connection.delete_table(table_name, disable=True)
    print(f"   Table '{table_name}' supprimée")
    
    connection.close()
    
    print("\n" + "=" * 60)
    print("✅ TOUS LES TESTS HBASE RÉUSSIS!")
    print("=" * 60)
    return True

if __name__ == "__main__":
    try:
        test_hbase()
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
