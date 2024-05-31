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
git clone https://github.com/zyr0z/archie --depth 1

echo "Executing archie Script"

cd $HOME/archie

exec ./archie.sh
