#!/bin/bash

# Actualizar el sistema
apt update && apt upgrade -y

# Instalar Ubuntu PRO by Lionner
sudo pro attach C19WNcWHBNdmnPM3HsCwqUEwKETjQ

# Instalar software necesario
apt install -y software-properties-common apt-transport-https ca-certificates curl

# Instalar el paquete de idioma español
apt install -y language-pack-es

# Configurar el idioma predeterminado a español
update-locale LANG=es_ES.UTF-8

# Agregar repositorio de Sury para versiones de PHP
add-apt-repository ppa:ondrej/php -y
apt update

# Instalar PHP desde 7.0 hasta 8.4, FPM y módulos comunes
PHP_VERSIONS=("7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")

for version in "${PHP_VERSIONS[@]}"; do
    # Instalar PHP, FPM y módulos comunes
    apt install -y php${version} php${version}-fpm php${version}-cli php${version}-common php${version}-mbstring php${version}-xml php${version}-curl php${version}-zip php${version}-mysql php${version}-gd php${version}-bcmath php${version}-intl php${version}-soap php${version}-opcache php${version}-readline php${version}-imagick php${version}-redis php${version}-json php${version}-imap php${version}-xmlrpc php${version}-gmp php${version}-apcu php${version}-memcached
done

# Instalar php-memcached y php-redis para todas las versiones
apt install -y php-memcached php-redis

# Asegurar que los servicios PHP-FPM estén activos
for version in "${PHP_VERSIONS[@]}"; do
    systemctl enable php${version}-fpm
    systemctl start php${version}-fpm
done

# Integrar versiones de PHP en HestiaCP
for version in "${PHP_VERSIONS[@]}"; do
    v-add-web-php ${version} fpm
done

echo "Todas las versiones de PHP han sido instaladas y configuradas en HestiaCP."

# Configuración común para todas las versiones de PHP (convertido a MB)
memory_limit="8192M"  # 8 GB en MB
upload_max_filesize="20480M"  # 20 GB en MB
post_max_size="20480M"  # 20 GB en MB
max_execution_time="60000"  # Aumentado a 60000 segundos
max_input_time="60000"  # Aumentado a 60000 segundos
timezone="Europe/Madrid"

# Iterar sobre cada versión de PHP instalada y actualizar php.ini
for version in "${PHP_VERSIONS[@]}"; do
    # Rutas de los archivos php.ini
    PHP_CLI_INI_PATH="/etc/php/$version/cli/php.ini"
    PHP_FPM_INI_PATH="/etc/php/$version/fpm/php.ini"
    PHP_APACHE_INI_PATH="/etc/php/$version/apache2/php.ini"

    # Comprobar y actualizar archivos php.ini
    for php_ini_path in $PHP_CLI_INI_PATH $PHP_FPM_INI_PATH $PHP_APACHE_INI_PATH; do
        if [ -f "$php_ini_path" ]; then
            echo "Actualizando PHP $version en $php_ini_path..."
            sed -i "s#^memory_limit = .*#memory_limit = $memory_limit#" $php_ini_path
            sed -i "s#^upload_max_filesize = .*#upload_max_filesize = $upload_max_filesize#" $php_ini_path
            sed -i "s#^post_max_size = .*#post_max_size = $post_max_size#" $php_ini_path
            sed -i "s#^max_execution_time = .*#max_execution_time = $max_execution_time#" $php_ini_path
            sed -i "s#^max_input_time = .*#max_input_time = $max_input_time#" $php_ini_path
            sed -i "s#^date.timezone = .*#date.timezone = \"$timezone\"#" $php_ini_path
        fi
    done
done

# Instalar ionCube para todas las versiones de PHP
for version in "${PHP_VERSIONS[@]}"; do
    apt install -y php${version}-ioncube-loader
done

# Instalar npm y mjs
apt install -y npm

# Verificar si npm se instaló correctamente
if command -v npm &>/dev/null; then
    echo "npm ha sido instalado correctamente."
else
    echo "Hubo un error al instalar npm."
fi

# Instalar HestiaCP
echo "Instalando HestiaCP..."
wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
bash hst-install.sh --lang 'es' --hostname 'cp.lionner.es' --username 'admin' --email 'admin@lionner.es' --password 'Vlamileos2507' --multiphp '7.0,7.1,7.2,7.3,7.4,8.0,8.1,8.2,8.3,8.4' --mysql8 yes --postgresql yes --sieve yes --quota yes --webterminal yes --interactive no --force Y

# Eliminar el archivo de instalación de HestiaCP
rm -f hst-install.sh

# Reiniciar servicios PHP y Apache para aplicar cambios
systemctl restart apache2
for version in "${PHP_VERSIONS[@]}"; do
    systemctl restart php${version}-fpm
done

# Reiniciar HestiaCP
systemctl restart hestia

echo "Instalación y configuración de PHP, ionCube, npm, mjs, php-memcached y php-redis completadas."
echo "HestiaCP ha sido instalado y configurado correctamente."
