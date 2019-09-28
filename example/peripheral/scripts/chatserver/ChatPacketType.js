
class ChatPacketType {
    // Client informs server...
    static UserIdentification   = 0x0A00; // User identifies to the server.
    static PushMessage          = 0x0A01; // Message to server.
    static NotifyMessageSeen    = 0x0A02; // User saw specified message.
    static RemoveMessage        = 0x0A03; // Specified message should be removed.
    static EditMessage          = 0x0A04; // Alternate content of specified message.
    // static UpdateUserInfo       = 0x0C10; // Update on user info.
    // static AskUserInfo          = 0x0C11; // Ask for update on info about specified user.

    // Server broadcasts to rest of clients...
    static Message              = 0x0B01; // Message to rest of clients.
    static MessageSeen          = 0x0B02; // Specified message was seen by rest of clients.
    static MessageRemoved       = 0x0B03; // Specified message was removed.
    static MessageRedacted      = 0x0B04; // Specified message was redacted.
    static UserJoined           = 0x0C01; // User joined the server (with user details) 
    static UserLeft             = 0x0C02; // Specified user left the server.
    static UserKicked           = 0x0C03; // Specified user was kicked from the server.
    static UserMuted            = 0x0C04; // Specified user was muted.
    static UserUnmuted          = 0x0C05; // Specified user was unmuted.
    // static UserInfo             = 0x0C10; // Specified user info (initial or update).
    
    // Server informs specified client...
    static AskUserIdentification= 0x0D00; // Ask for renewed user identification.
    static InvalidOperation     = 0x0D01; // The user tried to do invalid operation.
    static NoPermissions        = 0x0D02; // The user tried to do not permitted operation. 
    static FloodWarning         = 0x0D03; // Too many messages in short time.
    static MessageIdAssigned    = 0x0D04; // Last pushed message id was assigned. 
        // Server might respond with invalid ID meaning that message was rejected.
}

module.exports = ChatPacketType;
