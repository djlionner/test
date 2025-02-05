#!/bin/bash

# Actualizar sistema
apt update && apt upgrade -y

# Instalar software necesario
apt install -y software-properties-common apt-transport-https ca-certificates curl

# Agregar repositorio de Sury para versiones de PHP
add-apt-repository ppa:ondrej/php -y
apt update

# Lista de versiones de PHP compatibles con HestiaCP
PHP_VERSIONS=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3")

# Instalar todas las versiones de PHP con FPM y módulos básicos
for version in "${PHP_VERSIONS[@]}"; do
    apt install -y php${version} php${version}-fpm php${version}-cli php${version}-common php${version}-mbstring php${version}-xml php${version}-curl php${version}-zip php${version}-mysql php${version}-gd php${version}-bcmath php${version}-intl php${version}-soap php${version}-opcache php${version}-readline php${version}-imagick php${version}-redis php${version}-json php${version}-imap php${version}-xmlrpc
done

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
        sed -i "s#^memory_limit = .*#memory_limit = $memory_limit#" $PHP_CLI_INI_PATH
        sed -i "s#^upload_max_filesize = .*#upload_max_filesize = $upload_max_filesize#" $PHP_CLI_INI_PATH
        sed -i "s#^post_max_size = .*#post_max_size = $post_max_size#" $PHP_CLI_INI_PATH
        sed -i "s#^max_execution_time = .*#max_execution_time = $max_execution_time#" $PHP_CLI_INI_PATH
        sed -i "s#^max_input_time = .*#max_input_time = $max_input_time#" $PHP_CLI_INI_PATH
        sed -i "s#^date.timezone = .*#date.timezone = \"$timezone\"#" $PHP_CLI_INI_PATH
    fi

    if [ -f "$PHP_FPM_INI_PATH" ]; then
        echo "Actualizando PHP $version (FPM)..."
        sed -i "s#^memory_limit = .*#memory_limit = $memory_limit#" $PHP_FPM_INI_PATH
        sed -i "s#^upload_max_filesize = .*#upload_max_filesize = $upload_max_filesize#" $PHP_FPM_INI_PATH
        sed -i "s#^post_max_size = .*#post_max_size = $post_max_size#" $PHP_FPM_INI_PATH
        sed -i "s#^max_execution_time = .*#max_execution_time = $max_execution_time#" $PHP_FPM_INI_PATH
        sed -i "s#^max_input_time = .*#max_input_time = $max_input_time#" $PHP_FPM_INI_PATH
        sed -i "s#^date.timezone = .*#date.timezone = \"$timezone\"#" $PHP_FPM_INI_PATH
    fi

    if [ -f "$PHP_APACHE_INI_PATH" ]; then
        echo "Actualizando PHP $version (Apache)..."
        sed -i "s#^memory_limit = .*#memory_limit = $memory_limit#" $PHP_APACHE_INI_PATH
        sed -i "s#^upload_max_filesize = .*#upload_max_filesize = $upload_max_filesize#" $PHP_APACHE_INI_PATH
        sed -i "s#^post_max_size = .*#post_max_size = $post_max_size#" $PHP_APACHE_INI_PATH
        sed -i "s#^max_execution_time = .*#max_execution_time = $max_execution_time#" $PHP_APACHE_INI_PATH
        sed -i "s#^max_input_time = .*#max_input_time = $max_input_time#" $PHP_APACHE_INI_PATH
        sed -i "s#^date.timezone = .*#date.timezone = \"$timezone\"#" $PHP_APACHE_INI_PATH
    fi
done

# Reiniciar servicios PHP y Apache para aplicar cambios
systemctl restart apache2
for version in $PHP_VERSIONS; do
    systemctl restart php$version-fpm
done

# Reiniciar HestiaCP
systemctl restart hestia
