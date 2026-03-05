#!/bin/sh

# Usage: sh ssh.sh your@email.com
# Or via curl: curl -fsSL https://raw.githubusercontent.com/maticvertacnik/dotfiles/main/ssh.sh | sh -s your@email.com

EMAIL="$1"

if [ -z "$EMAIL" ]; then
    printf "Enter your email address: "
    read -r EMAIL
fi

if [ -z "$EMAIL" ]; then
    echo "Error: email address is required."
    exit 1
fi

if [ -f ~/.ssh/id_ed25519 ]; then
    echo "SSH key already exists at ~/.ssh/id_ed25519, skipping generation."
else
    echo "Generating a new SSH key for $EMAIL..."
    # https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key
    ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519
fi

# Write SSH config if not already present
if [ ! -f ~/.ssh/config ]; then
    touch ~/.ssh/config
fi

if ! grep -q "id_ed25519" ~/.ssh/config; then
    printf "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519\n" >> ~/.ssh/config
fi

# Add key to the running SSH agent and save passphrase to macOS Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null || ssh-add ~/.ssh/id_ed25519

echo "Key added to SSH agent."

echo ""
echo "SSH key ready. Copy your public key and add it to GitHub:"
echo "https://github.com/settings/ssh/new"
echo ""
pbcopy < ~/.ssh/id_ed25519.pub 2>/dev/null && echo "Public key copied to clipboard!" || cat ~/.ssh/id_ed25519.pub
