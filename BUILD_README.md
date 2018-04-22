# BitCore RPC Server - Build Docker Image

The Dockerfile will install all required stuff to run a BitCore RPC Server and is based on script btxsetup.sh (see: https://github.com/dArkjON/Bitcore-BTX-RPC-Installer/blob/master/btxsetup.sh)

## Needed files
- Dockerfile
- bitcore.conf

## Allocating 2GB Swapfile
Create a swapfile to speed up the building process. Recommended if not enough RAM available on your docker host server.
```
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

## Adding firewall rules
Open needed ports on your docker host server.
```
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8555/tcp
ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable
```

## Build process
```
docker build -t btx-rpc-server .
docker tag btx-rpc-server <repository>/btx-rpc-server
docker push <repository>/btx-rpc-server:<tag>
```
