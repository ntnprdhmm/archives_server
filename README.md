# ARCHIVES SERVER

## Netcat

https://doc.fedora-fr.org/wiki/Netcat,_connexion_client/serveur_en_bash

### server

Run a local server
```
bash server/server.sh [PORT]
```

### client

help
```
bash client/vsh.sh --help
```

mode list
```
bash client/vsh.sh -list localhost [PORT]  
```

mode extract 
```
bash client/vsh.sh -extract localhost [PORT] [ARCHIVE NAME]
```

mode browse
```
bash client/vsh.sh -browse localhost [PORT] [ARCHIVE NAME]
```