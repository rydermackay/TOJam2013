//
//  RGMAppDelegate.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMAppDelegate.h"
#import "RGMMenuViewController.h"

@implementation RGMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationChanged:) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
    
    return YES;
}

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

- (RGMMenuViewController *)menuViewController
{
    return (RGMMenuViewController *)self.window.rootViewController;
}

- (void)authenticationChanged:(NSNotification *)note
{
    if ([[GKLocalPlayer localPlayer] isAuthenticated]) {
        [[GKMatchmaker sharedMatchmaker] setInviteHandler:^(GKInvite *invite, NSArray *playersToInvite) {
            
            GKMatchmakerViewController *controller;
            
            if (invite) {
                controller = [[GKMatchmakerViewController alloc] initWithInvite:invite];
            } else if (playersToInvite.count > 0) {
                GKMatchRequest *request = [[GKMatchRequest alloc] init];
                request.minPlayers = 2;
                request.defaultNumberOfPlayers = request.minPlayers;
                request.maxPlayers = 4;
                request.playersToInvite = playersToInvite;
                controller = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
            }
            
            if (controller) {
                [[self menuViewController] presentMatchmakerViewController:controller];
            }
        }];
    }
}

@end
