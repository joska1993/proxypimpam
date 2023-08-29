#!/bin/bash

# Funciones para colores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Sin color

# Verificar si el script se ejecuta como superusuario
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Por favor, ejecuta este script como superusuario (root).${NC}"
  exit 1
fi

# Actualizar e instalar paquetes necesarios
echo -e "${GREEN}Actualizando e instalando paquetes necesarios...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y squid apache2-utils curl

# Pedir información del usuario
read -p "Introduce el nombre de usuario para el proxy: " USERNAME
read -s -p "Introduce la contraseña para el proxy: " PASSWORD
echo

# Configuración de Squid
echo -e "${GREEN}Configurando Squid...${NC}"

sudo bash -c "cat <<EOL > /etc/squid/squid.conf
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic realm Proxy
auth_param basic credentialsttl 2 hours
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all
http_port 3128
EOL"

# Crear o actualizar el archivo de contraseñas
echo -e "${GREEN}Configurando usuario y contraseña...${NC}"
sudo touch /etc/squid/passwd
sudo htpasswd -b /etc/squid/passwd $USERNAME $PASSWORD

# Apertura del puerto 3128 en el firewall
echo -e "${GREEN}Configurando firewall para permitir el puerto 3128...${NC}"
sudo ufw allow 3128/tcp

# Reiniciar Squid
echo -e "${GREEN}Reiniciando Squid...${NC}"
sudo systemctl restart squid

# Verificar si Squid está funcionando
if sudo systemctl is-active --quiet squid; then
  echo -e "${GREEN}Tu proxy está listo.${NC}"
  echo "IP: $(curl -s ifconfig.me)"
  echo "Puerto: 3128"
  echo "Usuario: $USERNAME"
  echo "Contraseña: $PASSWORD"
else
  echo -e "${RED}Hubo un problema al configurar Squid. Por favor, verifica los logs para más detalles.${NC}"
fi