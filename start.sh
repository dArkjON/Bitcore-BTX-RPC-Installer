#!/bin/bash
set -u

BOOTSTRAP='bootstrap.tar.gz'

#
# Set passwd of bitcore user
#
echo bitcore:${BTXPWD} | chpasswd

#
# Downloading bitcore.conf
#
cd /tmp/
wget https://raw.githubusercontent.com/LIMXTEC/Bitcore-BTX-RPC-Installer/master/bitcore.conf -O /tmp/bitcore.conf
chown bitcore:bitcore /tmp/bitcore.conf

#
# Configure bitcore.conf
#
printf "** Configure bitcore.conf ***\n"
mkdir -p /home/bitcore/.bitcore	
chown -R bitcore:bitcore /home/bitcore/
sudo -u bitcore cp /tmp/bitcore.conf /home/bitcore/.bitcore/bitcore.conf
sed -i "s/^\(rpcuser=\).*/rpcuser=btxrpcnode${BTXPWD}/" /home/bitcore/.bitcore/bitcore.conf
sed -i "s/^\(rpcpassword=\).*/rpcpassword=${BTXPWD}/" /home/bitcore/.bitcore/bitcore.conf

#
# Downloading bootstrap file
#
printf "** Downloading bootstrap file ***\n"
cd /home/bitcore/.bitcore/
if [ ! -d /home/bitcore/.bitcore/blocks ] && [ "$(curl -Is https://bitcore.cc/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitcore wget https://bitcore.cc/${BOOTSTRAP}; \
        sudo -u bitcore tar -xvzf ${BOOTSTRAP}; \
        sudo -u bitcore rm ${BOOTSTRAP}; \
fi

#
# Starting BitCore Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Starting BitCore Service ***\n"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
