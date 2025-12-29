import sys
import os
from wordcloud import WordCloud
import matplotlib.pyplot as plt

# ----------------------------
# Vérification de l’argument
# ----------------------------
if len(sys.argv) != 2:
    print("Usage : python nuage.py <langue>")
    print("Exemple : python nuage.py es")
    sys.exit(1)

lang = sys.argv[1]

# ----------------------------
# Chemins
# ----------------------------
dumps_dir = "../dumps-text"
output_dir = "../images"
output_file = f"{output_dir}/nuage_{lang}.png"

# ----------------------------
# Vérifications
# ----------------------------
if not os.path.isdir(dumps_dir):
    print("Erreur : dossier dumps-text introuvable")
    sys.exit(1)

os.makedirs(output_dir, exist_ok=True)

# ----------------------------
# Lecture de tous les dumps de la langue
# ----------------------------
texte = ""

for fichier in os.listdir(dumps_dir):
    if fichier.startswith(f"{lang}_") and fichier.endswith(".txt"):
        with open(os.path.join(dumps_dir, fichier), encoding="utf-8", errors="ignore") as f:
            texte += f.read() + " "

if texte.strip() == "":
    print(f"Aucun dump trouvé pour la langue : {lang}")
    sys.exit(1)

# ----------------------------
# Création du nuage
# ----------------------------
nuage = WordCloud(
    width=1000,
    height=500,
    background_color="white"
).generate(texte)

# ----------------------------
# Sauvegarde
# ----------------------------
nuage.to_file(output_file)

# ----------------------------
# Affichage
# ----------------------------
plt.figure(figsize=(12, 6))
plt.imshow(nuage)
plt.axis("off")
plt.show()

print(f"Nuage généré : {output_file}")




