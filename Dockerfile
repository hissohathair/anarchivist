#
# Dockerfile for Anarchivist. Only good for a dev environment so far.
#

# Builds on openpds/common, which contains Python, pip & virtualenv
#
FROM hissohathair/openpds-common


# Set correct environment variables, etc
#
MAINTAINER Daniel Austin <daniel.austin@smartservicescrc.com.au>
ENV HOME /root


# openPDS dependencies
#
RUN apt-get -y --no-install-recommends install postgresql-9.3 postgresql-server-dev-9.3 postgresql-contrib-9.3


# Set up Python and install app dependencies using pip (virtualenv already set up)
#
ADD ./conf /home/app/env/conf
WORKDIR /home/app/env
RUN BASH_ENV=/home/app/env/bin/activate bash -c "pip install -r conf/requirements.txt"

# Install the openPDS app files
# TODO: This might be better mounted as a VOLUME?


# App runs on 8002 by default
EXPOSE 8000


# Clean up APT when done.
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

