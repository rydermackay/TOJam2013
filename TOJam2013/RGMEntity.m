//
//  RGMEntity.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMEntity.h"

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
        _center = CGPointZero;
        _velocity = CGPointZero;
        _canJump = NO;
    }
    
    return self;
}

- (NSDictionary *)serializedCopy
{
    return @{
         @"identifier": self.identifier,
         @"center": @{
                 @"x": @(self.center.x),
                 @"y": @(self.center.y)
                 },
         @"velocity": @{
                 @"x": @(self.velocity.x),
                 @"y": @(self.velocity.y)
                 },
     }; 
}

- (void)setValuesWithJSON:(NSDictionary *)JSON
{
    self.identifier = [JSON valueForKey:@"identifier"];
    self.center = CGPointMake([[JSON valueForKeyPath:@"center.x"] floatValue], [[JSON valueForKeyPath:@"center.y"] floatValue]);
    self.velocity = CGPointMake([[JSON valueForKeyPath:@"velocity.x"] floatValue], [[JSON valueForKeyPath:@"velocity.y"] floatValue]);
}

- (NSString *)description
{
    NSMutableString *description = [[super description] mutableCopy];
    [description appendFormat:@"center: %@, velocity: %@", NSStringFromCGPoint(self.center), NSStringFromCGPoint(self.velocity)];
    
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
    
    CGPoint center = self.center;
    center.x += velocity.x * duration;
    center.y += velocity.y * duration;
    
    self.center = center;
    
    self.canJump = NO;
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

@end
