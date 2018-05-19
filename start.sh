#!/bin/bash
set -u

BOOTSTRAP='bootstrap.tar.gz'

#
# Set passwd of bitcore user
#
echo bitcore:${BTXPWD} | chpasswd

#
# Step 6/10 - Configure bitcore.conf
#
printf "** Step 6/10 - Configure bitcore.conf ***\n"
sudo -u bitcore mkdir -p /home/bitcore/.bitcore	
chown bitcore:bitcore -R /home/bitcore/
chown bitcore:bitcore /tmp/bitcore.conf
sudo -u bitcore cp /tmp/bitcore.conf /home/bitcore/.bitcore/bitcore.conf

#
# Step 8/10 - Downloading bootstrap file
#
printf "** Step 8/10 - Downloading bootstrap file ***\n"
cd /home/bitcore/.bitcore/
if [ ! -d /home/bitcore/.bitcore/blocks ] && [ "$(curl -Is https://bitcore.cc/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitcore wget https://bitcore.cc/${BOOTSTRAP}; \
        sudo -u bitcore tar -xvzf ${BOOTSTRAP}; \
        sudo -u bitcore rm ${BOOTSTRAP}; \
fi

#
# Step 9/10 - Starting BitCore Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Step 9/10 - Starting BitCore Service ***\n"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
