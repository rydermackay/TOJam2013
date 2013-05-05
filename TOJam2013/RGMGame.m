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
#import "RGMObstacle.h"

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

- (void)updateWithTimestamp:(NSTimeInterval)timestamp duration:(NSTimeInterval)duration
{
    [self willUpdate];
    
    // test fixed rate
    duration = 1.0/60.0;
    
    // apply input
    [self.inputs enumerateKeysAndObjectsUsingBlock:^(NSString *key, id <RGMInput> input, BOOL *stop) {
        RGMEntity *entity = [self entityForIdentifier:key];
        RGMInputMask inputMask = [input inputMask];
        if (inputMask & RGMInputMaskJump) {
            [entity jump];
        } else {
            [entity endJump];
        }
        
        const CGFloat maxHorizontalVelocity = 500;
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
    
    // update forces
    [self.entities enumerateKeysAndObjectsUsingBlock:^(NSString *key, RGMEntity *entity, BOOL *stop) {
        
        [entity updateForDuration:duration];
        if ([entity isKindOfClass:[RGMPrey class]] && [(RGMPrey *)entity isCaptured]) {
            return;
        }
        
        entity.frameBeforeStepping = entity.frame;
        
        NSInteger dx = entity.velocity.x * duration;
        NSInteger dy = entity.velocity.y * duration;
        
        if (dx > 0) {
            for (NSInteger i = 0; i < dx; i++) {
                entity.x++;
                [self hitTestEntity:entity];
                for (RGMObstacle *obstacle in self.tileMap.obstacles) {
                    [obstacle hitTestEntity:entity];
                }
            }
        } else if (dx < 0) {
            for (NSInteger i = 0; i > dx; i--) {
                entity.x--;
                [self hitTestEntity:entity];
                for (RGMObstacle *obstacle in self.tileMap.obstacles) {
                    [obstacle hitTestEntity:entity];
                }
            }
        }
        
        // step y, check collisions
        if (dy > 0) {
            for (NSInteger i = 0; i < dy; i++) {
                entity.y++;
                [self hitTestEntity:entity];
                for (RGMObstacle *obstacle in self.tileMap.obstacles) {
                    [obstacle hitTestEntity:entity];
                }
            }
        } else if (dy < 0) {
            for (NSInteger i = 0; i > dy; i--) {
                entity.y--;
                [self hitTestEntity:entity];
                for (RGMObstacle *obstacle in self.tileMap.obstacles) {
                    [obstacle hitTestEntity:entity];
                }
            }
        }
        
        entity.frameBeforeStepping = CGRectZero;
    }];
    
    [self didUpdate];
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
    
    if (CGRectGetMaxY(frame) > CGRectGetMaxY(bounds)) {
        entity.y = CGRectGetMaxY(bounds) - CGRectGetHeight(frame);
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
    id entity = [[entityClass alloc] initWithIdentifier:identifier];
    [self.entities setObject:entity forKey:identifier];
    
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
