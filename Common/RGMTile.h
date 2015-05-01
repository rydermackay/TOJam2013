//
//  RGMObstacle.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGMEntity;

typedef NS_ENUM(NSUInteger, RGMTileType) {
    RGMTileClear            = 0,
    RGMTileSolid            = 1,
    RGMTileSolidTop         = 2,
    RGMTileSolidRight       = 3,
    RGMTileSolidBottom      = 4,
    RGMTileSolidLeft        = 5,
    
    RGMTilePlatformLeft     = 10,
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
    RGMObstacleMaskSolidTop         = 1 << 0,
    RGMObstacleMaskSolidBottom      = 1 << 1,
    RGMObstacleMaskSolidLeft        = 1 << 2,
    RGMObstacleMaskSolidRight       = 1 << 3,
    
    RGMObstacleMaskSolid = RGMObstacleMaskSolidBottom | RGMObstacleMaskSolidLeft | RGMObstacleMaskSolidRight | RGMObstacleMaskSolidTop,
    
    RGMObstacleMaskSlopeLeft   = 1 << 4,
    RGMObstacleMaskSlopeRight  = 1 << 5,
};

@interface RGMTile : NSObject

- (instancetype)initWithTileType:(RGMTileType)type position:(RGMTilePosition)position;

@property (nonatomic, readonly) RGMTileType type;
@property (nonatomic, readonly) RGMTilePosition position;
@property (nonatomic, readonly) RGMObstacleMask mask;
@property (nonatomic, readonly) CGRect frame;

- (NSString *)textureName;

@end



#if !TARGET_OS_IPHONE

@interface RGMTile (Editor)

+ (NSArray *)tileTypes;
@property (nonatomic, readonly) NSImage *image;

@end

#endif // !TARGET_OS_IPHONE
