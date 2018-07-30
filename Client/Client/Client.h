//
//  Client.h
//  Client
//
//  Created by Dmitry Reshetnik on 7/31/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@interface Client : NSThread {
    CFSocketRef obj_client;
    NSTextField *targetText;
@private
    NSUInteger currentOffset;
@public
    __strong NSInputStream *input;
    __strong NSOutputStream *output;
    NSMutableArray *messageArray;
}

- (void)connectToServer:(NSTextField *)textField;
- (void)disconnectFromServer;
- (void)processConnectedSocket:(CFSocketNativeHandle)handle;
- (void)readFromStream:(NSInputStream *)stream;
- (void)writeToStream:(NSOutputStream *)stream;
- (void)runLoop;


@end
