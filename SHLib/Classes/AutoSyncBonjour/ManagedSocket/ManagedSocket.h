//
// Created by Dave Leverton on 04/06/2013.
// Copyright (c) 2013 BulbMBP5. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

#define DISCONNECT_MESSAGE @"managedDisco"
@class ManagedSocket;

typedef NS_ENUM(NSInteger, MessageType) {

    MESSAGE_TYPE_FILE,
    MESSAGE_TYPE_DICTIONARY,

};

@protocol ManagedSocketDelegate <NSObject>

@optional
- (void) managedSocket:(ManagedSocket *)managedSocket didConnectToHost:(NSString *)host onPort:(unsigned long)port;
- (void) managedSocket:(ManagedSocket *)managedSocket didAcceptNewSocket:(ManagedSocket *)socket;

- (void) managedSocket:(ManagedSocket *)managedSocket didReceivePartialFile:(NSData *)data;
- (void) managedSocket:(ManagedSocket *)managedSocket didReceiveFile:(NSUInteger)dataSize;
- (void) managedSocket:(ManagedSocket *)managedSocket didReceiveMessage:(NSDictionary *)message;
- (void) managedSocket:(ManagedSocket *)managedSocket downloadDidProgress:(NSUInteger)receivedDataSize expectedSize:(NSUInteger)expectedFileSize;
- (void) managedSocketConnectedSocketsDidChange:(ManagedSocket *)managedSocket;
- (void) managedSocketDidDisconnect:(ManagedSocket *)managedSocket withError:(NSError*)error;

@end

@interface ManagedSocket : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSMutableArray *connectedSockets;
@property (nonatomic, weak) id<ManagedSocketDelegate> delegate;

-(id)initWithDelegate:(id<ManagedSocketDelegate>)delegate;
-(id)initWithSocket:(GCDAsyncSocket *)socket delegate:(id<ManagedSocketDelegate>)delegate;
-(void)connectToHost:(NSString *)host onPort:(uint16_t)port;
-(void)startReadingData;
-(void)sendMessage:(NSDictionary *)message;
-(void)sendFileData:(NSData*)fileData;
-(void)sendFileAtPath:(NSString *)filePath;

-(void)stop;


@end