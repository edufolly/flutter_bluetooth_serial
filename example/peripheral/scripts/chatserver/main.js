/// Simple example Bluetooth serial chat server using packets.
/// TODO: Use multiple packets type, implement multiple clients, friend requesting, blocking
///
/// Prepared for https://github.com/edufolly/flutter_bluetooth_serial/ by Patryk (PsychoX) Ludwikowski

const readline = require('readline');
const BluetoothPacketsServer = require('./BluetoothPacketsServer.js');

var server = new BluetoothPacketsServer();
var input = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

server.onPacket((type, dataIt) => {
    const data = Array.from(dataIt);
    const text = String.fromCodePoint(...data);
    console.log('< ' + text);
});

server.onClosed(() => {
    console.log('= Closed by remote!')
    input.removeAllListeners('line');
    // Uncomment these to make it exit after one connection.
    // Otherwise, use Ctrl+C to close connection and stop listening.
    //input.close();
    //server.close();
});

server.listen((clientAddress) => {
    console.log('= Client: ' + clientAddress + ' connected!');
    input.on('line', (line) => {
        server.sendPacket(0x01, Buffer.from(line));
    });
}, (error) => {
    console.error('Failed on listening: ' + error);
}, {uuid: '00001101-0000-1000-8000-00805F9B34FB', channel: 1});
