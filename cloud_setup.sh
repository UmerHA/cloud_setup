#! /bin/bash
set -euo pipefail
# shorten motd
cd /etc/update-motd.d
sudo rm 10-help-text 50-* 9*
sudo sed -i 's/)\./). Let'\''s go!/' 00-header
cd ~
# install eza
sudo apt update
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza
cat >> .bashrc << 'EOF'

if command -v eza > /dev/null; then
  alias ls="eza"
  alias tree="eza --tree"
  alias lha="eza -lh --group-directories-first -a"
fi
EOF
# install tmux and lsyncd
sudo apt install -y tmux lsyncd
# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
# create ml env
mkdir ml && cd ml
uv venv --python 3.12
source .venv/bin/activate
uv pip install fastcore fastai notebook tqdm tabulate
# install shellsage
uv tool install --python 3.12 shell_sage
echo "Let's set up shellsage. Enter your anthropic key:"
read -rs key < /dev/tty
echo
echo "What model should the default be? (Defaults to claude-sonnet-5)"
read -r model < /dev/tty
model=${model:-claude-sonnet-5}
sed -i "s|api_key =|api_key = $key|; s|model = .*|model = $model|" ~/.config/shell_sage/shell_sage.conf
# public keys
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "Let's set up your public key(s). Enter one per line, empty line when done."
while read -r line < /dev/tty; do
  [ -z "$line" ] && break
  echo "$line" >> ~/.ssh/authorized_keys
done
chmod 600 ~/.ssh/authorized_keys
