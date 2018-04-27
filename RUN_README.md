# BitCore RPC Server - Run Docker Image

### (1) Pull docker image
```
docker pull dalijolijo/btx-rpc-server
```

### (2) Run docker container
```
docker run -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server -v /home/bitcore:/home/bitcore:rw -d btx-rpc-server
docker ps
```

### (3) Debbuging within a container (after start.sh execution)
Please execute "docker run" in (2) before you execute this commands:
```
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

### (4) Debbuging within a container during run (skip start.sh execution)
```
docker run -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server [-e BTXPWD='<PWD>'] --entrypoint bash dalijolijo/btx-rpc-server
docker run -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server -v /home/bitcore:/home/bitcore:rw --entrypoint bash btx-rpc-server
```
