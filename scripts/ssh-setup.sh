#!/bin/bash
export GH_TOKEN="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"

primary_email=$(gh api "https://api.github.com/user/emails" -q "'.[] | select(.primary) | .email'")

#               type          email        output_file         passphrase      quiet mode
ssh-keygen -t ed25519 -C "$primary_email" -f ~/.ssh/github -N "$SSH_PASSPHRASE" -q

# start ssh agent
eval "$(ssh-agent -s)" >/dev/null

# workaround to pass the SSH_PASSPHRASE to ssh-add
{
    sleep .1
    echo $SSH_PASSPHRASE
} | script -q /dev/null -c 'ssh-add ~/.ssh/github'

public_ssh_key=$(cat ~/.ssh/github.pub)

# add ssh key to github
gh ssh-key add --title $HOSTNAME --type "authentication" $public_ssh_key

# add signing key to github
gh ssh-key add --title $HOSTNAME --type "signing" $public_ssh_key
