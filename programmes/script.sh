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

#on initialise un compteur pour pouvoir numéroter les lignes
count=0

mot="Culture"


#début d'une boucle FOR ou WHILE pour chaque url
while read -r line;
do 
   #quelques variables utiles, encodage & code http
   data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o ./.data.tmp $line)
	http_code=$(echo "$data" | head -1)
	encoding=$(echo "$data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2)
   echo ${line};
   #-------------------------
   html=$(curl -Ls "$line")

   if [ $? -eq 0 ]; then #teste si la dernière commande a fonctionné

         #on gère les cas où l'encodage n'est pas utf-8 et on convertit
         if [[ "$encoding" != "UTF-8" || "$encoding" != "utf-8" ]]; then
            iconv -f "$encoding" -t utf-8
         fi

         #on récupère le texte de l'article et on compte
         nb_occurrences=$(echo $(lynx -dump -nolist "$line" | egrep -i -o "${mot}" | wc -l)) 

   fi

echo "numéro : $count";
echo "url : $line";
echo "code : $http_code";
echo "encodage : $encoding";
echo "nombre d'occurrences : $nb_occurrences";
#echo "page HTML brute : $nb_occurrences";
#echo "dump textuel : $nb_occurrences";
#echo "concordancier HTML : $nb_occurrences";


#on met à jour le compteur
count=$((i+1))
done < $fichier_urls
