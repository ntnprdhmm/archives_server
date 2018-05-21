# ARCHIVES SERVER

## Netcat

https://doc.fedora-fr.org/wiki/Netcat,_connexion_client/serveur_en_bash

run the server
```
nc -l 1234 < server/backpipe | server/entry.sh 1> server/backpipe
```

run the client
```
nc localhost 1234
```