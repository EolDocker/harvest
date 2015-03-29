# Based on welovecloud/apache-php53
FROM debian:squeeze
MAINTAINER Jeremy Rice

ENV LAST_FULL_REBUILD 2015-03-26

RUN groupmod -g 1002 www-data && \
  usermod -s /bin/bash -u 1002 -g 1002 -d /var/www www-data
RUN apt-get update && apt-get -y upgrade && \
  # Common packages
  apt-get -y install curl wget locales nano git vim-tiny && \
  echo "US/Eastern" > /etc/timezone && \
  dpkg-reconfigure -f noninteractive tzdata && \
  export LANGUAGE=en_US.UTF-8 && \
  export LANG=en_US.UTF-8 && \
  export LC_ALL=en_US.UTF-8 && \
  locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales && \
  wget -qO /root/dotdeb.gpg http://www.dotdeb.org/dotdeb.gpg && \
  apt-key add /root/dotdeb.gpg && \
  echo "deb http://dotdeb.netmirror.org/ squeeze all" > \
    /etc/apt/sources.list.d/dotdeb.list && \
  echo "deb-src http://dotdeb.netmirror.org/ squeeze all" >> \
    /etc/apt/sources.list.d/dotdeb.list && \
  apt-get update && \
  #OLD: apt-get -t squeeze-backports -y install nginx-extras && \
  apt-get install -y supervisor mysql-client \
    php5-cli php5-curl php-soap php5-imagick php5-gd php5-mcrypt \
    php5-xmlrpc php5-xsl php5-xdebug libarc-php \
    libphp-phpmailer libapache2-mod-php5 \
    php-auth-sasl php-http php-http-request php-http-upload \
    php-http-webdav-server php-image-text php-log php-mail \
    php-mail-mime php-mail-mimedecode php-mime-type php-net-dime php-net-ftp \
    php-net-smtp php-net-socket php-net-url php-pear php-xml-htmlsax3 \
    php-xml-parser php5-dev php5-memcache php5-memcached \
    # TODO: DO WE NEED THESE?
    # php5-mysqlnd libzend-framework-php libzend-framework-zendx-php libfpdf-tpl-php php-fpdf
    # php-imlib php5-ps 
    php5-uuid phpsysinfo php5-fpm && \
  git clone https://github.com/EOL/eol_php_code.git /var/www/eol_php_code && \
  apt-get -y purge git && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  apt-get -y autoremove

# TODO: Add the www-data user to chef (for harvest machine)

# TODO: cron
# TODO: rm supervisor or use it
# TODO: php-fpm
#OLD: COPY ./nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/log/supervisor # && \
  #LATER: chown -R www-data:www-data /var/www && \
# TODO:
# applications/xls2dwca/form_result.php
#   $final_archive_gzip_url = "http://services.eol.org/conversions/" ... etc
# config/environment.php
#   ini_set('memory_limit', '15360M'); // 1GB maximum memory usage
#   ini_set('max_execution_time', '604800'); // 6 hours
#   ini_set('display_errors', true);
#   if(!isset($GLOBALS['ENV_NAME'])) $GLOBALS['ENV_NAME'] = 'production';
#   if(!defined('WEB_ROOT')) define('WEB_ROOT', 'http://eol-thebeast.rc.fas.harvard.edu/eol_php_code/');
#   EVENTUALLY: (We'll want this on to start with, I think):
#   if(!isset($GLOBALS['ENV_MYSQL_DEBUG'])) $GLOBALS['ENV_MYSQL_DEBUG'] = false;
#   if(!defined('DOWNLOAD_TIMEOUT_SECONDS')) define('DOWNLOAD_TIMEOUT_SECONDS', '45');
#   $GLOBALS['log_file'] = fopen(DOC_ROOT . "temp/processes.log", "a+");
#   if(!defined('CONTENT_LOCAL_PATH'))          define('CONTENT_LOCAL_PATH', '/opt/content/')
#   if(!defined('CONTENT_RESOURCE_LOCAL_PATH')) define('CONTENT_RESOURCE_LOCAL_PATH', '/opt/resources/');
# rake_tasks/denormalize_tables.php  -- Comment this line out:
#   // shell_exec(PHP_BIN_PATH . dirname(__FILE__)."/top_images.php ENV_NAME=". $GLOBALS['ENV_NAME']);
# vendor/namelink/module.php -- Of course, we will change this IP...
#   define("TAXONFINDER_SOCKET_SERVER", "10.242.92.108");

#TEMP: COPY config/docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# sSMTP
#TEMP: RUN   apt-get -y install ssmtp

# PaaS bootstrap
#TEMP: COPY    bin/container-bootstrap.sh /usr/bin/container-bootstrap.sh
#TEMP: RUN     chmod +x /usr/bin/container-bootstrap.sh

# TODO: Add to docker, if we have users and groups, use those usermmod to change
# the id for user ; We also have eol_users, which is a another possibility.
# ...So we can either use those users, and create users without shells for
# things like www-data ... but we need to solve this later.

# TODO: create a user without shell and without homedir. ...then take uuid of
# that user and make that uuid in the container.

# TODO: Check thebeast for php.ini changes. :|

# TODO: Check thebeast for /etc/php5/cli/conf.d/*ini

# TODO: NOT writable by world:
RUN chmod -R a+w eol_php_code/log eol_php_code/temp eol_php_code/tmp \
  eol_php_code/applications/content_server/

COPY apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

EXPOSE 80

CMD ["/usr/sbin/apachectl", "start"]
# OLD: CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
