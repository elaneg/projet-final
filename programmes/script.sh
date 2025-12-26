#!/bin/bash

#on vérifie que l'utilisateur a donné un argument
if [ "$#" -ne 1 ]; then
echo "Veuillez rentrer un argument" 
exit 
fi

#début d'une boucle FOR pour chaque url
   #récupérer la page (commandes curl)
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
    
    #on créé une ligne dans le tableau html avec dedans les éléments suivants : lien, page avec contenu textuel utf-8 et encodage inital, contexte