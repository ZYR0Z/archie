#!/bin/bash

# Checking if is running in Repo Folder
if [[ "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')" =~ ^scripts$ ]]; then
    echo "You are running this in archie Folder."
    echo "Please use ./archie.sh instead"
    exit
fi

# Installing git

echo "Installing git."
pacman -Sy --noconfirm --needed git glibc

echo "Cloning the archie Project"
# depth 1 for quicker download & recursive to ensure all submodules get pulled
git clone --depth=1 --recursive https://github.com/zyr0z/archie

echo "Executing archie Script"

cd $HOME/archie

exec ./archie.sh
