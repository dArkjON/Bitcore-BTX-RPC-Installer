#!/bin/bash
set -u

#
# Step 9/10 - Starting BitCore Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Step 9/10 - Starting BitCore Service ***\n"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
