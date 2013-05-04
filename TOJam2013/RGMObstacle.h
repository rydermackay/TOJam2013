//
//  RGMObstacle.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, RGMObstacleMask) {
    RGMObstacleMaskNone     = 0,
    RGMObstacleMaskTop      = 1 << 1,
    RGMObstacleMaskBottom   = 1 << 2,
    RGMObstacleMaskLeft     = 1 << 3,
    RGMObstacleMaskRight    = 1 << 4,
    
    RGMObstacleMaskSolid = RGMObstacleMaskBottom | RGMObstacleMaskLeft | RGMObstacleMaskRight | RGMObstacleMaskTop,
};

@interface RGMObstacle : NSObject

@property (nonatomic, assign) CGPoint tilePosition;

@end
