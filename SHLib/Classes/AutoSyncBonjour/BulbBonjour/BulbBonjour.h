//
//  BulbBonjour.h
//  ImageViewer
//
//  Created by Terence Baker on 11/04/2013.
//  Copyright (c) 2013 BulbMBP5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "DNSSDBrowser.h"
#import "ManagedSocket.h"
#import "DNSSDRegistration.h"

#define BONJOUR_SUFFIX @"._tcp"
#define BONJOUR_NAME @"bulbpresenter"
#define BONJOUR_LOCAL @"local."
#define BONJOUR_BROWSE_ALL @"_services._dns-sd._udp."

#define PEER_RECONNECTED_NOTIFICATION @"clientReconnected"
#define PEERS_CONNECTED_CHANGED_NOTIFICATION @"peerChanged"

@class BulbBonjour;
@class BonjourPeer;
@class DNSSDRegistration;

typedef NS_ENUM(NSInteger, BonjourMode) {

    BONJOUR_MODE_CLIENT,
    BONJOUR_MODE_SERVER
};

@protocol BulbBonjourDelegate <NSObject>

@optional
- (void)bonjourDidConnect:(BulbBonjour *)bonjour;
- (void)bonjourDidConnect:(BulbBonjour *)bonjour toClient:(BonjourPeer *)socket;
- (void)bonjourDidDisconnect:(BulbBonjour *)bonjour fromClient:(BonjourPeer *)socket;
- (void)bonjourDidDisconnect:(BulbBonjour *)bonjour withError:(NSError *)error;
- (void)bonjourDidLoseConnection:(BulbBonjour *)bonjour;
- (void)bonjour:(BulbBonjour *)bonjour fileDownloadDidProgress:(NSInteger)currentSize totalToReceive:(NSUInteger)total;
- (void)bonjour:(BulbBonjour *)bonjour statusDidChange:(NSString *)status;
- (void)bonjour:(BulbBonjour *)bonjour partialFileReceived:(NSData *)data;
- (void)bonjour:(BulbBonjour *)bonjour fileReceived:(NSUInteger)dataSize;
- (void)bonjour:(BulbBonjour *)bonjour messageReceived:(NSDictionary *)message fromPeer:(BonjourPeer *)peer;

@end

@interface BulbBonjour : NSObject <ManagedSocketDelegate, DNSSDBrowserDelegate, DNSSDServiceDelegate>

@property(nonatomic, strong) DNSSDBrowser *browser;
@property(nonatomic, strong) DNSSDService *service;
@property(nonatomic, strong) DNSSDRegistration *registration;

@property(nonatomic, strong) NSString *connectedHost;
@property(assign) int connectedPort;

@property(nonatomic, strong) NSMutableArray *connectedPeers;
@property(nonatomic, strong) NSMutableArray *seenPeers;

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSDictionary *peerData;

@property(nonatomic, assign) BonjourMode mode;
@property(nonatomic, assign) BOOL connected;

@property(nonatomic, strong) ManagedSocket *managedSocket;

@property(nonatomic, weak) id <BulbBonjourDelegate> delegate;

- (void)searchWithBroadcastString:(NSString *)broadcastString isPrivate:(BOOL)isPrivate;
- (void)broadcastUsingType:(NSString *)type name:(NSString *)name isPrivate:(BOOL)isPrivate;
- (NSString *)broadcastString:(NSString *)string isPrivate:(BOOL)isPrivate;
- (void)stop;

- (void)sendFile:(NSString *)filePath;
- (void)sendMessage:(NSDictionary *)message;
- (NSDictionary *)getMessage:(NSDictionary *)message;

- (void)sendStatus:(NSString *)status;

@end
