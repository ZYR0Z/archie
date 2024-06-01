#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
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
                        SCRIPTHOME: archie
-------------------------------------------------------------------------

Installing AUR Softwares
"
source $HOME/archie/configs/setup.conf

cd ~
mkdir "/home/$USERNAME/.cache"
touch "/home/$USERNAME/.cache/zshhistory"
# TODO
git clone "https://github.com/ChrisTitusTech/zsh"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
ln -s "~/zsh/.zshrc" ~/.zshrc

sed -n '/'$INSTALL_TYPE'/q;p' ~/archie/pkg-files/${DESKTOP_ENV}.txt | while read line; do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done

if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/archie/pkg-files/aur-pkgs.txt | while read line; do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

# TODO
# Theming DE if user chose FULL installation
# if [[ $INSTALL_TYPE == "FULL" ]]; then
#   if [[ $DESKTOP_ENV == "kde" ]]; then
#     cp -r ~/archie/configs/.config/* ~/.config/
#     pip install konsave
#     konsave -i ~/archie/configs/kde.knsv
#     sleep 1
#     konsave -a kde
#   fi
# fi

echo -ne "
-------------------------------------------------------------------------
                    Copying Config Files to .config
-------------------------------------------------------------------------
"

cp -r ~/archie/configs/.config/* ~/.config/

echo -ne "
-------------------------------------------------------------------------
                        Setting up SSH for Git
-------------------------------------------------------------------------
"

if [[ $SSH_KEYGEN == "TRUE" ]]; then
  chmod +x $SCRIPT_DIR/scripts/ssh-setup.sh
  ./$SCRIPT_DIR/scripts/ssh-setup.sh |& tee ssh-setup.log
fi

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
