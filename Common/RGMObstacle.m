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

- (instancetype)initWithTileType:(RGMTileType)type {
    if (self = [super init]) {
        _type = type;
        _mask = RGMObstacleMaskForTileType(type);
    }
    return self;
}

static inline RGMObstacleMask RGMObstacleMaskForTileType(RGMTileType type) {
    switch (type) {
        case RGMTileSolid:
        case RGMTileSolidTop:
        case RGMTileSolidRight:
        case RGMTileSolidBottom:
        case RGMTileSolidLeft:
        case RGMTileWedgeTopLeft:
        case RGMTileWedgeTopRight:
            return RGMObstacleMaskSolid;
        case RGMTileSolidTopRight:
        case RGMTileSolidBottomRight:
        case RGMTileSolidBottomLeft:
        case RGMTileSolidTopLeft:
            return RGMObstacleMaskSolidSlopeRight;
        case RGMTilePlatformLeft:
        case RGMTilePlatformMiddle:
        case RGMTilePlatformRight:
            return RGMObstacleMaskSolidTop;
        case RGMTileClear:
        default:
            return RGMObstacleMaskNone;
    }
}

- (NSString *)textureName {
    return RGMTextureNameForTileType(self.type);
}

static inline NSString *RGMTextureNameForTileType(RGMTileType type) {
    switch (type) {
        case RGMTileClear:
            return @"clear";
        case RGMTileSolid:
            return @"solid";
        case RGMTileSolidTop:
            return @"solid-top";
        case RGMTileSolidTopRight:
            return @"solid-top";
        case RGMTileWedgeTopRight:
            return @"wedge-top-right";
        case RGMTileSolidRight:
            return @"solid-right";
        case RGMTileSolidBottomRight:
            return @"solid-bottom-right";
        case RGMTileSolidBottom:
            return @"solid-bottom";
        case RGMTileSolidBottomLeft:
            return @"solid-bottom-left";
        case RGMTileSolidLeft:
            return @"solid-left";
        case RGMTileSolidTopLeft:
            return @"solid-top-left";
        case RGMTileWedgeTopLeft:
            return @"wedge-top-left";
        case RGMTilePlatformLeft:
            return @"platform-left";
        case RGMTilePlatformMiddle:
            return @"platform-middle";
        case RGMTilePlatformRight:
            return @"platform-right";
        default:
            return @"unknown";
    }
}

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
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect) &&
            CGRectGetMaxY(entity.frameBeforeStepping) <= CGRectGetMinY(obstacleRect)) {  // collision
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.y = CGRectGetMinY(obstacleRect) - entity.size.height;
            [entity endJump];
            return YES;
        }
    }
    
    if (mask & RGMObstacleMaskSolidTop) {
        if (CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect) &&
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect) &&  // collision
            CGRectGetMinY(entity.frameBeforeStepping) >= CGRectGetMaxY(obstacleRect)) {
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.y = CGRectGetMaxY(obstacleRect);
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
