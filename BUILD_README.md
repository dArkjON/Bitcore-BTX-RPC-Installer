# BitCore RPC Server - Build Docker Image

The Dockerfile will install all required stuff to run a BitCore RPC Server and is based on script btxsetup.sh (see: https://github.com/dArkjON/Bitcore-BTX-RPC-Installer/blob/master/btxsetup.sh)

## Requirements
- Linux Ubuntu 16.04 LTS
- Running as docker host server (package docker-ce installed)
```
apt-get update
apt-get upgrade -y
apt-get install docker-ce -y
```

## Needed files
- Dockerfile
- bitcore.conf
- bitcored.sv.conf
- start.sh
- btx-docker.sh

## Allocating 2GB Swapfile
Create a swapfile to speed up the building process. Recommended if not enough RAM available on your docker host server.
```
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

## Build docker image
```
docker build [--build-arg BTXPWD='<bitcore user pwd>'] -t btx-rpc-server .
```

## Push docker image to hub.docker
```
docker tag btx-rpc-server <repository>/btx-rpc-server
docker login -u <repository> -p"<PWD>"
docker push <repository>/btx-rpc-server:<tag>
```
