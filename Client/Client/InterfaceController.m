//
//  InterfaceController.m
//  Client
//
//  Created by Dmitry Reshetnik on 7/31/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (IBAction)connectToServer:(id)sender {
    obj_client = [[Client alloc] init];
    [obj_client connectToServer:serverResponseText];
    [obj_client start];
}

- (IBAction)sendMessage:(id)sender {
    NSData *data = [[userDataText stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    [obj_client -> messageArray insertObject:data atIndex:0];
    NSString *empty = @"";
    [obj_client -> output write:[[empty dataUsingEncoding:NSUTF8StringEncoding] bytes] maxLength:1];
    
}

- (IBAction)disconnectFromServer:(id)sender {
    [obj_client disconnectFromServer];
    [obj_client cancel];
}


@end
