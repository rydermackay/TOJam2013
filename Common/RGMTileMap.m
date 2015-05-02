//
//  RGMTileMap.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMTileMap.h"
#import "RGMTile.h"

@implementation RGMTileMap {
    NSMutableArray *_tiles;
}

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        NSData *mapData = [[NSData alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:name withExtension:@"json"]];
        NSError *error;
        NSDictionary *map = [NSJSONSerialization JSONObjectWithData:mapData options:0 error:&error];
        if (!map) {
            NSLog(@"error loading map: %@", error);
            return nil;
        }
        NSParameterAssert([map isKindOfClass:[NSDictionary class]]);
        NSUInteger width = [map[@"size"][@"width"] unsignedIntegerValue];
        NSUInteger height = [map[@"size"][@"height"] unsignedIntegerValue];
        _size = (RGMSize){width, height};
        
        NSMutableArray *tiles = [NSMutableArray new];
        NSArray *array = map[@"tiles"];
        NSParameterAssert(array.count == _size.height);
        for (NSInteger y = array.count - 1; y >= 0; y--) {
            NSParameterAssert([array[y] count] == _size.width);
            for (NSInteger x = 0; x < [array[y] count]; x++) {
                const RGMTilePosition position = (RGMTilePosition){x, array.count - 1 - y};
                RGMTileType tileType = [array[y][x] unsignedIntegerValue];
                RGMTile *tile = [[RGMTile alloc] initWithTileType:tileType position:position];
                [tiles addObject:tile];
            }
        }
        
        _tiles = tiles;
    }
    
    return self;
}

- (NSArray *)tiles {
    return [_tiles copy];
}

- (RGMTilePosition)positionForIndex:(NSUInteger)idx {
    return (RGMTilePosition){idx % self.size.width, idx / self.size.width};
}

- (NSUInteger)indexForPosition:(RGMTilePosition)position {
    return position.y * self.size.width + position.x;
}

- (RGMTileType)tileTypeAtPosition:(RGMTilePosition)position {
    return [(RGMTile *)_tiles[[self indexForPosition:position]] type];
}

- (void)setTileType:(RGMTileType)type position:(RGMTilePosition)position {
    _tiles[[self indexForPosition:position]] = [[RGMTile alloc] initWithTileType:type position:position];
}

@end
