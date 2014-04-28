//
//  RGMDefines.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

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