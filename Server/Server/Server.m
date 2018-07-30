//
//  Server.m
//  Server
//
//  Created by Dmitry Reshetnik on 7/30/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import "Server.h"

@implementation Server

- (void)startServer:(NSTextField *)status {
    targetText = status;
    CFSocketContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    obj_server = CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, TCPServerCallBackHandler, &context);
    int so_reuse_flag = 1;
    setsockopt(CFSocketGetNative(obj_server), SOL_SOCKET, SO_REUSEADDR, &so_reuse_flag, sizeof(so_reuse_flag));
    setsockopt(CFSocketGetNative(obj_server), SOL_SOCKET, SO_REUSEPORT, &so_reuse_flag, sizeof(so_reuse_flag));
    struct sockaddr_in sock_addr;
    memset(&sock_addr, 0, sizeof(sock_addr));
    sock_addr.sin_len = sizeof(sock_addr);
    sock_addr.sin_family = AF_INET;
    sock_addr.sin_port = htons(3345);
    sock_addr.sin_addr.s_addr = INADDR_ANY;
    CFDataRef dataReference = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sock_addr, sizeof(sock_addr));
    CFSocketSetAddress(obj_server, dataReference);
    [targetText setStringValue:@"Server is start running\n"];
    CFRelease(dataReference);
}


- (void)stopServer {
    CFSocketInvalidate(obj_server);
    CFRelease(obj_server);
    [targetText setStringValue:[targetText.stringValue stringByAppendingString:@"Server is stop running\n"]];
    CFRunLoopStop(CFRunLoopGetCurrent());
}


- (void)runLoop {
    CFRunLoopSourceRef loop = CFSocketCreateRunLoopSource(kCFAllocatorDefault, obj_server, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopDefaultMode);
    CFRelease(loop);
    NSLog(@"Run Server");
    CFRunLoopRun();
}


void TCPServerCallBackHandler(CFSocketRef obj, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    switch (type) {
        case kCFSocketAcceptCallBack: {
            ClientHandler *obj_client = [[ClientHandler alloc] init];
            CFStreamCreatePairWithSocket(kCFAllocatorDefault, *(CFSocketNativeHandle *)data, &obj_client->readStream, &obj_client->writeStream);
            CFReadStreamSetProperty(obj_client->readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(obj_client->writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            [obj_client start];
        }
            break;
            
        default:
            break;
    }
}


@end
