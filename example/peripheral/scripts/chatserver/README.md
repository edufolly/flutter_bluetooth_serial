
## Simple example Bluetooth serial chat server

Node.js (JavaScript) script for simple Bluetooth serial chat server. 

### Installation

You need install `node` (with `npm` of course). In my experience it works with version 12 nicely, but you can try use 8 - pull request for this document if you tested.

After installing these, run `npm install` in main directory (this one with `package.json`). It will install necessary `node_modules`.

### Usage

Usage is simple, run it with:

```
npm start
```

in main directory and connect to the device. After connecting, there should be information (like `Client: XX:XX:XX:XX:XX:XX connected!`). You can now write the input and read incoming as output starting with `<`. After you are done, use `Ctrl`+`C` to exit or disconnect by the other device - in such case there should be `Closed by remote!` message, and the script is back to accepting incoming connections. 

Please note, it is simplest possible script to do the work - don't expect fancy input alignation, preserving line whilst echoing incoming data and so on.
