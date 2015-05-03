//
//  RGMEntity.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMEntity.h"
#import "RGMTile.h"

NSTimeInterval invincibilityDuration = 3;

@interface RGMEntity ()

@property (nonatomic, copy, readwrite) NSString *identifier;

@end



@implementation RGMEntity {
    BOOL _isJumping;
    BOOL _isHoldingJump;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _x = [aDecoder decodeIntegerForKey:@"x"];
        _y = [aDecoder decodeIntegerForKey:@"y"];
#if TARGET_OS_IPHONE
        _velocity = [aDecoder decodeCGPointForKey:@"velocity"];
        _size = [aDecoder decodeCGSizeForKey:@"size"];
#else
        [aDecoder decodeValueOfObjCType:@encode(CGPoint) at:&_velocity];
        [aDecoder decodeValueOfObjCType:@encode(CGSize) at:&_size];
#endif
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeInteger:self.x forKey:@"x"];
    [aCoder encodeInteger:self.y forKey:@"y"];
#if TARGET_OS_IPHONE
    [aCoder encodeCGPoint:self.velocity forKey:@"velocity"];
    [aCoder encodeCGSize:self.size forKey:@"size"];
#else
    [aCoder encodeValueOfObjCType:@encode(CGPoint) at:&_velocity];
    [aCoder encodeValueOfObjCType:@encode(CGSize) at:&_size];
#endif
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    NSParameterAssert(identifier.length > 0);
    
    if (self = [super init]) {
        _identifier = [identifier copy];
        _x = 0;
        _y = 0;
        _velocity = CGPointZero;
        _canJump = NO;
        _size = CGSizeMake(RGMTileSize, RGMTileSize);
    }
    
    return self;
}

- (void)setX:(NSInteger)x {
    _x = x;
    self.remainderPosition = CGPointMake(0, self.remainderPosition.y);
}

- (void)setY:(NSInteger)y {
    _y = y;
    self.remainderPosition = CGPointMake(self.remainderPosition.x, 0);
}

- (NSString *)description
{
    NSMutableString *description = [[super description] mutableCopy];
    [description appendFormat:@"frame: {{%f, %f}, {%f, %f}}, velocity: {%f, %f}", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height, self.velocity.x, self.velocity.y];
    
    return [description copy];
}

- (void)updateForDuration:(NSTimeInterval)duration
{
    const CGFloat gravity = [self gravity];
    const CGFloat maxDownwardVelocity = -MAXFLOAT;
    
    CGPoint velocity = self.velocity;
    velocity.y += gravity * duration;
    velocity.y = MAX(maxDownwardVelocity, velocity.y);
    self.velocity = velocity;
    self.canJump = NO;
}

- (CGFloat)gravity
{
    return _isJumping ? 0 : -2000;
}

- (void)jump
{
    if (!_isHoldingJump && self.canJump) {
        _isJumping = YES;
        self.velocity = CGPointMake(self.velocity.x, 250);
        self.canJump = NO;
        
        const NSTimeInterval jumpDuration = 0.15f;
        [self performSelector:@selector(stopJump) withObject:nil afterDelay:jumpDuration inModes:@[NSRunLoopCommonModes]];
    }
    _isHoldingJump = YES;   
}

- (void)stopJump {
    _isJumping = NO;
}

- (void)resetJump
{
    _isJumping = NO;
    _isHoldingJump = NO;
}

- (CGRect)frame
{
    return CGRectMake(self.x, self.y, self.size.width, self.size.height);
}

- (void)setInvincible:(BOOL)invincible
{
    if (_invincible == invincible) {
        return;
    }
    
    _invincible = invincible;
    [self performSelector:@selector(reset) withObject:nil afterDelay:invincibilityDuration inModes:@[NSRunLoopCommonModes]];
}

- (void)reset
{
    self.invincible = NO;
}

- (RGMHitTestMask)hitTestWithTile:(RGMTile *)tile fromRect:(CGRect)fromRect proposedRect:(CGRect)proposedRect {
    
    RGMHitTestMask hitTestMask = RGMHitTestNone;
    
    RGMObstacleMask mask = tile.mask;
    if (mask == RGMObstacleMaskNone) {
        return hitTestMask;
    }
    
    CGRect obstacleRect = tile.frame;
    CGRect entityRect = proposedRect;
    if (!CGRectIntersectsRect(obstacleRect, entityRect)) {
        return hitTestMask;
    }
    
    if (mask & RGMObstacleMaskSolidBottom) {
        if (CGRectGetMaxY(fromRect) <= CGRectGetMinY(obstacleRect) &&
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect)) {
            self.velocity = CGPointMake(self.velocity.x, 0);
            self.y = CGRectGetMinY(obstacleRect) - self.size.height;
            [self resetJump];
            hitTestMask |= RGMHitTestBottom;
        }
    }
    if (mask & RGMObstacleMaskSolidTop) {
        if (CGRectGetMinY(fromRect) >= CGRectGetMaxY(obstacleRect) &&
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect)) {
            self.velocity = CGPointMake(self.velocity.x, 0);
            self.y = CGRectGetMaxY(obstacleRect);
            self.canJump = YES;
            hitTestMask |= RGMHitTestTop;
        }
    }
    if (mask & RGMObstacleMaskSlopeLeft) {
        CGFloat yForMinX = 0;
        CGFloat yForMaxX = RGMTileSize;
        CGFloat slope = (yForMaxX - yForMinX) / CGRectGetWidth(obstacleRect);
        CGFloat x = CGRectGetMidX(entityRect) - CGRectGetMinX(obstacleRect);
        CGFloat height = x * slope;
        CGFloat maxY = MIN(MAX(CGRectGetMinY(obstacleRect), (CGRectGetMinY(obstacleRect) + height)), CGRectGetMaxY(obstacleRect));
        if (CGRectGetMinY(entityRect) < maxY) {
            self.velocity = CGPointMake(self.velocity.x, 0);
            self.y = maxY;
            self.canJump = YES;
            hitTestMask |= RGMHitTestTop;   // counts as walking on ground
        }
    }
    if (mask & RGMObstacleMaskSlopeRight) {
        CGFloat yForMinX = RGMTileSize;
        CGFloat yForMaxX = 0;
        CGFloat slope = (yForMaxX - yForMinX) / CGRectGetWidth(obstacleRect);
        //y = mx + b
        //m = y2 - y1 / x2 - x1
        CGFloat x = CGRectGetMidX(entityRect) - CGRectGetMinX(obstacleRect);
        CGFloat height = x * slope + yForMinX;
        CGFloat maxY = MIN(MAX(CGRectGetMinY(obstacleRect), (CGRectGetMinY(obstacleRect) + height)), CGRectGetMaxY(obstacleRect));
        if (CGRectGetMinY(entityRect) < maxY) {
            self.velocity = CGPointMake(self.velocity.x, 0);
            self.y = maxY;
            self.canJump = YES;
            hitTestMask |= RGMHitTestTop;
        }
    }
    if (mask & RGMObstacleMaskSolidLeft) {
        if (CGRectGetMaxX(fromRect) <= CGRectGetMinX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect)) {
            self.velocity = CGPointMake(0, self.velocity.y);
            self.x = CGRectGetMinX(obstacleRect) - self.size.width;
            hitTestMask |= RGMHitTestLeft;
        }
    }
    if (mask & RGMObstacleMaskSolidRight) {
        if (CGRectGetMinX(fromRect) >= CGRectGetMaxX(obstacleRect) &&
            CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect)) {
            self.velocity = CGPointMake(0, self.velocity.y);
            self.x = CGRectGetMaxX(obstacleRect);
            hitTestMask |= RGMHitTestRight;
        }
    }
    
    return hitTestMask;
}

- (void)didHitTile:(RGMTile *)tile mask:(RGMHitTestMask)mask {
    
}

- (RGMHitTestMask)hitTestWithEntity:(RGMEntity *)entity fromRect:(CGRect)fromRect proposedRect:(CGRect)proposedRect {
    return RGMHitTestFromToRect(fromRect, proposedRect, entity.frame);
}

static inline RGMHitTestMask RGMHitTestFromToRect(CGRect from, CGRect to, CGRect testRect) {
    RGMHitTestMask hitTestMask = RGMHitTestNone;
    if (CGRectIntersectsRect(testRect, to)) {
        if (CGRectGetMaxY(from) <= CGRectGetMinY(testRect) &&
            CGRectGetMaxY(to) > CGRectGetMinY(testRect)) {
            hitTestMask |= RGMHitTestBottom;
        }
        if (CGRectGetMinY(from) >= CGRectGetMaxY(testRect) &&
            CGRectGetMinY(to) < CGRectGetMaxY(testRect)) {
            hitTestMask |= RGMHitTestTop;
        }
        if (CGRectGetMaxX(from) <= CGRectGetMinX(testRect) &&
            CGRectGetMaxX(to) > CGRectGetMinX(testRect)) {
            hitTestMask |= RGMHitTestLeft;
        }
        if (CGRectGetMinX(from) >= CGRectGetMaxX(testRect) &&
            CGRectGetMinX(to) < CGRectGetMaxX(testRect)) {
            hitTestMask |= RGMHitTestRight;
        }
    }
    return hitTestMask;
}

- (void)didHitEntity:(RGMEntity *)entity mask:(RGMHitTestMask)mask {
    
}

- (CGPoint)distanceFrom:(RGMEntity *)entity {
    return CGPointMake(self.x - entity.x, self.y - entity.y);
}

- (BOOL)isMovingTowards:(RGMEntity *)entity axis:(RGMAxis)axis {
    switch (axis) {
        case RGMAxisHorizontal: return signbit([self distanceFrom:entity].x) == signbit(self.velocity.x);
        case RGMAxisVertical:   return signbit([self distanceFrom:entity].y) == signbit(self.velocity.y);
    }
}

@end
