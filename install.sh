#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

#Spotify and Brave gpg
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list


# Update packages list and update system
apt update
apt upgrade -y

# Install Terminus Fonts
sudo apt install fonts-terminus

# Set the font to Terminus Fonts
setfont /usr/share/consolefonts/Uni3-TerminusBold28x14.psf.gz

# Clear the screen
clear

# Install nala
apt install nala -y

# Making .config and Moving config files and background to Pictures
cd $builddir
mkdir -p /home/$username/.config
mkdir -p /home/$username/.fonts
mkdir -p /home/$username/Pictures
mkdir -p /home/$username/Pictures/backgrounds
cp -R dotconfig/* /home/$username/.config/
cp bg.jpg /home/$username/Pictures/backgrounds/
mv user-dirs.dirs /home/$username/.config
chown -R $username:$username /home/$username

# Installing Essential Programs 
nala install feh kitty rofi picom thunar nitrogen lxpolkit x11-xserver-utils unzip wget pipewire wireplumber pavucontrol build-essential libx11-dev libxft-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev zoxide xdg-utils -y
# Installing Other less important Programs
nala install neofetch flameshot psmisc mangohud vim lxappearance papirus-icon-theme lxappearance fonts-noto-color-emoji lightdm flatpak obs-studio remmina copyq btop intel-microcode neovim telegram-desktop brave-browser spotify-client -y

#Setup Flatpak 
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
#List Flatpak packages
flatpak install flathub com.github.unrud.VideoDownloader -y


# Download Nordic Theme
cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git

# Installing fonts
cd $builddir 
nala install fonts-font-awesome -y
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /home/$username/.fonts
mv dotfonts/fontawesome/otfs/*.otf /home/$username/.fonts/
chown $username:$username /home/$username/.fonts/*

# Reloading Font
fc-cache -vf
# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip

# Install Nordzy cursor
git clone https://github.com/alvatip/Nordzy-cursors
cd Nordzy-cursors
./install.sh
cd $builddir
rm -rf Nordzy-cursors

# Enable graphical login and change target from CLI to GUI
systemctl enable lightdm
systemctl set-default graphical.target

# Enable wireplumber audio service

sudo -u $username systemctl --user enable wireplumber.service

# Beautiful bash
cd $HOME
git clone https://github.com/ChrisTitusTech/mybash
cd mybash
bash setup.sh
cd $builddir

# DWM Setup
git clone https://github.com/ChrisTitusTech/dwm-titus
cd dwm-titus
make clean install
cp dwm.desktop /usr/share/xsessions
cd $builddir

# Use nala
bash scripts/usenala
