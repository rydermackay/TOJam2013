//
//  RGMMenuViewController.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMMenuViewController.h"
#import "RGMMainViewController.h"
#import <GameKit/GameKit.h>

static NSString * const kSingleplayerIdentifier = @"single";
static NSString * const kMultiplayerIdentifier = @"multi";

@interface RGMMenuViewController ()

- (IBAction)multiplayer:(id)sender;

@end



@implementation RGMMenuViewController {
    GKMatch *_match;
}

- (void)presentMatchmakerViewController:(GKMatchmakerViewController *)controller
{
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RGMMainViewController *controller = segue.destinationViewController;
    NSParameterAssert([controller isKindOfClass:[RGMMainViewController class]]);
    
    if ([segue.identifier isEqualToString:kMultiplayerIdentifier]) {
        controller.match = _match;
        _match = nil;
    }
}

- (IBAction)multiplayer:(id)sender
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.defaultNumberOfPlayers = request.minPlayers;
    request.maxPlayers = 4;
    
    GKMatchmakerViewController *controller = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    controller.matchmakerDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - GKMatchmakerViewControllerDelegate

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self rgm_presentError:error];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    _match = match;
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self performSegueWithIdentifier:kMultiplayerIdentifier sender:nil];
                             }];
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
