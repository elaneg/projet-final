#!/bin/bash

fichier_urls=$1

#on vérifie que l'utilisateur a donné un argument
if [ "$#" -ne 1 ]; then
echo "Erreur : Aucun argument. Veuillez indiquer un fichier" 
exit 
fi

#on vérifie que le fichier rentré en argument est valide
if [ ! -f "$fichier_urls" ]; then
    echo "Erreur : fichier '$fichier_urls' introuvable."
    exit
fi

#on détecte la langue du corpus en fonction du nom du fichier d'urls
lang=$(basename "$fichier_urls" | sed 's/corpus_//' | sed 's/.txt//') #on enlève ce qu'il y a avant et après corpus pour isoler la langue

#le mot change selon la langue
case "$lang" in
  fr)
    mot="Culture[s]?"
    ;;
  eng)
    mot="Culture[s]?"
    ;;
  es)
    mot="Cultura[s]?"
    ;;
  *)
    echo "Langue inconnue" #on gère les cas où la langue n'est pas reconnue
    exit 1
    ;;
esac

#fichier de tableau qui change selon la langue
tableau="../tableaux/tableau-${lang}.html"


#on définit l'en-tête du tableau
echo "<!DOCTYPE html>
   <html lang="fr">
	<head>
		<meta charset=\"UTF-8\">
      <title>Tableaux "$lang"</title>
      <link rel=\"stylesheet\" href=\"../style.css\">
	</head>
   <header>
      <nav class=\"navbar\">
         <ul class=\"menu\">
            <li><a href=\"../index.html\">Accueil</a></li>
         </ul>
      </nav>
   </header>

	<body>
   <main>
      <h1>Tableau "$lang"</h1>
		<table>
			<tr>
				<th>Numéro</th>
				<th>URL</th>
				<th>Code</th>
				<th>Encodage</th>
				<th>Nombre d'occurrences</th>
            <th>Page HTML brute</th>
            <th>Dump textuel</th>
            <th>Concordancier HTML</th>
			</tr>" > "$tableau"


#******************************************
#début de la boucle
#******************************************

#on initialise un compteur pour pouvoir numéroter les lignes
count=0
while read -r line;
do 
   #on récupère quelques variables utiles, encodage & code http (on reprend ce qu'on a fait dans le miniprojet)
   data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o ./.data.tmp $line)
	http_code=$(echo "$data" | head -1)
	encoding=$(echo "$data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2)
   #-------------------------

   #on rècupère le contenu de l'article et le met dans un fichier temporaire
   curl -Ls "$line" > temp.html #Ls gère les redirections (http/https...)

   if [ $? -eq 0 ]; then #teste si la dernière commande a fonctionné

         #on gère les cas où l'encodage n'est pas utf-8 et on convertit
         if [[ "$encoding" != "UTF-8" && "$encoding" != "utf-8" ]]; then
            iconv -f "$encoding" -t utf-8 temp.html > temp_utf8.html
         else
            cp temp.html temp_utf8.html

         fi

         #on stocke notre contenu html dans le dossier aspirations pour pouvoir l'afficher dans le tableau
         cp temp_utf8.html ../aspirations/${lang}_${count}.html

            #on récupère les dumps textuels
             lynx -dump -nolist temp_utf8.html > ../dumps-text/${lang}_${count}.txt

         #on récupère le texte de l'article et on compte
         nb_occurrences=$(echo $(lynx -dump -nolist "$line" | egrep -i -o "${mot}" | wc -l)) 

         #fichier de concordances 
         concord="../concordances/${lang}_${count}.html"

         #on récupère les concordances
         egrep -i -n ".{0,40}${mot}.{0,40}" ../dumps-text/${lang}_${count}.txt \n >> "$concord" #on prend ce qui est autour du mot

   fi

#juste pour checker qu'on récupère bien les infos qu'il nous faut, à supprimmer du script final
#echo "url : $line";
#echo "code : $http_code";
#echo "encodage : $encoding";
#echo "nombre d'occurrences : $nb_occurrences";
#echo "page HTML brute :  temp.html";
#echo "dump textuel :dumps-text/${lang}_${count}.txt";
#echo "concordancier HTML : $concord";

echo -e "			<tr>       
            <td>$count</td>
				<td>$line</td>
				<td>$http_code</td>
				<td>$encoding</td>
				<td>$nb_occurrences</td>
				<td><a href=\"../aspirations/"$lang"_"$count".html\">html</a></td>
            <td><a href=\"../dumps-text/"$lang"_"$count".txt\">dump</a></td>
            <td><a href=\""$concord"\">concordance</a></td>
			</tr>" >> "$tableau"


#on met à jour le compteur
count=$(expr $count + 1)

#on supprime les fichiers temporaires
rm temp.html temp_utf8.html 
done < $fichier_urls

#******************************************
#fin de la boucle
#******************************************

echo "		</table>
      </main>
	</body>
</html>"

rm ./.data.tmp
