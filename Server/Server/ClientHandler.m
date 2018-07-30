//
//  ClientHandler.m
//  Server
//
//  Created by Dmitry Reshetnik on 7/30/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import "ClientHandler.h"

@implementation ClientHandler

- (void)runLoop {
    messageArray = [[NSMutableArray alloc] init];
    input = (__bridge NSInputStream *)(readStream);
    output = (__bridge NSOutputStream *)(writeStream);
    [input setDelegate:self];
    [output setDelegate:self];
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [input open];
    [output open];
    CFRunLoopRun();
}


- (void)readFromStream:(NSInputStream *)stream {
    uint8_t buffer[1024];
    long receive_length = 0;
    receive_length = [stream read:buffer maxLength:1024];
    if (receive_length > 0) {
        NSData *receiveData = [NSData dataWithBytes:buffer length:receive_length];
        [messageArray insertObject:receiveData atIndex:0];
        NSString *data = [[NSString alloc] initWithBytes:buffer length:receive_length encoding:NSUTF8StringEncoding];
        [targetText setStringValue:[NSString stringWithFormat:@"%@%@",[targetText.stringValue stringByAppendingString:data],@"\n"]];
        NSString *empty = @"";
        [output write:[[empty dataUsingEncoding:NSUTF8StringEncoding] bytes] maxLength:1];
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

@end
