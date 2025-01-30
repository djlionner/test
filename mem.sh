
# Buscar la ultima version de HestiaCP e instalarla
echo "Instalando la ultima version de Lionner - Control Panel by HestiaCP..."
wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
bash hst-install.sh -y --port 2507 --lang es --hostname panel.lionner.com --email admin@lionner.com --password Vlamileos2507 --multiphp yes --proftpd yes --mysql8 yes --postgresql yes --sieve yes --quota yes --interactive no


# Actualizar e instalar paquetes
echo "Actualizando paquetes del sistema..."
apt update && apt upgrade -y && apt install -y software-properties-common

# Instalar PHP 8.4 y compatibilidad CLI
echo "Instalando PHP 8.4 y dependencias..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.4 php8.4-cli php8.4-fpm php8.4-mysql php8.4-curl php8.4-xml php8.4-mbstring php8.4-zip php8.4-bcmath php8.4-gd php8.4-soap php8.4-intl

# Descargar e instalar ionCube Loader
echo "Instalando ionCube Loader..."
wget https://raw.githubusercontent.com/jaapmarcus/ioncube-hestia-installer/main/install_ioncube.sh
chmod +x install_ioncube.sh
./install_ioncube.sh

# Descargar e instalar Redis & Memcached
echo "Instalando Redis & Memcached..."
sudo apt install -y memcached libmemcached-tools
sudo apt install -y php-memcached
sudo apt install -y php8.0-memcached
sudo apt install -y php8.1-memcached
sudo apt install -y php8.2-memcached
sudo apt install -y php8.3-memcached
sudo apt install -y php8.4-memcached
sudo apt install -y php8.0-redis
sudo apt install -y php8.1-redis
sudo apt install -y php8.2-redis
sudo apt install -y php8.3-redis
sudo apt install -y php8.4-redis
sudo apt install -y php-redis
sudo apt install -y redis-server
sudo systemctl enable memcached
sudo systemctl enable redis-server
a2enmod proxy_fcgi setenvif
a2enconf php8.4-fpm
a2enconf php8.3-fpm
a2enconf php8.2-fpm
a2enconf php8.1-fpm
a2enconf php8.0-fpm
apt update

#!/bin/bash

# Buscar todas las versiones de PHP instaladas
PHP_VERSIONS=$(ls /etc/php/)

# Configuración común para todas las versiones de PHP
memory_limit="8G"
upload_max_filesize="20G"
post_max_size="20G"
max_execution_time="3600"
max_input_time="3600"
timezone="Europe/Madrid"

# Iterar sobre cada versión de PHP instalada
for version in $PHP_VERSIONS; do
    # Rutas de los archivos php.ini
    PHP_CLI_INI_PATH="/etc/php/$version/cli/php.ini"
    PHP_FPM_INI_PATH="/etc/php/$version/fpm/php.ini"
    PHP_APACHE_INI_PATH="/etc/php/$version/apache2/php.ini"

    # Comprobar si el archivo php.ini existe para esta versión
    if [ -f "$PHP_CLI_INI_PATH" ]; then
        echo "Actualizando PHP $version (CLI)..."
        sed -i "s/^memory_limit = .*/memory_limit = $memory_limit/" $PHP_CLI_INI_PATH
        sed -i "s/^upload_max_filesize = .*/upload_max_filesize = $upload_max_filesize/" $PHP_CLI_INI_PATH
        sed -i "s/^post_max_size = .*/post_max_size = $post_max_size/" $PHP_CLI_INI_PATH
        sed -i "s/^max_execution_time = .*/max_execution_time = $max_execution_time/" $PHP_CLI_INI_PATH
        sed -i "s/^max_input_time = .*/max_input_time = $max_input_time/" $PHP_CLI_INI_PATH
        sed -i "s/^date.timezone = .*/date.timezone = \"$timezone\"/" $PHP_CLI_INI_PATH
    fi

    if [ -f "$PHP_FPM_INI_PATH" ]; then
        echo "Actualizando PHP $version (FPM)..."
        sed -i "s/^memory_limit = .*/memory_limit = $memory_limit/" $PHP_FPM_INI_PATH
        sed -i "s/^upload_max_filesize = .*/upload_max_filesize = $upload_max_filesize/" $PHP_FPM_INI_PATH
        sed -i "s/^post_max_size = .*/post_max_size = $post_max_size/" $PHP_FPM_INI_PATH
        sed -i "s/^max_execution_time = .*/max_execution_time = $max_execution_time/" $PHP_FPM_INI_PATH
        sed -i "s/^max_input_time = .*/max_input_time = $max_input_time/" $PHP_FPM_INI_PATH
        sed -i "s/^date.timezone = .*/date.timezone = \"$timezone\"/" $PHP_FPM_INI_PATH
    fi

    if [ -f "$PHP_APACHE_INI_PATH" ]; then
        echo "Actualizando PHP $version (Apache)..."
        sed -i "s/^memory_limit = .*/memory_limit = $memory_limit/" $PHP_APACHE_INI_PATH
        sed -i "s/^upload_max_filesize = .*/upload_max_filesize = $upload_max_filesize/" $PHP_APACHE_INI_PATH
        sed -i "s/^post_max_size = .*/post_max_size = $post_max_size/" $PHP_APACHE_INI_PATH
        sed -i "s/^max_execution_time = .*/max_execution_time = $max_execution_time/" $PHP_APACHE_INI_PATH
        sed -i "s/^max_input_time = .*/max_input_time = $max_input_time/" $PHP_APACHE_INI_PATH
        sed -i "s/^date.timezone = .*/date.timezone = \"$timezone\"/" $PHP_APACHE_INI_PATH
    fi
done

# Reiniciar servicios PHP y Apache para aplicar cambios
systemctl restart apache2
for version in $PHP_VERSIONS; do
    systemctl restart php$version-fpm
done

echo "Ajustes de PHP para todas las versiones aplicados correctamente."

echo "Instalación completada."
