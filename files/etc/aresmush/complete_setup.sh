(( EUID )) && { echo 'This script must be run with the root user.'; exit 1; }

export ARES_INSTALL_TEXT="\n\n<\033[0;34mINSTALL\033[0m>"

# Turn off auto prompts
export NEEDRESTART_MODE=l
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=y

echo "Give your MUSH a name.  You can change your game name, description and category later in the web portal configuration screen."
read MUSH_NAME
MUSH_NAME=${MUSH_NAME:-Your AresMUSH}

echo "Enter the hostname, like yourmush.aresmush.com. You can use the server's IP address if you aren't using a domain name."
read HOST_NAME
if [ -z "$HOST_NAME" ]
then
  echo "ERROR! Host name required."
  exit
fi

echo "Choose the port that people will connect to from a MUSH client.  See https://aresmush.com/tutorials/install/ports.html for help. [4201]"
read PORT_NUM
PORT_NUM=${PORT_NUM:-4201}
let WEBSOCKET_PORT=$PORT_NUM+1
let API_PORT=$PORT_NUM+2

echo "Enter a password for your ares user, or leave blank to generate a random password."
RANDOMPW=$(openssl rand 1000 | strings | grep -io [[:alnum:]] | head -n 16 | tr -d '\n')
read PASSWD
PASSWD=${PASSWD:-$RANDOMPW}
ENCRYPTEDPW=$(openssl passwd -1 "$PASSWD")

echo -e "ares user will be created with password $PASSWD"

echo -e "${ARES_INSTALL_TEXT} Beginning installation. This will take a little while. Please be patient..."

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Updating Ubuntu packages."

# Set up redis PPA so we get a recent version

add-apt-repository -y ppa:chris-lea/redis-server

DEBIAN_FRONTEND=noninteractive \
  apt-get \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages update

apt-get -y install dialog apt-utils

DEBIAN_FRONTEND=noninteractive \
  apt-get \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages upgrade


# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Create an ares user"

export ARES_USERNAME="ares"

adduser --disabled-password --gecos "" ${ARES_USERNAME}

usermod -p "$ENCRYPTEDPW" ${ARES_USERNAME}

# Add them to groups

addgroup www
usermod -a -G sudo,www,redis ${ARES_USERNAME}

# Needed for Ubuntu 21+ to allow web access to game dir

sudo chmod a+x /home/ares

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Give ares user access to www and redis directory for backups"

sudo chown ${ARES_USERNAME} /var/www/html
sudo chgrp redis /etc/redis/redis.conf 
sudo chmod g+rwx /etc/redis/redis.conf  
sudo chgrp redis /var/lib/redis
sudo chmod g+rwx /var/lib/redis
sudo chgrp redis /var/lib/redis/dump.rdb
sudo chmod g+rwx /var/lib/redis/dump.rdb
sudo chgrp www /etc/nginx/sites-available/default
sudo chmod g+rwx /etc/nginx/sites-available/default


# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Setup certbot requirements"

sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# #########################################################################################

sudo su - ares -c 'curl https://raw.githubusercontent.com/aresmush/aresmush/master/bin/install > install'
sudo su - ares -c 'chmod +x install'
sudo su - ares -c "./install \"mush_name=$MUSH_NAME~server_port=$PORT_NUM~host_name=$HOST_NAME\""

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Setup firewall for game port"

sudo ufw allow "Nginx HTTP"
sudo ufw allow "Nginx HTTPS"
sudo ufw allow "Nginx Full"
sudo ufw allow 4200:4210/tcp
sudo ufw allow $PORT_NUM/tcp
sudo ufw allow $WEBSOCKET_PORT/tcp
sudo ufw allow $API_PORT/tcp

echo -e "${ARES_INSTALL_TEXT} User ${ARES_USERNAME} created with password $PASSWD  Keep it in a safe place."

FILE=~/.ssh
if [ -d "$FILE" ]; then
  cp -R ~/.ssh /home/ares
  chown -R ares /home/ares/.ssh
  echo -e "${ARES_INSTALL_TEXT} SSH key copied to ares user. You can now log in using your SSH key."
fi

echo -e "${ARES_INSTALL_TEXT} Done!"

echo -e "${ARES_INSTALL_TEXT} It is highly recommended that you install a security certificate. Log in as the ares user and run bin/certs from the aresmush directory."
