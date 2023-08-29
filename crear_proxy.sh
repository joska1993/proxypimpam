#!/bin/bash

# Configuración inicial de colores
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Encabezado y bienvenida
echo -e "${CYAN}#########################################################${RESET}"
echo -e "${CYAN}#              PimPamSEO Proxy Script - Ver 0.3         #${RESET}"
echo -e "${CYAN}#########################################################${RESET}"

# Generar nombre de usuario y contraseña aleatorios
username=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5; echo '')
password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5; echo '')

# Actualizar el sistema y limpiar
echo -e "${GREEN}Actualizando sistema...${RESET}"
apt-get update
apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean -y

# Obtener información IP y ISP
IP=$(curl -s eth0.me)
ISP=$(curl -s https://ipwhois.app/json/$IP)

# Instalar dependencias
echo -e "${GREEN}Instalando dependencias...${RESET}"
apt-get install fail2ban software-properties-common -y
apt-get install build-essential libevent-dev libssl-dev -y

# Descargar e instalar 3proxy
echo -e "${GREEN}Descargando e instalando 3proxy...${RESET}"
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

# Configurar 3proxy
echo -e "${GREEN}Configurando 3proxy...${RESET}"
# El resto de tu código de configuración aquí...

# Iniciar proxy
echo -e "${GREEN}Iniciando proxy...${RESET}"
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start

# Información final
echo -e "${CYAN}#########################################################${RESET}"
echo -e "${CYAN}#         Script de Proxy Gratuito Creado por PimPamSEO  #${RESET}"
echo -e "${CYAN}#        Proxy: $IP:3130:${username}:${password}         #${RESET}"
echo -e "${CYAN}#########################################################${RESET}"
