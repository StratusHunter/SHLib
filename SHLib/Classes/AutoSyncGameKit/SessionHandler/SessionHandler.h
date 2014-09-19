//
//  SessionHandler.h
//  AudiTraining
//
//  Created by BulbMBP5 on 24/08/2012.
//  Copyright (c) 2012 BulbMBP5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

/**
* A Class which wraps GameKit in a static format, can be used only when you require one GKSession per App. Which is pretty much ever time right?
*/
@interface SessionHandler : NSObject

/**
* Set up a session with a number of variable parameters
*
* @param sessionID An ID which is used by GameKit to detect which clients / servers / peers to connect to
* @param name Display name which all other clients / server / peers can see
* @param mode GKSessionMode which determines whether this is a Server / Peer or Client
* @param delegate Delegate which receives connection changes and errors
*/
+ (void) setUpSessionWithSessionID:(NSString*)sessionID displayName:(NSString*)name sessionMode:(GKSessionMode)mode withDelegate:(id<GKSessionDelegate>) delegate;

+ (bool) firstConnect;
+ (void) setFirstConnect:(bool)firstConnect;

+ (void) tearDownSession;
+ (void) reloadSession;
+ (void) reloadSessionWithDisplayName:(NSString *)displayName;

+ (NSString *)peerId;

+ (void) connectToPeer:(NSString*)peerID;
+ (void) acceptConnectionFromPeer:(NSString*) peerID;
+ (void) denyConnectionFromPeer:(NSString*) peerID;
+ (void) setAvailable:(BOOL)available;

+ (NSString*) getNameForPeer:(NSString*) peerID;

+ (void) disconnectPeer:(NSString*)peerID;
+ (void) disconnectFromAllConnections;

+ (BOOL) sendData:(NSDictionary *)dict toPeer:(NSString*)peerID;
+ (BOOL) sendDataToAllPeers:(NSDictionary*)dict;
+ (NSDictionary*)readDataIntoDictionary:(NSData *)data;

@end
