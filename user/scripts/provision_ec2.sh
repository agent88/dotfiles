#!/bin/bash
#
# EC2 Web Server Install Script


# Variables
############

export USER_DIR=/home/ubuntu
export NODE_VERSION=v10.2.0 # Node.js version to install
export TERM=xterm
export EC2_DOMAIN=
export EC2_USER=
export GITHUB_USER=loriezn
export GITHUB_ACCESS_TOKEN=cb3b3ef296945bdf8c06c79949062125d17d9538
export SSH_KEYREG_FILE=${HOME}/.bash.d/ssh-keyreg
export WEBSITE_TARBALL_FILE_LOCATION=~/fake_sites/completed_mods/bubbleshinecleaning.tar.gz

# SCRIPT FUNCTIONS 
###################

function eco {
  echo "====================================="
  echo $1
  echo "====================================="
  sleep 0.5
}

function SET_EC2_HOSTNAME {
  eco "Setting instance hostname"
  ssh "$EC2_USER"@"$EC2_DOMAIN" "echo $EC2_DOMAIN | sudo tee /etc/hostname"
}

function CREATE_EC2_STORAGE_VOLUME {
  eco "Creating EC2 Stoarge Volume"
  sleep 1.5
  eco "Preparing data volume"  
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'echo -e "g\nn\n\n\n\nw" | sudo fdisk /dev/xvdb'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo mkfs.ext4 -L data-share /dev/xvdb1'

  eco "Creating \\/data directory"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo mkdir /data'

  eco "Attaching EC2 storage volume"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'echo "LABEL=data-share        /data   ext4    defaults                0 1" | sudo tee --append /etc/fstab'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo mount -a'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo chown "$USER":"$USER" /data'
}

function SETUP_EC2_BASE_PKGS {
  eco "Updating packages"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo apt update'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo apt full-upgrade -y'

  # Not strictly necessary, but good to have a task manager
  eco "Installing htop, git & openssh"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo apt install -y htop git openssh'
}

function SETUP_EC2_DOCKER {
  eco "Setting up docker"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo apt-get install apt-transport-https ca-certificates curl software-properties-common'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo apt-key fingerprint 0EBFCD88'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo apt update'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo apt install docker-ce'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo usermod -a -G docker "$USER"'

  eco "Install docker-compose"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo chmod +x /usr/local/bin/docker-compose'
}

function SETUP_ECC2_NODEJS {
  eco "Installing latest NVM"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'git clone git://github.com/creationix/nvm.git $USER_DIR/.nvm'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'echo . $USER_DIR/.nvm/nvm.sh >> $USER_DIR/.bashrc'
  ssh "$EC2_USER"@"$EC2_DOMAIN" '/. $USER_DIR/.bashrc' # Ensure variables are available within the current shell

  # Install Node.JS (+npm)
  eco "Installing Node.js"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'nvm install $NODE_VERSION'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'nvm alias default $NODE_VERSION'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'nvm use $NODE_VERSION'
}

function INSTALL_EC2_PROXY {
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'git clone https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion.git /data/docker-nginx-proxy'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'cp /data/docker-nginx-proxy/.env.sample /data/docker-nginx-proxy/.env'
}

function INSTALL_EC2_NEXTCLOUD {
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'git clone https://github.com/evertramos/docker-nextcloud-letsencrypt.git /data/docker-nextcloud-letsencrypt'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'cp /data/docker-nextcloud-letsencrypt/.env.sample /data/docker-nextcloud-letsencrypt/.env'
}

function INSTALL_EC2_WORDPRESS {
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'git clone https://github.com/evertramos/wordpress-docker-letsencrypt.git /data/wordpress-docker-letsencrypt'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'cp /data/wordpress-docker-letsencrypt/.env.sample /data/wordpress-docker-letsencrypt/.env'
}


# EC2 CONFIG SCRIPT
####################

# Take me home
eco "BEAM ME UP, SCOTTY!"
cd ~

# Set Variables
eco "Setting User Variables"
echo -n "EC2 Domain: "
read -r EC2_DOMAIN 
sleep 0.5
echo -n "EC2 Username: "
read -r EC2_USER
sleep 0.5
echo -n "Location of website tarball: "
read -r WEBSITE_TARBALL_FILE_LOCATION
sleep 0.5
echo -n "Github Personal Access Token: "
read -r GITHUB_ACCESS_TOKEN
sleep 0.5 

# Set hostname
SET_EC2_HOSTNAME

# Create data directory and attach storage volume
CREATE_EC2_STORAGE_VOLUME

# Update and install base packages
SETUP_EC2_BASE_PKGS

# Connect to EC2 and create SSH Key
function CONFIGURE_EC2_SSHGIT {
  eco "Creating Instance SSH Keys"
  sleep 0.5
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'ssh-keygen -t rsa -b 4096 -P "" -C "$USER@$HOSTNAME" -f ~/.ssh/id_rsa'
  scp "$EC2_USER"@"$EC2_DOMAIN" "$SSH_KEYREG_FILE" "$EC2_USER"@"$EC2_DOMAIN":
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo chmod +x ~/ssh-keyreg'
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'sudo cp ~/ssh-keyreg /usr/local/bin'
  ssh "$EC2_USER"@"$EC2_DOMAIN" "ssh-keyreg -u $GITHUB_USER:$GITHUB_ACCESS_TOKEN -p ~/.ssh/id_rsa.pub"
  ssh "$EC2_USER"@"$EC2_DOMAIN" 'ssh -T git@github.com:loriezn'
}

CONFIGURE_EC2_SSHGIT

# Configure dotfiles
eco "Configuring system dotfiles"
#git clone 

# nvm + Node.js
SETUP_ECC2_NODEJS
SETUP_EC2_DOCKER



# Get your project somehow (curl, wget, git)
# eco "Installing User Repo Project"
# cd ~
# git clone https://github.com/user/repo.git
# cd ~/repo
# git pull https://github.com/user/repo.git

# Install, setup, build, compile, whatever depending on your project
# npm install

# WIN ?
eco "OMG LASERS... PEW! PEW! WE'RE COMPLETE !"
