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
        NSDictionary *map = [NSJSONSerialization JSONObjectWithData:mapData options:0 error:&error];
        if (!map) {
            NSLog(@"error loading map: %@", error);
            return nil;
        }
        
        NSMutableArray *obstacles = [NSMutableArray new];
        
        for (NSDictionary *dictionary in map[@"obstacles"]) {
            RGMObstacle *obstacle = [[RGMObstacle alloc] init];
            
            CGPoint start = CGPointMake([[dictionary valueForKeyPath:@"start.x"] floatValue], [[dictionary valueForKeyPath:@"start.y"] floatValue]);
            CGPoint end = CGPointMake([[dictionary valueForKeyPath:@"end.x"] floatValue], [[dictionary valueForKeyPath:@"end.y"] floatValue]);
            obstacle.frame = RGMFrameFromTile(start, end);
            
            if ([[dictionary objectForKey:@"type"] isEqual:@"solid"]) {
                obstacle.mask = RGMObstacleMaskSolid;
            } else {
                obstacle.mask = RGMObstacleMaskSolidTop;
            }
            
            [obstacles addObject:obstacle];
        }
        
        _obstacles = [obstacles copy];
    }
    
    return self;
}

@end
