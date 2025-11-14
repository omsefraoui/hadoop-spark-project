#!/usr/bin/env python3
"""
TP2 - Partie 5 : HBase et Stockage NoSQL
Guide d'utilisation de HBase avec commandes shell
"""

print("""
=" * 80)
HBASE - Stockage NoSQL Columnar
=" * 80)

Ce script guide vous aide à manipuler HBase via le shell.
HBase doit être utilisé via 'hbase shell' pour les opérations.

COMMANDES HBASE À EXÉCUTER MANUELLEMENT:
==========================================

1. Se connecter au shell HBase:
   $ hbase shell

2. Créer une table avec 2 familles de colonnes:
   hbase> create 'employees_hbase', 'personal', 'professional'

3. Insérer des données:
   hbase> put 'employees_hbase', '1', 'personal:name', 'Alice'
   hbase> put 'employees_hbase', '1', 'personal:age', '30'
   hbase> put 'employees_hbase', '1', 'professional:title', 'Engineer'
   hbase> put 'employees_hbase', '1', 'professional:salary', '75000'

4. Lire les données:
   hbase> get 'employees_hbase', '1'
   hbase> scan 'employees_hbase'

5. Lister les tables:
   hbase> list

6. Décrire une table:
   hbase> describe 'employees_hbase'

7. Supprimer une donnée:
   hbase> delete 'employees_hbase', '1', 'personal:age'

8. Supprimer une table:
   hbase> disable 'employees_hbase'
   hbase> drop 'employees_hbase'

=" * 80)
EXERCICE 5.1 : Créer une table 'products'
=" * 80)

Créez une table 'products' avec:
- Column Family 'info' (name, category, description)
- Column Family 'pricing' (price, discount, currency)

Commandes à exécuter:

hbase> create 'products', 'info', 'pricing'

hbase> put 'products', 'p001', 'info:name', 'Laptop Dell'
hbase> put 'products', 'p001', 'info:category', 'Electronics'
hbase> put 'products', 'p001', 'pricing:price', '1200'
hbase> put 'products', 'p001', 'pricing:discount', '10%'

hbase> put 'products', 'p002', 'info:name', 'Mouse Logitech'
hbase> put 'products', 'p002', 'info:category', 'Accessories'
hbase> put 'products', 'p002', 'pricing:price', '25'

hbase> scan 'products'

=" * 80)
MODÈLE DE DONNÉES HBASE
=" * 80)

Table: products
├─ Row Key: p001
│  ├─ Column Family: info
│  │  ├─ info:name = "Laptop Dell"
│  │  └─ info:category = "Electronics"
│  └─ Column Family: pricing
│     ├─ pricing:price = "1200"
│     └─ pricing:discount = "10%"
│
└─ Row Key: p002
   ├─ Column Family: info
   │  ├─ info:name = "Mouse Logitech"
   │  └─ info:category = "Accessories"
   └─ Column Family: pricing
      └─ pricing:price = "25"

Caractéristiques:
- Row Key: Clé primaire unique (p001, p002)
- Column Family: Groupe de colonnes défini à la création
- Column: famille:qualificateur (dynamique)
- Valeurs stockées comme bytes

=" * 80)

Pour exécuter ces commandes:
1. Connectez-vous au conteneur: docker exec -it spark-master bash
2. Lancez le shell HBase: hbase shell
3. Exécutez les commandes ci-dessus

""")
