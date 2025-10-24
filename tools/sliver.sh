#!/bin/bash
# shout out TNTech <3

# Function to check if IP is bound to the server's network interfaces
is_valid_ip() {
  ip addr | grep -w "$1" > /dev/null 2>&1
}

# Check if IP address is provided as a command line argument
if [ -z "$1" ]; then
  while true; do
    read -p "Enter the server IP address: " server_ip
    if is_valid_ip "$server_ip"; then
      echo "Valid IP address: $server_ip"
      break
    else
      echo "The IP address $server_ip is not bound to any server interface. Please enter a valid IP address."
    fi
  done
else
  if is_valid_ip "$1"; then
    server_ip=$1
  else
    echo "The IP address $1 is not bound to any server interface. Please enter a valid IP address."
    exit 1
  fi
fi

# Install Sliver and set up environment
curl https://sliver.sh/install | sudo bash
sudo chmod +x /root/sliver-server
sudo systemctl enable --now sliver

# Install Metasploit
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall && ./msfinstall

# List of operator names
operators=("michael" "mike" "alex" "monte" "noah" "sam")

# Generate Sliver operators using the provided or entered IP address
for operator in "${operators[@]}"; do
  sudo /root/sliver-server operator --name "$operator" --lhost "$server_ip" --save "/opt/$operator.cfg"
done