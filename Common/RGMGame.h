//
//  RGMGame.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMTileMap.h"

@class RGMEntity;
@protocol RGMInput;

@interface RGMGame : NSObject

- (id)initWithMapName:(NSString *)mapName;
@property (nonatomic, strong, readonly) RGMTileMap *tileMap;

- (void)start;
- (void)end;

- (void)update:(CFTimeInterval)currentTime;

- (RGMEntity *)createEntity:(Class)entityClass identifier:(NSString *)identifier;
- (void)destroyEntity:(NSString *)identifier;

@property (nonatomic, strong, readonly) RGMEntity *localPlayer;
- (RGMEntity *)entityForIdentifier:(NSString *)identifier;
- (NSArray *)identifiers;

- (void)addInput:(id <RGMInput>)input toEntity:(RGMEntity *)entity;

@end
