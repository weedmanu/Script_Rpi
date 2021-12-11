#!/bin/bash

# variables pour les couleurs du texte dans le terminal
CYAN='\033[1;36m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# fonction qui vérifie si un paquet est installé ou pas
function verif() {
	# on liste les paquets présent et leurs statuts dans le fichier lamp.log
	echo $(dpkg --get-selections | grep $1) > /tmp/lamp.log
	# si le premier champs n'est pas vide
	if [[ -n $(cat /tmp/lamp.log | awk -F" " '{print $1}') ]]; then
		# si le deuxième champs est «deinstall», le paquet n'est plus installé
		if [[ $(cat /tmp/lamp.log | awk -F" " '{print $2}') == "deinstall" ]]; then
			# on retourne 1
			return 1
		# sinon c'est que le paquet est installé
		else
			# on retourne 0
			return 0
		fi
	# sinon, le premier champs est vide, le paquet n'a jamais été installé
	else
		# on retourne 1
		return 1
	fi
	# on supprime le fichier lamp.log
	rm /tmp/lamp.log
}

# on affiche du texte d'information dans le terminal
echo ""
printf "%b\n" "   ${GREEN}////////////////////////////////////////////////\n   ${YELLOW}//      Début du programme d’installation     //\n   ${RED}////////////////////////////////////////////////${NC}\n"
echo ""

# Si on répond oui à la fenêtre suivante
if ( whiptail 	--title "Mise à jour du système" \
				--yesno "Voulez vous mettre à jour le Raspberry ?" \
				--yes-button "oui" \
				--no-button "non" \
				--separate-output 10 60) then

	# on affiche du texte d'information dans le terminal
	echo ""
	printf "%b\n" "${BLUE}     ********************************\n     *   mise à jour du Raspberry   *\n     ********************************${NC}\n"
	echo ""
	printf "%b\n" "${CYAN}"
	apt-get update && apt-get upgrade -y # On met à jour le Raspberry
	echo ""
	printf "%b\n" "${NC}"
# Si on répond non
else
	printf "%b\n" "${RED}Vous ne souhaitez pas mettre à jour le Raspberry ${NC}\n"
fi

# Si on répond oui à la fenêtre suivante
if ( whiptail 	--title "Installation de Apache MariaDB PHP phpmyadmin" \
				--yesno "voulez vous lancer l'installation de Apache, MariaDB, PHP, et phpmyadmin ?" \
				--yes-button "oui" \
				--no-button "non" \
				--separate-output 10 60) then

	# on verifie si apache2 est installé
	verif "apache2"

	# si il ne l'est pas
	if (( $?  == 1 )); then
		echo ""
		printf "%b\n" "${BLUE}     *****************************\n     *   Installation d'apache   *\n     *****************************${NC}\n"
		echo ""
		printf "%b\n" "${CYAN}"
		apt-get install apache2 -y # on installe apache2
		echo ""
		printf "%b\n" "${NC}"
		chown -R pi:www-data /var/www/html/
		chmod -R 770 /var/www/html/
		rm /var/www/html/index.html &>/dev/null
	# si il est déjà installé
	else
		echo ""
		printf "%b\n" "${RED} apache2 est déjà installé ${NC}"
		echo ""
	fi

	# on verifie si PHP est installé
	verif "php"

	# si il ne l'est pas
	if (( $?  == 1 )); then
		echo ""
		printf "%b\n" "${BLUE}     ***************************\n     *   Installation de PHP   *\n     ***************************${NC}\n"
		echo ""
		printf "%b\n" "${CYAN}"
		apt-get install php php-mbstring -y # on installe php et php-mbstring
		echo ""
		printf "%b\n" "${NC}"
	# si il est déjà installé
	else
		echo ""
		printf "%b\n" "${RED} PHP est déjà installé ${NC}"
		echo ""
	fi

	# on verifie si MariaDB est installé
	verif "mariadb"

	# si il ne l'est pas
	if (( $?  == 1 )); then
		echo ""
		printf "%b\n" "${BLUE}     *******************************\n     *   Installation de MariaDB   *\n     *******************************${NC}\n"
		echo ""
		printf "%b\n" "${CYAN}"
		apt-get install mariadb-server php-mysql -y # on installe mariadb-server et php-mysql
		printf "%b\n" "${NC}"
		
		# on affiche une fenêtre qui prévient de la configuration de MariaDB
		whiptail --title "Installation de Apache MariaDB PHP phpmyadmin" \
				 --msgbox "Vous allez configurer MariaDB, répondez «y» à toutes les questions.\nEntrez sans mot de passe
puis donnez un mot de passe à l'utilisateur root" 10 60

		printf "%b\n" "${YELLOW}"

		mysql_secure_installation # on lance la configuration de MariaDB

		printf "%b\n" "${NC}"
		
		# on affiche une fenêtre qui informe que l'on va créer un nouvel utilisateur pour MariaDB
		whiptail --title "$titre" \
				 --msgbox "On va créer un nouvel utilisateur pour MariaDB car on ne travail pas sous l'utilisateur root" 10 60
		exitstatus=$?
		if [ $exitstatus = 1 ]; then
			exit
		fi
		mdp_root_sql=$(whiptail --passwordbox "Quelle est le mote de passe root de MariaDB ?" 8 39 --title "Congiguration de MariaDB" 3>&1 1>&2 2>&3)

		login=$(whiptail --inputbox "Quelle est le login du nouvel utilisateur de MariaDB ?" 8 39 --title "Congiguration de MariaDB" 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ $exitstatus = 1 ]; then
			exit
		fi
		mdp_user_sql=$(whiptail --passwordbox "Quelle est le mote de passe de cet utilisateur de MariaDB ?" 8 39 --title "Congiguration de MariaDB" 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ $exitstatus = 1 ]; then
			exit
		fi
		# on crée l'utilisateur
		mysql -hlocalhost -uroot -p${mdp_root_sql} -e "CREATE USER ${login}@localhost IDENTIFIED BY '${mdp_user_sql}';"
		mysql -hlocalhost -uroot -p${mdp_root_sql} -e "GRANT ALL PRIVILEGES ON *.* TO '${login}'@'localhost';"
		mysql -hlocalhost -uroot -p${mdp_root_sql} -e "FLUSH PRIVILEGES;"
		
	# si il est déjà installé
	else
		echo ""
		printf "%b\n" "${RED} MariaDB est déjà installé ${NC}"
		echo ""
	fi

	# on verifie si phpmyadmin est installé
	verif "phpmyadmin"

	# si il ne l'est pas
	if (( $?  == 1 )); then
		echo ""
		printf "%b\n" "${BLUE}     **********************************\n     *   Installation de phpmyadmin   *\n     **********************************${NC}\n"
		echo ""
		printf "%b\n" "${CYAN}"
		apt-get install phpmyadmin -y # on installe phpmyadmin
		echo ""
		printf "%b\n" "${NC}"
		
		# on ajoute la config de phpmyadmn à apache
		echo "" >> /etc/apache2/apache2.conf
		echo "# On inclut la config de phpmyadmin" >> /etc/apache2/apache2.conf
		echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
		
		# on corrige un bug dans le fichier sql.lib.php si il est présent.
		sed -i "s/|\s*\((count(\$analyzed_sql_results\['select_expr'\]\)/| (\1)/g" /usr/share/phpmyadmin/libraries/sql.lib.php
		
		# on redémarre apache
		service apache2 restart
		
	# si il est déjà installé
	else
		echo ""
		printf "%b\n" "${RED} phpmyadmin est déjà installé ${NC}"
		echo ""
	fi
	
# si on répond non 
else
	printf "%b\n" "${RED}Vous ne souhaitez pas installer la suite apache PHP MariaDB phpmyadmin${NC}\n"
fi

# on récupère l'IP du Raspberry
IP=$(hostname -I | awk '{print $1}')

# On affiche une fenêtre qui informe de la fin du programme avec les liens vers phpmyadmin
whiptail --title "Installation de Apache MariaDB PHP phpmyadmin" \
		 --msgbox "L'installation est terminée.\n\n http://${HOSTNAME}.local/phpmyadmin\n http://${IP}/phpmyadmin" 10 60
		 
# fin
exit

