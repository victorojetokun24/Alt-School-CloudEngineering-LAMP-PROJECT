#!/bin/bash

#BASCH SCRIPT TO AUTOMATE THE DEPLOYMENT OF LAMP (LINUX, APACHE, MYSQL, PHP) STACK ON REMOTE UBUNTU APACHE SERVER (SLAVE)

# UPDATING INSTANCE PACKAGES
echo "Updating ubuntu instance ########################"
sudo apt update
echo "update completed and ready"

# INSTALLING APACHE SERVER AND MYQL-SERVER
sudo apt install apache2 mysql-server -y
echo "Apache server and mysql successfully installed..........."

# ADDING PHP REPOSITORIES
ondre(){
echo "Repositories adding in progress ##################"
yes | sudo add-apt-repository ppa:ondrej/php
# UPDATING ALL INSTALLED PACKAGES
sudo apt update
}

# INSTALLING PHP AND EXTENSIONS
php_extension(){
sudo apt install hp libapache2-mod-php php-mysql php8.3 php8.3-curl php8.3-dom php8.3-mbstring php8.3-xml php8.3-mysql php8.3-sqlite3 -y
echo "Php and extensions installed"
}

# UNINSTALLING OLD PHP VERSIONS
php_old_repo(){
sudo apt-get purge php7.4 php7.4-common -y
echo "Remove old php versions"
}

# INSTALLING AND CONFIGURING GIT ON INSTANCES
git_install_Config(){
echo "Installation and configuring git"
sudo apt install git -y
git config --global user.name "victorojetokun24"
git config --global user.email "victorojetokun24@gmail.com"
echo "Git installation and configuration configuration successful"
}

# INSTALLING ARCHIVES PACKAGES 
sudo apt install zip unzip -y
echo "zip and unzip installed successfully"

# UPDATING AN UPGRADE PACKAGES
sudo apt-get update && sudo apt upgrade -y
echo "updated package completed"

# ENABLES THE APACHE REWRITE MODULE FOR CREATING URL
apache_rewrite_url(){
sudo a2enmod rewrite
sudo a2enmod php8.3
sudo service apache2 restart
echo "process completed #####################################"
}

databse_user_setup(){
MYSQL_COMMANDS=$(cat <<EOF
# CREATE USER 
CREATE USER 'victorojetokun'@'localhost' IDENTIFIED BY '09032111796';

# CREATE DATABASE
CREATE DATABASE laravel_db;

# GRANTING PRIVILEGES
GRANT ALL PRIVILEGES ON laravel_db . * TO 'victorojetokun'@'localhost';

# FLUSHING PRRIVILEGES
FLUSH PRIVILEGES;

# TERMINATE PROCESS
EXIT;
EOF
)
echo "$MYSQL_COMMANDS" | sudo mysql -u root
echo "Database and user successfully created"
}

# SWITCHING TO BINARY DIR
cd /usr/bin

# MANAGING DEPENDENCIES WITH COMPOSER
composer_depend(){
curl -sS https://getcomposer.org/installer | sudo php
sudo mv composer.phar composer
echo "composer installed ##############################"
}

# SWITCHING INTO VAR/WWW/ TO CLONE THE PHP APPLICATION
cd /var/www/

# CLONING PHP APPLICATION FROM GITHUB
sudo git clone https://github.com/laravel/laravel.git

# SWITCHING TO LARAVEL DIRECTORY
cd laravel

# GET DEPENDENCIES WITH COMPOSER
autoloader_composer(){
composer install --optimize-autoloader --no-dev
yes | sudo composer update
sudo cp .env.example .env
}


# CONFIGURING THE .ENV FILE FOR DATABASE CONF USING IF ELSE STATEMENT
modify_env_file(){
DB_HOST="localhost"
DB_DATABASE="laravel_db"
DB_USERNAME="victorojetokun"
DB_PASSWORD="09032111796"

# Set the path to your .env file
ENV_FILE="/var/www/laravel/"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found."
  exit 0
else
# MODIFIYING THE FILE SED -i TO EDIT LINE 
# Alter the .env file
  sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST}/" ${ENV_FILE}
  sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/" ${ENV_FILE}
  sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/" ${ENV_FILE}
  sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" ${ENV_FILE}

  exit 1
 fi
}

# GENERATE APP_KEY VALUE WITH IN .ENV FILE
echo "generating the APP_KEY value within your .env file"
sudo php artisan key:generate

# VALIDATING THE USER 
ps aux | grep "apache" | awk '{print $1}' | grep -v root | head -n 1

# CHANGING STORAGE/BOOTSTRAP TO BE OWNED BY WWW-DATA
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache

# SWITCHING TO SITES-AVAILABLE DIR AND CP 000-DEFAULT TO LARAVEL.CONF
cd /etc/apache2/sites-available/

# COPING THE CONTENT OF 000-DEFAULT.CONF TO LARAVEL.CONF
sudo cp 000-default.conf laravel.conf

# CHANGING THE OWNERSHIP OF LARAVEL.CONF TO VAGRANT (USER) AND VAGRANT (GROUP)
sudo chown vagrant:vagrant laravel.conf

# CHANGING FILE TO WRITE PERMISSSION
chmod +w laravel.conf

# MODIFING LARAVEL CONF FILE TO POINT TO THE PUBLIC DIR OF THE LARAVEL APPLICATION
sudo cat<<EOF >laravel.conf
<VirtualHost *:80>
ServerName 192.168.33.20
DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined

</VirtualHost>
EOF
echo "modifying completed #########################"


# DISABLE 000-DEFAULT.CONF FILE
sudo a2dissite 000-default.conf
echo "000-default.conf disenabled"

# ENABLING LARAVEL.CONF FILE
sudo a2ensite laravel.conf

# VALIDATING APACHE CONF
apache2ctl -t
echo "checking Apache configuration files without actually restarting the Apache web server"
sudo systemctl restart apache2

# CREATING DATABASE.SQLITE FILE
sudo touch /var/www/laravel/database/database.sqlite

# CHANGING OWNERSHIP TO WWW-DATA (USER) AND WWW-DATA (GROUP)
sudo chown www-data:www-data /var/www/laravel/database/database.sqlite
echo "creating empty SQLite database file named database.sqlite in the /var/www/laravel/database/"

# NAVIGATION INTO LARAVEL APPLICATION DIR
cd /var/www/laravel/
sudo php artisan migrate
echo "Executing database migrations defined in the Laravel application #################"

# POPULATING AND MIGRATION DATABASE
sudo php artisan db:seed
echo "Seeding the database with initial data  ################"

# OPEN FIREWALL FOR APACHE FULL, PORT 8000 and OPENSSH
port_ufw(){
  sudo ufw allow 'Apache Full'
  sudo ufw allow openSSH
  sudo ufw allow 8000
  sudo ufw enable
  echo "Firewall configured and enabled"
}

# RESTARTING APACHE SERVER TO SPRING UP LARAVEL APPLICATION
sudo systemctl restart apache2

echo "Laravel Application deployed successfully #######################"

# CALLING UP THE FUNCTIONS USING MAIN
main(){
ondre
php_extension
php_old_repo
git_install_config
apache_rewrite_url
database_user_setup
composer_depend
autoloader_compose
modify_env_file
port_wfw
}
# Execute function
main
