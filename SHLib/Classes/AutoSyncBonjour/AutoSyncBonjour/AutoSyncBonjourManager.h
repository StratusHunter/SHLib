//
// Created by Dave Leverton on 14/06/2013.
// Copyright (c) 2013 Bulb Studios. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BulbBonjour.h"

#define BONJOUR_SERVER_CONNECTIONS_CHANGED @"serverConnectionsChanged"
#define BONJOUR_CLIENT_CONTACT_ADDED @"bonjourClientContactAdded"
#define IS_ACTIVE_CHANGED @"is_active_changed"
#define IS_CONNECTED_CHANGED @"is_connected_changed"

#define MESSAGE_BLOCK void (^)(NSDictionary *, BonjourPeer*)
#define CONNECT_BLOCK void (^)()
#define CONNECT_TO_CLIENT_BLOCK void (^)(BonjourPeer*)
#define DISCONNECT_BLOCK void (^)(NSError*)
#define DISCONNECT_FROM_CLIENT_BLOCK void (^)(BonjourPeer*)
#define FILE_PROGRESS_BLOCK void (^)(float)
#define FILE_RECEIVED_BLOCK void (^)(NSUInteger)
#define PARTIAL_FILE_RECEIVED_BLOCK void (^)(NSData*)
#define STATUS_CHANGED_BLOCK void (^)(NSString*)

typedef NS_ENUM(NSUInteger , AutoSyncBonjourMode) {

    AUTO_SYNC_CLIENT,
    AUTO_SYNC_SERVER
};

@interface AutoSyncBonjourManager : NSObject <BulbBonjourDelegate>

+ (instancetype) instance;

- (void)setupWithMode:(AutoSyncBonjourMode)mode serviceId:(NSString *)serviceId andDisplayName:(NSString *)displayName isPrivate:(BOOL)
private;
- (void)setupBonjour;
- (void)setupBonjourWithDisplayName:(NSString *)displayName;


@property (assign) AutoSyncBonjourMode mode;
@property (nonatomic, strong) BulbBonjour * bonjour;

@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isPrivate;

@property (nonatomic, assign) NSUInteger timeActive;
@property (nonatomic, strong) NSString* displayName;

- (void)postMessage:(NSDictionary*)message;
- (void)sendFile:(NSString*)filePath;

- (void)teardownBonjour;

- (MESSAGE_BLOCK)addMessageHandler:(MESSAGE_BLOCK)messageHandler;
- (void)removeMessageHandler:(MESSAGE_BLOCK)messageHandler;

- (CONNECT_BLOCK)addConnectHandler:(CONNECT_BLOCK)connectHandler;
- (void)removeConnectHandler:(CONNECT_BLOCK)connectHandler;

- (CONNECT_TO_CLIENT_BLOCK)addConnectToClientHandler:(CONNECT_TO_CLIENT_BLOCK)connectToClientHandler;
- (void)removeConnectToClientHandler:(CONNECT_TO_CLIENT_BLOCK)connectToClientHandler;

- (DISCONNECT_BLOCK)addDisconnectHandler:(DISCONNECT_BLOCK)disconnectHandler;
- (void)removeDisconnectHandler:(DISCONNECT_BLOCK)disconnectHandler;

- (DISCONNECT_FROM_CLIENT_BLOCK)addDisconnectFromClientHandler:(DISCONNECT_FROM_CLIENT_BLOCK)disconnectFromClientHandler;
- (void)removeDisconnectFromClientHandler:(DISCONNECT_FROM_CLIENT_BLOCK)disconnectFromClientHandler;

- (FILE_PROGRESS_BLOCK)addFileProgressHandler:(FILE_PROGRESS_BLOCK)fileProgressHandler;
- (void)removeFileProgressHandler:(FILE_PROGRESS_BLOCK)fileProgressHandler;

- (PARTIAL_FILE_RECEIVED_BLOCK)addPartialReceiveFileHandler:(PARTIAL_FILE_RECEIVED_BLOCK)partialReceiveFileHandler;
- (void)removePartialReceiveFileHandler:(PARTIAL_FILE_RECEIVED_BLOCK)partialReceiveFileHandler;

- (FILE_RECEIVED_BLOCK)addReceiveFileHandler:(FILE_RECEIVED_BLOCK)receiveFileHandler;
- (void)removeReceiveFileHandler:(FILE_RECEIVED_BLOCK)receiveFileHandler;

- (STATUS_CHANGED_BLOCK)addStatusChangedHandler:(STATUS_CHANGED_BLOCK)statusChangedHandler;
- (void)removeStatusChangedHandler:(STATUS_CHANGED_BLOCK)statusChangedHandler;

- (void)setPeerName:(NSString*)name;

@property (nonatomic, strong) NSMutableArray *messageHandlers;
@property (nonatomic, strong) NSMutableArray *connectHandlers;
@property (nonatomic, strong) NSMutableArray *connectToClientHandlers;
@property (nonatomic, strong) NSMutableArray *disconnectHandlers;
@property (nonatomic, strong) NSMutableArray *disconnectFromClientHandlers;
@property (nonatomic, strong) NSMutableArray *fileProgressHandlers;
@property (nonatomic, strong) NSMutableArray *receiveFileHandlers;
@property (nonatomic, strong) NSMutableArray *partialReceiveFileHandlers;
@property (nonatomic, strong) NSMutableArray *statusChangedHandlers;

@end