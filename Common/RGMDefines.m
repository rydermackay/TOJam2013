//
//  RGMDefines.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMDefines.h"

NSUInteger  RGMTileSize     = 16;

CGRect RGMFrameForTilePosition(RGMTilePosition position) {
    return CGRectMake(position.x * RGMTileSize, position.y * RGMTileSize, RGMTileSize, RGMTileSize);
}

CGRect RGMFrameFromTile(CGPoint from, CGPoint to) {
    NSCParameterAssert(from.x <= to.x);
    NSCParameterAssert(from.y <= to.y);
    return CGRectMake(from.x * RGMTileSize, from.y * RGMTileSize, (1 + to.x - from.x) * RGMTileSize, (1 + to.y - from.y) * RGMTileSize);
}