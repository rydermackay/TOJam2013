//
//  RGMPredator.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMEntity.h"

@class RGMPrey;

@interface RGMPredator : RGMEntity

- (void)capturePrey:(RGMPrey *)prey;
- (void)dropPrey;

@end
