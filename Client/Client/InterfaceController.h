//
//  InterfaceController.h
//  Client
//
//  Created by Dmitry Reshetnik on 7/31/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Client.h"

@interface InterfaceController : NSObject {
    Client *obj_client;
    __weak IBOutlet NSTextField *userDataText;
    __weak IBOutlet NSTextField *serverResponseText;
}

- (IBAction)connectToServer:(id)sender;
- (IBAction)disconnectFromServer:(id)sender;
- (IBAction)sendMessage:(id)sender;


@end
