//
//  RGMTileMap.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMDefines.h"
#import "RGMTile.h"

@interface RGMTileMap : NSObject

- (id)initWithName:(NSString *)name;
@property (nonatomic, readonly) RGMSize size;
@property (nonatomic, copy, readonly) NSArray *tiles;

- (RGMTileType)tileTypeAtPosition:(RGMTilePosition)position;
- (void)setTileType:(RGMTileType)type position:(RGMTilePosition)position;

- (void)enumerateTilesWithBlock:(void(^)(RGMTile *tile, RGMTilePosition position))block;

@end
