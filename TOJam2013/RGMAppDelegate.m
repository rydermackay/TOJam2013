//
//  RGMAppDelegate.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMAppDelegate.h"

@implementation RGMAppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *controller, NSError *error) {
        if (controller) {
            [[[application keyWindow] rootViewController] presentViewController:controller animated:YES completion:nil];
        } else if (error) {
            [[[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

@end
