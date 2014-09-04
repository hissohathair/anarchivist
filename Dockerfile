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
RUN /build/utilities.sh

# Common development headers necessary for many Ruby gems,
RUN /build/devheaders.sh

# Ruby support.
ADD fake-ruby-switch.sh /build/ruby-switch
#RUN /build/ruby1.9.sh
RUN /build/ruby2.0.sh
#RUN /build/ruby2.1.sh

# Python support.
RUN /build/python.sh

# Node.js and Meteor support.
RUN /build/nodejs.sh

# Enable Nginx & Passenger
#RUN rm -f /etc/service/nginx/down
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN mkdir /home/app/webapp
# TODO: RUN ...commands to place your web app in /home/app/webapp..


# TODO: Wordpress build etc

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
