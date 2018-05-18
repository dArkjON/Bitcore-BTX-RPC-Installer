#!/bin/bash
set -u

DOCKER_REPO='dalijolijo'

#
# Check distro version (TODO)
#
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [[ $OS =~ "Ubuntu" ]] && [[ $VER =~ "16" ]] || [[ $OS =~ "ubuntu" ]] && [[ $VER =~ "16" ]]; then
    echo "Configuration for $OS ($VER)..."
 
    # Firewall settings (for Ubuntu)
    echo "Firewall settings"
    ufw logging on
    ufw allow 22/tcp
    ufw limit 22/tcp
    ufw allow 8555/tcp
    ufw allow 40332/tcp
    # if other services run on other ports, they will be blocked!
    #ufw default deny incoming 
    ufw default allow outgoing 
    yes | ufw enable

    # Installation further package (Ubuntu 16.04)
    echo "Installation further package"
    apt-get update
    sudo apt-get install -y apt-transport-https \
                            ca-certificates \
                            curl \
                            software-properties-common
else
    echo "$OS ($VER) not supported!"
    exit
fi

#
# Set bitcore user pwd
#
echo -n "Enter new password for [bitcore] user and Hit [ENTER]: "
read BTXPWD

#
# Pull docker images and run the docker container
#
docker pull ${DOCKER_REPO}/btx-rpc-server
docker run -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server  -e BTXPWD='${BTXPWD}' -v /home/bitcore:/home/bitcore:rw -d ${DOCKER_REPO}/btx-rpc-server
