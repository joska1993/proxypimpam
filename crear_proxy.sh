#!/bin/bash
##############################################################
# Script_Name : PimPamSEO Proxy Script
# Description : Install and configure a proxy server
# For Ubuntu 12 and later .04 LTS versions only
# Released : August 2023
# Web Site : https://pimpamseo.com
# Version : 1.0
##############################################################

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Function to display the banner
display_banner() {
  echo -e "\e[1;34m##############################################################\e[0m"
  echo -e "\e[1;33m#              PimPamSEO Free Proxy Script - Ver 1.1         #\e[0m"
  echo -e "\e[1;34m##############################################################\e[0m"
}

# Function to update and clean the system
update_system() {
  apt-get update && \
  apt-get upgrade -y && \
  apt-get autoremove -y && \
  apt-get autoclean -y || {
    echo "Failed to update and clean the system."
    exit 1
  }
}

# Function to install dependencies
install_dependencies() {
  apt-get install -y fail2ban software-properties-common build-essential libevent-dev libssl-dev || {
    echo "Failed to install dependencies."
    exit 1
  }
}

# Function to install 3proxy
install_3proxy() {
  cd /usr/local/etc || exit 1
  wget https://github.com/z3APA3A/3proxy/archive/0.8.12.tar.gz || exit 1
  tar zxvf 0.8.12.tar.gz && rm 0.8.12.tar.gz || exit 1
  mv -T 3proxy-0.8.12 3proxy || exit 1
  cd 3proxy || exit 1
  make -f Makefile.Linux && make -f Makefile.Linux install || exit 1
  mkdir log || exit 1
}

# Function to start proxy
start_proxy() {
  sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start || {
    echo "Failed to start proxy."
    exit 1
  }
}

# Function to display proxy information
display_info() {
  local public_ip=$(curl -s eth0.me)
  echo -e "\e[1;34m#       Proxy: $public_ip:3130:$username:$password           #\e[0m"
  echo -e "\e[1;34m##############################################################\e[0m"
}

# Generate username and password
username=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 10)
password=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 10)

# Show banner
display_banner

# Update and clean the system
update_system

# Install dependencies
install_dependencies

# Install 3proxy
install_3proxy

# Configure and start proxy
start_proxy

# Display information
display_info
