//
//  RGMScene.h
//  TOJam2013
//
//  Created by Ryder Mackay on 1/9/2014.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class RGMGame;

@interface RGMScene : SKScene

@property (nonatomic, weak) RGMGame *game;
@property (nonatomic) SKNode *world;

@end
