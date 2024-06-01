primary_email=$(
    curl -L -s \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_API_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/user/emails | jq -r '.[] | select(.primary) | .email'
)
#               type          email        output_file         passphrase      quiet mode
ssh-keygen -t ed25519 -C "$primary_email" -f ~/.ssh/github -N "$SSH_PASSPHRASE" -q

# start ssh agent
eval "$(ssh-agent -s)" >/dev/null

# TODO: without passphrase prompt
ssh-add -q ~/.ssh/github

public_ssh_key=$(cat ~/.ssh/github.pub)

# add ssh key to github via API
curl -L -o /dev/null -s \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_API_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/keys \
    -d "{\"title\":\"$HOSTNAME\",\"key\":\"$public_ssh_key\"}"

# add signing key to github via API
curl -L -o /dev/null -s \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_API_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/ssh_signing_keys \
    -d "{\"title\":\"$HOSTNAME\",\"key\":\"$public_ssh_key\"}"
