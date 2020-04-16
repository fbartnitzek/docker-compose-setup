FROM nextcloud:apache

RUN apt-get update && apt-get install -y procps smbclient libsmbclient-dev && rm -rf /var/lib/apt/lists/*
RUN pecl install smbclient && docker-php-ext-enable smbclient;
