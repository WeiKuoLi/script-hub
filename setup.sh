#!/bin/bash

# Detect the actual user if run with sudo
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Update package lists
sudo apt update

######## basic #######

# wget and dpkg
sudo apt install -y dpkg wget

# Install Git, Vim, SSH, g++, build-essential, and CMake
sudo apt install -y vim ssh g++ build-essential cmake

# Add aliases to the real user's home directory
echo 'alias l="ls"' >> "$REAL_HOME/.bash_aliases"
echo 'alias ll="ls -l"' >> "$REAL_HOME/.bash_aliases"
echo 'alias p="python3"' >> "$REAL_HOME/.bash_aliases"
echo 'alias sshxxx="ssh -XY wli22@bastion.crc.nd.edu"' >> "$REAL_HOME/.bash_aliases"
chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.bash_aliases"


######## miniconda with jupyter notebook #######

# Install Miniconda (The -b flag automatically accepts the installer license)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
sudo bash /tmp/miniconda.sh -b -p /opt/miniconda

# Fix permissions so your user can use conda without sudo
sudo chown -R "$REAL_USER:$REAL_USER" /opt/miniconda

# Add Miniconda bin directory to PATH for the real user
echo 'export PATH="/opt/miniconda/bin:$PATH"' >> "$REAL_HOME/.bashrc"
chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.bashrc"

# Dynamically source conda into this script session so the next commands work
source /opt/miniconda/etc/profile.d/conda.sh

# Initialize conda for the user's interactive shell
/opt/miniconda/bin/conda init bash

# --- ACCEPT TERMS OF SERVICE AUTOMATICALLY ---
# Tell Conda's TOS plugin to auto-accept the repository agreements
export CONDA_PLUGINS_AUTO_ACCEPT_TOS=yes
/opt/miniconda/bin/conda config --set plugins.auto_accept_tos yes

# Create conda environment 'torch' and install required packages
conda create -y -n torch python=3.9
conda activate torch
conda install -y pytorch cpuonly numpy matplotlib pandas -c pytorch

# Final message
echo -e "\nSetup complete. Conda environment 'torch' created."


######## git #######

sudo apt install -y git

# Configure Git for the real user
sudo -u "$REAL_USER" git config --global user.email "wli22@nd.edu"
sudo -u "$REAL_USER" git config --global user.name "WeiKuo Li"

# Check if SSH key exists
ssh_dir="$REAL_HOME/.ssh"
ssh_pub_key="$ssh_dir/id_rsa.pub"

if [ ! -f "$ssh_pub_key" ]; then
    echo "SSH key not found. Generating new SSH key..."
    sudo -u "$REAL_USER" mkdir -p "$ssh_dir"
    sudo -u "$REAL_USER" ssh-keygen -t rsa -b 4096 -C "wli22@nd.edu" -f "$ssh_dir/id_rsa" -N ""
    echo -e "\nNew SSH key generated:"
    cat "$ssh_pub_key"
else
    echo "SSH key found:"
    cat "$ssh_pub_key"
fi

# Prompt user to add SSH key to GitHub
read -p "Please add your SSH key to GitHub and press Enter to continue..."

# Test SSH connection to GitHub as the real user
sudo -u "$REAL_USER" ssh -T -o StrictHostKeyChecking=accept-new git@github.com

# Clone repository to ~/Code (Now targeting your real home directory)
code_dir="$REAL_HOME/Code"
sudo -u "$REAL_USER" mkdir -p "$code_dir"
cd "$code_dir" || exit 1

sudo -u "$REAL_USER" git clone git@github.com:WeiKuoLi/Ascii_waves.git
sudo -u "$REAL_USER" git clone git@github.com:WeiKuoLi/script-hub.git

cd ./script-hub || exit 1
sudo -u "$REAL_USER" python3 test.py

# Confirmation message
echo -e "\nRepository cloned successfully to $code_dir"


######## vim #########
# Safely write to the real user's .vimrc and fix ownership
echo "set tabstop=2" >> "$REAL_HOME/.vimrc"
echo "set shiftwidth=2" >> "$REAL_HOME/.vimrc"
echo "set expandtab" >> "$REAL_HOME/.vimrc"
chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.vimrc"
