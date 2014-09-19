//
//  SessionHandler.m
//  AudiTraining
//
//  Created by BulbMBP5 on 24/08/2012.
//  Copyright (c) 2012 BulbMBP5. All rights reserved.
//

#import "SessionHandler.h"


@implementation SessionHandler

static GKSession *sSession;
static NSString *sSessionID;
static NSString *sName;
static GKSessionMode sMode;
static id <GKSessionDelegate> sDelegate;
static bool sFirstConnect;
static NSString *sUDID;

+ (void)setUpSessionWithSessionID:(NSString *)sessionID displayName:(NSString *)name sessionMode:(GKSessionMode)mode withDelegate:(id <GKSessionDelegate>)delegate {

    if (sSession == nil) {

        sSession = [[GKSession alloc] initWithSessionID:sessionID displayName:name sessionMode:mode];
    }

    sSessionID = sessionID;
    sName = name;
    sMode = mode;
    sDelegate = delegate;
    sFirstConnect = true;

    [sSession setDelegate:delegate];
    [sSession setDataReceiveHandler:delegate withContext:nil];
}

+ (bool)firstConnect {

    return sFirstConnect;
}

+ (void)setFirstConnect:(bool)firstConnect {

    sFirstConnect = firstConnect;
}

+ (void)tearDownSession {

    [sSession setAvailable:NO];
    [sSession setDelegate:nil];
    [sSession setDataReceiveHandler:nil withContext:nil];
    [sSession disconnectFromAllPeers];
    sSession = nil;
}

+ (void)reloadSessionWithDisplayName:(NSString *)displayName {

    sName = displayName;

    sSession = [[GKSession alloc] initWithSessionID:sSessionID displayName:sName sessionMode:sMode];
    [sSession setDelegate:sDelegate];
    [sSession setDataReceiveHandler:sDelegate withContext:nil];
    [sSession setDisconnectTimeout:5];

    // Set Available needs to be delayed after being initialised, Init does some setup in the background by the looks of things. Setting available before this is done can cause connectivity issues
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [sSession setAvailable:YES];
    });
}

+ (void)reloadSession {

    [self reloadSessionWithDisplayName:sName];
}

+ (NSString *)GetUUID {

    if (sUDID) {

        return sUDID;
    }

    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    sUDID = (__bridge NSString *) string;
    CFRelease(theUUID);
    return (__bridge NSString *) string;
}

+ (NSString*)peerId {

    return [sSession peerID];
}

+ (void)connectToPeer:(NSString *)peerID {

    [sSession connectToPeer:peerID withTimeout:5];
    //NSLog(@"Connect");
}

+ (void)acceptConnectionFromPeer:(NSString *)peerID {

    [sSession acceptConnectionFromPeer:peerID error:nil];
    //NSLog(@"Accept");
}

+ (void)denyConnectionFromPeer:(NSString *)peerID {

    [sSession denyConnectionFromPeer:peerID];
    //NSLog(@"Deny");
}

+ (void)setAvailable:(BOOL)available {

    // Set Available needs to be delayed after being initialised, Init does some setup in the background by the looks of things. Setting available before this is done can cause connectivity issues
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [sSession setAvailable:available];
    });
    //NSLog(@"Set Avail");
}

+ (NSString *)getNameForPeer:(NSString *)peerID {

    return [sSession displayNameForPeer:peerID];
    //NSLog(@"Get Name");
}

+ (void)disconnectPeer:(NSString *)peerID {

    [sSession disconnectPeerFromAllPeers:peerID];
    //NSLog(@"Disco one");
}

+ (void)disconnectFromAllConnections {

    [sSession disconnectFromAllPeers];
    //NSLog(@"Disco from all");
}

+ (BOOL)sendData:(NSDictionary *)dict toPeer:(NSString *)peerID {

    NSMutableDictionary *mutableDict = [dict mutableCopy];
    [mutableDict setObject:[self GetUUID] forKey:@"udid"];

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:mutableDict forKey:@"data"];
    [archiver finishEncoding];

    NSError *error = nil;
    [sSession sendData:data toPeers:@[peerID] withDataMode:GKSendDataReliable error:&error];

    if (error != nil) {

        //NSLog(@"Error Sending Data! %@", error);
        return false;
    }

    return true;
}

/**
 * Send data as an NSDictionary - easier than downloading a JSON formatter, as it will only be the app connecting to the app!
 *
 * @param dict: The dictionary to send
 * @return returns if the send was successful or not;
 *
 */
+ (BOOL)sendDataToAllPeers:(NSDictionary *)dict {

    NSMutableDictionary *mutableDict = [dict mutableCopy];
    [mutableDict setObject:[self GetUUID] forKey:@"udid"];

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:mutableDict forKey:@"data"];
    [archiver finishEncoding];

    NSError *error = nil;
    [sSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];

    if (error != nil) {

        //NSLog(@"Error Sending Data! %@", error);
        return false;
    }

    return true;
}


/**
 * Read data as an NSDictionary - easier than downloading a JSON formatter, as it will only be the app connecting to the app!
 *
 * @param data: The data to return as a Dictionary
 * @return returns an NSDictionary which holds the data!
 *
 */
+ (NSDictionary *)readDataIntoDictionary:(NSData *)data {

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableDictionary *dict = [unarchiver decodeObjectForKey:@"data"];
    [unarchiver finishDecoding];

    return dict;
}

@end
