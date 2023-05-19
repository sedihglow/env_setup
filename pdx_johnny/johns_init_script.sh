NAME_FIRST_LAST="John Andersen"
EMAIL=johnandersenpdx@gmail.com

# Create homedir venv
mkdir -p ~/.local/.venv
python -m venv ~/.local/.venv || python3 -m venv ~/.local/.venv
. ~/.local/.venv/bin/activate
python -m pip install -U pip setuptools wheel
python -m pip install -U keyring keyrings-alt

# Install GitHub CLI
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# Log into GitHub
gh auth login

# Configure git
git config --global user.name $NAME_FIRST_LAST
git config --global user.email $EMAIL
git config --global pull.rebase true

# Clone dotfiles
git clone https://github.com/pdxjohnny/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
echo -e 'if [ -f ~/.pdxjohnnyrc ]; then\n. ~/.pdxjohnnyrc\nfi' | tee "${HOME}/.bashrc"
history -a
exec bash
dotfiles_branch=$(hostname)-$(date "+%4Y-%m-%d-%H-%M")
git checkout -b $dotfiles_branch
git push --set-upstream origin $dotfiles_branch

# Modify dotfiles for host
# Open tmux and copy based the errors into invalid
# cat > /tmp/invalid <<'EOF'
# EOF
# grep -vE $(invalid=$(< /tmp/invalid); invalid=${invalid/$'\n'/ }; echo $invalid | sed -e 's/ /|/g' < ~/.tmux.conf) \
#   | (temp_conf=$(mktemp); cat > $temp_conf \
#      && truncate  --no-create -s 0 ~/.tmux.conf \
#      && tee -a  ~/.tmux.conf < $temp_conf)
sed -i "s/Dot Files/Dot Files: $dotfiles_branch/g" README.md
# Save modifications
cd ~/.dotfiles
git commit -sam "Initial auto-tailor for $(hostname)"
git push

# Install extras
pip install --force-reinstall -U https://github.com/ytdl-org/youtube-dl/archive/refs/heads/master.tar.gz#egg=youtube_dl
