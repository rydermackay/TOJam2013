//
//  RGMTileMap.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMTileMap.h"
#import "RGMObstacle.h"

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
                RGMObstacleMask mask = [map[y][x] unsignedIntegerValue];
                if (mask == RGMObstacleMaskNone) {
                    continue;
                }
                
                RGMObstacle *obstacle = [[RGMObstacle alloc] init];
                obstacle.frame = RGMFrameForTile(CGPointMake(x, y));
                obstacle.mask = mask;
                [obstacles addObject:obstacle];
            }
        }
        
        _obstacles = [obstacles copy];
    }
    
    return self;
}

@end
