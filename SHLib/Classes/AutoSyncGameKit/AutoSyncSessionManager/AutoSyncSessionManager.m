/*
 *	AutoSyncSessionManager.m
 *	ImageViewer
 *	
 *	Created by BulbMBP5 on 03/12/2012.
 *	Copyright 2012 BulbMBP5. All rights reserved.
 */

#import "AutoSyncSessionManager.h"
#import "SessionPeer.h"

typedef NS_ENUM(NSInteger, AutoSyncMessageType) {

    MESSAGE_NEW_SESSION,
    MESSAGE_CONNECT,
    MESSAGE_SERVER_TO_CLIENT,
    MESSAGE_CLIENT_TO_SERVER

};

@interface AutoSyncSessionManager()

// Make any initialization of your class.
- (id) initSingleton;

@property (readonly) NSMutableDictionary* udidByPeerId;
@property (readonly) NSMutableDictionary* peersById;

@property (nonatomic, strong) NSMutableDictionary* previousMessageTimes;

@end

@implementation AutoSyncSessionManager

- (id) initSingleton
{
	if ((self = [super init]))
	{
        _udidByPeerId = [NSMutableDictionary new];
        _peersById = [NSMutableDictionary new];
        _peersArray = [NSMutableArray new];
        
        _previousMessageTimes = [NSMutableDictionary new];
        _isConnected = NO;
	}
	
	return self;
}

+ (AutoSyncSessionManager *) instance
{
	// Persistent instance.
	static AutoSyncSessionManager *_default = nil;
	
	// Small optimization to avoid wasting time after the
	// singleton being initialized.
	if (_default != nil)
	{
		return _default;
	}
	
	// Allocates once with Grand Central Dispatch (GCD) routine.
	// It's thread safe.
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
				  {
					  _default = [[AutoSyncSessionManager alloc] initSingleton];
				  });

	return _default;
}

- (void)setupSession
{
    [SessionHandler reloadSession];
    [self addObservers];
}

- (void)setupSessionWithDisplayName:(NSString *)displayName
{
    [SessionHandler reloadSessionWithDisplayName:displayName];
    [self addObservers];
}

- (void)teardownSession
{
    [self setIsConnected:NO];
    [SessionHandler tearDownSession];
    [self.peersArray removeAllObjects];
    [self removeObservers];
}

-(void)removeObservers {

    // Remove all Observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupAs:(GKSessionMode)mode withSessionId:(NSString*)sessionId andDisplayName:(NSString*)displayName {

    _mode = mode;
    [SessionHandler setUpSessionWithSessionID:sessionId displayName:displayName sessionMode:mode withDelegate:self];
    [SessionHandler setAvailable:YES];
    [self addObservers];
}

- (void) addObservers {

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

    // Register for notifications when the application leaves the background state
    // on its way to becoming the active application.
    [defaultCenter addObserver:self
                      selector:@selector(willEnterForeground)
                          name:UIApplicationWillEnterForegroundNotification
                        object:nil];

    // Register for notifications when when the application enters the background.
    [defaultCenter addObserver:self
                      selector:@selector(didEnterBackground)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:nil];

}

- (void)willEnterForeground {

    [SessionHandler reloadSession];
    
    if( self.mode == GKSessionModeServer) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SERVER_CONNECTIONS_CHANGED object:nil];
    }
}

- (void)didEnterBackground {

    [self setIsConnected:NO];
    [SessionHandler tearDownSession];
    [self.peersArray removeAllObjects];
}

- (NSString*)peerId {

    return [SessionHandler peerId];
}

- (void) postMessage:(NSDictionary*)message {
    
    NSMutableDictionary* mutableMessage = [message mutableCopy];

    [mutableMessage setObject:[self peerId] forKey:SENDER_PEER_ID];

    if( _mode == GKSessionModeClient) {

        [mutableMessage setObject:@(MESSAGE_CLIENT_TO_SERVER) forKey:@"type"];
    }
    else {
        
        [mutableMessage setObject:@(MESSAGE_SERVER_TO_CLIENT) forKey:@"type"];
    }
    
    [SessionHandler sendDataToAllPeers:mutableMessage];
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    
    if( _mode == GKSessionModeServer) {
                
        [SessionHandler acceptConnectionFromPeer:peerID];
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
    NSString* peerName = [SessionHandler getNameForPeer:peerID];

    [self setState:state];
    
    NSLog(@"Session Peer:%@ - DidChangeState: %d", session.displayName, state);

    if( state == GKPeerStateAvailable) {
        
        if( _mode == GKSessionModeClient) {
            
            [self setIsConnected:NO];

            _serverPeerID = peerID;
            [SessionHandler connectToPeer:_serverPeerID];
        }
    }
    else if( state == GKPeerStateConnected) {
        
        if( _mode == GKSessionModeClient && peerID == _serverPeerID) {
            
            if( [SessionHandler firstConnect]) {
                
                [SessionHandler sendData:@{ @"type":@(MESSAGE_NEW_SESSION) } toPeer:peerID];
                [SessionHandler setFirstConnect:NO];
            }
            
            [SessionHandler sendData:@{ @"type":@(MESSAGE_CONNECT) } toPeer:peerID];
            [self setIsConnected:YES];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Successfully connected" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];

        }
    }
    else if ( state == GKPeerStateDisconnected) {
        
        if( _mode == GKSessionModeServer) {
            
            [[[UIAlertView alloc] initWithTitle:@"Peer Disconnected" message:[NSString stringWithFormat:@"You have been disconnected from the Peer: %@", peerName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];

            NSString* udid = [_udidByPeerId objectForKey:peerID];
            
            if( udid) {
                
                SessionPeer* peer = [_peersById objectForKey:udid];
                
                [peer setConnected:NO];
                [_peersArray removeObject:peer];
            }
            
            if( [_peersArray count] == 0) {
                
                [self setIsConnected:NO];
            }
            
            [SessionHandler disconnectPeer:peerID];
        }
        else {
            
            if( _serverPeerID == peerID) {
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:@"You have been disconnected from the Master device." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
                
                [SessionHandler disconnectFromAllConnections];
                [self setIsConnected:NO];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SERVER_CONNECTIONS_CHANGED object:nil];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    
    //NSLog(@"Session Did Fail: %@", error);
    
    [SessionHandler tearDownSession];
    [SessionHandler reloadSession];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    
    //NSLog(@"Session Connection With Peer Failed: %@", error);
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sync Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if( buttonIndex == 1) {
        
        // -------
        // Retry
        // -------
        if( _mode == GKSessionModeClient) {
            
            [SessionHandler connectToPeer:_serverPeerID];
        }
    }
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    
    NSDictionary* dataDict = [SessionHandler readDataIntoDictionary:data];
    
    //NSLog(@"Message Received: %@", dataDict);
    
    AutoSyncMessageType messageType = [[dataDict objectForKey:@"type"] intValue];
        
    [_previousMessageTimes objectForKey:@(messageType)];
    
    if( _mode == GKSessionModeServer) {
    
        NSString* senderUDID = [dataDict objectForKey:@"udid"];
        
        if( senderUDID) {
            
            [_udidByPeerId setObject: senderUDID forKey: peer];
            
            SessionPeer* sessionPeer = [_peersById objectForKey:senderUDID];
            
            switch ( messageType) {
                    
                case MESSAGE_CONNECT: {
                                        
                    if( !sessionPeer) {
                        
                        sessionPeer = [[SessionPeer alloc] initWithPeerId:peer andPeerName:[SessionHandler getNameForPeer:peer]];
                        
                        [_peersById setObject:sessionPeer forKey:senderUDID];
                    }
                    
                    [sessionPeer setConnected:YES];
                    [sessionPeer setPeerId:peer];
                    [sessionPeer setPeerName:[SessionHandler getNameForPeer:peer]];
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Peer Connected" message:[NSString stringWithFormat:@"Peer Connected: %@", [sessionPeer peerName]]  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];

                    if( [_peersArray containsObject:sessionPeer]) {
                        
                        NSInteger index = [_peersArray indexOfObject:sessionPeer];
                        [_peersArray replaceObjectAtIndex:index withObject:sessionPeer];
                    }
                    else {
                        
                        [_peersArray addObject:sessionPeer];
                    }
                    
                    [self setIsConnected:YES];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:SERVER_CONNECTIONS_CHANGED object:nil];

                    break;
                }
                
                case MESSAGE_NEW_SESSION:
                    
                    if( sessionPeer) {
                        
                        [_peersById removeObjectForKey:senderUDID];
                        [_peersArray removeObject:sessionPeer];
                    }
                    
                    break;
                    
                case MESSAGE_CLIENT_TO_SERVER:
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_SERVER_DID_RECEIVE_MESSAGE_NOTIFICAITON object:self userInfo:dataDict];
                    break;
                    
                default:
                    break;
            }
        }
    }
    else // They are a client
    {
        switch ( messageType) {
         
            case MESSAGE_SERVER_TO_CLIENT:
                
                [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_CLIENT_DID_RECEIVE_MESSAGE_NOTIFICAITON object:self userInfo:dataDict];
                break;
                
            default:
                break;
        }
    }
}


@end
