//
//  InterfaceController.m
//  Server
//
//  Created by Dmitry Reshetnik on 7/30/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (IBAction)startServer:(id)sender {
    obj_server = [[Server alloc] init];
    [obj_server startServer:statusText];
    [obj_server start];
}

- (IBAction)stopServer:(id)sender {
    [obj_server stopServer];
    [obj_server cancel];
}


@end
