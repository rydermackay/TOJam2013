//
//  RGMObstacle.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMObstacle.h"
#import "RGMEntity.h"

@implementation RGMObstacle

- (BOOL)hitTestEntity:(RGMEntity *)entity
{
    RGMObstacleMask mask = self.mask;
    
    CGRect obstacleRect = self.frame;
    CGRect entityRect = entity.frame;
    
    if (mask == RGMObstacleMaskNone) {
        return NO;
    }
    
    if (mask & RGMObstacleMaskSolidBottom) {
        if (CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect) &&
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect) &&  // collision
            CGRectGetMinY(entity.frameBeforeStepping) >= CGRectGetMaxY(obstacleRect)) {
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.y = CGRectGetMaxY(obstacleRect);
            [entity endJump];
            return YES;
        }
    }
    
    if (mask & RGMObstacleMaskSolidTop) {
        if (CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect) &&
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect) &&
            CGRectGetMaxY(entity.frameBeforeStepping) <= CGRectGetMinY(obstacleRect)) {  // collision
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.y = CGRectGetMinY(obstacleRect) - entity.size.height;
            entity.canJump = YES;
            return YES;
        }
    }
    
    if (mask & RGMObstacleMaskSolidLeft) {
        if (CGRectGetMaxX(entity.frameBeforeStepping) <= CGRectGetMinX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect) &&  // collision
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect) &&
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect)) {
            entity.velocity = CGPointMake(0, entity.velocity.y);
            entity.x = CGRectGetMinX(obstacleRect) - entity.size.width;
            return YES;
        }
    }
    
    if (mask & RGMObstacleMaskSolidRight) {
        if (CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect) &&  // collision
            CGRectGetMinX(entity.frameBeforeStepping) >= CGRectGetMaxX(obstacleRect) &&
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect) &&
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect)) {
            entity.velocity = CGPointMake(0, entity.velocity.y);
            entity.x = CGRectGetMaxX(obstacleRect);
            return YES;
        }
    }
    
    return NO;
}

@end
