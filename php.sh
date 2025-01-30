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

echo "Ajustes de PHP para todas las versiones aplicados correctamente."
