//
// Created by Dave Leverton on 04/06/2013.
// Copyright (c) 2013 BulbMBP5. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ManagedSocket.h"

#define NO_TIMEOUT -1
// Tags 10x always get done
#define SIZE_TAG 101
#define TYPE_TAG 102
// Tags 20x are MESSAGE_TYPE_FILE
#define FILENAME_TAG 201
#define FILE_TAG 202
#define PACKETED_FILE_TAG 203

// Tags 30x are MESSAGE_TYPE_DICTIONARY
#define DICTIONARY_TAG 301

#define CHUNK (1024 * 32) //32kb

@interface ManagedSocket () {
    
    BOOL _readQueued;
    BOOL _writingQueued;
}

@property(assign) NSInteger dataSize;
@property(assign) NSInteger transferredDataSize;

@property(nonatomic, strong) NSMutableData *recievedData; //Should only be used for messages as files could get huge!
@property(nonatomic, strong) NSFileHandle *fileHandle;

@property(nonatomic, strong) NSError* error; // Any error recieved stored in here

@end

@implementation ManagedSocket

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.connectedSockets = [NSMutableArray new];
        _readQueued = NO;
        _writingQueued = NO;
        self.error = nil;
    }
    
    return self;
}


- (id)initWithDelegate:(id <ManagedSocketDelegate>)delegate {
    
    self = [self init];
    
    if (self) {
        
        self.delegate = delegate;
        
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return self;
}

- (id)initWithSocket:(GCDAsyncSocket *)socket delegate:(id <ManagedSocketDelegate>)delegate {
    
    self = [self init];
    
    if (self) {
        
        self.delegate = delegate;
        self.socket = socket;
        [self.socket setDelegate:self];
    }
    
    return self;
}


- (void)connectToHost:(NSString *)host onPort:(uint16_t)port {
    
    // Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
    //
    // If your server is also using GCDAsyncSocket then you don't have to worry about it,
    // as the socket automatically handles both protocols for you transparently;
    NSLog(@"Attempting connection to %@:%d", host, port);
    
    NSError *err = nil;
    if ([self.socket connectToHost:host onPort:port withTimeout:10 error:&err]) {
        
        NSLog(@"Success");
    }
    else {
        
        NSLog(@"Unable to connect: %@", err);
    }
}

- (NSUInteger)chunkedDataSizeForCurrentFile {
    
    // Pick a static filesize for each chunk, as this could become very large if just 1% chunks
    NSUInteger chunkSize = CHUNK;
    NSUInteger remainingFile = self.dataSize - self.transferredDataSize;
    
    if (chunkSize > remainingFile) {
        
        chunkSize = remainingFile;
    }
    
    return chunkSize;
}

-(void)startReadingData {
    
    if( !_readQueued) {
        
        [self.socket readDataToLength:sizeof(NSUInteger) withTimeout:NO_TIMEOUT tag:SIZE_TAG];
        _readQueued = YES;
    }
}

- (void)sendFileData:(NSData *)fileData {
    
    if (!_writingQueued) {
        
        _writingQueued = YES;
        
        NSUInteger size = fileData.length;
        NSInteger messageType = MESSAGE_TYPE_FILE;
        NSLog(@"Send File: %lubytes", (unsigned long)size);
        
        [self.socket writeData:[NSData dataWithBytes:&size length:sizeof(size)] withTimeout:NO_TIMEOUT tag:SIZE_TAG];
        [self.socket writeData:[NSData dataWithBytes:&messageType length:sizeof(messageType)] withTimeout:NO_TIMEOUT tag:TYPE_TAG];
        [self.socket writeData:fileData withTimeout:NO_TIMEOUT tag:FILE_TAG];
        
        _writingQueued = NO;
    }
}

- (void)sendMessage:(NSDictionary *)message {
    
    if (!_writingQueued) {
        
        _writingQueued = YES;
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:message options:kNilOptions error:nil];
        
        int32_t size = (int32_t)data.length;
        int32_t messageType = MESSAGE_TYPE_DICTIONARY;
        
        if( size > 0) {
            
            NSLog(@"Send Message: %@", message);
            [self.socket writeData:[NSData dataWithBytes:&size length:sizeof(size)] withTimeout:NO_TIMEOUT tag:SIZE_TAG];
            [self.socket writeData:[NSData dataWithBytes:&messageType length:sizeof(messageType)] withTimeout:NO_TIMEOUT tag:TYPE_TAG];
            [self.socket writeData:data withTimeout:NO_TIMEOUT tag:DICTIONARY_TAG];
        }
        
        _writingQueued = NO;
    }
}

- (void)stop {
    
    [self closeStream];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.socket disconnect];
    self.recievedData = [NSMutableData new];
    self.transferredDataSize = 0;
    
    for( ManagedSocket *socket in self.connectedSockets) {
        
        [socket stop];
    }
    
    [self.connectedSockets removeAllObjects];
    
    NSLog(@"Socket Stop");
    if ([self.delegate respondsToSelector:@selector(managedSocketDidDisconnect:withError:)]) {
        [self.delegate managedSocketDidDisconnect:self withError:self.error];
    }
}

- (void)sendFileAtPath:(NSString *)filePath {
    
    if (!_writingQueued) {
        
        _writingQueued = YES;
        
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSUInteger size = [fileDictionary fileSize];
        NSInteger messageType = MESSAGE_TYPE_FILE;
        NSLog(@"Send File: %lubytes", (unsigned long)size);
        
        self.dataSize = size;
        self.transferredDataSize = 0;
        
        [self.socket writeData:[NSData dataWithBytes:&size length:sizeof(size)] withTimeout:NO_TIMEOUT tag:SIZE_TAG];
        [self.socket writeData:[NSData dataWithBytes:&messageType length:sizeof(messageType)] withTimeout:NO_TIMEOUT tag:TYPE_TAG];
        
        self.fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        [self streamFile];
    }
}

- (void)streamFile {
    
    if (self.fileHandle != nil) {
        
        NSUInteger maxLength = [self chunkedDataSizeForCurrentFile];
        
        [self.fileHandle seekToFileOffset:self.transferredDataSize];
        NSData *data = [self.fileHandle readDataOfLength:maxLength];
        
        //NSLog(@"Stream Data: %lu", data.length);

        if (data.length > 0) {
            
            [self.socket writeData:data withTimeout:NO_TIMEOUT tag:PACKETED_FILE_TAG];
        }
        else {
            
            [self closeStream];
        }
    }
}

-(void)closeStream {
    
    _writingQueued = NO;
    
    if (self.fileHandle != nil) {
        
        [self.fileHandle closeFile];
        self.fileHandle = nil;
    }
}

#pragma mark - Async
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    //NSLog(@"Did Write Data: %lu", tag);
    
    if (tag == PACKETED_FILE_TAG) {
        
        self.transferredDataSize += [self chunkedDataSizeForCurrentFile];
        [self streamFile];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    NSLog(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
    
    [self.delegate managedSocket:self didConnectToHost:host onPort:port];
    
    if (sock == self.socket) {
        // Always start by reading a Size item ... SIZE is basically a message saying "DATA COMING! THIS SIZE!"
        [self startReadingData];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    NSLog(@"Socket:didAcceptNewSocket");
    
    ManagedSocket *managedSocket = [[ManagedSocket alloc] initWithSocket:newSocket delegate:self.delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedSocketDisconnect:) name:DISCONNECT_MESSAGE object:managedSocket];
    [self.connectedSockets addObject:managedSocket];
    
    if ([self.delegate respondsToSelector:@selector(managedSocketConnectedSocketsDidChange:)]) {
        [self.delegate managedSocketConnectedSocketsDidChange:self];
    }
    if ([self.delegate respondsToSelector:@selector(managedSocket:didAcceptNewSocket:)]) {
        [self.delegate managedSocket:self didAcceptNewSocket:managedSocket];
    }
    
    [managedSocket startReadingData];
}

- (void)managedSocketDisconnect:(NSNotification *)notification {
    
    NSLog(@"Managed Socket Disconnect");
    ManagedSocket *socket = notification.object;
    
    if([self.connectedSockets containsObject:socket]) {
        
        [self.connectedSockets removeObject:socket];
        
        if ([self.delegate respondsToSelector:@selector(managedSocketConnectedSocketsDidChange:)]) {
            
            [self.delegate managedSocketConnectedSocketsDidChange:self];
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    NSLog(@"SocketDidDisconnect:WithError: %@", err);
    
    if( sock == self.socket) {
        
        self.error = err;
        [[NSNotificationCenter defaultCenter] postNotificationName:DISCONNECT_MESSAGE object:self];
        [self stop];
        self.socket = nil;
    }
    else {
        
        NSUInteger indexToRemove = NSNotFound;
        for( ManagedSocket *managedSocket in self.connectedSockets) {
            
            if( managedSocket.socket == sock) {
                
                [managedSocket stop];
                indexToRemove = [self.connectedSockets indexOfObject:managedSocket];
            }
        }
        
        if( indexToRemove != NSNotFound) {
            
            [self.connectedSockets removeObjectAtIndex:indexToRemove];
            if ([self.delegate respondsToSelector:@selector(managedSocketConnectedSocketsDidChange:)]) {
                [self.delegate managedSocketConnectedSocketsDidChange:self];
            }
        }
    }
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    
    NSLog(@"socketDidCloseReadStream");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    _readQueued = NO;
    
    //NSLog(@"Did Read Data: %lu", tag);
    
    if (sock != self.socket) {
        
        // This is not the socket we are looking for
        return;
    }
    
    if (tag == SIZE_TAG) {
        
        // Always the first message, so clear all previous data
        self.recievedData = [NSMutableData new];
        self.transferredDataSize = 0;
        
        // We have the SIZE of the message or file, now we need to determine which one of those it is!
        int32_t size;
        [data getBytes:&size length:sizeof(size)];
        NSLog(@"File Length: %d - SizeOf: %ld", size, sizeof(int32_t));
        
        self.dataSize = size;
        [sock readDataToLength:sizeof(int32_t) withTimeout:NO_TIMEOUT tag:TYPE_TAG];
    }
    else if (tag == TYPE_TAG) {
        
        int32_t type;
        [data getBytes:&type length:sizeof(int32_t)];
        NSLog(@"Message Type: %d", type);
        
        switch (type) {
                
            case MESSAGE_TYPE_DICTIONARY:
                [sock readDataToLength:[self chunkedDataSizeForCurrentFile] withTimeout:NO_TIMEOUT tag:DICTIONARY_TAG];
                break;
                
            case MESSAGE_TYPE_FILE:
                [sock readDataToLength:[self chunkedDataSizeForCurrentFile] withTimeout:NO_TIMEOUT tag:FILE_TAG];
                break;
            default:
                break;
        }
    }
    else if (tag == FILE_TAG || tag == PACKETED_FILE_TAG) {
        
        self.transferredDataSize += [data length];
        //NSLog(@"Transferred Data: %lu", self.transferredDataSize);

        if ([self.delegate respondsToSelector:@selector(managedSocket:downloadDidProgress:expectedSize:)]) {
            
            [self.delegate managedSocket:self downloadDidProgress:self.transferredDataSize expectedSize:self.dataSize];
        }
        
        if ([self.delegate respondsToSelector:@selector(managedSocket:didReceivePartialFile:)]) {
            
            [self.delegate managedSocket:self didReceivePartialFile:data];
        }
        
        if (self.transferredDataSize >= self.dataSize) {
            
            if ([self.delegate respondsToSelector:@selector(managedSocket:didReceiveFile:)]) {
                [self.delegate managedSocket:self didReceiveFile:self.transferredDataSize];
            }
            
            [self startReadingData];
        }
        else {
            
            [sock readDataToLength:[self chunkedDataSizeForCurrentFile] withTimeout:NO_TIMEOUT tag:tag];
        }
    }
    else if (tag == DICTIONARY_TAG) {
        
        [self.recievedData appendData:data];
        self.transferredDataSize += [data length];
        
        if ([self.delegate respondsToSelector:@selector(managedSocket:downloadDidProgress:expectedSize:)]) {
            
            [self.delegate managedSocket:self downloadDidProgress:self.transferredDataSize expectedSize:self.dataSize];
        }
        
        if (self.transferredDataSize >= self.dataSize) {
            
            NSDictionary *message = [NSJSONSerialization JSONObjectWithData:self.recievedData options:kNilOptions error:nil];
            
            if ([self.delegate respondsToSelector:@selector(managedSocket:didReceiveMessage:)]) {
                [self.delegate managedSocket:self didReceiveMessage:message];
            }
            
            [self startReadingData];
        }
        else {
            
            [sock readDataToLength:[self chunkedDataSizeForCurrentFile] withTimeout:NO_TIMEOUT tag:DICTIONARY_TAG];
        }
        
    }
}

@end