FROM brunoric/hhvm:deb-hhvm

ENV CTF_PATH /var/www/fbctf
ENV DEBIAN_FRONTEND noninteractive
ENV CTF_REPO https://github.com/rhenar0/fbctf

RUN apt-get update && apt-get install -y --force-yes curl language-pack-en git npm nodejs-legacy nginx mysql-client

#RUN wget http://ports.ubuntu.com/pool/main/c/ca-certificates/ca-certificates_20240203~20.04.1_all.deb
RUN apt install ca-certificates

RUN update-ca-certificates

# Install Composer
#RUN curl --insecure -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN wget https://getcomposer.org/download/latest-1.x/composer.phar
RUN chmod a+x composer.phar
RUN mv composer.phar /usr/bin/composer.phar

RUN mkdir -p $CTF_PATH
WORKDIR $CTF_PATH

# Install CTF
RUN git clone --depth 1 $CTF_REPO .

# Install Vendors
RUN composer.phar install

RUN npm cache clean -f
RUN npm install -g n
RUN node --version

RUN n 10.12.0

# Build assets
RUN npm install && npm install -g grunt@1.0.1 && npm install -g flow-bin@0.35.0
RUN grunt

# Add nginx configuration
COPY ["templates/fbctf.conf", "templates/fbctf_ssl.tmpl.conf", "/etc/nginx/sites-available/"];

COPY ["templates/settings.tmpl.ini", "entrypoint.sh", "./"]

RUN chmod +x entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["./entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
