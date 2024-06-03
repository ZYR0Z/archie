#!/usr/bin/env bash
echo -ne "
-------------------------------------------------------------------------
                █████╗ ██████╗  ██████╗██╗  ██╗██╗███████╗
               ██╔══██╗██╔══██╗██╔════╝██║  ██║██║██╔════╝
               ███████║██████╔╝██║     ███████║██║█████╗  
               ██╔══██║██╔══██╗██║     ██╔══██║██║██╔══╝  
               ██║  ██║██║  ██║╚██████╗██║  ██║██║███████╗
               ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚══════╝
------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source ${HOME}/archie/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
  grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
-------------------------------------------------------------------------
                        Enabling SSH Server
-------------------------------------------------------------------------
"

if [[ $ENABLE_SSH_SERVER == "TRUE" ]]; then
  systemctl enable sshd.service
  systemctl start sshd.service
fi

echo -ne "
-------------------------------------------------------------------------
                        Setting up SSH for Git
-------------------------------------------------------------------------
"

if [[ $SSH_KEYGEN == "TRUE" ]]; then
  #              type         email        output_file        passphrase
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/git -N "$SSH_PASSPHRASE"

  # start ssh agent
  eval "$(ssh-agent -s)" >/dev/null

  # workaround to pass the SSH_PASSPHRASE to ssh-add
  {
    sleep .1
    echo $SSH_PASSPHRASE
  } | script -q /dev/null -c 'ssh-add ~/.ssh/git'

  git config --global user.name "$GIT_USER"
  git config --global user.email "$GIT_EMAIL"
  git config --global user.signingkey "$HOME/.ssh/git.pub"
  git config --global gpg.format ssh
  git config --global commit.gpgsign true

fi

echo -ne "
-------------------------------------------------------------------------
               Creating Grub Boot Menu
-------------------------------------------------------------------------
"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
  sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi

# needed for os probing
sudo pacman -S --noconfirm --needed os-prober

echo -e "Configuring grub..."
# set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub
# make timeout longer
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=30/' /etc/default/grub
# make it maximum resolution
sed -i 's/^#GRUB_GFXMODE=.*/GRUB_GFXMODE=auto/' /etc/default/grub
# probe for other operating systems
sed -i 's/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub

echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
                        Enabling Login Manager
-------------------------------------------------------------------------
"

if [[ ! "${DESKTOP_ENV}" == "server" ]]; then
  sudo pacman -S --noconfirm --needed ly
  systemctl enable ly.service
fi

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable cups.service
echo "  Cups enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r $HOME/archie
rm -r /home/$USERNAME/archie

# Replace in the same state
cd $pwd
