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

- (instancetype)initWithTileType:(RGMTileType)type position:(RGMTilePosition)position {
    if (self = [super init]) {
        _type = type;
        _position = position;
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

- (CGRect)frame {
    return RGMFrameForTilePosition(self.position);
}

@end

#if !TARGET_OS_IPHONE

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

#endif // !TARGET_OS_IPHONE