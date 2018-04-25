# BitCore RPC Server - Run Docker Image

### (1) Pull docker image
```
docker pull dalijolijo/btx-rpc-server
```

### (2) Run docker container
```
docker run --rm -p 40332:40332 -p 8555:8555 -p 9051:9051 --name btx-rpc-server -d [-e BTXPWD='<PWD>'] dalijolijo/btx-rpc-server
docker ps
```

### (3) Debbuging within a container after run
```
docker run -it -p 40332:40332 -p 8555:8555 -p 9051:9051 --entrypoint bash dalijolijo/btx-rpc-server
```

### (4) Debbuging within a container (after start.sh execution)
Please execute "docker run" in (2) before you execute this commands:
```
docker ps
docker exec -it btx-rpc-server bash
  <container># cat /var/log/supervisor/supervisord.log
  <container># supervisorctl status
  <container># cat /home/bitcore/.bitcore/debug.log
```
