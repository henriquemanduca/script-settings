#!/usr/bin/env bash
# ----------------------------- VARIABLES ----------------------------- #
URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_SIMPLE_NOTE="https://github.com/Automattic/simplenote-electron/releases/download/v1.8.0/Simplenote-linux-1.8.0-amd64.deb"
URL_DBEAVER="https://dbeaver.io/files/7.2.1/dbeaver-ce_7.2.1_amd64.deb"
VS_CODE="https://az764295.vo.msecnd.net/stable/e5e9e69aed6e1984f7499b7af85b3d05f9a6883a/code_1.49.2-1600965325_amd64.deb"
DOWNLOADS="$HOME/Downloads/programs"

PROGRAMS=(
  gnome-boxes
  brave-browser
  font-manager
  zsh
  typora
  ca-certificates
  docker-ce
)

sudo apt install apt-transport-https curl wget -y

## Download and installation ##
mkdir "$DOWNLOADS"
wget -c "$URL_GOOGLE_CHROME"  -P "$DOWNLOADS"
wget -c "$URL_SIMPLE_NOTE"    -P "$DOWNLOADS"
wget -c "$URL_DBEAVER"        -P "$DOWNLOADS"
wget -c "$VS_CODE"            -P "$DOWNLOADS"

# ----------------------------- REQUIREMENTS ----------------------------- #

## Removing any locks on the apt ##
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

timedatectl set-local-rtc 1 --adjust-system-clock

# ----------------------------- REMOVE ----------------------------- #
echo ">>>> Remove libreoffice"
sudo apt-get remove --purge libreoffice* -y

sudo apt clean -y
sudo apt-get autoremove -y

sudo apt update && sudo apt upgrade -y
clear

echo ">>>> Install Fira Code"
sudo apt install fonts-firacode

## Adding third-party repositories##

# add Typora's repository
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
sudo add-apt-repository 'deb https://typora.io/linux ./'

# add Doker's repository
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# ----------------------------- EXECUTION ----------------------------- #
## Updating the repository after adding new repositories ##
echo ""
echo ""
sudo apt update -y
sudo apt upgrade -y


## Installing .deb packages downloaded in the previous session ##
sudo dpkg -i $DOWNLOADS/*.deb
sudo apt-get -f install -y

curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

# Install programs in apt
for program_name in ${PROGRAMS[@]}; do
  if ! dpkg -l | grep -q $program_name; then # Only install if not already installed
    apt install "$program_name" -y
  else
    echo "[INSTALADO] - $program_name"
  fi
done

# ----------------------------- AFTER-INSTALLATION ----------------------------- #
## Finalization, update and cleaning ##
sudo apt update -y
sudo apt dist-upgrade -y

sudo apt autoclean
sudo apt autoremove -y

# ----------------------------- OTHERS SETTINGS ----------------------- #
## Docker without sudo
sudo usermod -aG docker ${USER} && su - ${USER}

## SSH
echo ">>>> Generate key ssh"
ssh-keygen -t rsa -b 4096 -C "henriquemanduca@live.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa



