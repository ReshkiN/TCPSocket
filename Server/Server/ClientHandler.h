//
//  ClientHandler.h
//  Server
//
//  Created by Dmitry Reshetnik on 7/30/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface ClientHandler : NSThread {
@public
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSTextField *targetText;
@private
    __strong NSInputStream *input;
    __strong NSOutputStream *output;
    NSUInteger currentOffset;
    NSMutableArray *messageArray;
}

- (void)runLoop;
- (void)readFromStream:(NSInputStream *)stream;
- (void)writeToStream:(NSOutputStream *)stream;


@end
