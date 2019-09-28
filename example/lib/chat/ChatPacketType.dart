
class ChatPacketType {
    // Client informs server...
    static const UserIdentification   = 0x0A00; // User identifies to the server.
    static const PushMessage          = 0x0A01; // Message to server.
    static const NotifyMessageSeen    = 0x0A02; // User saw specified message.
    static const RemoveMessage        = 0x0A03; // Specified message should be removed.
    static const EditMessage          = 0x0A04; // Alternate content of specified message.

    // Server broadcasts to rest of clients...
    static const Message              = 0x0B01; // Message to rest of clients.
        // `clientID` - 1 byte, `messageID` - 2 bytes, `context` - the rest
    static const MessageSeen          = 0x0B02; // Specified message was seen by rest of clients.
    static const MessageRemoved       = 0x0B03; // Specified message was removed.
    static const MessageRedacted      = 0x0B04; // Specified message was redacted.
    static const UserJoined           = 0x0C01; // User joined the server (with user details) 
    static const UserLeft             = 0x0C02; // Specified user left the server.
    static const UserKicked           = 0x0C03; // Specified user was kicked from the server.
    static const UserMuted            = 0x0C04; // Specified user was muted.
    static const UserUnmuted          = 0x0C05; // Specified user was unmuted.
    
    // Server informs specified client...
    static const AskUserIdentification= 0x0D00; // Ask for renewed user identification.
    static const InvalidOperation     = 0x0D01; // The user tried to do invalid operation.
    static const NoPermissions        = 0x0D02; // The user tried to do not permitted operation. 
    static const FloodWarning         = 0x0D03; // Too many messages in short time.
    static const MessageIdAssigned    = 0x0D04; // Last pushed message id was assigned. 
        // Server might respond with invalid ID meaning that message was rejected.
}
