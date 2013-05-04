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

- (BOOL)hitTestEntity:(RGMEntity *)entity entityRect:(CGRect)entityRect obstacleRect:(CGRect)obstacleRect
{
    RGMObstacleMask mask = self.mask;
    
    if (mask == RGMObstacleMaskNone) {
        return NO;
    }
    
    if (mask & RGMObstacleMaskSolidBottom) {
        if (CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect) &&
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect) &&  // collision
            CGRectGetMaxY(entityRect) > CGRectGetMaxY(obstacleRect) && entity.velocity.y < 0) {
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.center = CGPointMake(entity.center.x, CGRectGetMaxY(obstacleRect) + CGRectGetHeight(entityRect) * 0.5f);
            [entity endJump];
            return YES;
        }
    }
    
    if (mask & RGMObstacleMaskSolidTop) {
        if (CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect) &&
            CGRectGetMinY(entityRect) < CGRectGetMinY(obstacleRect) &&
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect) && entity.velocity.y > 0) {  // collision
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.center = CGPointMake(entity.center.x, CGRectGetMinY(obstacleRect) - CGRectGetHeight(entityRect) * 0.5f);
            entity.canJump = YES;
            return YES;
        }
    }
    
    if (mask & RGMObstacleMaskSolidLeft) {
        if (CGRectGetMinX(entityRect) < CGRectGetMinX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect) &&  // collision
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect) &&
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect) && entity.velocity.x > 0) {
            entity.velocity = CGPointMake(0, entity.velocity.y);
            entity.center = CGPointMake(CGRectGetMinX(obstacleRect) - CGRectGetWidth(entityRect) * 0.5f, entity.center.y);
            return YES;
        }
    }
    
    if (mask & RGMObstacleMaskSolidRight) {
        if (CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect) &&  // collision
            CGRectGetMaxX(entityRect) > CGRectGetMaxX(obstacleRect) &&
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect) &&
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect) && entity.velocity.x < 0) {
            entity.velocity = CGPointMake(0, entity.velocity.y);
            entity.center = CGPointMake(CGRectGetMaxX(obstacleRect) + CGRectGetWidth(entityRect) * 0.5f, entity.center.y);
            return YES;
        }
    }
    
    return NO;
}

@end
