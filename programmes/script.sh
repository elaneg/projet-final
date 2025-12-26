#!/bin/bash

#on vérifie que l'utilisateur a donné un argument
if [ "$#" -ne 1 ]; then
echo "Erreur : Aucun argument. Veuillez indiquer un fichier" 
exit 
fi

#on vérifie que le fichier rentré en argument est valide
if [ ! -f "$URL" ]; then
    echo "Erreur : fichier '$URL' introuvable."
    exit
fi

#on initialise un compteur pour pouvoir numéroter les lignes
count=0


#début d'une boucle FOR ou WHILE pour chaque url
while read -r line;
do 
   #récupérer la page (commandes curl)
   	page=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o ./.data.tmp $line)
    #on récupère l'encodage et le code http
    http_code=$(echo "$data" | head -1)
	encoding=$(echo "$data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2)

   #stocker localement dans un dossier idoine (??)
   #condition IF pour vérifier que ya pas d'erreur
      #ok, condition IF pour vérifier que   la page est en utf-8
         #ok, on extrait le texte avec LYNX 
         #on extrait des contextes autour des mots choisis avec EGREP
      #sinon, ELSE
         #détecter l'encodage de la page avec FILE 
         #avec IF, si l'encodage est reconnu :
            #extraire le texte avec ICONV 
            #convertir en utf-8
            #extraire les contextes 
        #sinon, ELSE : 
           #on fait rien
    #sinon (ELSE) :
       #on fait rien
    
    #on met à jour le compteur
    count=$(expr $count + 1)
    #on créé une ligne dans le tableau html avec dedans les éléments suivants : lien, page avec contenu textuel utf-8 et encodage inital, contexte