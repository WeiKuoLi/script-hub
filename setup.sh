#!/bin/bash

# Update package lists
sudo apt update

# wget and dpkg
sudo apt install dpkg wget

# Install Google Chrome stable
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Install Git, Vim, SSH, g++, build-essential, and CMake
sudo apt install git vim ssh g++ build-essential cmake

# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p /opt/miniconda

# Add Miniconda bin directory to PATH in .bashrc
echo 'export PATH="/opt/miniconda/bin:$PATH"' >> ~/.bashrc

# Reload .bashrc
source ~/.bashrc

# Initialize conda
conda init

# Reload .bashrc
source ~/.bashrc

# Create conda environment 'science' and install required packages
conda create -y -n science python=3.9
conda activate science
conda install -y -n science torch matplotlib numpy pandas ipykernel

# Set up Jupyter Notebook kernel
python -m ipykernel install --user --name=science --display-name="python [science]"

# Final message
echo -e "\nSetup complete. Conda environment 'science' and Jupyter Notebook kernel 'science' created."


# Update package lists and install Git
#sudo apt update
sudo apt install -y git

# Configure Git user email and name
git config --global user.email "wli22@nd.edu"
git config --global user.name "WeiKuo Li"

# Check if SSH key exists in ~/.ssh/id_rsa.pub
ssh_dir="$HOME/.ssh"
ssh_pub_key="$ssh_dir/id_rsa.pub"

if [ ! -f "$ssh_pub_key" ]; then
    echo "SSH key not found. Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -C "wli22@nd.edu" -f "$ssh_dir/id_rsa" -N ""
    echo -e "\nNew SSH key generated:"
    cat "$ssh_pub_key"
else
    echo "SSH key found:"
    cat "$ssh_pub_key"
fi

# Prompt user to add SSH key to GitHub
read -p "Please add your SSH key to GitHub and press Enter to continue..."

# Test SSH connection to GitHub
ssh -T git@github.com

# Clone repository to ~/Code (create directory if not exist)
code_dir="$HOME/Code"
mkdir -p $code_dir  # create directory if not exist
cd $code_dir || exit 1  # change directory to Code or exit if failed

git clone git@github.com:WeiKuoLi/Ascii_waves.git

# Confirmation message
echo -e "\nRepository cloned successfully to $code_dir/Ascii_waves."



