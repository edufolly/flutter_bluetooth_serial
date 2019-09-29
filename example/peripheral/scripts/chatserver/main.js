/// Example Bluetooth serial chat server using packets.
///
/// Prepared for https://github.com/edufolly/flutter_bluetooth_serial/ by Patryk (PsychoX) Ludwikowski

const readline = require('readline');
const assert = require('assert');
const {execSync} = require('child_process');
const BluetoothPacketsServerPort = require('./BluetoothPacketsServerPort.js');
const ChatPacketType = require('./ChatPacketType.js');

let serverRunning = true;
let serverAddress = '';
let lastMessageId = 0;
let lastUserId = 0;

class MessageData extends Buffer {
    constructor(content, clientId = 0, messageId = undefined) {
        if (messageId == undefined) {
            messageId = ++lastMessageId;
        }

        super(1 + 2 + Buffer.byteLength(content, 'utf-8'));

        this[0] = clientId;
        this[1] = messageId / 0xFF;
        this[2] = messageId % 0xFF;
        this.write(content, 2, 'utf-8');
    }
}

let freeColors = Array(17).fill(undefined).map((_, i) => i + 1);

class Client {
    constructor(serverPort, address, channel) {
        this.id = ++lastUserId;
        this.serverPort = serverPort;
        this.address = address;
        this.channel = channel;

        this.serverPort.onClosed = () => this._onClosed();
        this.serverPort.onPacket = (...args) => this._onPacket(...args);

        this.colorId = freeColors.splice(Math.floor(Math.random() * freeColors.length), 1)[0];
    }

    toString() {
        // TODO: Missing client name :C
        return `#${('' + this.id).padStart(2, '0')} ${this.address}`;
    }

    sendPacket(type, data) {
        return this.serverPort.sendPacket(type, data);
    }

    _onClosed() {
        this.serverPort.close();
        clients.delete(this);
        freePorts.push(this.channel);
        freeColors.push(this.colorId);
    }

    _onPacket(type, dataIterable) {
        switch (type) {
            case ChatPacketType.PushMessage: {
                // There seems to be no way to directly decode Iterator of 
                // bytes (ints < 256) into String (at least in basic modules).
                // Starting with 3 bytes gap to avoid further copying in order
                // to broadcast the message (3 bytes broadcast packet header).
                let buffer = Buffer.allocUnsafe(3 + dataIterable.length);
                let it = dataIterable.iterator;
                buffer[0] = this.id;
                
                // Assign next message ID
                lastMessageId += 1;
                buffer[1] = lastMessageId / 0xFF;
                buffer[2] = lastMessageId % 0xFF;
                
                for (let i = 3; i < dataIterable.length + 3; i++) {
                    buffer[i] = it.next().value;
                }

                const text = buffer.toString('utf-8', 3);
                console.log(`#${('' + lastMessageId).padStart(4, '0')} <${this.toString()}> ${text}`);

                clients.broadcastPacket(ChatPacketType.Message, buffer, [this]);
                this.sendPacket(ChatPacketType.MessageIdAssigned, Buffer.from([buffer[1], buffer[2]]));
                break;
            }
            case ChatPacketType.UserIdentification:
            case ChatPacketType.NotifyMessageSeen:
            case ChatPacketType.RemoveMessage: {
                let it = dataIterable.iterator;
                const high = it.next().value;
                const low = it.next().value;
                const messageId = (high * 0xFF + low);
                // TODO: Allow only removing/editing messages added by the same user (requires message history).
                console.log(`Client ${this.toString()} removes message #${('' + messageId).padStart(4, '0')}`);
                clients.broadcastPacket(ChatPacketType.MessageRemoved, Buffer.from([high, low]));
                break;
            }
            case ChatPacketType.EditMessage:
            //case ChatPacketType.UpdateUserInfo:
            //case ChatPacketType.AskUserInfo:
                // TODO: Multiple packet type still not implemented
                throw 'not implemented';
            
            default:
                console.warn(`Unhandled packet type: ${type}`);
                break;
        }
    }
}

class ClientsSet extends Set {
    broadcastPacket(type, data, omitClientsList = []) {
        if (data) {
            assert(data instanceof Buffer);
        }
        for (const client of this) {
            if (omitClientsList.includes(client)) {
                continue;
            }

            client.serverPort.sendPacket(type, data);
        }
    };

    add(client) {
        super.add(client);
        console.info(`Client ${client.toString()} joined the server`);
        clients.broadcastPacket(ChatPacketType.UserJoined, Buffer.from([client.id, client.colorId]));
    }

    delete(client) {
        super.delete(client);
        console.info(`Client ${client.toString()} left the server`);
        clients.broadcastPacket(ChatPacketType.UserLeft, Buffer.from([client.id]));
    }
}

let clients = new ClientsSet();

// Note: Bluetooth Classic (Serial RFCOMM) supports 30 channels (like ports).
// See https://people.csail.mit.edu/albert/bluez-intro/x148.html for details.
// Note: In real world, free ports should not contain these already used by 
// system or other apps or already marked in SDP records.
let freePorts = Array(30).fill(undefined).map((_, i) => i + 1);

async function listenForNextClient(channel) {
    let serverPort = new BluetoothPacketsServerPort();

    let clientAddress = await new Promise((resolve, reject) => {
        let address;
        serverPort.onPacket = (type, dataIterable) => {
            if (type == ChatPacketType.UserIdentification) {
                resolve(address);
            }
            else {
                reject(new Error('Invalid user identification'));
            }
        };
        serverPort.listen((clientAddress) => {
            address = clientAddress;
            // TOOD: might start condition race against resolving in `onPacket`
        }, reject, {channel: channel});
    });

    // await new Promise(resolve => setTimeout(resolve, 0x17));

    return new Client(serverPort, clientAddress, channel);
}

// Main
(async () => {
    serverAddress = execSync("hcitool dev | awk 'ORS=\"\";$0=$2'").toString();
    console.debug(`Server MAC address: ${serverAddress}`);
    
    console.debug(`Setuping interface...`);
    let input = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    }).on('line', (line) => {
        if (line.startsWith('/')) {
            // TODO: special commands
            if (line.startsWith('/shrug')) {
                line = '¯\\_(ツ)_/¯' + line.substring(7);
                lastMessageId += 1;
                console.log(`#${('' + lastMessageId).padStart(4, '0')} <SRV ${serverAddress}> ${line}`);
                clients.broadcastPacket(ChatPacketType.Message, new MessageData(line, 0, lastMessageId));
            }
        }
        else {
            if (clients.size == 0) {
                console.warn('No clients connected');
                return;
            }
            lastMessageId += 1;
            console.log(`#${('' + lastMessageId).padStart(4, '0')} <SRV ${serverAddress}> ${line}`);
            clients.broadcastPacket(ChatPacketType.Message, new MessageData(line, 0, lastMessageId)); // Server uses 0 as clientID.
        }
    });
    //input._writeToOutput = (string) => {
    //    // Disable output
    //}; 

    console.info(`Listening for connections...`);
    while (serverRunning) {
        let channel = freePorts.pop();
        if (!channel) {
            throw new Error('No free port avaliable.');
        }
        console.debug(`Picked channel no. ${channel} for next client`);

        let client = await listenForNextClient(channel);

        clients.add(client);
    }
    console.info('Closing the server...');
})();
