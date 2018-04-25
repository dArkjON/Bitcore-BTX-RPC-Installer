# STEPS TO RUN DOCKER CONTAINER

## Short description
* Dockerfile: Template to build docker image
* Docker Image: Can be pushed, pulled, tagged to the docker-registry
* Docker Container: Instance of a tagged docker image


## STEPS
### 1) Create Dockerfile
Define base image
```
FROM ubuntu:16.04
```
Needed Ports must be exposed
```
EXPOSE 8555 9051 40332
```
Define user during execution
```
USER root
```
Define working dir
```
WORKDIR /root
```
Change form sh to bash 
```
SHELL ["/bin/bash", "-c"]
```
Define environment variables
```
ENV BOOTSTRAP "bootstrap240318.tar.gz"
```
Every RUN is a new layer => use of && \
Example:
```
cd && \
 rm -rf BitCore && \
 echo '*** Done 4/10 ***
```
Change form sh to bash 
```
SHELL ["/bin/bash", "-c"]
```
Copy files into the docker image (in the same directory as the Dockerfile)
```
COPY bitcore.conf /tmp
```
Use of if/for statements in this way
Example:
```
RUN if [ "$(curl -Is https://bitcore.cc/$BOOTSTRAP | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
 wget https://bitcore.cc/$BOOTSTRAP; \
 tar -xvzf $BOOTSTRAP; \
 rm $BOOTSTRAP; \
 fi
```
Define the starting point of docker container
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
docker build [--build-arg BTXPWD='<bitcore user pwd>'] [--build-arg BOOTSTRAP='<bootstrapDDMMYY.tar.gz>'] -t btx-rpc-server .
```

### 3) Tag docker image
```
docker tag btx-rpc-server dalijolijo/btx-rpc-server
```

### 4) Login to hub.docker
```
docker login -u dalijolijo -p"<PWD>"
```

### 5) Push docker images
```
docker push dalijolijo/btx-rpc-server
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
docker pull dalijolijo/btx-rpc-server
```

### 8) Run docker container
```
docker run --rm -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server -d [-e BTXPWD='<PWD>'] dalijolijo/btx-rpc-server
```

### 9) Debbuging within a container after run
```
docker run -p 40332:40332 -p 8555:8555 -p 9051:9051 --entrypoint bash dalijolijo/btx-rpc-server
```

### 10) Debbuging within a container (after start.sh execution)
Please execute "docker run" in 9) before you execute this command:
```
docker exec -it btx-rpc-server bash
container# cat /home/bitcore/.bitcore/debug.log
container# cat /var/log/supervisor/supervisord.log
```
