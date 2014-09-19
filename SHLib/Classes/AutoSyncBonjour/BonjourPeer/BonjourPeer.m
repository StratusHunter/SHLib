//
//  BonjourPeer.m
//  bulbraries
//
//  Created by Dave Leverton on 22/08/2013.
//  Copyright (c) 2013 Bulb Studios. All rights reserved.
//

#import "BonjourPeer.h"
#import "ManagedSocket.h"

@implementation BonjourPeer

- (id)init {

    self = [super init];
    if( self) {

        self.deviceId = @"";
        self.name = @"";
        self.socket = nil;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)message {

    if (self = [super init]) {

        self.socket = nil;
        self.deviceId = message[BONJOUR_DEVICE_ID] ?: @"";
        self.name = message[BONJOUR_CLIENT_NAME] ?: @"";
        self.peerData = message[BONJOUR_CLIENT_DATA] ?: @{};
    }

    return self;
}

-(NSDictionary *)toJSON {

    NSMutableDictionary *jsonDict = [NSMutableDictionary new];

    jsonDict[BONJOUR_CLIENT_NAME] = self.name ?: @"";
    jsonDict[BONJOUR_DEVICE_ID] = self.deviceId ?: @"";
    jsonDict[BONJOUR_CLIENT_DATA] = self.peerData ?: @{};

    return jsonDict;
}

- (void)sendMessage:(NSDictionary *)message {

    NSString* uuidString = [[UIDevice currentDevice].identifierForVendor UUIDString];

    NSMutableDictionary* mutableMessage = [message mutableCopy];
    mutableMessage[BONJOUR_CLIENT_NAME] = self.name ?: @"";
    mutableMessage[BONJOUR_DEVICE_ID] = uuidString ?: @"";
    mutableMessage[BONJOUR_CLIENT_DATA] = self.peerData ?: @{};

    [self.socket sendMessage:mutableMessage];
}

- (void)sendFile:(NSData *)file {

    [self.socket sendFileData:file];
}

-(void)sendFileAtPath:(NSString *)filePath {

    [self.socket sendFileAtPath:filePath];
}

@end
