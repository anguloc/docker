FROM centos:centos7
MAINTAINER zy

ADD config /home/config
ADD src /home/src

RUN yum -y install \
        wget \
        gcc \
        make \
        autoconf \
        libxml2 \
        libxml2-devel \
        openssl \
        openssl-devel \
        libcurl \
        libcurl-devel \
        pcre \
        pcre-devel \
        libxslt \
        libxslt-devel \
        bzip2 \
        bzip2-devel \
        libedit \
        libedit-devel \
        glibc-headers \
        gcc-c++ \
        libjpeg \
        libjpeg-devel \
        libpng \
        libpng-devel \
        freetype \
        freetype-devel \
        gmp \
        gmp-devel \
        readline \
        readline-devel \
        net-tools \
        vim \
    && yum clean all

# nginx 
RUN cd /home/src && wget http://nginx.org/download/nginx-1.14.2.tar.gz && tar -xzf nginx-1.14.2.tar.gz && cd nginx-1.14.2 \
    && ./configure \
      --prefix=/usr/local/nginx \
      --with-http_stub_status_module \
      --with-http_ssl_module \
      --with-file-aio \
      --with-http_realip_module \
      && make \
      && make install

# php-src
RUN cd /home/src && wget -O php-7.2.16.tar.gz http://hk2.php.net/get/php-7.2.16.tar.gz/from/this/mirror && tar -xzf php-7.2.16.tar.gz
#RUN cd /home/src && tar -xzf php-7.2.16.tar.gz
RUN cd /home/src/php-7.2.16 \
    && ./configure \
    	--prefix=/usr/local/php \
        --with-config-file-path=/usr/local/php/etc \
        --with-config-file-scan-dir=/usr/local/php/etc/conf.d \
    	--with-curl \
    	--with-freetype-dir \
    	--with-gd \
    	--with-gettext \
    	--with-iconv-dir \
    	--with-kerberos \
    	--with-libdir=lib64 \
    	--with-libxml-dir \
    	--with-mysqli \
    	--with-openssl \
    	--with-pcre-regex \
    	--with-pdo-mysql \
    	--with-pdo-sqlite \
    	--with-pear \
    	--with-xmlrpc \
    	--with-xsl \
    	--with-zlib \
    	--with-bz2 \
    	--with-mhash \
    	--enable-fpm \
    	--enable-bcmath \
    	--enable-libxml \
    	--enable-inline-optimization \
    	--enable-mbregex \
    	--enable-mbstring \
    	--enable-opcache \
    	--enable-pcntl \
    	--enable-shmop \
    	--enable-soap \
    	--enable-sockets \
    	--enable-sysvsem \
    	--enable-sysvshm \
    	--enable-xml \
    	--enable-zip \
    && make \
    && make install

RUN cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf \
    && cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

RUN mkdir -p /usr/local/php/etc/conf.d

RUN cp /home/src/php-7.2.16/php.ini-development /usr/local/php/etc/php.ini

RUN ln -s /usr/local/php/bin/php /usr/local/bin/php


# swoole.so
RUN cd /home/src && wget -O swoole-src-4.3.1.tar.gz https://github.com/swoole/swoole-src/archive/v4.3.1.tar.gz && tar -xzf swoole-src-4.3.1.tar.gz
RUN cd /home/src/swoole-src-4.3.1 \
    && /usr/local/php/bin/phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config --enable-openssl --enable-swoole \
    && make \
    && make install \
    && echo "extension=swoole.so" > /usr/local/php/etc/conf.d/swoole.ini 

# redis.so
RUN cd /home/src && wget http://pecl.php.net/get/redis-4.3.0.tgz && tar -xzf redis-4.3.0.tgz 
RUN cd /home/src/redis-4.3.0 \
    && /usr/local/php/bin/phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install \
    && echo "extension=redis.so" > /usr/local/php/etc/conf.d/redis.ini 


## v2
# libmemcached  ./configure --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached --disable-memcached-sasl

# memcached

# imagemagick ./configure --prefix=/usr/local/imagemagick --enable-shared=yes -enable-static=yes --with-freetype=yes --with-jpeg=yes --with-png=yes --with-tiff=yes --with-webp=yes \

# yar

# yaf


RUN chmod a+rx /home/config/run.sh

ENTRYPOINT /home/config/run.sh

EXPOSE 22 80 443 
