//
//  BulbBonjour.m
//  ImageViewer
//
//  Created by Terence Baker on 11/04/2013.
//  Copyright (c) 2013 BulbMBP5. All rights reserved.
//

#import "BulbBonjour.h"
#import "NSString+Base64.h"
#import "BonjourPeer.h"

#define TIME_BETWEEN_ATTEMPTS 5

@interface BulbBonjour ()

@property(strong, nonatomic) NSTimer *connectionAttemptTimer;
@property(strong, nonatomic) NSString *broadcastType;
@property(assign) int connectionAttempts;

@end

@implementation BulbBonjour

- (void)searchWithBroadcastString:(NSString *)broadcastString isPrivate:(BOOL)isPrivate {

    [self stop];

    NSLog(@"Searching for %@ , Private : %d", [self broadcastString:broadcastString isPrivate:isPrivate], isPrivate);

    self.mode = BONJOUR_MODE_CLIENT;
    self.connectionAttempts = 0;
    self.broadcastType = [self broadcastString:broadcastString isPrivate:isPrivate];

    self.browser = [[DNSSDBrowser alloc] initWithDomain:BONJOUR_LOCAL type:self.broadcastType];
    [self.browser setDelegate:self];
    [self.browser startBrowse:NO]; //Start in wifi mode only due to speed
    [self sendStatus:@"Connecting..."];

    self.connectionAttemptTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_BETWEEN_ATTEMPTS target:self selector:@selector(reAttemptConnection) userInfo:nil repeats:YES];
}

- (void)reAttemptConnection {

    [self.browser stop];

    self.connectionAttempts++;

    [self.browser startBrowse:YES]; //Now search for Bluetooth too
    [self sendStatus:[NSString stringWithFormat:@"%@ (%d)", @"Connecting...", self.connectionAttempts]];
}

- (void)broadcastUsingType:(NSString *)type name:(NSString *)name isPrivate:(BOOL)isPrivate {

    [self stop];

    self.mode = BONJOUR_MODE_SERVER;
    self.managedSocket = [[ManagedSocket alloc] initWithDelegate:self];

    NSError *err = nil;

    [[self.managedSocket socket] acceptOnPort:0 error:&err];

    self.connectedPort = [[self.managedSocket socket] localPort];

    self.registration = [[DNSSDRegistration alloc] initWithDomain:BONJOUR_LOCAL type:[self broadcastString:type isPrivate:isPrivate] name:name port:self.connectedPort];
    [self.registration start];

    NSLog(@"Broadcasting %@ on Port: %d Private: %d", [self broadcastString:type isPrivate:isPrivate], self.connectedPort, isPrivate);
}

- (NSString *)broadcastString:(NSString *)string isPrivate:(BOOL)isPrivate {

    NSString *pinBase64 = (isPrivate) ? [string base64Encode] : string;
    NSString *nameBase64 = (isPrivate) ? [BONJOUR_NAME base64Encode] : BONJOUR_NAME;

    //Remove invalid characters
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    pinBase64 = [[pinBase64 componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    nameBase64 = [[nameBase64 componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];

    NSString *broadcastString = [NSString stringWithFormat:@"_%@_%@%@", pinBase64, nameBase64, BONJOUR_SUFFIX];

    return broadcastString;
}

- (void)stop {

    NSLog(@"Bonjour Stop");
    self.connectedPeers = [NSMutableArray new];
    self.seenPeers = [NSMutableArray new];
    [self.registration stop];
    [self.service stop];
    [self.browser stop];
    [self.managedSocket stop];
    self.connected = NO;

    self.managedSocket = nil;
    self.browser = nil;
    self.service = nil;
    self.registration = nil;

    self.connectedHost = nil;
    self.connectedPort = 0;

    [self.connectionAttemptTimer invalidate];
    self.connectionAttemptTimer = nil;
}

- (void)sendStatus:(NSString *)status {

    if ([_delegate respondsToSelector:@selector(bonjour:statusDidChange:)]) {

        [_delegate bonjour:self statusDidChange:status];
    }
}

- (void)sendFile:(NSString *)filePath {

    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {

        [self.managedSocket sendFileData:data];
    }
}

- (NSString *)name {

    return _name ?: [[UIDevice currentDevice] name];
}

- (BonjourPeer *)getNewPeer {

    NSString *uuidString = [[UIDevice currentDevice].identifierForVendor UUIDString];

    BonjourPeer *peer = [[BonjourPeer alloc] init];
    peer.name = self.name ?: @"";
    peer.deviceId = uuidString ?: @"";
    peer.peerData = self.peerData ?: @{};

    return peer;
}

- (NSDictionary *)getMessage:(NSDictionary *)message {

    BonjourPeer *peer = [self getNewPeer];
    NSMutableDictionary *mutableMessage = [message mutableCopy] ?: [NSMutableDictionary new];
    [mutableMessage addEntriesFromDictionary:[peer toJSON]];

    mutableMessage[BONJOUR_TIME_STAMP] = @([[NSDate date] timeIntervalSince1970]); //Timestamp every message

    return mutableMessage;
}

- (void)sendMessage:(NSDictionary *)message {

    NSDictionary *mutableMessage = [self getMessage:message];

    if (self.mode == BONJOUR_MODE_SERVER) {

        for (ManagedSocket *socket in self.managedSocket.connectedSockets) {

            [socket sendMessage:mutableMessage];
        }
    }
    else {

        [self.managedSocket sendMessage:mutableMessage];
    }
}

#pragma mark DNSSDBrowserDelegate
- (void)dnssdBrowser:(DNSSDBrowser *)browser didAddService:(DNSSDService *)service moreComing:(BOOL)moreComing {

    NSLog(@"didAddService");
    [service setDelegate:self];
    [service startResolve];
}

#pragma mark DNSSDServiceDelegate
- (void)dnssdServiceDidStop:(DNSSDService *)service {

    NSLog(@"dnssdServiceDidStop");
    self.service = nil;
}

- (void)dnssdServiceDidResolveAddress:(DNSSDService *)service {

    NSLog(@"dnssdServiceDidResolveAddress %@:%lu", service.resolvedHost, (unsigned long) service.resolvedPort);
    self.service = service;

    if (self.managedSocket == nil) {

        self.connectedHost = service.resolvedHost;
        self.connectedPort = service.resolvedPort;

        [self.connectionAttemptTimer invalidate];
        self.connectionAttemptTimer = nil;
        [self.browser stop];

        self.managedSocket = [[ManagedSocket alloc] initWithDelegate:self];
        [self.managedSocket connectToHost:service.resolvedHost onPort:(uint16_t) service.resolvedPort];
    }
}

#pragma mark ManagedSocket Delegate
- (void)managedSocket:(ManagedSocket *)managedSocket didConnectToHost:(NSString *)host onPort:(unsigned long)port {

    NSLog(@"Socket:DidConnectToHost: %@ Port: %lu", host, port);

    self.connected = YES;
    id <BulbBonjourDelegate> o = self.delegate;
    if ([o respondsToSelector:@selector(bonjourDidConnect:)]) {
        [o bonjourDidConnect:self];
    }

    NSLog(@"beginReadingData");
    if (managedSocket == self.managedSocket) {
        [self sendStatus:@"Downloading..."];
    }
}

- (void)managedSocket:(ManagedSocket *)managedSocket didAcceptNewSocket:(ManagedSocket *)socket {

    NSLog(@"managedSocket:didAcceptNewSocket");

    //Used to add the peer to the connected and seen list however we have no name or deviceId making problems finding out when a device reconnects
    BonjourPeer *peer = [BonjourPeer new];
    peer.socket = socket;

    self.connected = YES;
    id <BulbBonjourDelegate> o = self.delegate;
    if ([o respondsToSelector:@selector(bonjourDidConnect:toClient:)]) {
        [o bonjourDidConnect:self toClient:peer];
    }
}

- (void)managedSocket:(ManagedSocket *)managedSocket didReceivePartialFile:(NSData *)data {

    //NSLog(@"managedSocket:didReceivePartialFile");
    id <BulbBonjourDelegate> o = self.delegate;
    if ([o respondsToSelector:@selector(bonjour:partialFileReceived:)]) {
        [o bonjour:self partialFileReceived:data];
    }
}

- (void)managedSocket:(ManagedSocket *)managedSocket didReceiveFile:(NSUInteger)fileSize {

    NSLog(@"managedSocket:didReceiveFile");
    id <BulbBonjourDelegate> o = self.delegate;
    if ([o respondsToSelector:@selector(bonjour:fileReceived:)]) {
        [o bonjour:self fileReceived:fileSize];
    }
}

- (void)managedSocket:(ManagedSocket *)managedSocket didReceiveMessage:(NSDictionary *)message {

    BonjourPeer *receivedPeer = [[BonjourPeer alloc] initWithJSON:message];
    receivedPeer.socket = managedSocket;

    [self addNewPeer:receivedPeer];

    id <BulbBonjourDelegate> o = self.delegate;
    if ([o respondsToSelector:@selector(bonjour:messageReceived:fromPeer:)]) {
        [o bonjour:self messageReceived:message fromPeer:receivedPeer];
    }
}

- (void)managedSocket:(ManagedSocket *)managedSocket downloadDidProgress:(NSUInteger)receivedDataSize expectedSize:(NSUInteger)expectedFileSize {

    //NSLog(@"managedSocket:downloadDidProgress");
    id <BulbBonjourDelegate> o = self.delegate;
    if ([o respondsToSelector:@selector(bonjour:fileDownloadDidProgress:totalToReceive:)]) {
        [o bonjour:self fileDownloadDidProgress:receivedDataSize totalToReceive:expectedFileSize];
    }
}

- (void)managedSocketConnectedSocketsDidChange:(ManagedSocket *)managedSocket {

    NSLog(@"managedSocketConnectedSocketsDidChange");
    id <BulbBonjourDelegate> o = self.delegate;
    if ([o respondsToSelector:@selector(bonjourDidLoseConnection:)]) {
        [o bonjourDidLoseConnection:self];
    }
}

- (void)managedSocketDidDisconnect:(ManagedSocket *)managedSocket withError:(NSError *)error {

    NSLog(@"managedSocketDidDisconnect");

    BonjourPeer *peer = [self getPeer:managedSocket fromArray:self.connectedPeers];
    [self removeConnectedPeer:managedSocket];

    id <BulbBonjourDelegate> o = self.delegate;

    if (managedSocket == self.managedSocket) {

        if ([o respondsToSelector:@selector(bonjourDidDisconnect:withError:)]) {
            [o bonjourDidDisconnect:self withError:error];
        }
    }
    else {

        if ([o respondsToSelector:@selector(bonjourDidDisconnect:fromClient:)]) {
            [o bonjourDidDisconnect:self fromClient:peer];
        }
    }
}

- (void)addNewPeer:(BonjourPeer *)peer {

    int connectedCount = (int) self.connectedPeers.count;
    int seenCount = (int) self.seenPeers.count;

    [self removeDuplicatePeers:peer inArray:self.seenPeers];
    [self removeDuplicatePeers:peer inArray:self.connectedPeers];

    [self.connectedPeers addObject:peer];
    [self.seenPeers addObject:peer];

    if (seenCount == self.seenPeers.count && connectedCount < self.connectedPeers.count) {

        [[NSNotificationCenter defaultCenter] postNotificationName:PEER_RECONNECTED_NOTIFICATION object:nil userInfo:@{PEER_RECONNECTED_NOTIFICATION : peer}];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:PEERS_CONNECTED_CHANGED_NOTIFICATION object:nil];
}

- (void)removeConnectedPeer:(ManagedSocket *)socket {

    BonjourPeer *peer = [self getPeer:socket fromArray:self.connectedPeers];

    if (peer != nil) {

        [self removeDuplicatePeers:peer inArray:self.connectedPeers];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:PEERS_CONNECTED_CHANGED_NOTIFICATION object:nil];
}

- (void)removeDuplicatePeers:(BonjourPeer *)peer inArray:(NSMutableArray *)peerList {

    if (peer.socket != nil) {

        NSArray *duplicateSockets = [peerList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"socket == %@", peer.socket]];
        [peerList removeObjectsInArray:duplicateSockets];
    }

    if (peer.deviceId != nil) {

        NSArray *duplicateSockets = [peerList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"deviceId == %@", peer.deviceId]];
        [peerList removeObjectsInArray:duplicateSockets];
    }
}

- (BonjourPeer *)getPeer:(ManagedSocket *)socket fromArray:(NSArray *)peerList {

    if (socket != nil) {

        NSArray *peerArray = [peerList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"socket == %@", socket]];

        if ([peerArray count] > 0) {

            return peerArray[0];
        }
    }

    return nil;
}

@end
