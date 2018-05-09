#!/bin/bash
set -u

DOCKER_REPO='dalijolijo'

#
# Set bitcore user pwd
#
echo '*** Step 0/10 - User input ***'
echo -n "Enter new password for [bitcore] user and Hit [ENTER]: "
read BTXPWD

#
# Check distro version (TODO)
#
#cat /etc/issue
#echo 'Checking OS version.'
#if [[ -r /etc/os-release ]]; then
#		. /etc/os-release
#		if [[ "${VERSION_ID}" != "16.04" ]]; then
#			echo "This script only supports ubuntu 16.04 LTS, exiting."
#			exit 1
#		fi
#fi

#
# Firewall settings (for Ubuntu)
#
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8555/tcp
ufw allow 40332/tcp
# if other services run on other ports, they will be blocked!
#ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable


#
# Installation of docker package
#
apt-get update
apt-get upgrade -y
apt-get install docker.io -y
docker pull ${DOCKER_REPO}/btx-rpc-server
docker run -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server  -e BTXPWD='${BTXPWD}' -v /home/bitcore:/home/bitcore:rw -d ${DOCKER_REPO}/btx-rpc-server
