# Script_Rpi

## Installation

en SSH ou directement dans le terminal du Raspberry pi, on tape :

**cd /home/pi && git clone https://github.com/weedmanu/Script_Rpi.git**

puis une fois le dossier copié :

**chmod +x /home/pi/Script_Rpi/config.sh /home/pi/Script_Rpi/lamp.sh**

afin de rendre les scripts exécutable.

### config.sh

Un script qui sert à mettre le Raspberry pi en français, changer le mot de passe de l'utilisateur pi, changer le nom d'hôte.

**sudo /home/pi/Script_Rpi/./config.sh**

### lamp.sh

Un script qui sert à installer et configurer apache2, php, mariadb et phpmyadmin

**sudo /home/pi/Script_Rpi/./lamp.sh**

