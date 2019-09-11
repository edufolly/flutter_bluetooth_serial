
## Simple example Bluetooth serial chat server

Node.js (JavaScript) script for simple Bluetooth serial chat server using simple packet system. 

### Installation

You need install `node` (with `npm` of course). In my experience it works with version 12 nicely, but you can try use 8 - please commit changes for this document if tested. Also, the script uses [`bluetooth-serial-port`](https://www.npmjs.com/package/bluetooth-serial-port) library for Node Bluetooth serial connectivity. Please note, that the library implements listening only for Linux based devices for now. 

After installing these, run `npm install` in main directory (this one with `package.json`). It will install necessary `node_modules`. You might wa

### Usage

Usage is simple, run it with:

```
npm start
```

in main directory and connect to the device. After connecting, there should be information (like `Client: XX:XX:XX:XX:XX:XX connected!`). You can now write the input and read incoming as output starting with `<`. After you are done, use `Ctrl`+`C` to exit or disconnect by the other device - in such case there should be `Closed by remote!` message, and the script is back to accepting incoming connections. 

Please note, it is simplest possible script to do the work - don't expect fancy input alignation, preserving line whilst echoing incoming data and so on.

### To-do

More packets and features:
* "seen" notification,
* removing message,
* multiple clients,
* blocking/unblocking users
* ...
