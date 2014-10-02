# 
# Dockerfile for Anarchivist.
#
# We build on phusion/passenger-docker. Get latest build number from here:
#	https://github.com/phusion/passenger-docker/blob/master/Changelog.md
#
#FROM phusion/passenger-full:0.9.11
FROM phusion/passenger-customizable:0.9.11
MAINTAINER Daniel Austin <daniel.austin@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Build system and git.
RUN apt-get update
RUN apt-get -y upgrade
RUN /build/utilities.sh

# Common development headers necessary for many Ruby gems
RUN /build/devheaders.sh

# Ruby support. There's an issue on Ubuntu at the moment that results
# in a missing ruby-switch. But we're not really using that anyway so
# we'll put in a stub so that the rest of the Passenger Dockerfile
# works.
#
ADD fake-ruby-switch.sh /build/ruby-switch
RUN /build/ruby2.0.sh

# Python support.
RUN /build/python.sh

# Node.js and Meteor support.
RUN /build/nodejs.sh

# Enable Nginx & Passenger
RUN rm -f /etc/service/nginx/down
ADD ./conf/nginx.conf /etc/nginx/nginx.conf
ADD ./conf/nginx-default.conf /etc/nginx/sites-available/default
ADD ./conf/webapp.conf /etc/nginx/sites-enabled/webapp.conf

# TODO: RUN ...commands to place your web app in /home/app/webapp..
RUN mkdir /home/app/webapp


# Wordpress build 
#
# Basic Requirements
#
RUN apt-get -y install mysql-server mysql-client php5-fpm php5-mysql php-apc pwgen python-setuptools unzip
RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache \
    	       	       php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# Default MySQL conf file (my.cnf) is fine.

# php-fpm config (from docker-wordpress-nginx)
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# Install Wordpress
ADD http://wordpress.org/latest.tar.gz /usr/share/nginx/latest.tar.gz
RUN cd /usr/share/nginx/ && tar xvf latest.tar.gz && rm latest.tar.gz
RUN mv /usr/share/nginx/html/5* /usr/share/nginx/wordpress
RUN rm -rf /usr/share/nginx/www
RUN mv /usr/share/nginx/wordpress /usr/share/nginx/www
RUN chown -R www-data:www-data /usr/share/nginx/www

# Wordpress Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
#EXPOSE 3306
EXPOSE 80

# Run Wordpress & dependencies as "daemons"
RUN mkdir /etc/service/memcached
ADD ./bin/memcached.sh /etc/service/memcached/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Do it.
CMD ["/bin/bash", "/start.sh"]
