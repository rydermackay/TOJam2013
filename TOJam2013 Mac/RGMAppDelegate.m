//
//  RGMAppDelegate.m
//  TOJam2013 Mac
//
//  Created by Ryder Mackay on 1/9/2014.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import "RGMAppDelegate.h"
#import "RGMScene.h"
#import "RGMGame.h"
#import "RGMInput.h"

@implementation RGMAppDelegate {
    RGMGame *_game;
}

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _game = [[RGMGame alloc] initWithMapName:@"Map"];;
    [_game start];
    
    RGMScene *scene = [RGMScene sceneWithSize:CGSizeMake(640, 480)];
    scene.game = _game;
    [_game addInput:(id<RGMInput>)scene toEntity:[_game entityForIdentifier:@"me"]];
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
