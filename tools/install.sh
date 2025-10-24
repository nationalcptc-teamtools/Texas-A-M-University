#!/bin/bash

# A script to quickly set up a Kali Linux machine, or any other Linux distribution that uses apt.

# Sets username variable to the user's username with whoami
username="$(whoami)"

# Continue with the full setup if no specific repositories were specified
# Ask user if they want to install SecLists and/or lxd privesc
read -p "Do you want to install SecLists? (y/n): " response1
read -p "Do you want to install Ghidra? (y/n): " response2
read -p "Do you want to install GhostWriter? (y/n): " response3
sudo apt update
# Install required packages, gobuster, rlwrap, and remmina (RDP but kinda better than freexrdp)
sudo apt install -y ldap-utils gobuster remmina rlwrap krb5-user libkrb5-dev

# Install cyberchef
sudo apt install -y ffuf cewl cyberchef

# unzip rockyou.txt
sudo gunzip /usr/share/wordlists/rockyou.txt.gz

# Clone all GitHub repositories if no -r option was used
mkdir -p ~/tools
cd ~/tools

# install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt update -y -qq > /dev/null 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
sudo curl -sSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl start docker
sudo systemctl enable docker > /dev/null 2>&1
sudo usermod -aG docker $USER

# Create linux-binary directory and download files
mkdir linux-binary
cd linux-binary

wget https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_386.gz
wget https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz
gunzip *.gz
mv chisel_1.9.1_linux_386 chisel32
mv chisel_1.9.1_linux_amd64 chisel64
wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_agent_0.7.5_linux_amd64.tar.gz
wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_proxy_0.7.5_linux_amd64.tar.gz
tar -xzvf ligolo-ng_agent_0.7.5_linux_amd64.tar.gz
tar -xzvf ligolo-ng_proxy_0.7.5_linux_amd64.tar.gz
rm -f README.md ligolo-ng_proxy_0.7.5_linux_amd64.tar.gz ligolo-ng_agent_0.7.5_linux_amd64.tar.gz LICENSE
git clone https://github.com/rebootuser/LinEnum.git
wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
cd ..

# Create windows-binary directory and download files
mkdir windows-binary
cd windows-binary
wget https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_windows_386.gz
wget https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_windows_amd64.gz
gunzip *.gz
mv chisel_1.9.1_windows_386 chisel32.exe
mv chisel_1.9.1_windows_amd64 chisel64.exe
wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_agent_0.7.5_windows_amd64.zip
wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.7.5/ligolo-ng_proxy_0.7.5_windows_amd64.zip
# unzip *.zip
rm -f README.md
wget https://github.com/peass-ng/PEASS-ng/releases/download/20240519-fab0d0d5/winPEASx64.exe
git clone https://github.com/int0x33/nc.exe.git
git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries.git
wget https://github.com/antonioCoco/RunasCs/releases/download/v1.5/RunasCs.zip

# add mimikatz (stable)
mkdir mimikatz
cd mimikatz
wget https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip
# WHY ARE ALL THE UNZIPS COMMENTED OUT, IDK
# unzip mimikatz_trunk.zip
cd ..

git clone https://github.com/Kevin-Robertson/Powermad.git
wget https://github.com/PowerShellMafia/PowerSploit/raw/master/Recon/PowerView.ps1

wget https://github.com/SpecterOps/SharpHound/releases/download/v2.7.2/SharpHound_v2.7.2_windows_x86.zip
cd ..

# create webapp directory which stores all webapp related tools
mkdir webapp
cd webapp
git clone https://github.com/BlackArch/webshells.git
git clone https://github.com/ambionics/phpggc.git
git clone https://github.com/synacktiv/php_filter_chain_generator.git
cd ..

# Create rev-eng directory and download files
mkdir rev-eng
cd rev-eng
wget https://github.com/icsharpcode/AvaloniaILSpy/releases/download/v7.2-rc/Linux.x64.Release.zip
# unzip Linux.x64.Release.zip
# unzip ILSpy-linux-x64-Release.zip
cd ..

# Install bloodhound, neo4j
sudo apt install -y bloodhound neo4j

# installs seclists if user wants
if [[ "$response1" = "y" || "$response1" = "Y" ]]; then
    sudo apt install -y seclists
else
    echo "No action taken for SecLists."
fi

if [[ "$response2" = "y" || "$response2" = "Y" ]]; then
    sudo apt install -y ghidra
else
    echo "No action taken for Ghidra."
fi


if [[ "$response3" = "y" || "$response3" = "Y" ]]; then
    # install GhostWriter
    if [ ! -d "Ghostwriter" ]; then
    git clone https://github.com/GhostManager/Ghostwriter.git
    cd Ghostwriter
    chmod +x ghostwriter-cli-linux
    ./ghostwriter-cli-linux install
    else
    echo "Ghostwriter directory already exists, no action taken"
    fi
else
    echo "No action taken for Ghostwriter."
fi

# Recursively change permissions to be correct
sudo chown -R $username:$username ~/tools

echo ""
echo ""
echo '============== Good luck and happy hacking! =============='