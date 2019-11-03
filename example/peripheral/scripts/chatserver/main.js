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

let serverOptions = {
    floodCounter: 3,
    floodDisconnectThreshold: 33,
    floodCounterRecoveryTimeout: 3333
};

// TOOD: Instead of having united message IDs, client could hold `messageIdOffset` 
//  and have the messages stored in array (which could prevent scanning while
//  searching for specified message. Also, some messages could be periodicly
//  dropped from storage, and offset could be updated (and also sent to server).

let lastMessageId = 0;
function getNextMessageId() {
    if (lastMessageId == 0xFFFF) { // Last 2 byte message ID 
        lastMessageId = 1;

        // Reset last seen message IDs on value overflow
        for (let client of clients) {
            client.lastSeenMessageId = 0;
        }
    }
    return ++lastMessageId
}
let lastClientId = 0;

function encounterMutedCheck(client) {
    if (clients.getById(client.id).muted) {
        client.sendPacket(ChatPacketType.NoPermissions, Buffer.from('muted', 'utf-8'));
        return;
    }
}
function encounterFloodingCheck(client) {
    if (client.floodCounter >= serverOptions.floodCounter) {
        client.sendPacket(ChatPacketType.FloodWarning);
        if (client.floodCounter >= serverOptions.floodDisconnectThreshold) {
            console.log(`Kicking client ${client.toString()} due to flooding`);
            clients.broadcastPacket(ChatPacketType.UserKicked, Buffer.from([client.id]));
            setTimeout(() => client.kick(), 0x17);
            return;
        }
        console.log(`Client ${client.toString()} warned about flooding (level: ${client.floodCounter})`);
        return;
    }
    client.floodCounter += 1;
    setTimeout(() => {
        client.floodCounter -= 1;
    }, serverOptions.floodCounterRecoveryTimeout);
}

class MessageData extends Buffer {
    constructor(content, clientId = 0, messageId = undefined) {
        if (messageId == undefined) {
            messageId = getNextMessageId();
        }

        super(1 + 2 + Buffer.byteLength(content, 'utf-8'));

        this[0] = clientId;
        this[1] = messageId / 0xFF;
        this[2] = messageId % 0xFF;
        this.write(content, 3, 'utf-8');
    }
}

class MessageHistoryEntry {
    constructor(data) {
        // this._data = data;
        // For now, only these are required:
        this.clientId = data[0];
        this.removed = false;
    }

    // get clientId() {
    //     return this._data[0];
    // }

    // get messageId() {
    //     return this._data[1] * 0xFF + this._data[2];
    // }

    // get contentAsString() {
    //     return this._data.toString('utf-8', 3);
    // }
}

let messages = [];

let freeColors = Array(17).fill(undefined).map((_, i) => i + 1);

class Client {
    constructor(serverPort, address, channel) {
        this.id = ++lastClientId;
        this.serverPort = serverPort;
        this.address = address;
        this.channel = channel;

        this.serverPort.onClosed = () => this._onClosed();
        this.serverPort.onPacket = (...args) => this._onPacket(...args);

        this.colorId = freeColors.splice(Math.floor(Math.random() * freeColors.length), 1)[0];

        this.lastSeenMessageId = 0;

        this.muted = false;
        this.floodCounter = 0;
    }

    toString() {
        // TODO: Missing client name :C
        return `#${('' + this.id).padStart(2, '0')} ${this.address}`;
    }

    sendPacket(type, data) {
        return this.serverPort.sendPacket(type, data);
    }

    kick() {
        this._onClosed();
    }

    _onClosed() {
        clients.delete(this);
        freePorts.push(this.channel);
        freeColors.push(this.colorId);
        this.serverPort.close();
    }

    _onPacket(type, dataIterable) {
        switch (type) {
            case ChatPacketType.PushMessage: {
                encounterMutedCheck(this);
                encounterFloodingCheck(this);

                // There seems to be no way to directly decode Iterator of 
                // bytes (ints < 256) into String (at least in basic modules).
                // Starting with 3 bytes gap to avoid further copying in order
                // to broadcast the message (3 bytes broadcast packet header).
                let it = dataIterable.iterator;
                let buffer = Buffer.allocUnsafe(3 + dataIterable.length);
                buffer[0] = this.id;

                // Prepare data 
                for (let i = 3; i < dataIterable.length + 3; i++) {
                    buffer[i] = it.next().value;
                }
                const text = buffer.toString('utf-8', 3);

                // Assign next message ID
                const messageId = getNextMessageId();
                buffer[1] = messageId / 0xFF;
                buffer[2] = messageId % 0xFF;

                // Add to history
                messages[messageId] = new MessageHistoryEntry(buffer);

                console.log(`#${('' + messageId).padStart(4, '0')} <${this.toString()}> ${text}`);

                clients.broadcastPacket(ChatPacketType.Message, buffer, [this]);
                this.sendPacket(ChatPacketType.MessageIdAssigned, Buffer.from([buffer[1], buffer[2]]));

                // Updating seen message id, but not broadcasting,
                // since the message is freshly pushed. What it's mean is, 
                // if there is single user, there will be no 'seen', 
                // but this is quite special situation...
                // Also, please note that there is assumption, that message id
                // numbers are considered as indexing. In some systems, 
                // like multi-user distributed/decentralized systems, 
                // there would be no such assumption - messages could be 
                // received asynchronously by different users.
                this.lastSeenMessageId = messageId;
                break;
            }

            case ChatPacketType.UserIdentification:
                // Ignore. It was used while initializing chat session.
                break;

            case ChatPacketType.NotifyMessageSeen: {
                let it = dataIterable.iterator;
                const high = it.next().value;
                const low = it.next().value;
                const messageId = (high * 0xFF + low);

                if (messageId > this.lastSeenMessageId) {
                    this.lastSeenMessageId = messageId;
                }

                for (const client of clients) {
                    if (client.lastSeenMessageId < messageId) {
                        return;
                    }
                }

                clients.broadcastPacket(ChatPacketType.MessageSeen, Buffer.from([high, low]));
                break;
            }

            case ChatPacketType.RemoveMessage: {
                let it = dataIterable.iterator;
                const high = it.next().value;
                const low = it.next().value;
                const messageId = (high * 0xFF + low);

                if (messages[messageId].clientId != this.id) {
                    this.sendPacket(ChatPacketType.NoPermissions, Buffer.from('not message owner', 'utf-8'));
                    return;
                }

                if (messages[messageId].removed) {
                    this.sendPacket(ChatPacketType.InvalidOperation, Buffer.from('message removed', 'utf-8'));
                    return;
                }

                messages[messageId].removed = true;

                console.log(`Client ${this.toString()} removes message #${('' + messageId).padStart(4, '0')}`);
                clients.broadcastPacket(ChatPacketType.MessageRemoved, Buffer.from([high, low]));
                break;
            }

            case ChatPacketType.EditMessage: {
                encounterMutedCheck(this);
                encounterFloodingCheck(this);

                let it = dataIterable.iterator;
                const messageIdHigh = it.next().value;
                const messageIdLow  = it.next().value;
                const messageId = messageIdHigh * 0xFF + messageIdLow;

                if (messages[messageId].clientId != this.id) {
                    this.sendPacket(ChatPacketType.NoPermissions, Buffer.from('not message owner', 'utf-8'));
                    return;
                }

                if (messages[messageId].removed) {
                    this.sendPacket(ChatPacketType.InvalidOperation, Buffer.from('message removed', 'utf-8'));
                    return;
                }

                let buffer = Buffer.allocUnsafe(dataIterable.length);
                buffer[0] = messageIdHigh;
                buffer[1] = messageIdLow;

                // Prepare data 
                for (let i = 2; i < dataIterable.length + 2; i++) {
                    buffer[i] = it.next().value;
                }
                const text = buffer.toString('utf-8', 2);

                console.log(`#${('' + messageId).padStart(4, '0')} <${this.toString()}> ${text}`);

                clients.broadcastPacket(ChatPacketType.MessageRedacted, buffer);
                break;
            }

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

            client.sendPacket(type, data);
        }
    };

    add(client) {
        super.add(client);
        console.info(`Client ${client.toString()} joined the server`);
        clients.broadcastPacket(ChatPacketType.UserJoined, Buffer.from([client.id, client.colorId]));
    }

    delete(client) {
        if (super.delete(client)) {
            console.info(`Client ${client.toString()} left the server`);
            clients.broadcastPacket(ChatPacketType.UserLeft, Buffer.from([client.id]));
        }
    }

    getById(id) {
        for (let client of this) {
            if (client.id == id) {
                return client;
            }
        }
        return undefined;
    }

    getByAddress(address) {
        address = address.toUpperCase();
        for (let client of this) {
            if (client.address == address) {
                return client;
            }
        }
        return undefined;
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

    return new Client(serverPort, clientAddress.toUpperCase(), channel);
}

function parseCommand(line) {
    let parts = line.split(' ');

    // Helper functions
    function consumeForClient(part) {
        // Try get client as ID
        let clientId = parseInt(part);
        if (clientId) {
            let client = clients.getById(clientId);
            if (client) {
                return client;
            }
        }
        // Try get client as address
        let client = clients.getByAddress(part);
        if (client) {
            return client;
        }
        throw 'Client not found';
    }

    let commandName = parts[0].substring(1).toLowerCase();

    try {
        switch (commandName) {
            case 'kick': {
                let client = consumeForClient(parts[1]);
                console.log(`Kicking client ${client.toString()}`);
                clients.broadcastPacket(ChatPacketType.UserKicked, Buffer.from([client.id]));
                setTimeout(() => client.kick(), 0x17);
                break;
            }
            case 'mute': {
                let client = consumeForClient(parts[1]);
                if (client.muted) {
                    console.warn(`Client ${client.toString()} already muted.`);
                }
                client.muted = true;
                console.info(`Client ${client.toString()} muted.`);
                clients.broadcastPacket(ChatPacketType.UserMuted, Buffer.from([client.id]));
                break;
            }
            case 'unmute': {
                let client = consumeForClient(parts[1]);
                if (!client.muted) {
                    console.warn(`Client ${client.toString()} is not muted.`);
                }
                client.muted = false;
                console.info(`Client ${client.toString()} unmuted.`);
                clients.broadcastPacket(ChatPacketType.UserUnmuted, Buffer.from([client.id]));
                break;
            }
            default:
                console.warn(`Unknown server console command: ${commandName}`);
                break;
        }
    }
    catch (e) {
        console.warn('Command failed: ', e);
    }
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
        if (line.startsWith('/shrug')) {
            line = '¯\\_(ツ)_/¯ ' + line.substring(7);
        }
        if (line.startsWith('/')) {
            parseCommand(line);
        }
        else {
            if (clients.size == 0) {
                console.warn('No clients connected to send this message.');
                return;
            }
            getNextMessageId();
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
