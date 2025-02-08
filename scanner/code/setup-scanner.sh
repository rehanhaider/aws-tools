#!/bin/bash

set -e  # Exit immediately if a command fails

# Define Go version
GO_VERSION="1.23.5"
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_TAR}"

# Install dependencies
apt update
apt install -y wget
apt install -y ruby

# Change to /tmp to avoid clutter in the working directory
cd /tmp

# Download new Go version
echo "Downloading Go ${GO_VERSION}..."
wget -q --show-progress "${GO_URL}"

# Remove old Go version
echo "Removing old Go installation..."
rm -rf /usr/local/go

# Install new Go version
echo "Extracting Go ${GO_VERSION}..."
tar -C /usr/local -xzf "${GO_TAR}"
rm "${GO_TAR}"  # Cleanup tar file

# Set up environment variables permanently
echo "Setting up Go environment variables..."
echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile.d/go.sh > /dev/null
chmod +x /etc/profile.d/go.sh

# Install Nuclie in /tmp/go
/usr/local/go/bin/go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
# git clone https://github.com/projectdiscovery/nuclei.git /tmp/nuclei
# cd /tmp/nuclei/cmd/nuclei
# /usr/local/go/bin/go build
# mv nuclei /usr/local/bin

# Set up environment variables for current session
export PATH=$PATH:/usr/local/go/bin