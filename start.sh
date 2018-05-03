#!/bin/bash
set -u

BOOTSTRAP='bootstrap.tar.gz'

#
# Step 8/10 - Downloading bootstrap file
#
mkdir -p /home/bitcore/.bitcore
chown -R bitcore:bitcore /home/bitcore
cd /home/bitcore/.bitcore/
printf "** Step 8/10 - Downloading bootstrap file ***"
if [ ! -d /home/bitcore/.bitcore/blocks ] && [ "$(curl -Is https://bitcore.cc/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitcore wget https://bitcore.cc/$BOOTSTRAP; \
        sudo -u bitcore tar -xvzf $BOOTSTRAP; \
fi
printf "*** Done 8/10 ***"

#
# Step 9/10 - Starting BitCore Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Step 9/10 - Starting BitCore Service ***\n"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
