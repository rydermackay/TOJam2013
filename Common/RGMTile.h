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
    RGMTileSolidRight       = 3,
    RGMTileSolidBottom      = 4,
    RGMTileSolidLeft        = 5,
    
    RGMTilePlatformLeft = 10,
    RGMTilePlatformMiddle,
    RGMTilePlatformRight,
    
    RGMTileSolidTopLeft     = 20,
    RGMTileWedgeTopLeft     = 21,
    RGMTileSolidTopRight    = 22,
    RGMTileWedgeTopRight    = 23,
    RGMTileSolidBottomLeft  = 24,
    RGMTileSolidBottomRight = 25,
};

typedef NS_OPTIONS(NSUInteger, RGMObstacleMask) {
    RGMObstacleMaskNone             = 0,
    RGMObstacleMaskSolidTop         = 1 << 1,
    RGMObstacleMaskSolidBottom      = 1 << 2,
    RGMObstacleMaskSolidLeft        = 1 << 3,
    RGMObstacleMaskSolidRight       = 1 << 4,
    
    RGMObstacleMaskSolid = RGMObstacleMaskSolidBottom | RGMObstacleMaskSolidLeft | RGMObstacleMaskSolidRight | RGMObstacleMaskSolidTop,
    
    RGMObstacleMaskSlopeLeft   = 1 << 5,
    RGMObstacleMaskSlopeRight  = 1 << 6,
};

@interface RGMTile : NSObject

- (instancetype)initWithTileType:(RGMTileType)type;

@property (nonatomic) RGMTileType type;
@property (nonatomic) RGMObstacleMask mask;
@property (nonatomic) CGRect frame;

- (BOOL)hitTestEntity:(RGMEntity *)entity;
- (NSString *)textureName;

@end
