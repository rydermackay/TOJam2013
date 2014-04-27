//
//  RGMObstacle.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMTile.h"
#import "RGMEntity.h"

@implementation RGMTile

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
            return RGMObstacleMaskSlopeRight | RGMObstacleMaskSolidLeft;
        case RGMTileSolidTopLeft:
            return RGMObstacleMaskSlopeLeft | RGMObstacleMaskSolidRight;
        case RGMTilePlatformLeft:
        case RGMTilePlatformMiddle:
        case RGMTilePlatformRight:
            return RGMObstacleMaskSolidTop;
        case RGMTileSolidBottomRight:
        case RGMTileSolidBottomLeft:
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
            return @"solid-top-right";
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

- (BOOL)hitTestEntity:(RGMEntity *)entity {
    RGMObstacleMask mask = self.mask;
    if (mask == RGMObstacleMaskNone) {
        return NO;
    }
    
    CGRect obstacleRect = self.frame;
    CGRect entityRect = entity.frame;
    if (!CGRectIntersectsRect(obstacleRect, entityRect)) {
        return NO;
    }
    BOOL hit = NO;
    
    if (mask & RGMObstacleMaskSolidBottom) {
        if (CGRectGetMaxY(entity.frameBeforeStepping) <= CGRectGetMinY(obstacleRect) &&
            CGRectGetMaxY(entityRect) > CGRectGetMinY(obstacleRect)) {
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.y = CGRectGetMinY(obstacleRect) - entity.size.height;
            [entity endJump];
            hit = YES;
        }
    }
    if (mask & RGMObstacleMaskSolidTop) {
        if (CGRectGetMinY(entity.frameBeforeStepping) >= CGRectGetMaxY(obstacleRect) &&
            CGRectGetMinY(entityRect) < CGRectGetMaxY(obstacleRect)) {
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.y = CGRectGetMaxY(obstacleRect);
            entity.canJump = YES;
            hit = YES;
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
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.y = maxY;
            entity.canJump = YES;
            hit = YES;
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
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.y = maxY;
            entity.canJump = YES;
            hit = YES;
        }
    }
    if (mask & RGMObstacleMaskSolidLeft) {
        if (CGRectGetMaxX(entity.frameBeforeStepping) <= CGRectGetMinX(obstacleRect) &&
            CGRectGetMaxX(entityRect) > CGRectGetMinX(obstacleRect)) {
            entity.velocity = CGPointMake(0, entity.velocity.y);
            entity.x = CGRectGetMinX(obstacleRect) - entity.size.width;
            hit = YES;
        }
    }
    if (mask & RGMObstacleMaskSolidRight) {
        if (CGRectGetMinX(entity.frameBeforeStepping) >= CGRectGetMaxX(obstacleRect) &&
            CGRectGetMinX(entityRect) < CGRectGetMaxX(obstacleRect)) {
            entity.velocity = CGPointMake(0, entity.velocity.y);
            entity.x = CGRectGetMaxX(obstacleRect);
            hit = YES;
        }
    }
    
    return hit;
}

@end

@implementation RGMTile (Editor)

+ (NSArray *)tileTypes {
    return @[@(RGMTileClear),
             @(RGMTileSolid),
             @(RGMTileSolidTop),
             @(RGMTileSolidRight),
             @(RGMTileSolidBottom),
             @(RGMTileSolidLeft),
             @(RGMTilePlatformLeft),
             @(RGMTilePlatformMiddle),
             @(RGMTilePlatformRight),
             @(RGMTileSolidTopLeft),
             @(RGMTileWedgeTopLeft),
             @(RGMTileSolidTopRight),
             @(RGMTileWedgeTopRight),
             @(RGMTileSolidBottomLeft),
             @(RGMTileSolidBottomRight)];
}

- (NSImage *)image {
    return [NSImage imageNamed:self.textureName];
}

@end
