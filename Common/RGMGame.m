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
#import "RGMBug.h"

@implementation RGMGame {
    long long _bugSpawnCounter;
}

- (instancetype)initWithMapName:(NSString *)mapName
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
    
    [self spawnBug];
}

- (void)spawnBug {
    RGMEntity *bug = [self createEntity:[RGMBug class] identifier:[NSUUID UUID].UUIDString];
    bug.x = self.localPlayer.x + arc4random_uniform(100) - 50;
    bug.y += 25 + arc4random_uniform(100);
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
        if ([entity isKindOfClass:[RGMPredator class]]) {
            if (inputMask & RGMInputMaskFire) {
                [(RGMPredator *)entity fire];
            } else {
                [(RGMPredator *)entity resetFire];
            }
        }
        
        const CGFloat maxHorizontalVelocity = 120;
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
        CGFloat dx = entity.remainderPosition.x + entity.velocity.x * duration;
        CGFloat dy = entity.remainderPosition.y + entity.velocity.y * duration;
        entity.remainderPosition = CGPointMake(dx - round(dx), dy - round(dy));
        [self stepEntity:entity axis:RGMAxisHorizontal amount:round(dx)];
        [self stepEntity:entity axis:RGMAxisVertical   amount:round(dy)];
    }];
    
    _bugSpawnCounter++;
    if (_bugSpawnCounter > 60*1.5) {
        [self spawnBug];
        _bugSpawnCounter = 0;
    }
    
    [self didUpdate];
}

- (void)stepEntity:(RGMEntity *)entity axis:(RGMAxis)axis amount:(NSInteger)amount {
    if (amount == 0) {
        return;
    }
    CGRect fromRect = entity.frame;
    CGRectEdge edge;
    if (axis == RGMAxisHorizontal) {
        edge = amount > 0 ? CGRectMaxXEdge : CGRectMinXEdge;
        entity.x += amount;
    } else {
        edge = amount > 0 ? CGRectMaxYEdge : CGRectMinYEdge;
        entity.y += amount;
    }
    [self hitTestEntity:entity];
    
    NSArray *tiles = [[self tilesIntersectingEntityRect:entity.frame edge:edge] copy];
    for (RGMTile *tile in [tiles copy]) {
        if (tile.mask & (RGMObstacleMaskSlopeLeft | RGMObstacleMaskSlopeRight) &&
            CGRectGetMidX(entity.frame) <= CGRectGetMaxX(tile.frame) &&
            CGRectGetMidX(entity.frame) > CGRectGetMinX(tile.frame)) {
            tiles = @[tile];
            break;
        }
    }
    for (RGMTile *tile in tiles) {
        [entity hitTestWithTile:tile fromRect:fromRect proposedRect:entity.frame];
    }
    
    [self.entities enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([entity.identifier isEqual:key]) {
            return;
        }
        
        RGMHitTestMask mask = [entity hitTestWithEntity:obj fromRect:fromRect proposedRect:entity.frame];
        if (mask != RGMHitTestNone) {
            [entity didHitEntity:obj mask:mask];
            *stop = YES; // can only interact w/ one entity per frame?!
        }
    }];
}

- (NSArray *)tilesIntersectingEntityRect:(CGRect)entityRect edge:(CGRectEdge)edge {
    return [self.tileMap.tiles objectsAtIndexes:[self.tileMap.tiles indexesOfObjectsPassingTest:^BOOL(RGMTile *tile, NSUInteger idx, BOOL *stop) {
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

- (void)hitTestEntity:(RGMEntity *)entity {
    
    CGRect frame = entity.frame;
    CGRect bounds = RGMFrameFromTile(CGPointMake(0, 0), CGPointMake(self.tileMap.size.width - 1, self.tileMap.size.height - 1));
    
    // prevent player from escaping along x-axis
    if (entity == self.localPlayer) {
        if (CGRectGetMinX(frame) < CGRectGetMinX(bounds)) {
            entity.x = CGRectGetMinX(bounds);
            entity.velocity = CGPointMake(0, entity.velocity.y);
        }
        if (CGRectGetMaxX(frame) > CGRectGetMaxX(bounds)) {
            entity.x = CGRectGetMaxX(bounds) - CGRectGetWidth(frame);
            entity.velocity = CGPointMake(0, entity.velocity.y);
        }
    }
    
    // kill everyone else
    if (!CGRectIntersectsRect(frame, bounds)) {
        [self destroyEntity:entity.identifier];
    }
}

- (void)didUpdate
{
    
}

- (void)addInput:(id <RGMInput>)input toEntity:(RGMEntity *)entity
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
