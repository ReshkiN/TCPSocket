//
//  Client.m
//  Client
//
//  Created by Dmitry Reshetnik on 7/31/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import "Client.h"

@implementation Client

- (void)connectToServer:(NSTextField *)textField {
    targetText = textField;
    CFSocketContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    obj_client = CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, TCPServerCallBackHandler, &context);
    int socket_reuse_flag = 1;
    setsockopt(CFSocketGetNative(obj_client), SOL_SOCKET, SO_REUSEADDR, &socket_reuse_flag, sizeof(socket_reuse_flag));
    setsockopt(CFSocketGetNative(obj_client), SOL_SOCKET, SO_REUSEPORT, &socket_reuse_flag, sizeof(socket_reuse_flag));
    struct sockaddr_in sock_addr;
    memset(&sock_addr, 0, sizeof(sock_addr));
    sock_addr.sin_len = sizeof(sock_addr);
    sock_addr.sin_family = AF_INET;
    sock_addr.sin_port = htons(3345);
    inet_pton(AF_INET, "127.0.0.1", &sock_addr.sin_addr);
    CFDataRef dataReference = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sock_addr, sizeof(sock_addr));
    if (CFSocketConnectToAddress(obj_client, dataReference, -1) == kCFSocketSuccess) {
        [targetText setStringValue:@"Connected\n"];
    }
    CFRelease(dataReference);
}

- (void)disconnectFromServer {
    CFSocketInvalidate(obj_client);
    CFRelease(obj_client);
    [targetText setStringValue:[targetText.stringValue stringByAppendingString:@"Disconnected\n"]];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)processConnectedSocket:(CFSocketNativeHandle)handle {
    messageArray = [[NSMutableArray alloc] init];
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, handle, &readStream, &writeStream);
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    input = (__bridge NSInputStream *)(readStream);
    output = (__bridge NSOutputStream *)(writeStream);
    [input setDelegate:self];
    [output setDelegate:self];
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [input open];
    [output open];
}


- (void)runLoop {
    CFRunLoopSourceRef loop = CFSocketCreateRunLoopSource(kCFAllocatorDefault, obj_client, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopDefaultMode);
    CFRelease(loop);
    CFRunLoopRun();
}

- (void)readFromStream:(NSInputStream *)stream {
    uint8_t buffer[1024];
    long receive_length = 0;
    receive_length = [stream read:buffer maxLength:1024];
    if (receive_length > 0) {
        NSString *data = [[NSString alloc] initWithBytes:buffer length:receive_length encoding:NSUTF8StringEncoding];
        [targetText setStringValue:[NSString stringWithFormat:@"%@%@",[targetText.stringValue stringByAppendingString:data],@"\n"]];
        //NSData *receiveData = [NSData dataWithBytes:buffer length:receive_length];
        //[messageArray insertObject:receiveData atIndex:0];
    }
}


- (void)writeToStream:(NSOutputStream *)stream {
    if ([messageArray count] > 0) {
        NSData *data = [messageArray lastObject];
        uint8_t *dataBytes = (uint8_t *)[data bytes];
        dataBytes += currentOffset;
        NSUInteger length = [data length] - currentOffset > 1024 ? 1024 : [data length] - currentOffset;
        NSUInteger sentLength = [stream write:dataBytes maxLength:length];
        if (sentLength > 0) {
            currentOffset += sentLength;
            if (currentOffset == [data length]) {
                [messageArray removeLastObject];
                currentOffset = 0;
            }
        }
    }
}


- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            [self writeToStream:(NSOutputStream *)stream];
        }
            break;
            
        case NSStreamEventHasBytesAvailable: {
            [self readFromStream:(NSInputStream *)stream];
        }
            break;
            
        case NSStreamEventEndEncountered: {
            NSLog(@"Stream is end");
        }
            break;
            
        case NSStreamEventErrorOccurred: {
            NSError *error = [stream streamError];
            NSLog(@"%li: %@", (long)[error code], [error localizedDescription]);
        }
            break;
            
        default:
            NSLog(@"Unprocessed event %lu", (unsigned long)eventCode);
            break;
    }
}


void TCPServerCallBackHandler(CFSocketRef obj, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    Client *obj_client_pointer = (__bridge Client *)info;
    switch (type) {
        case kCFSocketConnectCallBack: {
            if (data) {
                [obj_client_pointer disconnectFromServer];
            } else {
                CFSocketNativeHandle handle = CFSocketGetNative(obj);
                CFSocketSetSocketFlags(obj, 0);
                CFSocketInvalidate(obj);
                CFRelease(obj);
                [obj_client_pointer processConnectedSocket:handle];
            }
        }
            break;
            
        default:
            break;
    }
}


@end
