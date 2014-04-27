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

@interface RGMAppDelegate () <NSWindowDelegate>
@property (nonatomic) RGMGame *game;
@end

@implementation RGMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.game = [[RGMGame alloc] initWithMapName:@"Map"];
    [self.game start];
    
    RGMScene *scene = [RGMScene sceneWithSize:CGSizeMake(320, 240)];
    scene.game = self.game;
    [self.game addInput:(id<RGMInput>)scene toEntity:[_game entityForIdentifier:@"me"]];
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];
    [self.window setContentSize:scene.size];
    self.window.contentAspectRatio = scene.size;
    [self zoomWindowByFactor:2 animate:NO];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)increaseSize:(id)sender {
    [self zoomWindowByFactor:2 animate:YES];
}

- (IBAction)decreaseSize:(id)sender {
    [self zoomWindowByFactor:0.5 animate:YES];
}

- (NSRect)windowFrameWithZoomFactor:(CGFloat)zoomFactor {
    NSRect frame = self.window.frame;
    NSSize contentSize = [self.window.contentView bounds].size;
    frame.size.width += (zoomFactor - 1) * contentSize.width;
    frame.size.height += (zoomFactor - 1) * contentSize.height;
    frame.origin.y += NSHeight(self.window.frame) - NSHeight(frame);
    frame = NSRectFittingRect(self.window.screen.frame, frame);
    
    return frame;
}

static inline NSRect NSRectFittingRect(NSRect bounds, NSRect frame) {
    if (NSContainsRect(bounds, frame) && !NSIntersectsRect(bounds, frame)) {
        return frame;
    }
    if (NSMinX(frame) < NSMinX(bounds)) {
        frame.origin.x += NSMinX(bounds) - NSMinX(frame);
    }
    if (NSMaxX(frame) > NSMaxX(bounds)) {
        frame.origin.x -= NSMaxX(frame) - NSMaxX(bounds);
    }
    if (NSMinY(frame) < NSMinY(bounds)) {
        frame.origin.y += NSMinY(bounds) - NSMinY(frame);
    }
    if (NSMaxY(frame) > NSMaxY(bounds)) {
        frame.origin.y -= NSMaxY(frame) - NSMaxY(bounds);
    }
    return frame;
}

- (void)zoomWindowByFactor:(CGFloat)zoomFactor animate:(BOOL)animate {
    NSRect frame = [self windowFrameWithZoomFactor:zoomFactor];
    [self.window setFrame:frame display:YES animate:animate];
}

- (BOOL)canResizeWindowWithFrame:(NSRect)frame {
    NSRect screenFrame = self.window.screen.frame;
    return  NSWidth(frame) <= NSWidth(screenFrame) && NSHeight(frame) <= NSHeight(screenFrame);
}

#pragma mark - Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(increaseSize:)) {
        return [self canResizeWindowWithFrame:[self windowFrameWithZoomFactor:2]];
    } else if (menuItem.action == @selector(decreaseSize:)) {
        return [self canResizeWindowWithFrame:[self windowFrameWithZoomFactor:0.5]];
    }
    return YES;
}

@end
