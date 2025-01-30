#!/bin/bash

# Eliminar UFW si está instalado
echo "Verificando si UFW está instalado..."
if dpkg -l | grep -q ufw; then
    echo "UFW detectado. Desinstalando UFW..."
    apt remove --purge ufw -y
    apt autoremove -y
    echo "UFW desinstalado correctamente."
else
    echo "UFW no está instalado, continuando con la instalación."
fi

# Actualizar e instalar paquetes
echo "Actualizando paquetes del sistema..."
apt update && apt upgrade -y && apt install -y software-properties-common

# Descargar e instalar HestiaCP
wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
bash hst-install.sh --port 2507 --lang es --hostname panel.lionner.com --email admin@lionner.com --password Vlamileos2507 --multiphp yes --proftpd yes --mysql8 yes --postgresql yes --sieve yes --quota yes --interactive no --force

# Instalar PHP 8.4, ionCube y compatibilidad CLI
echo "Instalando PHP 8.4 y dependencias..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.4 php8.4-cli php8.4-fpm php8.4-mysql php8.4-curl php8.4-xml php8.4-mbstring php8.4-zip php8.4-bcmath php8.4-gd php8.4-soap php8.4-intl

# Descargar e instalar ionCube Loader
echo "Instalando ionCube Loader..."
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvzf ioncube_loaders_lin_x86-64.tar.gz -C /usr/lib/php/
echo "zend_extension=/usr/lib/php/ioncube/ioncube_loader_lin_8.4.so" > /etc/php/8.4/fpm/conf.d/00-ioncube.ini
echo "zend_extension=/usr/lib/php/ioncube/ioncube_loader_lin_8.4.so" > /etc/php/8.4/cli/conf.d/00-ioncube.ini
systemctl restart php8.4-fpm

# Descargar e instalar Redis & Memcached
echo "Instalando Redis & Memcached..."
apt install -y redis-server
apt install -y memcached libmemcached-tools
systemctl restart memcached
systemctl restart redis-server
apt install -y php-memcached
apt install -y php-redis
systemctl enable memcached
systemctl enable redis-server

# Configurar usuario y dominios en HestiaCP
echo "Configurando usuario y dominios en HestiaCP..."
v-add-user lionnermedia password "lionnermedia - user" lionnermedia@lionner.com

# Configurar dominios para el nuevo usuario
for domain in cloud.lionnermedia.com nube.lionnermedia.com webhost.lionnermedia.com hosting.lionnermedia.com host.lionnermedia.com lionnermedia.com; do
    v-add-web-domain lionnermedia $domain
    v-add-letsencrypt-domain lionnermedia $domain
done

# Crear cuentas de correo
echo "Creando cuentas de correo..."
declare -a emails=("admin" "management" "noreply" "cloud" "hosting")
for email in "${emails[@]}"; do
    v-add-mail-domain lionnermedia lionnermedia.com
    v-add-mail-account lionnermedia lionnermedia.com $email "password"
done

# Instalar skins de HestiaCP
echo "Instalando skins de HestiaCP..."
mkdir -p /usr/local/hestia/web/themes
cd /usr/local/hestia/web/themes
git clone https://github.com/MaxiZamorano/maxtheme.git

# Configurar PHP para Nextcloud
echo "Configurando PHP para Nextcloud..."
echo "memory_limit = 8G" >> /etc/php/8.4/fpm/php.ini
echo "upload_max_filesize = 20G" >> /etc/php/8.4/fpm/php.ini
echo "date.timezone = Europe/Madrid" >> /etc/php/8.4/fpm/php.ini
systemctl restart php8.4-fpm

# Reiniciar HestiaCP
echo "Reiniciando HestiaCP..."
systemctl restart hestia

echo "Instalación completada."
