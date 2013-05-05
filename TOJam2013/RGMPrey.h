//
//  RGMPrey.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMEntity.h"

@class RGMPredator;

@interface RGMPrey : RGMEntity

@property (nonatomic, assign, getter = isCaptured) BOOL captured;
@property (nonatomic, weak) RGMPredator *predator;

@end
