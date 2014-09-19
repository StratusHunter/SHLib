//
//  SessionPeer.m
//  AudiTraining
//
//  Created by BulbMBP5 on 19/09/2012.
//  Copyright (c) 2012 BulbMBP5. All rights reserved.
//

#import "SessionPeer.h"

@implementation SessionPeer

- (id)initWithPeerId:(NSString*)peerId andPeerName:(NSString*)peerName {
    
    self = [self init];
    
    if( self) {
        
        _peerId = peerId;
        _peerName = peerName;

        _connected = true;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    
    SessionPeer* peer = (SessionPeer*)object;
    
    return (_peerId == [peer peerId]) && ( _peerName == [peer peerName] );
}

@end
