# BitCore RPC Server - Run Docker Image

## Adding firewall rules
Open needed ports on your docker host server.
```
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8555/tcp
ufw allow 8556/tcp
ufw allow 9051/tcp
ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable
```

## Pull docker image
```
docker pull limxtec/btx-rpc-server
```

## Run docker container
```
docker run -p 8555:8555 -p 8556:8556 -p 9051:9051 --name btx-rpc-server -e BTXPWD='NEW_BTX_PWD' -v /home/bitcore:/home/bitcore:rw -d limxtec/btx-rpc-server
docker ps
```

## Debbuging within a container (after start.sh execution)
Please execute ```docker run``` without option ```--entrypoint bash``` before you execute this commands:
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

## Debbuging within a container during run (skip start.sh execution)
```
docker run -p 8555:8555 -p 8556:8556 -p 9051:9051 --name btx-rpc-server -e BTXPWD='NEW_BTX_PWD' -v /home/bitcore:/home/bitcore:rw --entrypoint bash limxtec/btx-rpc-server
```

## Stop docker container
```
docker stop btx-rpc-server
docker rm btx-rpc-server
```
