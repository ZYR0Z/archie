primary_email=$(
    curl -L -s \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_API_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/user/emails | jq -r '.[] | select(.primary) | .email'
)
#               type          email        output_file    quiet mode
ssh-keygen -t ed25519 -C "$primary_email" -f ~/.ssh/github -q

# start ssh agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github -q

public_ssh_key=$(cat ~/.ssh/github.pub)

# add ssh key to github via API
curl -L -o /dev/null -s \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_API_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/keys \
    -d "{\"title\":\"$NAME_OF_MACHINE\",\"key\":\"$public_ssh_key\"}"

# add signing key to github via API
curl -L -o /dev/null -s \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_API_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/ssh_signing_keys \
    -d "{\"title\":\"$NAME_OF_MACHINE\",\"key\":\"$public_ssh_key\"}"

exit
