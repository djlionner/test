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
sudo apt install -y redis-server
sudo apt install -y memcached libmemcached-tools
sudo apt install memcached
systemctl restart memcached
systemctl restart redis-server
sudo apt install -y php-memcached
sudo apt install -y php-redis
sudo systemctl enable memcached
sudo systemctl enable redis-server

echo "Instalación completada."
