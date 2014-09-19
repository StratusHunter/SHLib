//
// Created by Dave Leverton on 14/06/2013.
// Copyright (c) 2013 Bulb Studios. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AutoSyncBonjourManager.h"
#import "BonjourPeer.h"

@interface AutoSyncBonjourManager ()

@property(nonatomic, strong) NSString *serviceId;
@property(nonatomic, strong) NSTimer *activeTimer;
@property(nonatomic, strong) NSTimer *heartbeat;
@property(nonatomic, strong) NSTimer *reconnectTimer;

@property(assign) BOOL wasActive;

- (AutoSyncBonjourManager *)initSingleton;

@end

@implementation AutoSyncBonjourManager {
}

- (AutoSyncBonjourManager *)initSingleton {

    if ((self = [super init])) {
        [self setIsConnected:NO];
        self.messageHandlers = [NSMutableArray new];
        self.connectHandlers = [NSMutableArray new];
        self.connectToClientHandlers = [NSMutableArray new];
        self.disconnectFromClientHandlers = [NSMutableArray new];
        self.disconnectHandlers = [NSMutableArray new];
        self.fileProgressHandlers = [NSMutableArray new];
        self.receiveFileHandlers = [NSMutableArray new];
        self.statusChangedHandlers = [NSMutableArray new];
        self.partialReceiveFileHandlers = [NSMutableArray new];
    }

    return self;
}

+ (AutoSyncBonjourManager *)instance {
    // Persistent instance.
    static AutoSyncBonjourManager *_default = nil;

    // Small optimization to avoid wasting time after the
    // singleton being initialized.
    if (_default != nil) {
        return _default;
    }

    // Allocates once with Grand Central Dispatch (GCD) routine.
    // It's thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        _default = [[AutoSyncBonjourManager alloc] initSingleton];
    });

    return _default;
}

- (void)setIsActive:(BOOL)isActive {

    BOOL activeChanged = (isActive != _isActive);

    _isActive = isActive;

    if (activeChanged) {

        [[NSNotificationCenter defaultCenter] postNotificationName:IS_ACTIVE_CHANGED object:nil]; //Allows us to dodge using KVO
    }
}

- (void)setIsConnected:(BOOL)isConnected {

    BOOL connectedChanged = (isConnected != _isConnected);

    _isConnected = isConnected;

    if (connectedChanged) {

        [[NSNotificationCenter defaultCenter] postNotificationName:IS_CONNECTED_CHANGED object:nil]; //Allows us to dodge using KVO
    }
}

- (void)setupWithMode:(AutoSyncBonjourMode)mode serviceId:(NSString *)serviceId andDisplayName:(NSString *)displayName isPrivate:(BOOL)isPrivate {

    [self teardownBonjour];
    [self stopHeartbeat];

    if (mode == AUTO_SYNC_CLIENT) {

        // Stop the server and start the client
        [self.bonjour stop];
        self.bonjour = nil;

        self.bonjour = [[BulbBonjour alloc] init];
        [self.bonjour setDelegate:self];
        [self.bonjour searchWithBroadcastString:serviceId isPrivate:isPrivate];
    }
    else {

        // Stop the client and start the server
        [self.bonjour stop];
        self.bonjour = nil;

        self.bonjour = [[BulbBonjour alloc] init];
        [self.bonjour setDelegate:self];
        [self.bonjour broadcastUsingType:serviceId name:displayName isPrivate:isPrivate];

        [self startHeartbeat];
    }

    [self setIsActive:YES];

    self.timeActive = 0;

    if (self.activeTimer) {

        [self stopTimer];
    }
    self.activeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(activeTick) userInfo:nil repeats:YES];

    self.mode = mode;
    self.serviceId = serviceId;
    self.isPrivate = isPrivate;

    if (displayName) {
        self.displayName = displayName;
    }
    else {
        self.displayName = @"";
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self addObservers];
}

- (void)addObservers {

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

    // Register for notifications when the application leaves the background state
    // on its way to becoming the active application.
    [defaultCenter addObserver:self
                      selector:@selector(willEnterForeground)
                          name:UIApplicationWillEnterForegroundNotification
                        object:nil];

    // Register for notifications when when the application enters the background.
    [defaultCenter addObserver:self
                      selector:@selector(didEnterBackground)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:nil];
}

- (void)willEnterForeground {

    if (self.wasActive) {

        [self setupBonjour];
    }
}

- (void)didEnterBackground {

    self.wasActive = self.isActive;
    [self teardownBonjour];
}

- (void)activeTick {

    self.timeActive += 1.0f;
}

- (void)stopTimer {

    [self.activeTimer invalidate];
    self.activeTimer = nil;
}

//Keeps bluetooth connections active
- (void)startHeartbeat {

    if (self.heartbeat) {

        [self stopHeartbeat];
    }

    self.heartbeat = [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(onHeartBeat) userInfo:nil repeats:YES];
}

- (void)onHeartBeat {

    //We dont care about the message. We just need to keep the bluetooth connection active
    [self postMessage:nil];
}

- (void)stopHeartbeat {

    if (self.heartbeat) {

        [self.heartbeat invalidate];
    }

    self.heartbeat = nil;
}

- (void)postMessage:(NSDictionary *)message {

    [self.bonjour sendMessage:message];
}

- (void)sendFile:(NSString *)filePath {

    [self.bonjour sendFile:filePath];
}

- (void)teardownBonjour {

    //Commented this out on a bit of a whim....lets cross our fingers it doesn't break anything eh
    //if ( self.isConnected || self.isActive) {

    [self setIsConnected:NO];
    [self setIsActive:NO];

    self.timeActive = 0;

    [self stopHeartbeat];
    [self stopTimer];

    NSLog(@"teardownBonjour");
    [self.bonjour stop];

    [self cancelAutoReconnect];
    //}
}

- (void)setupBonjour {

    [self setupWithMode:self.mode serviceId:self.serviceId andDisplayName:self.displayName isPrivate:self.isPrivate];
}

- (void)setupBonjourWithDisplayName:(NSString *)displayName {

    [self setupWithMode:self.mode serviceId:self.serviceId andDisplayName:displayName isPrivate:self.isPrivate];
}

- (id)addBlock:(id)block toArray:(NSMutableArray *)array {

    if (array != nil && block != nil) {

        [array addObject:block];
        return [array lastObject];
    }
    else {

        return nil;
    }
}

- (MESSAGE_BLOCK)addMessageHandler:(MESSAGE_BLOCK)messageHandler {

    return [self addBlock:messageHandler toArray:self.messageHandlers];
}

- (void)removeMessageHandler:(MESSAGE_BLOCK)messageHandler {

    [self.messageHandlers removeObject:messageHandler];
}

- (CONNECT_BLOCK)addConnectHandler:(CONNECT_BLOCK)connectHandler {

    return [self addBlock:connectHandler toArray:self.connectHandlers];
}

- (void)removeConnectHandler:(CONNECT_BLOCK)connectHandler {

    [self.connectHandlers removeObject:connectHandler];
}

- (CONNECT_TO_CLIENT_BLOCK)addConnectToClientHandler:(CONNECT_TO_CLIENT_BLOCK)connectToClientHandler {

    return [self addBlock:connectToClientHandler toArray:self.connectToClientHandlers];
}

- (void)removeConnectToClientHandler:(CONNECT_TO_CLIENT_BLOCK)connectToClientHandler {

    [self.connectToClientHandlers removeObject:connectToClientHandler];
}

- (DISCONNECT_BLOCK)addDisconnectHandler:(DISCONNECT_BLOCK)disconnectHandler {

    return [self addBlock:disconnectHandler toArray:self.disconnectHandlers];
}

- (void)removeDisconnectHandler:(DISCONNECT_BLOCK)disconnectHandler {

    [self.disconnectHandlers removeObject:disconnectHandler];
}

- (DISCONNECT_FROM_CLIENT_BLOCK)addDisconnectFromClientHandler:(DISCONNECT_FROM_CLIENT_BLOCK)disconnectFromClientHandler {

    return [self addBlock:disconnectFromClientHandler toArray:self.disconnectFromClientHandlers];
}

- (void)removeDisconnectFromClientHandler:(DISCONNECT_FROM_CLIENT_BLOCK)disconnectFromClientHandler {

    [self.disconnectFromClientHandlers removeObject:disconnectFromClientHandler];
}

- (FILE_PROGRESS_BLOCK)addFileProgressHandler:(FILE_PROGRESS_BLOCK)fileProgressHandler {

    return [self addBlock:fileProgressHandler toArray:self.fileProgressHandlers];
}

- (void)removeFileProgressHandler:(FILE_PROGRESS_BLOCK)fileProgressHandler {

    [self.fileProgressHandlers removeObject:fileProgressHandler];
}

- (PARTIAL_FILE_RECEIVED_BLOCK)addPartialReceiveFileHandler:(PARTIAL_FILE_RECEIVED_BLOCK)partialReceiveFileHandler {

    return [self addBlock:partialReceiveFileHandler toArray:self.partialReceiveFileHandlers];
}

- (void)removePartialReceiveFileHandler:(PARTIAL_FILE_RECEIVED_BLOCK)partialReceiveFileHandler {

    [self.partialReceiveFileHandlers removeObject:partialReceiveFileHandler];
}

- (FILE_RECEIVED_BLOCK)addReceiveFileHandler:(FILE_RECEIVED_BLOCK)receiveFileHandler {

    return [self addBlock:receiveFileHandler toArray:self.receiveFileHandlers];
}

- (void)removeReceiveFileHandler:(FILE_RECEIVED_BLOCK)receiveFileHandler {

    [self.receiveFileHandlers removeObject:receiveFileHandler];
}

- (STATUS_CHANGED_BLOCK)addStatusChangedHandler:(STATUS_CHANGED_BLOCK)statusChangedHandler {

    return [self addBlock:statusChangedHandler toArray:self.statusChangedHandlers];
}

- (void)removeStatusChangedHandler:(STATUS_CHANGED_BLOCK)statusChangedHandler {

    [self.statusChangedHandlers removeObject:statusChangedHandler];
}

#pragma mark Bonjour Callbacks

- (void)bonjourDidConnect:(BulbBonjour *)bonjour {

    [self setIsConnected:YES];

    NSArray *allConnectHandlers = [self.connectHandlers copy];
    for (
            void (^connectHandler)()
            in allConnectHandlers) {
        connectHandler();
    }
}

- (void)bonjourDidConnect:(BulbBonjour *)bonjour toClient:(BonjourPeer *)peer {

    NSArray *allConnectHandlers = [self.connectToClientHandlers copy];
    for (
            void (^connectToClient)(BonjourPeer *)
            in allConnectHandlers) {

        connectToClient(peer);
    }

    [self setIsConnected:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:BONJOUR_SERVER_CONNECTIONS_CHANGED object:nil];
}

- (void)bonjour:(BulbBonjour *)bonjour fileDownloadDidProgress:(NSInteger)currentSize totalToReceive:(NSUInteger)total {

    NSArray *allFileProgress = [self.fileProgressHandlers copy];
    for (
            void (^fileProgressHandler)(float)
            in allFileProgress) {

        fileProgressHandler((float) currentSize / (float) total);
    }
}

- (void)bonjour:(BulbBonjour *)bonjour statusDidChange:(NSString *)status {

    NSArray *allStatusChanged = [self.statusChangedHandlers copy];
    for (
            void (^statusChangedHandler)(NSString *)
            in allStatusChanged) {

        statusChangedHandler(status);
    }
}

- (void)bonjour:(BulbBonjour *)bonjour partialFileReceived:(NSData *)data {

    NSArray *partialFileReceived = [self.partialReceiveFileHandlers copy];
    for (
            void (^partialReceiveFileHandler)(NSData *)
            in partialFileReceived) {

        partialReceiveFileHandler(data);
    }
}

- (void)bonjour:(BulbBonjour *)bonjour fileReceived:(NSUInteger)dataSize {

    NSArray *allFileReceived = [self.receiveFileHandlers copy];
    for (
            void (^receiveFileHandler)(NSUInteger)
            in allFileReceived) {

        receiveFileHandler(dataSize);
    }
}

- (void)bonjour:(BulbBonjour *)bonjour messageReceived:(NSDictionary *)message fromPeer:(BonjourPeer *)peer {

    NSLog(@"Recieved Message: %@", message);

    NSArray *allMessageHandlers = [self.messageHandlers copy];

    for (
            void (^messageHandler)(NSDictionary *, BonjourPeer *)
            in allMessageHandlers) {

        messageHandler(message, peer);
    }
}

- (void)bonjourDidDisconnect:(BulbBonjour *)bonjour withError:(NSError *)error {

    NSLog(@"bonjourDidDisconnect");

    BOOL wasConnected = self.isConnected;

    [self setIsConnected:NO];

    NSArray *allDisconnectHandlers = [self.disconnectHandlers copy];
    for (
            void (^disconnectHandler)(NSError *)
            in allDisconnectHandlers) {
        disconnectHandler(error);
    }

    if (wasConnected) {
        // Reconnect if still isConnected, wait a few seconds before trying though, as can sometimes still have the old connection lingering around

        double delayInSeconds = 2.0;

        [self cancelAutoReconnect];
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:delayInSeconds target:self selector:@selector(setupBonjour) userInfo:nil repeats:NO];
    }
}

- (void)bonjourDidDisconnect:(BulbBonjour *)bonjour fromClient:(BonjourPeer *)peer {

    NSLog(@"bonjourDidDisconnect:fromClient:");
    NSArray *allDisconnectHandlers = [self.disconnectFromClientHandlers copy];
    for (
            void (^disconnectHandler)(BonjourPeer *)
            in allDisconnectHandlers) {
        disconnectHandler(peer);
    }
}

- (void)bonjourDidLoseConnection:(BulbBonjour *)bonjour {

    [[NSNotificationCenter defaultCenter] postNotificationName:BONJOUR_SERVER_CONNECTIONS_CHANGED object:nil];
}

- (void)setPeerName:(NSString *)name {

    [self.bonjour setName:name];
}

- (void)setPeerData:(NSDictionary *)peerData {

    [self.bonjour setPeerData:peerData];
}

- (void)cancelAutoReconnect {

    [self.reconnectTimer invalidate];
    self.reconnectTimer = nil;
}
@end