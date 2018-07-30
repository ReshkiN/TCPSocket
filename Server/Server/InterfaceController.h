//
//  InterfaceController.h
//  Server
//
//  Created by Dmitry Reshetnik on 7/30/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Server.h"

@interface InterfaceController : NSObject {
    Server *obj_server;
    __weak IBOutlet NSTextField *statusText;
}

- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;


@end
