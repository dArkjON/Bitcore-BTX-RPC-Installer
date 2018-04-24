#!/bin/bash
set -u

#
# Step 9/10 - Starting BitCore Service
#
# Hint: docker not supported systemd
printf "*** Step 9/10 - Starting BitCore Service ***\n"
/usr/local/bin/bitcored -daemon -disablewallet -pid=/home/bitcore/.bitcore/bitcored.pid -conf=/home/bitcore/.bitcore/bitcore.conf -datadir=/home/bitcore/.bitcore/
printf "BitCore Server installed! Weeee!\n"
printf "*** Done 9/10 ***\n\n"


#
# Step 0/10 - User input
#
echo -n "Enter new password for [bitcore] user and Hit [ENTER]: "
read BTXPWD
echo bitcore:$BTXPWD | chpasswd

printf "\n*** Step 10/10 - Wait for wallet synchronization!***\n"
printf "I advice to wait until wallet synchronization ends.\n"
printf 'Easiest way to do it, is to catch new block message, where "height=***" is equal to "Current numbers of blocks" in local wallet (help>debug>information)\n\n'
sleep 5
printf "Now go, and visit our telegram channel at t.me/bitcore_btx_official tell us how its going!\n\n"
read -p "Press enter to monitor debug.log"
tail -f /home/bitcore/.bitcore/debug.log
