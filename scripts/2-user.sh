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

Installing AUR Softwares
"
source $HOME/archie/configs/setup.conf

cd ~
mkdir "/home/$USERNAME/.cache"
touch "/home/$USERNAME/.cache/zshhistory"

echo -ne "
-------------------------------------------------------------------------
                    Copying Config Files to .config
-------------------------------------------------------------------------
"
mkdir "/home/$USERNAME/.config"
cp -r ~/archie/configs/.config/* ~/.config/

if [[ ! "${DESKTOP_ENV}" == "i3wm" ]]; then
  # make sure xorg starts i3
  echo "exec i3" >~/.xinitrc
fi

# TODO: add .zshrc to dotfiles
# ln -s "~/zsh/.zshrc" ~/.zshrc

sed -n '/'$INSTALL_TYPE'/q;p' ~/archie/pkg-files/${DESKTOP_ENV}.txt | while read line; do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
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
  rm -r ~/$AUR_HELPER
  sed -n '/'$INSTALL_TYPE'/q;p' ~/archie/pkg-files/aur-pkgs.txt | while read line; do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
