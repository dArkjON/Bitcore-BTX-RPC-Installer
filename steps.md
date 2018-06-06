# STEPS TO RUN DOCKER CONTAINER

## Short description
* Dockerfile: Template to build docker image
* Docker Image: Can be pushed, pulled, tagged to the docker-registry
* Docker Container: Instance of a tagged docker image


## STEPS
### 1) Create Dockerfile
#### Define base image
```FROM ubuntu:16.04```
#### Needed Ports must be exposed
```EXPOSE 8555 9051 40332```
#### Define user during execution
```USER root```
#### Define working dir
```WORKDIR /root```
#### Change form sh to bash 
```SHELL ["/bin/bash", "-c"]```
#### Define environment variables
```ENV BTXPWD "xyz" ```
#### Every RUN is a new layer
Example:
```
cd && \
 rm -rf BitCore && \
 echo '*** Done 4/10 ***'
```
#### Change form sh to bash 
```SHELL ["/bin/bash", "-c"]```
#### Copy files into the docker image (in the same directory as the Dockerfile)
```COPY bitcore.conf /tmp```
#### Use of if/for statements in this way
Example:
```
RUN if [ "$(curl -Is https://bitcore.cc/$BOOTSTRAP | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
 wget https://bitcore.cc/$BOOTSTRAP; \
 tar -xvzf $BOOTSTRAP; \
 rm $BOOTSTRAP; \
 fi
```
#### Define the starting point of docker container
Example:
```
COPY start.sh /root/start.sh
RUN \
 rm -f /var/log/access.log && mkfifo -m 0666 /var/log/access.log && \
 chmod 755 /root/start.sh /usr/local/bin/*
ENV TERM linux
CMD ["/root/start.sh"]
```
#### Hints:
- no systemd permission within the docker image => run daemon in foreground
- no ufw within the docker image, but configuration on docker host needed 


### 2) Build docker image
```
docker build [--build-arg BTXPWD='<bitcore user pwd>'] -t btx-rpc-server .
```

### 3) Tag docker image
```
docker tag btx-rpc-server <repository>/btx-rpc-server
```

### 4) Login to hub.docker
```
docker login -u <repository> -p"<PWD>"
```

### 5) Push docker images
```
docker push <repository>/btx-rpc-server
```

### 6) Cleanup docker images
#### a) Delete all stopped containers (including data-only containers)
```
docker rm $(docker ps -a -q)
```
#### b) Delete all 'untagged/dangling' (<none>) images
```
docker rmi $(docker images -q -f dangling=true)
```

### 7) Pull docker image
```
docker pull <repository>/btx-rpc-server
```

### 8) Run docker container
```
docker run -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server -e BTXPWD='NEW_BTX_PWD' -v /home/bitcore:/home/bitcore:rw -d <repository>/btx-rpc-server
docker ps
```

## DEBUGGING

### A) Debbuging within a container (after start.sh execution)
Please execute "docker run" in 8) before you execute this command:
```
tail -f /home/bitcore/.bitcore/debug.log
docker ps
docker exec -it btx-rpc-server bash
  # you are inside the btx-rpc-server container
  root@container# supervisorctl status bitcored
  root@container# cat /var/log/supervisor/supervisord.log
  # Change to bitcore user
  root@container# sudo su bitcore
  bitcore@container# cat /home/bitcore/.bitcore/debug.log
  bitcore@container# bitcore-cli getinfo
```

### B) Debbuging within a container during run (skip start.sh execution)
```
docker run -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server -e BTXPWD='NEW_BTX_PWD' -v /home/bitcore:/home/bitcore:rw --entrypoint bash <repository>/btx-rpc-server
```


## USE OF VOLUME (FILE SHARING)
If the Dockerfile define the ```VOLUME``` you can share files between docker host and docker container.

### Example:

```VOLUME /var/log```

To find out the share directory you need the name of the mounted volume:
```
docker inspect -f "{{json .Mounts}}" btx-rpc-server | jq .
[
  {
    "Propagation": "",
    "RW": true,
    "Mode": "",
    "Driver": "local",
    "Destination": "/var/log",
    "Source": "/var/lib/docker/volumes/1092068a8200e64d27a1f5971fba1078980ccd20616119474b59af1557332307/_data",
    "Name": "1092068a8200e64d27a1f5971fba1078980ccd20616119474b59af1557332307",
    "Type": "volume"
  }
]
```
Here is the mapping:
* DOCKERHOST: ```/var/lib/docker/volumes/1092068a8200e64d27a1f5971fba1078980ccd20616119474b59af1557332307/_data```
* DOCKER CONTAINER: ```/var/log```

