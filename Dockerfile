# This Dockerfile is based on script btxsetup.sh (see: https://github.com/dArkjON/Bitcore-BTX-RPC-Installer/blob/master/btxsetup.sh)
# BitCore Repo : https://github.com/LIMXTEC/BitCore/
# 
# This Dockerfile will install all required stuff to run a BitCore RPC Server.
# To build a docker image for btx-rpc-server the Dockerfile and bitcore.conf is needed.
# 1. docker build -t btx-rpc-server
# 2. docker push <repository>/btx-rpc-server:<tag>

# Use an official Ubuntu runtime as a parent image
FROM ubuntu:16.04

# Define environment variable
ENV HOME /root
ENV BTXPWD "bitcore"
ENV BOOTSTRAP "bootstrap240318.tar.gz"

# Set the working directory to /app
WORKDIR /root

RUN echo '******************************' && \
    echo '*** BitCore BTX RPC Server ***' && \
    echo '******************************'

#
# Step 1/10 - creating bitcore user
#
RUN echo '*** Step 1/10 - creating bitcore user ***' && \
    adduser --disabled-password --gecos "" bitcore && \
    usermod -a -G sudo bitcore && \
    echo bitcore:$BTXPWD | chpasswd && \
    echo '*** Done 1/10 ***'

#
# Step 2/10 - Allocating 2GB Swapfile
#
# RUN echo '*** Step 2/10 - Allocating 2GB Swapfile ***' && \
#    dd if=/dev/zero of=/swapfile bs=1M count=2048 && \
#    mkswap /swapfile && \
#    swapon /swapfile && \
#    chmod 600 /swapfile && \
#    echo '*** Done 2/10 ***'

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
                        git \
                        libboost-all-dev \
                        libevent-dev \
                        libminiupnpc-dev \
                        libssl-dev \
                        libtool \
                        pkg-config \
                        software-properties-common \
                        ufw && \
    add-apt-repository -y ppa:bitcoin/bitcoin && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y  libdb4.8-dev \
                        libdb4.8++-dev && \
    echo '*** Done 3/10 ***'

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
    rm -rf BitCore && \
    echo '*** Done 4/10 ***'

#
# Step 5/10 - Adding firewall rules
#
RUN echo '*** Step 5/10 - Adding firewall rules ***' && \
    ufw logging on && \
    ufw allow 22/tcp && \
    ufw limit 22/tcp && \
    ufw allow 8555/tcp && \
    ufw default deny incoming && \
    ufw default allow outgoing && \
    yes | ufw enable && \
    echo '*** Done 5/10 ***'

#
# Step 6/10 - Configure bitcore.conf
#
ADD --chown=bitcore bitcore.conf /tmp
RUN echo '*** Step 6/10 - Configure bitcore.conf ***' && \
    sudo -u bitcore mkdir /home/bitcore/.bitcore && \
    sudo -u bitcore mv /tmp/bitcore.conf /home/bitcore/.bitcore/ && \
    cd /home/bitcore/.bitcore && \
    echo '*** Done 6/10 ***'

#
# Step 7/10 - Adding bitcore daemoon as a service
#
RUN echo '*** Step 7/10 - Adding bitcore daemoon as a service ***' && \
    mkdir /usr/lib/systemd/system && \
    echo -e "[Unit]\nDescription=BitCore's distributed currency daemon\nAfter=network.target\n\n[Service]\nUser=bitcore\nGroup=bitcore\n\nType=forking\nPIDFile=/home/bitcore/.bitcore/bitcored.pid\n\nExecStart=/usr/local/bin/bitcored -daemon -disablewallet -pid=/home/bitcore/.bitcore/bitcored.pid \\n          -conf=/home/bitcore/.bitcore/bitcore.conf -datadir=/home/bitcore/.bitcore/\n\nExecStop=-/usr/local/bin/bitcore-cli -conf=/home/bitcore/.bitcore/bitcore.conf \\n         -datadir=/home/bitcore/.bitcore/ stop\n\nRestart=always\nPrivateTmp=true\nTimeoutStopSec=60s\nTimeoutStartSec=2s\nStartLimitInterval=120s\nStartLimitBurst=5\n\n[Install]\nWantedBy=multi-user.target\n" > /usr/lib/systemd/system/bitcore.service && \
    echo '*** Done 7/10 ***'

#
# Step 8/10 - Downloading bootstrap file
#
RUN echo '*** Step 8/10 - Downloading bootstrap file ***' && \
    if [ "$(curl -Is https://bitcore.cc/$BOOTSTRAP | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then && \
        sudo -u bitcore wget https://bitcore.cc/$BOOTSTRAP && \
        sudo -u bitcore tar -xvzf $BOOTSTRAP && \
        sudo -u bitcore rm $BOOTSTRAP && \
    fi && \
    echo '*** Done 8/10 ***'

#
# Step 9/10 - Starting BitCore Service
#
RUN echo '*** Step 9/10 - Starting BitCore Service ***' && \
    systemctl enable bitcore && \
    systemctl start bitcore && \
    echo 'BitCore Server installed! Weeee!' && \
    echo '*** Done 9/10 ***'

#
# Make ports available to the world outside this container
#
EXPOSE 40332
EXPOSE 8555

#
# Step 0/10 - User input
#
ENTRYPOINT echo -n "Enter new password for [bitcore] user and Hit [ENTER]: " && \
           read BTXPWD && \
           echo bitcore:$BTXPWD | chpasswd && \
           echo '*** Step 10/10 - Wait for wallet synchronization!***' && \
           echo 'To make sure everything working properly you need to reboot server, i advice to wait until wallet synchronization ends.' && \
           echo 'Easiest way to do it, is to catch new block message, where "height=***" is equal to "Current numbers of blocks" in local wallet (help>debug>information)' && \
           sleep 5 && \
           echo 'Now go, and visit our telegram channel at t.me/bitcore_btx_official tell us how its going!' && \
           echo ' ' && \
           read -p "Press enter to monitor debug.log" && \
           tail -f debug.log
