#!/bin/bash

#///////////////////////////////////////////    Heure GMT   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

# on recherche la zone GMT installé                : timedatectl
# on récupère la quatrième ligne                     : sed -n 4p
# on remplace T et tout ce qu'il y a avant par T    : sed 's/\s*T/T/g'
HR=`timedatectl | sed -n 4p | sed 's/\s*T/T/g'`

#************************   demande de changement   ************************
if ( whiptail   --title "Changement de l'heure GMT" \
                --backtitle "Paramétrage du Raspberry pi" \
                --yesno "La zone GMT actuelle est :\n\n ${HR} \n\nVoulez vous la changer en Europe/Paris ?" \
                --yes-button "oui" \
                --no-button "non" \
                --separate-output 12 70 )
then    # si on répond oui
    # on applique le changement
    timedatectl set-timezone Europe/Paris >/dev/null
    # on recherche la nouvelle zone GMT installé           : timedatectl
    # on récupère la quatrième ligne                     : sed -n 4p
    # on remplace T et tout ce qu'il y a avant par T    : sed 's/\s*T/T/g'
    NHR=`timedatectl | sed -n 4p | sed 's/\s*T/T/g'`
    # on affiche l'info du changement
    whiptail    --title "Changement de l'heure GMT" \
                --backtitle "Paramétrage du Raspberry pi" \
                --msgbox "Changement de l'heure GMT effectué : \n\n ${NHR}" 12 70
else    # si on répond non
    # on affiche l'info de l'annulation
    whiptail    --title "Changement de l'heure GMT" \
                --backtitle "Paramétrage du Raspberry pi" \
                --msgbox "Changement de l'heure GMT annulée !!!" 12 70
fi



#///////////////////////////////////////////    Langage     \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#************************   recherche du langage installé  ************************
for ((i=0; i<=100; i+=10))            # boucle for pour la barre de progression de 0 a 100 avec un pas de 10
do
    sleep 0.1                         # temps entre chaque boucle
    echo $i                           # le pourcentage dans la barre
    if [[ $i == 50 ]]; then           # si on arrive a 50 %
        # on recherche la langue installée : locale-gen
        # on récupère la deuxième ligne : sed -n 2p
        # on supprime les espaces en début de ligne et récupère le 3eme argument : cut -d ' ' -f 3
        # on supprime les . en fin de fichier : sed 's/[.]*$//'
        langage=`locale-gen | sed -n 2p | cut -d ' ' -f 3 | sed 's/[.]*$//'`
    fi
# on lance la boucle dans une barre de progression
done > >( whiptail  --title "Changement de la langue du système" \
                    --gauge "Recherche du langage système en cours ...." 12 70 0 )

#************************   demande de changement   ************************
if (whiptail --title "Changement de la langue du système" \
             --backtitle "Paramétrage du Raspberry pi" \
             --yesno "Le langage actuel est :\n\n ${langage} \n\nVoulez vous le passer en français ?" \
             --yes-button "oui" \
             --no-button "non" \
             --separate-output 12 70) \
then    # si on répond oui
        # on dé commente la ligne fr_FR.UTF-8 du fichier /etc/locale.gen
    sed -i "s/^# *\(fr_FR.UTF-8\)/\1/" /etc/locale.gen
        # on commente la ligne en_GB.UTF-8 UTF-8 du fichier /etc/locale.gen
    sed -i "s/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g" /etc/locale.gen
        # on applique le changement :
    for ((i=0; i<=100; i+=10))            # boucle for pour la barre de progression de 0 a 100 avec un pas de 10
    do
        sleep 0.1                         # temps entre chaque boucle
        echo $i                           # le pourcentage dans la barre
        if [[ $i == 50 ]]; then           # si on arrive a 50 %
            # on remplace la ligne LANG=en_GB.UTF-8 en  LANG=fr_FR.UTF-8 du fichier /etc/default/locale
            sed -i "s/LANG=en_GB.UTF-8/LANG=fr_FR.UTF-8/g" /etc/default/locale
            # on ajoute ces 2 lignes au fichier /etc/default/locale
            echo 'LANGUAGE=fr_FR.UTF-8' >> /etc/default/locale
            echo 'LC_ALL=fr_FR.UTF-8' >> /etc/default/locale
            # on recherche la nouvelle langue installée                              : locale-gen
            # on récupère la deuxième ligne                                          : sed -n 2p
            # on supprime les espaces en début de ligne et récupère le 3eme argument : cut -d ' ' -f 3
            # on supprime les . en fin de fichier                                    : sed 's/[.]*$//'
            Nlangage=`locale-gen | sed -n 2p | cut -d ' ' -f 3 | sed 's/[.]*$//'`
        fi
    # on lance la boucle dans une barre de progression
    done > >( whiptail  --title "Changement de la langue du système" \
                        --gauge "Modification du langage système en cours ...." 12 70 0)
    # on affiche l'info du changement
    whiptail    --title "Changement de la langue du système" \
                --backtitle "Paramétrage du Raspberry pi" \
                --msgbox "Changement de langage effectué !!! \n\n ${Nlangage}" 12 70
else    # si on répond non
    # on affiche l'info de l'annulation
    whiptail    --title "Changement de la langue du système"  \
                --backtitle "Paramétrage du Raspberry pi" \
                --msgbox "Changement de langage annulée !!!" 12 70
fi



#///////////////////////////////////////////    mot de passe    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#************************   demande de changement   ************************
if ( whiptail   --title "Changement du mot de passe du user pi" \
                --backtitle "Paramétrage du Raspberry pi" \
                --yesno "Voulez vous changer le mot de passe du user pi ?" \
                --yes-button "oui" \
                --no-button "non" \
                --separate-output 12 70 )
then    # si on répond oui
    # on demande un nouveau mot de passe
    MDP=$( whiptail --title "mot de passe" \
                    --backtitle "Paramétrage du Raspberry pi" \
                    --passwordbox "Choisissez un mot de passe :" 12 70 3>&1 1>&2 2>&3 )
    exitstatus=$?
    # si on valide OK
    if [ $exitstatus = 0 ]; then
        # on remplace le mot de passe par le nouveau
        echo "pi:${MDP}" | sudo chpasswd >/dev/null
        # on affiche l'info du changement
        whiptail    --title "Changement du mot de passe du user pi" \
                    --backtitle "Paramétrage du Raspberry pi" \
                    --msgbox "Changement du mot de passe fait !!!" 12 70
    # si on valide Cancel
    else
        # on affiche l'info de l'annulation
        whiptail    --title "Changement du mot de passe du user pi" \
                    --backtitle "Paramétrage du Raspberry pi" \
                    --msgbox "Changement du mot de passe annulé !!!" 12 70
    fi
else    # si on répond non
    # on affiche l'info de l'annulation
    whiptail    --title "Changement du mot de passe du user pi" \
                --backtitle "Paramétrage du Raspberry pi" \
                --msgbox "Changement du mot de passe annulée !!!" 12 70
fi



#///////////////////////////////////////////    Hostname    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

# on récupère le hostname
HN=`cat /etc/hostname`

#************************   demande de changement   ************************
if (whiptail --title "Changement du Hostname" \
             --backtitle "Paramétrage du Raspberry pi" \
             --yesno "Le hostname actuel est :\n\n ${HN} \n\nVoulez vous le changer ?" \
             --yes-button "oui" \
             --no-button "non" \
             --separate-output 12 70) \
then    # si on répond oui
    # on demande un nouveau nom
    NHN=$(whiptail  --title "Changement du Hostname" \
                    --backtitle "Paramétrage du Raspberry pi" \
                    --inputbox "Choisissez un hostname :" 12 70 3>&1 1>&2 2>&3)
    exitstatus=$?
    # si on valide OK
    if [ $exitstatus = 0 ]; then
        # on remplace l'ancien hostname par le nouveau dans /etc/hostname et /etc/hosts
        sed -i "s/${HN}/${NHN}/g" /etc/hostname /etc/hosts
        # on affiche l'info du changement
        whiptail    --title "Changement du Hostname" \
                    --backtitle "Paramétrage du Raspberry pi" \
                    --msgbox "Changement du hostname fait !!! \n\n ${NHN}" 12 70
    # si on valide Cancel
    else
        # on affiche l'info de l'annulation
        whiptail    --title "Changement du Hostname" \
                    --backtitle "Paramétrage du Raspberry pi" \
                    --msgbox "Changement du hostname annulé !!!" 12 70
    fi
else    # si on répond non
    # on affiche l'info de l'annulation
    whiptail    --title "Changement du Hostname" \
                --backtitle "Paramétrage du Raspberry pi" \
                --msgbox "Changement du hostname annulée !!!" 12 70
fi


#///////////////////////////////////////////    redémarrage       \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#************************   demande de redémarrage ************************
if ( whiptail   --title "redémarrage du système" \
                --backtitle "Paramétrage du Raspberry pi" \
                --yesno "Le système doit être redémarré pour prendre en compte les changements. \n\nVoulez vous le faire maintenant ?" \
                --yes-button "oui" \
                --no-button "non" \
                --separate-output 12 70) \
then    # si on répond oui
    # on prévient du redémarrage
    whiptail    --title "redémarrage du système" \
                --backtitle "Paramétrage du Raspberry pi" \
                --msgbox "Le système va redémarrer !!!" 12 70
    # on redémarre
    reboot
else    # si on répond non
    # on affiche l'info de l'annulation
    whiptail    --title "redémarrage du système" \
                --backtitle "Paramétrage du Raspberry pi" \
                --msgbox "redémarrage annulée !!!" 12 70
fi


