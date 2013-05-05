//
//  RGMObstacle.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGMEntity;

typedef NS_OPTIONS(NSUInteger, RGMObstacleMask) {
    RGMObstacleMaskNone         = 0,
    RGMObstacleMaskSolidTop     = 1 << 1,
    RGMObstacleMaskSolidBottom  = 1 << 2,
    RGMObstacleMaskSolidLeft    = 1 << 3,
    RGMObstacleMaskSolidRight   = 1 << 4,
    
    RGMObstacleMaskSolid = RGMObstacleMaskSolidBottom | RGMObstacleMaskSolidLeft | RGMObstacleMaskSolidRight | RGMObstacleMaskSolidTop,
};

@interface RGMObstacle : NSObject

@property (nonatomic, assign) RGMObstacleMask mask;
@property (nonatomic, assign) CGRect frame;

- (BOOL)hitTestEntity:(RGMEntity *)entity;

@end
