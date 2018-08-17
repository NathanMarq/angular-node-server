#!/usr/bin/env bash

echo "### Setting up env variables: ###"
if [ -d /vagrant ]
  then
    ENV_USER=vagrant

    sudo rm -rf /var/www
    sudo ln -s /vagrant /var/www

  else
    sudo rm -rf /var/www
    sudo mkdir /var/www
    ENV_USER=ubuntu
fi

# echo "### set up PPA for Node: ###"
# curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -

echo "### add apt-get repo for redis: ###"
sudo apt-add-repository -y ppa:chris-lea/redis-server

echo "### Updating apt-get: ###"
sudo apt-get update
sudo apt-get -y upgrade

echo "### Copy bash_profile ###"
# copy our fancy bash profile over :)
cp /var/www/bootstrapping/.bash_profile ~/
source ~/.bash_profile

echo -e "\n######## install 1GB swap... ########\n"
# create the swapfile and set perms:
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
# tell mem management to use that file for swap:
sudo mkswap /swapfile
sudo swapon /swapfile
printf "/swapfile   none    swap    sw    0   0\n" | sudo tee -a /etc/fstab
# set "swappiness" - basically whether it should be used as last resort or not
sudo sysctl vm.swappiness=10
printf "\nvm.swappiness=10\n" | sudo tee -a /etc/sysctl.conf
# how fast should we be clearing inode info from the cache?
sudo sysctl vm.vfs_cache_pressure=50
printf "vm.vfs_cache_pressure=50\n" | sudo tee -a /etc/sysctl.conf
sudo swapon -s

# RUN OUR INSTALLS:

# TOOLS
  # unzip
  # curl
  # vim
  # git

# SERVER UTILS
  # nginx - for internal app routing with port forwarding
  # python
  # g++
  # make

# WEBSERVER UTILS
  # nodejs
  # upstart - runs webserver perpetually, after restarts
  # monit - for restarting webserver after crashes, and reporting

echo "### Installing general utils: ###"
sudo apt-get install -y unzip curl vim git nginx python-software-properties python g++ make
sudo apt-get install -y nodejs
sudo apt-get install -y npm
sudo apt-get install -y build-essential
# sudo apt-get install -y upstart
sudo apt-get install -y monit

echo "\n######## install redis... ########\n"
sudo apt-get -y install redis-server redis-tools

echo "### Copying nginx files: ###"
sudo cp /var/www/bootstrapping/nodeserver_nginx.conf /etc/nginx/sites-available/
sudo rm /etc/nginx/sites-enabled/default

sudo ln -s /etc/nginx/sites-available/nodeserver_nginx.conf /etc/nginx/sites-enabled/nodeserver_nginx.conf

echo "### Start nginx: ###"
sudo service nginx start
sudo service nginx reload

echo "### Install Certbot: ###"
sudo wget https://dl.eff.org/certbot-auto
sudo chmod a+x ~/certbot-auto
sudo ~/certbot-auto -n

echo "### Upgrade Node to newest version: ###"
sudo npm cache clean -f
sudo npm install -g n
sudo n stable

echo "### Add npm registry: ###"
sudo npm config set registry http://registry.npmjs.org/

cd /var/www/application

echo "### NPM Install: ###"
sudo npm install
sudo npm install --save -g supervisor

# copy conf files over
echo -e "\nTIMESTAMP: " `date`
echo -e "\n######## install systemd script... ########\n"

sudo cp /var/www/bootstrapping/nodeserver_systemd.service /etc/systemd/system/nodeserver.service
sudo systemctl enable nodeserver.service
sudo systemctl daemon-reload

echo "### Copy monit conf file: ###"
sudo cp /var/www/bootstrapping/nodeserver_monit.conf /etc/monit/conf.d/
sudo chmod 700 /etc/monit/conf.d/nodeserver_monit.conf

echo "### Set up Cron job(s): ###"
crontab -l > ~/mycron
echo "0 0-23/2 * * * monit -d 10 -c /etc/monit/conf.d/nodeserver_monit.conf" >> ~/mycron
crontab ~/mycron
rm ~/mycron

echo "### Starting nodeserver daemon: ###"
# start the node server daemon
sudo systemctl restart nodeserver.service

echo "### Starting monit: ###"
# start monit for error checking
sudo monit -d 10 -c /etc/monit/conf.d/nodeserver_monit.conf
