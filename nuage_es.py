from wordcloud import WordCloud
import matplotlib.pyplot as plt

#Pour ouvrir le texte espagnol
with open("dumps-text/corpus_es.txt", encoding="utf-8") as f:
    texte = f.read()

#On crée le nuage de mots et son style
nuage = WordCloud(
    width=800,
    height=400,
    background_color="white"
).generate(texte)

#POur sauvegarder l'image
nuage.to_file("nuage_es.png")

#et enfin l'afficher
plt.imshow(nuage)
plt.axis("off")
plt.show()



