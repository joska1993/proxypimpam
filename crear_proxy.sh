#!/bin/bash

# Verificar si el script se ejecuta como superusuario
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como superusuario (root)."
  exit 1
fi

# Actualizar e instalar paquetes necesarios
echo "Actualizando e instalando paquetes necesarios..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y squid curl

# Instalar apache2-utils si htpasswd no está instalado
if ! command -v htpasswd &> /dev/null; then
    echo "Instalando apache2-utils para htpasswd..."
    sudo apt install -y apache2-utils
fi

# Pedir información del usuario
read -p "Introduce el nombre de usuario para el proxy: " USERNAME
read -s -p "Introduce la contraseña para el proxy: " PASSWORD
echo

# Configuración de Squid
echo "Configurando Squid..."
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
echo "Configurando usuario y contraseña..."
sudo touch /etc/squid/passwd
sudo htpasswd -b /etc/squid/passwd $USERNAME $PASSWORD

# Apertura del puerto 3128 en el firewall
echo "Configurando firewall para permitir el puerto 3128..."
sudo ufw allow 3128/tcp

# Reiniciar Squid
echo "Reiniciando Squid..."
sudo systemctl restart squid

# Verificar si Squid está funcionando
if sudo systemctl is-active --quiet squid; then
  echo "Tu proxy está listo."
  echo "IP: $(curl -s ifconfig.me)"
  echo "Puerto: 3128"
  echo "Usuario: $USERNAME"
  echo "Contraseña: $PASSWORD"
else
  echo "Hubo un problema al configurar Squid. Por favor, verifica los logs para más detalles."
fi
