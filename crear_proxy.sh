#!/bin/bash

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar squid
sudo apt install -y squid

# Pedir el nombre de usuario y contraseña
read -p "Introduce el nombre de usuario para el proxy: " USERNAME
read -s -p "Introduce la contraseña para el proxy: " PASSWORD
echo

# Configurar Squid
sudo bash -c "cat <<EOL >> /etc/squid/squid.conf
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic realm Proxy
auth_param basic credentialsttl 2 hours
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
EOL"

# Crear o actualizar el archivo de contraseña
if [ ! -f /etc/squid/passwd ]; then
    sudo touch /etc/squid/passwd
fi
sudo htpasswd -b /etc/squid/passwd $USERNAME $PASSWORD

# Reiniciar Squid para aplicar los cambios
sudo systemctl restart squid

# Mostrar datos del proxy
echo "Tu proxy está listo"
echo "IP: $(curl -s ifconfig.me)"
echo "Puerto: 3128"
echo "Usuario: $USERNAME"
echo "Contraseña: $PASSWORD"
