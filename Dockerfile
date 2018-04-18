# Use an official Ubuntu runtime as a parent image
FROM ubuntu:16.04

# Define environment variable
ENV NAME "BitCore BTX RPC Server"
ENV HOME /root

# Set the working directory to /app
WORKDIR /root

# Copy the current directory contents into the container at /app
#ADD root/.bashrc /root/.bashrc

#
# Step 2/10
#
# Allocating 2GB Swapfile
#RUN echo '*** Step 2/10 - Allocating 2GB Swapfile ***' && \
#    dd if=/dev/zero of=/swapfile bs=1M count=2048 && \
#    mkswap /swapfile && \
#    swapon /swapfile && \
#    chmod 600 /swapfile && \
#    echo '*** Done 2/10 ***'


#
# Step 3/10
#
# Running updates and installing required packages
RUN echo '*** Step 3/10 - Running updates and installing required packages ***' && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install apt-utils build-essential libtool autotools-dev autoconf automake pkg-config libssl-dev libboost-all-dev git software-properties-common libminiupnpc-dev libevent-dev ufw -y && \
    add-apt-repository ppa:bitcoin/bitcoin -y && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install libdb4.8-dev libdb4.8++-dev -y && \
    echo '*** Done 3/10 ***'

#
# Step 4/10
#
# Cloning and Compiling BitCore Wallet
RUN echo '*** Step 4/10 - Cloning and Compiling BitCore Wallet ***' && \
    cd && \
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
# Step 5/10
#
# Adding firewall rules
RUN echo '*** Step 5/10 - Adding firewall rules ***' && \
    ufw logging on && \
    ufw allow 22/tcp && \
    ufw limit 22/tcp && \
    ufw allow 8555/tcp && \
    ufw default deny incoming && \
    ufw default allow outgoing && \
    yes | ufw enable && \
    echo '*** Done 5/10 ***'


# Make ports available to the world outside this container
EXPOSE 40332
EXPOSE 8555

# Run XXXX  when the container launches

#RUN wget https://raw.githubusercontent.com/dArkjON/Bitcore-BTX-RPC-Installer/master/btxsetup.sh && chmod +x btxsetup.sh
#CMD ["bash", "btxsetup.sh"]
#CMD ["python", "app.py"]
CMD ["bash"]
