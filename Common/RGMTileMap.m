//
//  RGMTileMap.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMTileMap.h"
#import "RGMTile.h"

@interface RGMTileMap ()

@property (nonatomic, copy) NSArray *obstacles;

@end



@implementation RGMTileMap

- (id)initWithName:(NSString *)name
{
    if (self = [super init]) {
        NSData *mapData = [[NSData alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:name withExtension:@"json"]];
        NSError *error;
        NSArray *map = [NSJSONSerialization JSONObjectWithData:mapData options:0 error:&error];
        if (!map) {
            NSLog(@"error loading map: %@", error);
            return nil;
        }
        
        NSMutableArray *obstacles = [NSMutableArray new];
        
        for (int y = 0; y < map.count; y++) {
            for (int x = 0; x < [map[y] count]; x++) {
                const CGPoint tile = CGPointMake(x, map.count - 1 - y);
                RGMTileType tileType = [map[y][x] unsignedIntegerValue];
                
                RGMTile *obstacle = [[RGMTile alloc] initWithTileType:tileType];
                obstacle.frame = RGMFrameForTile(tile);
                [obstacles addObject:obstacle];
            }
        }
        
        _obstacles = [obstacles copy];
    }
    
    return self;
}

@end
