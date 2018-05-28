# BitCore RPC Server - Dockerfile (04-2018)
#
# This Dockerfile will install all required stuff to run a BitCore RPC Server and is based on script btxsetup.sh (see: https://github.com/dArkjON/Bitcore-BTX-RPC-Installer/blob/master/btxsetup.sh)
# BitCore Repo : https://github.com/LIMXTEC/BitCore/
# E-Mail: info@bitcore.cc
# 
# To build a docker image for btx-rpc-server from the Dockerfile the bitcore.conf is also needed.
# See BUILD_README.md for further steps.

# Use an official Ubuntu runtime as a parent image
FROM ubuntu:16.04

LABEL maintainer="Jon D. (dArkjON), David B. (dalijolijo)"
LABEL version="0.1"

# Make ports available to the world outside this container
# DefaultPort = 8555
# RPCPort = 8556
# TorPort = 9051
EXPOSE 8555 8556 9051

USER root

# Change sh to bash
SHELL ["/bin/bash", "-c"]

# Define environment variable
ENV BTXPWD "bitcore"

RUN echo '*** BitCore BTX RPC Server ***'

#
# Step 1/10 - creating bitcore user
#
RUN echo '*** Step 1/10 - creating bitcore user ***' && \
    adduser --disabled-password --gecos "" bitcore && \
    usermod -a -G sudo,bitcore bitcore && \
    echo bitcore:$BTXPWD | chpasswd

#
# Step 2/10 - Allocating 2GB Swapfile
#
RUN echo '*** Step 2/10 - Allocating 2GB Swapfile ***' && \
    echo 'not needed: skipped'

#
# Step 3/10 - Running updates and installing required packages
#
RUN echo '*** Step 3/10 - Running updates and installing required packages ***' && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y  apt-utils \
                        autoconf \
                        automake \
                        autotools-dev \
                        build-essential \
                        curl \
                        git \
                        libboost-all-dev \
                        libevent-dev \
                        libminiupnpc-dev \
                        libssl-dev \
                        libtool \
                        libzmq5-dev \
                        pkg-config \
                        software-properties-common \
                        sudo \
                        supervisor \
                        vim \
                        wget && \
    add-apt-repository -y ppa:bitcoin/bitcoin && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y  libdb4.8-dev \
                        libdb4.8++-dev

#
# Step 4/10 - Cloning and Compiling BitCore Wallet
#
RUN echo '*** Step 4/10 - Cloning and Compiling BitCore Wallet ***' && \
    cd && \
    echo "Execute a git clone of LIMXTEC/BitCore. Please wait..." && \
    git clone https://github.com/LIMXTEC/BitCore.git && \
    cd BitCore && \
    ./autogen.sh && \
    ./configure --disable-dependency-tracking --enable-tests=no --without-gui --disable-hardening && \
    make && \
    cd && \
    cd BitCore/src && \
    strip bitcored && \
    cp bitcored /usr/local/bin && \
    strip bitcore-cli && \
    cp bitcore-cli /usr/local/bin && \
    chmod 775 /usr/local/bin/bitcore* && \
    cd && \
    rm -rf BitCore

#
# Step 5/10 - Adding firewall rules
#
RUN echo '*** Step 5/10 - Adding firewall rules ***' && \
    echo 'must be configured on the socker host: skipped'

#
# Step 6/10 - Configure bitcore.conf	
#	
COPY bitcore.conf /tmp	
RUN echo '*** Step 6/10 - Configure bitcore.conf ***' && \	
    chown bitcore:bitcore /tmp/bitcore.conf && \	
    sudo -u bitcore mkdir -p /home/bitcore/.bitcore && \	
    sudo -u bitcore cp /tmp/bitcore.conf /home/bitcore/.bitcore/bitcore.conf

#
# Step 7/10 - Adding bitcore daemon as a service
#
RUN echo '*** Step 7/10 - Adding bitcore daemon ***' && \
    echo 'docker not supported systemd: skipped'

#
# Copy Supervisor Configuration
#
COPY *.sv.conf /etc/supervisor/conf.d/

#
# Logging outside docker container
#
VOLUME /var/log

#
# Copy start script
#
RUN echo '*** Copy start script ***'
COPY start.sh /usr/local/bin/start.sh
RUN rm -f /var/log/access.log && mkfifo -m 0666 /var/log/access.log && \
    chmod 755 /usr/local/bin/*

ENV TERM linux
CMD ["/usr/local/bin/start.sh"]
