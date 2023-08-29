#!/bin/bash
##############################################################
# Script_Name : PimPamSEO Proxy Script
# Description : Install and configure a proxy server
# For Ubuntu 12 and later .04 LTS versions only
# Released : August 2023
# Web Site : https://pimpamseo.com
# Version : 1.0
##############################################################
echo;/bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
/bin/echo -e "\e[1;36m#             PimPamSEO Proxy Script - Ver 1.0                     #\e[0m"
/bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m";echo;username=$(head /dev/urandom|tr -dc A-Za-z0-9|head -c 5;echo '');password=$(head /dev/urandom|tr -dc A-Za-z0-9|head -c 5;echo '')
apt-get update;apt-get upgrade -y;apt-get autoremove -y;apt-get autoclean -y
IP=$(curl -s eth0.me)
ISP=$(curl -s https://ipwhois.app/json/$IP)
#if [[ $ISP != *"Digital"* ]];then echo -e "\e[1;91m ERROR: THIS SCRIPT IS DESIGNED TO WORK WITH DIGITAL OCEAN ONLY! \e[0m";exit 0;fi
apt-get install fail2ban software-properties-common -y;apt-get install build-essential libevent-dev libssl-dev -y
rm -rf /usr/local/etc/3proxy
cd /usr/local/etc
wget https://github.com/z3APA3A/3proxy/archive/0.8.12.tar.gz
tar zxvf 0.8.12.tar.gz
rm 0.8.12.tar.gz
mv 3proxy-0.8.12 3proxy 
cd 3proxy
make -f Makefile.Linux
make -f Makefile.Linux install
mkdir log 
cd cfg
rm 3proxy.cfg.sample
echo "#!/usr/local/bin/3proxy
daemon
pidfile /usr/local/etc/3proxy/3proxy.pid
nserver 1.1.1.1
nserver 1.0.0.1
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
log /usr/local/etc/3proxy/log/3proxy.log D
logformat \"- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T\"
archiver rar rar a -df -inul %A %F
rotate 30
internal 0.0.0.0
external 0.0.0.0
authcache ip 60




proxy -p3130 -a -n
" >> /usr/local/etc/3proxy/cfg/3proxy.cfg
chmod 700 3proxy.cfg
sed -i '14s/.*/       \/usr\/local\/etc\/3proxy\/cfg\/3proxy.cfg/' /usr/local/etc/3proxy/scripts/rc.d/proxy.sh
sed -i "4ish /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start" /etc/rc.local
sed -i '17s/.*/auth strong/' /usr/local/etc/3proxy/cfg/3proxy.cfg  
sed -i "15s/.*/users $username:CL:$password/" /usr/local/etc/3proxy/cfg/3proxy.cfg 
sed -i "18s/.*/allow $username /" /usr/local/etc/3proxy/cfg/3proxy.cfg 
PUBLIC_IP=$(curl -s eth0.me)
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start

echo
/bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
/bin/echo -e "\e[1;36m#             PimPamSEO Proxy Script - Ver 1.0                 \e[0m"
/bin/echo -e "\e[1;36m              Proxy: $PUBLIC_IP:3130:$username:$password                \e[0m"
/bin/echo -e "\e[1;36m#                                                             #\e[0m"
/bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
echo
