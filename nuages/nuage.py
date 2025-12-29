import sys
import os
from wordcloud import WordCloud, STOPWORDS
import matplotlib.pyplot as plt

# Vérification de l’argument
if len(sys.argv) != 2:
    print("Usage : python nuage.py <langue>")
    print("Exemple : python nuage.py es")
    sys.exit(1)

lang = sys.argv[1]

# Chemins
context_dir = "../contextes"
output_dir = "../images"
output_file = f"{output_dir}/nuage_{lang}.png"


# Vérifications

if not os.path.isdir(context_dir):
    print("Erreur : dossier contextes introuvable")
    sys.exit(1)

os.makedirs(output_dir, exist_ok=True)

# Lecture de tous les fichiers contextes de la langue
texte = ""

for fichier in os.listdir(context_dir):
    if fichier.startswith(f"{lang}_") and fichier.endswith(".txt"):
        with open(os.path.join(context_dir, fichier), encoding="utf-8", errors="ignore") as f:
            texte += f.read() + " "

if texte.strip() == "":
    print(f"Aucun contexte trouvé pour la langue : {lang}")
    sys.exit(1)
#Ajout de la liste de stopwords pour éviter les mots "inutiles"
stopwords = set(STOPWORDS)
stopwords.update([
    # Français
    "le","il", "entre", "leur","cette","ce","chaque","comment","ou","se","peut","elle","dans","aux","comme","culturelles","culturelle","ainsi","ls","ainsi","qu","par","sa","son","d","par","autre","culturels","qui","que","pour","plus","sur","l","culturel","culturelle", "la", "les", "de", "des", "en","définition","ne","sont","Paris","Frane","l'Agriculture", "du", "et", "est", "à","avec","lle","être", "un", "une",
    "permet","chez","fait","donc","bien",
    # Anglais
    "or", "with", "use", "used", "men", "the", "a", "an", "in", "of","may","cultured","cultural","for"
    # Espagnol
    "del", "que", "o", "y", "el", "la", "de", "en","las","para","e","lo","como","una","uno","es","los","por","su","culturales"
])
#on l'ajustera au fur et à mesure selon nos résultats

# Création du nuage
nuage = WordCloud(
    width=1000,
    height=500,
    background_color="black",
    stopwords=stopwords
).generate(texte)

# Sauvegarde
nuage.to_file(output_file)

# Affichage
plt.figure(figsize=(12, 6))
plt.imshow(nuage)
plt.axis("off")
plt.show()

print(f"Nuage généré : {output_file}")




