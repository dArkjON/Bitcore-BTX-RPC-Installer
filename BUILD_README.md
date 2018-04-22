# BitCore RPC Server - Build Docker Image

The Dockerfile will install all required stuff to run a BitCore RPC Server and is based on script btxsetup.sh (see: https://github.com/dArkjON/Bitcore-BTX-RPC-Installer/blob/master/btxsetup.sh)

## Needed files
- Dockerfile
- bitcore.conf

## Allocating 2GB Swapfile (if not enough RAM available)
```
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

## Build process
```
docker build -t btx-rpc-server
docker push <repository>/btx-rpc-server:<tag>
```
