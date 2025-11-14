# TP Apache HBase - Guide Étudiant

## 📚 Objectifs du TP
- Comprendre les concepts de base de HBase (tables, familles de colonnes, rowkey)
- Manipuler des données dans HBase avec Python (HappyBase)
- Effectuer des opérations CRUD
- Comprendre le modèle de données NoSQL orienté colonnes

## ⏱️ Durée estimée
2 heures

---

## 🔧 Prérequis

### Vérification de HBase
Dans le conteneur Docker, vérifiez que HBase fonctionne :
```bash
# Vérifier le statut
hbase version

# Accéder au shell HBase
hbase shell
```

Dans le shell HBase :
```ruby
status
list
exit
```

---

## 📖 Partie 1 : Découverte du shell HBase

### Exercice 1.1 : Commandes de base
**Objectif** : Se familiariser avec le shell HBase.

1. Lancez le shell HBase :
```bash
hbase shell
```

2. **Question 1.1** : Créez une table nommée `etudiants` avec deux familles de colonnes :
   - `info` : pour les informations personnelles
   - `notes` : pour les notes académiques

```ruby
create 'etudiants', 'info', 'notes'
```

3. **Question 1.2** : Vérifiez que la table a été créée :
```ruby
list
describe 'etudiants'
```

4. **Question 1.3** : Insérez des données dans la table :
```ruby
put 'etudiants', 'etud001', 'info:nom', 'Ahmed'
put 'etudiants', 'etud001', 'info:prenom', 'Hassan'
put 'etudiants', 'etud001', 'info:filiere', 'Informatique'
put 'etudiants', 'etud001', 'notes:math', '16'
put 'etudiants', 'etud001', 'notes:physique', '14'

put 'etudiants', 'etud002', 'info:nom', 'Fatima'
put 'etudiants', 'etud002', 'info:prenom', 'Zahra'
put 'etudiants', 'etud002', 'info:filiere', 'Mathématiques'
put 'etudiants', 'etud002', 'notes:math', '18'
put 'etudiants', 'etud002', 'notes:physique', '17'
```

5. **Question 1.4** : Récupérez toutes les données d'un étudiant :
```ruby
get 'etudiants', 'etud001'
```

6. **Question 1.5** : Récupérez uniquement la famille de colonnes `info` :
```ruby
get 'etudiants', 'etud001', {COLUMN => 'info'}
```

7. **Question 1.6** : Scannez toute la table :
```ruby
scan 'etudiants'
```

8. **Question 1.7** : Supprimez une cellule spécifique :
```ruby
delete 'etudiants', 'etud001', 'notes:physique'
```

9. **Question 1.8** : Désactivez et supprimez la table :
```ruby
disable 'etudiants'
drop 'etudiants'
```

---

## 🐍 Partie 2 : HBase avec Python (HappyBase)

### Exercice 2.1 : Connexion et opérations CRUD
**Objectif** : Manipuler HBase depuis Python.

1. Créez un script Python :
```python
import happybase

# Connexion à HBase
connection = happybase.Connection('localhost')
print("Tables disponibles:", connection.tables())
```

2. **Question 2.1** : Créez une table `produits` avec les familles de colonnes `info` et `stock` :

```python
# À compléter par l'étudiant
connection.create_table(
    'produits',
    {'info': dict(), 'stock': dict()}
)
```

3. **Question 2.2** : Insérez plusieurs produits dans la table :

```python
table = connection.table('produits')

# Insérer un produit
table.put(b'prod001', {
    b'info:nom': b'Ordinateur',
    b'info:marque': b'Dell',
    b'stock:quantite': b'50',
    b'stock:prix': b'8000'
})

# Insérer d'autres produits (à compléter)
```

4. **Question 2.3** : Récupérez et affichez un produit spécifique.

5. **Question 2.4** : Scannez tous les produits et affichez-les.

6. **Question 2.5** : Mettez à jour la quantité en stock d'un produit.

7. **Question 2.6** : Supprimez un produit de la table.

---

## 📊 Partie 3 : Gestion d'un système de capteurs IoT

### Exercice 3.1 : Base de données de capteurs
**Objectif** : Modéliser et stocker des données de capteurs de température.

1. **Question 3.1** : Créez une table `capteurs` avec :
   - Famille `localisation` : ville, batiment, salle
   - Famille `mesures` : temperature, humidite, timestamp

2. **Question 3.2** : Insérez des données de 5 capteurs différents.

3. **Question 3.3** : Récupérez toutes les mesures d'un capteur spécifique.

4. **Question 3.4** : Utilisez un scan avec filtre pour trouver tous les capteurs dans une ville donnée.

**Indice** : 
```python
for key, data in table.scan(filter="SingleColumnValueFilter('localisation', 'ville', =, 'binary:Oujda')"):
    print(key, data)
```

5. **Question 3.5** : Créez une fonction qui calcule la température moyenne de tous les capteurs.

---

## 🎯 Partie 4 : Projet final - Système de messagerie

### Exercice 4.1 : Mini-réseau social
**Objectif** : Créer un système de messages entre utilisateurs.

1. **Question 4.1** : Créez une table `messages` avec :
   - Famille `expediteur` : nom, id
   - Famille `contenu` : texte, timestamp
   - Famille `destinataire` : nom, id

2. **Question 4.2** : Utilisez des rowkeys au format : `userid_timestamp` pour trier chronologiquement.

3. **Question 4.3** : Implémentez les fonctions suivantes :
   - `envoyer_message(expediteur, destinataire, texte)`
   - `lire_messages(userid)` : affiche les N derniers messages
   - `compter_messages(userid)` : compte le nombre de messages

4. **Question 4.4** : Testez votre système avec au moins 10 messages entre 3 utilisateurs.

---

## 📝 Questions de réflexion

1. Quelle est la différence entre une base de données relationnelle et HBase ?

2. Comment choisir un bon rowkey dans HBase ?

3. Pourquoi HBase utilise-t-il des familles de colonnes ?

4. Dans quel cas utiliseriez-vous HBase plutôt qu'une base SQL ?

5. Comment HBase assure-t-il la scalabilité horizontale ?

---

## 🎓 Livrable attendu

Créez un script Python contenant :
- Toutes vos réponses aux exercices
- Le code commenté pour chaque partie
- Un fichier README expliquant comment exécuter votre code
- Vos réponses aux questions de réflexion

**Format** : `TP_HBase_NOM_Prenom.py` + `README.md`

---

**Bon travail !** 🚀
