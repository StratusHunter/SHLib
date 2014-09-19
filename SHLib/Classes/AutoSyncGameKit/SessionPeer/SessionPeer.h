//
//  SessionPeer.h
//  AudiTraining
//
//  Created by BulbMBP5 on 19/09/2012.
//  Copyright (c) 2012 BulbMBP5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionHandler.h"

/**
* A class used by SessionHandler and AutoSyncSessionManager to handle Peers, this is used to make sure when a peer disconnects and reconnects it is handled as the same peer within the system
*/
@interface SessionPeer : NSObject

- (id)initWithPeerId:(NSString*)peerId andPeerName:(NSString*)peerName;

@property (nonatomic) NSString* peerId;
@property (nonatomic) NSString* peerName;

@property (nonatomic) bool connected;

@end
