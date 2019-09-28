
## Example Bluetooth serial chat server

Node.js (JavaScript) script for Bluetooth serial chat server using simple packets system to ease implementing communication. Server supports up to 7 clients connected to single server.

### Installation

You need install `node` (with `npm` of course). In my experience it works with version 12 nicely, but you can try use 8 - please commit changes for this document if tested. Also, the script uses [`bluetooth-serial-port`](https://www.npmjs.com/package/bluetooth-serial-port) library for Node Bluetooth serial connectivity. Please note, that the library implements listening only for Linux based devices for now. 

After installing these, run `npm install` in main directory (this one with `package.json`). It will install necessary `node_modules`. 

### Usage

Usage is simple, run it with:

```
sudo npm start
```

_Note: Requires `sudo` in order to allow add SDP records._

To exit use `Ctrl`+`C` to exit. You can write on server side to message from the server. The rest is pretty self explanatory: incoming messages are listed, there are special messages if user joined or left and etc.

Please note, it is still simple script to do the work - don't expect fancy input alignation, preserving line whilst echoing incoming data and so on.

### To-do

More packets and features:
* "seen" notification,
* removing message,
~~* multiple clients,~~ _added lately_
* server commands,
* blocking/unblocking users
* ...
