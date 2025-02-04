#!/bin/bash



# Install Go

## Remove old version
sudo rm -rf /usr/local/go

## Install new version
wget https://go.dev/dl/go1.23.5.linux-amd64.tar.gz -O ~/go.tar.gz
sudo tar -C /usr/local -xzf ~/go.tar.gz
sudo rm ~/go.tar.gz

## Set up environment variables
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

## Install Nuclie in /tmp/go
go install 
