# ARCHIVES SERVER

## Netcat

https://doc.fedora-fr.org/wiki/Netcat,_connexion_client/serveur_en_bash

## Run the Server

To run the server on localhost, go into the **server** directory and run the following command.
```
bash server.sh <PORT>
```

## Run the client

### Make VSH a shell command

* Go into at the client folder.
* Print and copy the current path using `pwd`
* Add it to the PATH variable `export PATH=$PATH:<copied_path>`

Now you can run the **vsh** command in your shell.

***vsh** will be available only on the current shell only. To make it permanent, you should add it to your **~/.bashrc** file*

### Use VSH

To display the help
```
vsh --help
```

To list the archives on the server
```
vsh -list localhost [PORT]  
```

To extract and archive from the server to the your current path
```
vsh -extract localhost [PORT] [ARCHIVE NAME]
```

To browse an archive
```
vsh -browse localhost [PORT] [ARCHIVE NAME]
```