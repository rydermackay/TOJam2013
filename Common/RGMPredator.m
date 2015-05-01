//
//  RGMPredator.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMPredator.h"
#import "RGMPrey.h"
#import "RGMMultiplayerGame.h"
#import "RGMEvent.h"
#import "RGMBall.h"

static NSTimeInterval captivePreyDuration = 5;

@implementation RGMPredator {
    __weak RGMPrey *_captivePrey;
    BOOL _canFire;
    __weak RGMEntity *_fireball;
}

- (CGSize)size
{
    return CGSizeMake(RGMTileSize, RGMTileSize * 1.5);
}

- (void)fire {
    if (!_fireball) {
        _canFire = NO;
        _fireball = [self.game createEntity:[RGMBall class] identifier:@"fire"];
        _fireball.x = self.x;
        _fireball.y = self.y;
    }
}

- (void)capturePrey:(RGMPrey *)prey
{
    if ([_captivePrey isEqual:prey]) {
        return;
    }
    
    if (prey.invincible) {
        return;
    }
    
    [self dropPrey];
    _captivePrey = prey;
    _captivePrey.captured = YES;
    _captivePrey.predator = self;
    
    // use notifications idiot
    if ([self.game isKindOfClass:[RGMMultiplayerGame class]]) {
        RGMMultiplayerGame *game = (RGMMultiplayerGame *)self.game;
        RGMEvent *event = [RGMEvent eventWithType:RGMEventTypeCapture userInfo:@{RGMEventPredatorKey : self.identifier, RGMEventPreyKey : prey.identifier }];
        [game enqueueEventForSending:event];
    }
    
    [self performSelector:@selector(dropPrey) withObject:nil afterDelay:captivePreyDuration inModes:@[NSRunLoopCommonModes]];
}

- (void)dropPrey
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dropPrey) object:nil];
    
    if (_captivePrey) {
        if ([self.game isKindOfClass:[RGMMultiplayerGame class]]) {
            RGMMultiplayerGame *game = (RGMMultiplayerGame *)self.game;
            RGMEvent *event = [RGMEvent eventWithType:RGMEventTypeEscape userInfo:@{RGMEventPredatorKey : self.identifier, RGMEventPreyKey : _captivePrey.identifier }];
            [game enqueueEventForSending:event];
        }
    }
    
    _captivePrey.captured = NO;
    _captivePrey = nil;
}

- (void)setY:(NSInteger)y
{
    [super setY:y];
    _captivePrey.y = CGRectGetMaxY(self.frame);
}

- (void)setX:(NSInteger)x
{
    [super setX:x];
    _captivePrey.x = self.x + (self.size.width - _captivePrey.size.width) * 0.5f;
}

- (BOOL)hitTestWithEntity:(RGMEntity *)entity
{
    if ([entity isKindOfClass:[RGMPrey class]]) {
        if (CGRectIntersectsRect(self.frame, entity.frame)) {
            [self capturePrey:(RGMPrey *)entity];
            return YES;
        }
    }
    
    return NO;
}

- (void)didHitEntity:(RGMEntity *)entity mask:(RGMHitTestMask)mask {
    if ([entity.identifier isEqualToString:@"bug"] && mask & RGMHitTestTop) {
        [self.game destroyEntity:entity.identifier];
    }
}

@end
