//
//  RGMGame.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMGame.h"
#import "RGMGame_Private.h"
#import "RGMEntity.h"
#import "RGMPredator.h"
#import "RGMPrey.h"
#import "RGMInput.h"
#import "RGMTileMap.h"
#import "RGMTile.h"

@implementation RGMGame

- (id)initWithMapName:(NSString *)mapName
{
    RGMTileMap *tileMap = [[RGMTileMap alloc] initWithName:mapName];
    NSParameterAssert(tileMap);
    if (self = [super init]) {
        _tileMap = tileMap;
        _entities = [NSMutableDictionary new];
        _inputs = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)start
{
    self.localPlayer = [self createEntity:[RGMPredator class] identifier:@"me"];
    
    [self createEntity:[RGMPrey class] identifier:@"prey1"];
    [self createEntity:[RGMPrey class] identifier:@"prey2"];
}

- (void)end
{
    _entities = [NSMutableDictionary new];
}

- (NSArray *)identifiers
{
    return self.entities.allKeys;
}

- (void)willUpdate
{
    
}

- (void)update:(CFTimeInterval)currentTime
{
    [self willUpdate];
    
    // test fixed rate
    CFTimeInterval duration = 1.0/60.0;
    
    // apply input
    [self.inputs enumerateKeysAndObjectsUsingBlock:^(NSString *key, id <RGMInput> input, BOOL *stop) {
        RGMEntity *entity = [self entityForIdentifier:key];
        RGMInputMask inputMask = [input inputMask];
        if (inputMask & RGMInputMaskJump) {
            [entity jump];
        } else {
            [entity endJump];
        }
        
        const CGFloat maxHorizontalVelocity = 200;
        CGPoint velocity = entity.velocity;
        CGFloat xComponent = 0;
        
        if (inputMask & RGMInputMaskLeft) {
            xComponent = -maxHorizontalVelocity;
        }
        if (inputMask & RGMInputMaskRight) {
            xComponent = maxHorizontalVelocity;
        }
        
        CGFloat n = 0.80;
        velocity.x *= n;
        velocity.x += xComponent * (1.0 - n);
        
        entity.velocity = velocity;
    }];
    
    
    [self.entities enumerateKeysAndObjectsUsingBlock:^(NSString *key, RGMEntity *entity, BOOL *stop) {
        [entity updateForDuration:duration];
        if ([entity isKindOfClass:[RGMPrey class]] && [(RGMPrey *)entity isCaptured]) {
            return;
        }
        NSInteger dx = entity.velocity.x * duration;
        NSInteger dy = entity.velocity.y * duration;
        [self stepEntity:entity axis:RGMAxisHorizontal amount:dx];
        [self stepEntity:entity axis:RGMAxisVertical amount:dy];
    }];
    
    [self didUpdate];
}

- (void)stepEntity:(RGMEntity *)entity axis:(RGMAxis)axis amount:(NSInteger)amount {
    entity.frameBeforeStepping = entity.frame;
    for (NSInteger i = 0; i < fabsf(amount); i++) {
        CGRectEdge edge;
        if (axis == RGMAxisHorizontal) {
            edge = amount > 0 ? CGRectMaxXEdge : CGRectMinXEdge;
            entity.x += amount > 0 ? 1 : -1;
        } else {
            edge = amount > 0 ? CGRectMaxYEdge : CGRectMinYEdge;
            entity.y += amount > 0 ? 1 : -1;
        }
        [self hitTestEntity:entity];
        
        NSArray *tiles = [self tilesIntersectingEntityRect:entity.frame edge:edge];
        RGMTile *hitTestTile;
        for (RGMTile *tile in tiles) {
            if (tile.mask & (RGMObstacleMaskSlopeLeft | RGMObstacleMaskSlopeRight) &&
                CGRectGetMidX(entity.frame) <= CGRectGetMaxX(tile.frame) &&
                CGRectGetMidX(entity.frame) > CGRectGetMinX(tile.frame)) {
                hitTestTile = tile;
                break;
            }
        }
        if (hitTestTile) {
            [hitTestTile hitTestEntity:entity];
        } else {
            for (RGMTile *tile in tiles) {
                [tile hitTestEntity:entity];
            }
        }
    }
}

- (NSArray *)tilesIntersectingEntityRect:(CGRect)entityRect edge:(CGRectEdge)edge {
    return [self.tileMap.obstacles objectsAtIndexes:[self.tileMap.obstacles indexesOfObjectsPassingTest:^BOOL(RGMTile *tile, NSUInteger idx, BOOL *stop) {
        CGRect tileRect = tile.frame;
        if (CGRectIntersectsRect(tile.frame, entityRect)) {
            switch (edge) {
                case CGRectMinXEdge:
                    return CGRectGetMinX(entityRect) <= CGRectGetMaxX(tileRect);
                case CGRectMaxXEdge:
                    return CGRectGetMaxX(entityRect) >= CGRectGetMinX(tileRect);
                case CGRectMinYEdge:
                    return CGRectGetMinY(entityRect) <= CGRectGetMaxY(tileRect);
                case CGRectMaxYEdge:
                    return CGRectGetMaxY(entityRect) >= CGRectGetMinY(tileRect);
            }
        }
        return NO;
    }]];
}

- (void)hitTestEntity:(RGMEntity *)entity
{
    CGRect frame = entity.frame;
    CGRect bounds = RGMFrameFromTile(CGPointMake(0, 0), CGPointMake(RGMFieldSize.width - 1, RGMFieldSize.height - 1));
    
    if (CGRectGetMinX(frame) < CGRectGetMinX(bounds)) {
        entity.x = CGRectGetMinX(bounds);
        entity.velocity = CGPointMake(0, entity.velocity.y);
    }
    
    if (CGRectGetMaxX(frame) > CGRectGetMaxX(bounds)) {
        entity.x = CGRectGetMaxX(bounds) - CGRectGetWidth(frame);
        entity.velocity = CGPointMake(0, entity.velocity.y);
    }
    
    if (CGRectGetMinY(frame) < CGRectGetMinY(bounds)) {
        entity.y = CGRectGetMinY(bounds);
        entity.velocity = CGPointMake(entity.velocity.x, 0);
        entity.canJump = YES;
    }
    
    [self hitTestAgainstOtherEntities:entity];
}

- (void)hitTestAgainstOtherEntities:(RGMEntity *)entity
{
    [self.entities enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([entity.identifier isEqual:key]) {
            return;
        }
        
        [entity hitTestWithEntity:obj];
    }];
}

- (void)didUpdate
{
    
}

- (void)addInput:(id)input toEntity:(RGMEntity *)entity
{
    NSParameterAssert(self.inputs[entity.identifier] == nil);
    [self.inputs setObject:input forKey:entity.identifier];
}

- (RGMEntity *)createEntity:(Class)entityClass identifier:(NSString *)identifier
{
    NSParameterAssert(entityClass != NULL && identifier.length > 0);
    RGMEntity *entity = [[entityClass alloc] initWithIdentifier:identifier];
    [self.entities setObject:entity forKey:identifier];
    entity.game = self;
    entity.x = RGMTileSize * 2;
    entity.y = RGMTileSize * 2;
    
    return entity;
}

- (void)destroyEntity:(NSString *)identifier
{
    NSParameterAssert(identifier.length > 0);
    [self.entities removeObjectForKey:identifier];
}

- (RGMEntity *)entityForIdentifier:(NSString *)identifier
{
    NSParameterAssert(identifier.length > 0);
    return [self.entities objectForKey:identifier];
}

@end
