//
//  RGMDefines.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

@import CoreGraphics.CGGeometry;

typedef NS_ENUM(NSUInteger, RGMAxis) {
    RGMAxisHorizontal,
    RGMAxisVertical,
};

typedef struct {
    NSUInteger x;
    NSUInteger y;
} RGMTilePosition;

typedef struct {
    NSUInteger width;
    NSUInteger height;
} RGMSize;

extern NSUInteger RGMTileSize;

extern CGRect RGMFrameForTilePosition(RGMTilePosition position);
extern CGRect RGMFrameFromTile(CGPoint from, CGPoint to);

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
