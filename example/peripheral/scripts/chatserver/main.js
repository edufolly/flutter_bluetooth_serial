/// Simple example Bluetooth serial chat server
///
/// Prepared for https://github.com/edufolly/flutter_bluetooth_serial/ by Patryk (PsychoX) Ludwikowski

const readline = require('readline');
const { BluetoothSerialPortServer } = require('bluetooth-serial-port');

var channel = 1;
var UUID = '00001101-0000-1000-8000-00805F9B34FB';

var server = new BluetoothSerialPortServer();
var input = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

server.on('data', (buffer) => {
    console.log('< ' + buffer);
});

server.on('closed', () => {
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
        server.write(Buffer.from(line + '\r\n'), (error, bytesWritten) => {
            if (error) {
                console.error('Failed to write: ' + error);
            }
        });
    });
}, (error) => {
    console.error('Failed on listening: ' + error);
}, {uuid: UUID, channel: channel} );
