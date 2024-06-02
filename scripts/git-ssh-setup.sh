#!/bin/bash
#               type          email        output_file         passphrase      quiet mode
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
