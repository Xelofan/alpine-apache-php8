FROM alpine:3
MAINTAINER Paul Smith <pa.ulsmith.net>

# Add repos
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Add basics first
RUN apk update && apk upgrade && apk add \
	bash apache2 php8-apache2 curl ca-certificates openssl openssh git php8 php8-phar php8-json php8-iconv php8-openssl tzdata openntpd nano

# Add Composer
RUN curl -sS https://getcomposer.org/installer | php8 && mv composer.phar /usr/local/bin/composer

# Setup apache and php
RUN apk add \
	php8-ftp \
	php8-xdebug \
	php8-pecl-mcrypt \
	php8-mbstring \
	php8-soap \
	php8-gmp \
	php8-pdo_odbc \
	php8-dom \
	php8-pdo \
	php8-zip \
	php8-mysqli \
	php8-sqlite3 \
	php8-pdo_pgsql \
	php8-bcmath \
	php8-gd \
	php8-odbc \
	php8-pdo_mysql \
	php8-pdo_sqlite \
	php8-gettext \
	php8-xml \
	php8-xmlreader \
	php8-xmlwriter \
	php8-tokenizer \
	php8-pecl-xmlrpc \
	php8-bz2 \
	php8-pdo_dblib \
	php8-curl \
	php8-ctype \
	php8-session \
	php8-redis \
	php8-exif \
	php8-intl \
	php8-fileinfo \
	php8-ldap \
	php8-apcu

# Problems installing in above stack
RUN apk add php8-simplexml

RUN cp /usr/bin/php8 /usr/bin/php \
    && rm -f /var/cache/apk/*

# Add apache to run and configure
RUN sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_module/LoadModule\ session_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_cookie_module/LoadModule\ session_cookie_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_crypto_module/LoadModule\ session_crypto_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ deflate_module/LoadModule\ deflate_module/" /etc/apache2/httpd.conf \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/app/public\"#g" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#/app/public#" /etc/apache2/httpd.conf \
    && printf "\n<Directory \"/app/public\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf

RUN mkdir /app && mkdir /app/public && chown -R apache:apache /app && chmod -R 755 /app && mkdir bootstrap
ADD start.sh /bootstrap/
RUN chmod +x /bootstrap/start.sh

EXPOSE 80
ENTRYPOINT ["/bootstrap/start.sh"]
