//
//  BonjourPeer.h
//  bulbraries
//
//  Created by Dave Leverton on 22/08/2013.
//  Copyright (c) 2013 Bulb Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ManagedSocket;

#define BONJOUR_CLIENT_NAME @"clientName"
#define BONJOUR_DEVICE_ID @"deviceId"
#define BONJOUR_TIME_STAMP @"timeStamp"
#define BONJOUR_CLIENT_DATA @"clientData"

@interface BonjourPeer : NSObject

@property (strong, nonatomic) NSString* deviceId;
@property (strong, nonatomic) NSString*name;
@property (strong, nonatomic) ManagedSocket* socket;
@property (strong, nonatomic) NSDictionary* peerData;

-(void)sendMessage:(NSDictionary*)message;
-(void)sendFile:(NSData*)file;
-(void)sendFileAtPath:(NSString *)filePath;

-(id)initWithJSON:(NSDictionary *)message;
-(NSDictionary *)toJSON;
@end
