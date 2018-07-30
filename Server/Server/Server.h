//
//  Server.h
//  Server
//
//  Created by Dmitry Reshetnik on 7/30/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ClientHandler.h"
#include <sys/socket.h>
#include <netinet/in.h>

@interface Server : NSThread {
    CFSocketRef obj_server;
    NSTextField *targetText;
}

- (void)runLoop;
- (void)startServer:(NSTextField *)status;
- (void)stopServer;


@end
