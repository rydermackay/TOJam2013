//
//  RGMTileMap.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMDefines.h"

@class RGMTile, RGMTileType;

@interface RGMTileMap : NSObject

- (instancetype)initWithName:(NSString *)name;
@property (nonatomic, readonly) RGMSize size;
@property (nonatomic, copy, readonly) NSArray *tiles;
@property (nonatomic, copy, readonly) NSDictionary *tileDefinitions;

- (void)enumerateTiles:(void (^)(RGMTile *tile))block;

- (RGMTile *)tileAtPosition:(RGMTilePosition)position;
- (void)setTileType:(RGMTileType *)type position:(RGMTilePosition)position;

- (NSData *)JSONRepresentation;

@end
