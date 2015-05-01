//
//  RGMEntity.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

@import Foundation;
@import SpriteKit;

extern NSTimeInterval invincibilityDuration;

@class RGMGame, RGMTile;

// which side a collision occurred on wrt the static obstacle being tested
// i.e. a character moving right hitting the left side of a solid wall returns RGMHitTestLeft
// can be combined for some reason
typedef NS_OPTIONS(NSUInteger, RGMHitTestMask) {
    
    RGMHitTestNone        = 0,  // all zeros; no collision
    
    RGMHitTestTop         = 1 << 0,
    RGMHitTestBottom      = 1 << 1,
    RGMHitTestLeft        = 1 << 2,
    RGMHitTestRight       = 1 << 3,
};

@interface RGMEntity : NSObject <NSCoding>

- (id)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;
@property (nonatomic, assign) CGSize size;
- (CGRect)frame;

@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint remainderPosition; // non-integral position from last frame

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage *image;
#else
@property (nonatomic, strong) NSImage *image;
#endif

@property (nonatomic, strong) SKTexture *texture;
@property (nonatomic, strong) SKColor *color;

- (void)updateForDuration:(NSTimeInterval)interval;

@property (nonatomic, assign, getter = isInvincible) BOOL invincible;
- (void)reset;

@property (nonatomic, assign) BOOL canJump;
- (void)jump;
- (void)endJump;

- (RGMHitTestMask)hitTestWithTile:(RGMTile *)tile fromRect:(CGRect)fromRect proposedRect:(CGRect)proposedRect;
- (void)didHitTile:(RGMTile *)tile mask:(RGMHitTestMask)mask;
- (RGMHitTestMask)hitTestWithEntity:(RGMEntity *)entity fromRect:(CGRect)fromRect proposedRect:(CGRect)proposedRect;
- (void)didHitEntity:(RGMEntity *)entity mask:(RGMHitTestMask)mask;

@property (nonatomic, weak) RGMGame *game;

// helpers
- (CGPoint)distanceFrom:(RGMEntity *)entity;
- (BOOL)isMovingTowards:(RGMEntity *)entity axis:(RGMAxis)axis;

@end
