(( EUID )) && { echo 'This script must be run with the root user.'; exit 1; }

export ARES_INSTALL_TEXT="\n\n<\033[0;34mINSTALL\033[0m>"

sed -i 's/#$nrconf{kernelhints} = -1;/$nrconf{kernelhints} = 0;/' /etc/needrestart/needrestart.conf

# Turn off auto prompts
export NEEDRESTART_MODE=l
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=y

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Updating Ubuntu packages."

# Set up redis PPA so we get a recent version

add-apt-repository -y ppa:redislabs/redis

apt-get -y update
apt-get -y install dialog apt-utils

DEBIAN_FRONTEND=noninteractive \
  apt-get \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages upgrade

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Installing SSL/HTTPS utils."
apt-get install -y binutils
apt-get install -y apt-transport-https

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Installing Git"
apt-get install -y git

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Install gem bundler for dependencies."
apt-get install -y ruby-bundler

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Need ruby dev for local gems."
apt-get install -y ruby-dev

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Nginx for web server."
apt-get install -y nginx

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Dependency mgmt for ember cli"
apt-get install -y nodejs
apt-get install -y npm
apt-get install -y python3

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Redis database"
apt-get install -y redis-server

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Protect SSH from multiple failed logins."
apt-get install -y fail2ban

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Allow unattended upgrades"
apt-get install -y unattended-upgrades

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Turn unatteded upgrades on."
dpkg-reconfigure -f noninteractive unattended-upgrades


# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Start the database server, then restart it to ensure that a dump file is immediately generated."
service redis-server start
service redis-server restart

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Have the game server start when the server reboots"

echo "sudo -u ares -i '/home/ares/onboot.sh'" > /root/onboot.sh
echo "sudo hugeadm --thp-never" >> /root/onboot.sh
chmod +x /root/onboot.sh

if [ -e /etc/rc.local ]
then
    sed -i -e '$i \/root/onboot.sh &\n' /etc/rc.local
else
    printf '%s\n' '#!/bin/bash' '/root/onboot.sh &\n' 'exit 0' | sudo tee -a /etc/rc.local
fi

sudo chmod +x /etc/rc.local

sudo systemctl enable redis-server

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} RVM needs some libs."

DEBIAN_FRONTEND=noninteractive \
  apt-get \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages update

DEBIAN_FRONTEND=noninteractive \
  apt-get \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages upgrade


apt-get install -y autoconf automake bison libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool libyaml-dev pkg-config sqlite3 zlib1g-dev libreadline-dev libssl-dev libssl3 openssl

DEBIAN_FRONTEND=noninteractive \
  apt-get \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages upgrade


# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Setup firewall"

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw --force enable

# Clean up DO droplet stuff
apt-get purge droplet-agent* -y

# #########################################################################################

echo -e "${ARES_INSTALL_TEXT} Done!"

