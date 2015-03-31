FROM ubuntu:precise
MAINTAINER Jeremy Rice

ENV LAST_FULL_REBUILD 2015-03-29

RUN groupmod -g 1002 www-data && \
  usermod -s /bin/bash -u 1002 -g 1002 -d /home/www-data www-data

RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install python-software-properties locales git vim-tiny \
    supervisor sudo ruby1.9.1 \
    php5-cli && \
    echo "US/Eastern" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata


ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales

RUN add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get install -qq -y nginx && \
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
    chown -R www-data:www-data /var/www

RUN gem install biodiversity --version 3.1.5 --no-ri --no-rdoc
RUN apt-get -y -qq install php5-fpm
    RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
    RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/eol_php_code_production.patch \
     /var/www/eol_php_code_production.patch
COPY files/* /var/www/

RUN git clone https://github.com/EOL/eol_php_code.git \
      /var/www/eol_php_code && \
    cd /var/www/eol_php_code && \
    patch -p1 < /var/www/eol_php_code_production.patch && \
    cd .. && ln -s eol_php_code_production/applications/conversions && \
    rm /var/www/eol_php_code_production.patch && \
    ln -s eol_php_code/applications/datasets && \
    ln -s eol_php_code/applications/dwc_validator && \
    ln -s eol_php_code/applications/schema && \
    ln -s eol_php_code/applications/specialist_project_converter && \
    ln -s eol_php_code/applications/urls_lookup && \
    ln -s eol_php_code/applications/validator && \
    ln -s eol_php_code/applications/xls2dwca && \
    ln -s eol_php_code/applications/xls2EOL && \
    cd && chown www-data:www-data -R /var/www

CMD ["/usr/bin/supervisord"]
