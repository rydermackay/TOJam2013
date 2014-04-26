//
//  RGMObstacle.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMTileMap.h"

@class RGMEntity;

typedef NS_ENUM(NSUInteger, RGMTileType) {
    RGMTileClear            = 0,
    RGMTileSolid            = 1,
    RGMTileSolidTop         = 2,
    RGMTileSolidTopRight    = 3,
    RGMTileSolidRight       = 4,
    RGMTileSolidBottomRight = 5,
    RGMTileSolidBottom      = 6,
    RGMTileSolidBottomLeft  = 7,
    RGMTileSolidLeft        = 8,
    RGMTileSolidTopLeft     = 9,
    
    RGMTilePlatformLeft = 10,
    RGMTilePlatformMiddle,
    RGMTilePlatformRight,
};

typedef NS_OPTIONS(NSUInteger, RGMObstacleMask) {
    RGMObstacleMaskNone             = 0,
    RGMObstacleMaskSolidTop         = 1 << 1,
    RGMObstacleMaskSolidBottom      = 1 << 2,
    RGMObstacleMaskSolidLeft        = 1 << 3,
    RGMObstacleMaskSolidRight       = 1 << 4,
    RGMObstacleMaskSolidSlopeLeft   = 1 << 5,
    RGMObstacleMaskSolidSlopeRight  = 1 << 6,
    
    RGMObstacleMaskSolid = RGMObstacleMaskSolidBottom | RGMObstacleMaskSolidLeft | RGMObstacleMaskSolidRight | RGMObstacleMaskSolidTop,
};

@interface RGMObstacle : NSObject

- (instancetype)initWithTileType:(RGMTileType)type;

@property (nonatomic) RGMTileType type;
@property (nonatomic) RGMObstacleMask mask;
@property (nonatomic) CGRect frame;

- (BOOL)hitTestEntity:(RGMEntity *)entity;
- (NSString *)textureName;

@end
