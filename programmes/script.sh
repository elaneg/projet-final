#!/bin/bash

fichier_urls=$1

#on vérifie que l'utilisateur a donné un argument
if [ "$#" -ne 1 ]; then
    echo "Erreur : Aucun argument. Veuillez indiquer un fichier"
    exit 1
fi

#on vérifie que le fichier rentré en argument est valide
if [ ! -f "$fichier_urls" ]; then
    echo "Erreur : fichier '$fichier_urls' introuvable."
    exit 1
fi

#on détecte la langue du corpus en fonction du nom du fichier d'urls
lang=$(basename "$fichier_urls" | sed 's/corpus_//' | sed 's/.txt//') 
#on enlève ce qu'il y a avant et après corpus pour isoler la langue

#le mot change selon la langue
case "$lang" in
  fr) mot="\<cultures?\>" ;;
  eng) mot="\<cultures?\>" ;;
  es) mot="\<culturas?\>" ;;
  *)
    echo "Langue inconnue $lang" #on gère les cas où la langue n'est pas reconnue
    exit 1
    ;;
esac

#creation des dossiers
mkdir -p ../aspirations ../dumps-text ../concordances ../tableaux ../contextes

#fichier de tableau qui change selon la langue
tableau="../tableaux/tableau-${lang}.html"


#on définit l'en-tête du tableau
cat > "$tableau" <<EOF
<!DOCTYPE html>
<html lang="$lang">
<head>
  <meta charset="UTF-8">
  <title>Tableau $lang</title>
  <link rel="stylesheet" href="../style.css">
</head>
<header>
<nav class="navbar">
<ul class="menu">
<li><a href="../index.html">Accueil</a></li>
  <li class="dropdown">
                <a href="#">Tableaux ▾</a>
                <ul class="dropdown-menu">
                    <li><a href="../tableaux/tableau-fr.html">Tableau français</a></li>
                    <li><a href="../tableaux/tableau-eng.html">Tableau anglais</a></li>
                    <li><a href="../tableaux/tableau-es.html">Tableau espagnol</a></li>
                </ul>
            </li>

            <li><a href="nuages/nuages.html">Nuages de mots</a></li>
</ul>
</nav>
</header>
<body>
<main>
<h1>Tableau d'analyse ($lang)</h1>
<table>
<tr>
  <th>Numéro</th>
  <th>URL</th>
  <th>Code</th>
  <th>Encodage</th>
  <th>Occurrences</th>
  <th>HTML</th>
  <th>Dump</th>
  <th>Concordance</th>
</tr>
EOF

#******************************************
#début de la boucle
#******************************************

#on initialise un compteur pour pouvoir numéroter les lignes
count=0

while read -r line || [ -n "$line" ]; do

  echo "Traitement $lang #$count"
  
   #on récupère quelques variables utiles, encodage & code http (on reprend ce qu'on a fait dans le miniprojet)
   data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o .data.tmp "$line")
   http_code=$(echo "$data" | head -1)
   encoding=$(echo "$data" | tail -1 | grep -Po "charset=\S+" | cut -d= -f2)
   #-------------------------

   #on rècupère le contenu de l'article et le met dans un fichier temporaire
   curl -Ls "$line" > temp.html  #Ls gère les redirections (http/https...)

         # gestion robuste de l'encodage
if [[ -n "$encoding" && "$encoding" != "UTF-8" && "$encoding" != "utf-8" ]]; then
      iconv -f "$encoding" -t utf-8 temp.html > temp_utf8.html 2>/dev/null || cp temp.html temp_utf8.html
  else
      cp temp.html temp_utf8.html
  fi


         #on stocke notre contenu html dans le dossier aspirations pour pouvoir l'afficher dans le tableau
         cp temp_utf8.html "../aspirations/${lang}_${count}.html"

            #on récupère les dumps textuels
             lynx -dump -nolist temp_utf8.html > "../dumps-text/${lang}_${count}.txt"

         #on récupère le texte de l'article et on compte
         nb_occurrences=$(egrep -i -o "$mot" "../dumps-text/${lang}_${count}.txt" | wc -l)


         # fichier de concordances
concord="../concordances/${lang}_${count}.html"

{
echo "<html>
<head>
<meta charset='UTF-8'>
<style>
table { border-collapse: collapse; width: 100%; }
td, th { border: 1px solid #ccc; padding: 6px; }
.mot { color: red; font-weight: bold; }
</style>
</head>
<body>

<h2>Concordancier - ${lang} - ${count}</h2>
<table>
<tr>
<th>Contexte gauche</th>
<th>Mot</th>
<th>Contexte droit</th>
</tr>"


egrep -o -i ".{0,40}${mot}.{0,40}" "../dumps-text/${lang}_${count}.txt" \
| sed -E "s/(.*)(${mot})(.*)/<tr><td>\1<\/td><td class=\"mot\">\2<\/td><td>\3<\/td><\/tr>/I"


echo "</table>
</body>
</html>"
} > "$concord"

#fichier de contexte qui récupère uniquement le contenu textuel des concordanciers pour le nuage de mots
contexte="../contextes/${lang}_${count}.txt"

egrep -i ".{0,40}${mot}.{0,40}" "../dumps-text/${lang}_${count}.txt" \
| sed -E "s/^(.{0,40})(${mot})(.{0,40})$/\1 | \2 | \3/I" \
> "$contexte"




 cat >> "$tableau" <<EOF
<tr>
  <td>$count</td>
  <td>$line</td>
  <td>$http_code</td>
  <td>$encoding</td>
  <td>$nb_occurrences</td>
  <td><a href="../aspirations/${lang}_${count}.html">html</a></td>
  <td><a href="../dumps-text/${lang}_${count}.txt">dump</a></td>
  <td><a href="../concordances/${lang}_${count}.html">concordance</a></td>
</tr>
EOF


#on met à jour le compteur
count=$((count + 1))

sleep 1 # pause 1 seconde entre chaque URL pour éviter les problèmes type code http 429

done < "$fichier_urls"

#******************************************
#fin de la boucle
#******************************************

cat >> "$tableau" <<EOF
</table>
</main>
</body>
</html>
EOF

rm -f temp.html temp_utf8.html .data.tmp
