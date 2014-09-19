/*
 *	AutoSyncSessionManager.h
 *	Bulb Presenter
 *
 *  AutoSyncSessionManager is a Singleton class which allows the Automatic connection between iOS Devices through GameKit
 *  If 2 iOS devices setup with the same sessionId, they will automatically connect with each other.
 *
 *	Created by Dave Leverton on 03/12/2012.
 *	Copyright 2012-2013 Dave Leverton. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SessionHandler.h"
#import "NSString+Base64.h"

#define SESSION_SERVER_DID_RECEIVE_MESSAGE_NOTIFICAITON @"serverDidReceiveMessageNotification"
#define SESSION_CLIENT_DID_RECEIVE_MESSAGE_NOTIFICAITON @"clientDidReceiveMessageNotification"
#define SERVER_CONNECTIONS_CHANGED @"serverConnectionsChanged"
#define SLAVE_CLIENT_CONTACT_ADDED @"slaveClientDetailsAdded"
#define SENDER_PEER_ID @"peerId"

@interface AutoSyncSessionManager : NSObject <GKSessionDelegate, UIAlertViewDelegate>
{
@private
    NSString* _serverPeerID;
}

@property (readonly) GKSessionMode mode;
@property (readonly) NSMutableArray* peersArray;

@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) GKPeerConnectionState state;

/**
 * Get the singleton instance
 */
+ (AutoSyncSessionManager *) instance;

/**
* Setup this instance either as a Client, Peer or Server with a specific Session ID and display name
* If 2 devices on the same Network (Bluetooth or WiFi) call this function with the same Session ID they will try to Auto Connect!
* One Device must be a Server if all other devices are Clients. If all devices are Peers then that is fine, not need for a server.
*
* @param mode A GKSessionMode which is passed to GameKit, either GKSessionModeServer, GKSessionModePeer or GKSessionModeClient
* @param sessionId A NSString to let GameKit know which session to try and join, can be anything but should be the same as the server or clients that you're trying to connect to
* @param displayName A NSString which is passed around GameKit as the display name for a peer
*/
- (void) setupAs:(GKSessionMode)mode withSessionId:(NSString*)sessionId andDisplayName:(NSString*)displayName;

/**
* Post a message as an NSDictionary to all connected Peers, if:
* - GKSessionMode is Server it will send to all Clients
* - GKSessionMode is Peer it will send to all other Peers
* - GKSessionMode is Client it will send to the Server
*
* @param message An NSDictionary which is posted to GameKit. The dictionary has
*/
- (void) postMessage:(NSDictionary*)message;

/**
* Teardown the session (Stop broadcasting + disconnect)
*/
- (void) teardownSession;

/**
* Setup a session with default or previous settings (Can be used as a reload)
*/
- (void) setupSession;

/**
* Setup a session with defaults or previous settings, with a new Display Name (Used for changing usernames while connected)
*/
- (void) setupSessionWithDisplayName:(NSString *)displayName;

@end