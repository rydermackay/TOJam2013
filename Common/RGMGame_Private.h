//
//  RGMGame_Private.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMGame.h"

@class RGMTileMap;

@interface RGMGame ()

@property (nonatomic, strong) RGMTileMap *tileMap;
@property (nonatomic, strong) NSMutableDictionary *entities;
@property (nonatomic, strong) NSMutableDictionary *inputs;
@property (nonatomic, strong) RGMEntity *localPlayer;

- (void)willUpdate;
- (void)didUpdate;

@end
