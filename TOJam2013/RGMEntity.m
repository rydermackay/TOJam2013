//
//  RGMEntity.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMEntity.h"

NSTimeInterval invincibilityDuration = 3;

@interface RGMEntity ()

@property (nonatomic, copy, readwrite) NSString *identifier;

@end



@implementation RGMEntity {
    BOOL _isJumping;
    NSDate *_jumpDate;
}

- (id)initWithIdentifier:(NSString *)identifier
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

- (NSDictionary *)serializedCopy
{
    return @{
         @"identifier": self.identifier,
         @"x": @(self.x),
         @"y": @(self.y),
         @"velocity": @{
                 @"x": @(self.velocity.x),
                 @"y": @(self.velocity.y)
                 },
     }; 
}

- (void)setValuesWithJSON:(NSDictionary *)JSON
{
    self.identifier = [JSON valueForKey:@"identifier"];
    self.x = [JSON[@"x"] integerValue];
    self.y = [JSON[@"y"] integerValue];
    self.velocity = CGPointMake([[JSON valueForKeyPath:@"velocity.x"] floatValue], [[JSON valueForKeyPath:@"velocity.y"] floatValue]);
}

- (NSString *)description
{
    NSMutableString *description = [[super description] mutableCopy];
    [description appendFormat:@"origin: %@, velocity: %@", NSStringFromCGPoint(CGPointMake(self.x, self.y)), NSStringFromCGPoint(self.velocity)];
    
    return [description copy];
}

- (void)updateForDuration:(NSTimeInterval)duration
{
    const CGFloat gravity = [self gravity];
    const CGFloat maxDownwardVelocity = MAXFLOAT;
    
    CGPoint velocity = self.velocity;
    velocity.y += gravity * duration;
    velocity.y = MIN(maxDownwardVelocity, velocity.y);
    self.velocity = velocity;
    
    self.x += velocity.x * duration;
    self.y += velocity.y * duration;
}

- (CGFloat)gravity
{
    return _isJumping ? 0 : 3000;
}

- (void)jump
{
    if (!self.canJump) {
        return;
    }
    
    self.velocity = CGPointMake(self.velocity.x, -500);
    self.canJump = NO;
    _isJumping = YES;
    
    const NSTimeInterval jumpDuration = 0.15f;
    [self performSelector:@selector(endJump) withObject:nil afterDelay:jumpDuration inModes:@[NSRunLoopCommonModes]];
}

- (void)endJump
{
    _isJumping = NO;
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

@end
