//
//  RGMPrey.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMPrey.h"
#import "RGMPredator.h"

@implementation RGMPrey {
    BOOL _invincible;
}

- (CGSize)size
{
    return CGSizeMake(RGMTileSize * 0.5, RGMTileSize * 0.5);
}

- (void)jump
{
    if (self.isCaptured) {
        // roll to escape
        if (!arc4random_uniform(10)){
            [self.predator dropPrey];
        }
    } else {
        [super jump];
    }
}

- (void)updateForDuration:(NSTimeInterval)interval
{
    if (self.isCaptured) {
        return;
    }
    
    [super updateForDuration:interval];
}

- (void)setCaptured:(BOOL)captured
{
    if (_captured == captured) {
        return;
    }
    
    _captured = captured;
    
    self.velocity = CGPointZero;
    
    if (!_captured) {
        self.velocity = CGPointMake((CGFloat)arc4random_uniform(100) - 50.0, 0);
        self.canJump = YES;
        [self jump];
        self.invincible = YES;
    }
}

- (BOOL)canJump
{
    if (self.isCaptured) {
        return NO;
    }
    
    return [super canJump];
}

@end
