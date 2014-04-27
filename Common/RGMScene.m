//
//  RGMScene.m
//  TOJam2013
//
//  Created by Ryder Mackay on 1/9/2014.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import "RGMScene.h"
#import "RGMInput.h"
#import <TargetConditionals.h>
#import "RGMGame.h"
#import "RGMTileMap.h"
#import "RGMTile.h"
#import "RGMEntity.h"

#if !TARGET_OS_IPHONE
#import <Carbon/Carbon.h>
#endif

@implementation RGMScene {
    SKSpriteNode *_sprite;
    RGMInputMask _inputMask;
    
    NSMutableArray *_obstacleNodes;
    NSMutableDictionary *_entityNodes;
}

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        _entityNodes = [NSMutableDictionary new];
        _world = [SKNode node];
        _world.name = @"world";
        [self insertChild:_world atIndex:0];
    }
    
    return self;
}

- (void)loadMap
{
    _obstacleNodes = [NSMutableArray new];
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Textures"];
    [atlas preloadWithCompletionHandler:^{}];
    [self.game.tileMap.obstacles enumerateObjectsUsingBlock:^(RGMTile *obstacle, NSUInteger idx, BOOL *stop) {
        SKSpriteNode *node = [SKSpriteNode node];
        node.size = obstacle.frame.size;
        node.anchorPoint = CGPointZero;
        node.position = CGPointMake(CGRectGetMinX(obstacle.frame), CGRectGetMinY(obstacle.frame));
        node.texture = [SKTexture textureWithImageNamed:[obstacle textureName]];
        node.texture.filteringMode = SKTextureFilteringNearest;
        
        [_obstacleNodes addObject:node];
        [_world insertChild:node atIndex:0];
    }];
}

- (void)update:(CFTimeInterval)currentTime {
    
    // collect inputs
    
    if (!_obstacleNodes) {
        [self loadMap];
    }
    
    [self.game update:currentTime];
    
    for (NSString *identifier in self.game.identifiers) {
        RGMEntity *entity = [self.game entityForIdentifier:identifier];
        SKSpriteNode *node = [_entityNodes objectForKey:identifier];
        if (node == nil) {
            node = [SKSpriteNode new];
            _entityNodes[identifier] = node;
            [self.world addChild:node];
        }
        node.hidden = NO;
        node.size = entity.frame.size;
        node.position = CGPointMake(entity.x + floorf(CGRectGetWidth(node.frame) * 0.5),
                                    entity.y + floorf(CGRectGetHeight(node.frame) * 0.5));
//        node.texture = entity.image ? [SKTexture textureWithCGImage:entity.image.CGImage] : nil;
        node.color = [entity color] ?: [SKColor yellowColor];
        if (entity.isInvincible && ((NSInteger)((currentTime) * 5) % 2 == 0)) {
            node.hidden = YES;
        }
    }
    
    SKSpriteNode *node = _entityNodes[@"me"];
    const CGFloat minDistance = RGMTileSize * 8;
    CGPoint playerPosition = [self convertPoint:node.position fromNode:self.world];
    CGPoint worldPosition = self.world.position;
    if (playerPosition.x < minDistance) {
        worldPosition.x += minDistance - playerPosition.x;
        if (worldPosition.x > 0) {
            worldPosition.x = 0;
        }
    } else if (playerPosition.x >= CGRectGetWidth(self.frame) - minDistance) {
        worldPosition.x += CGRectGetWidth(self.frame) - playerPosition.x - minDistance;
        CGRect worldFrame = self.world.calculateAccumulatedFrame;
        if (worldPosition.x < CGRectGetWidth(self.frame) - CGRectGetWidth(worldFrame)) {
            worldPosition.x = CGRectGetWidth(self.frame) - CGRectGetWidth(worldFrame);
        }
    }
    self.world.position = worldPosition;
}

#if !TARGET_OS_IPHONE

// http://boredzo.org/blog/archives/2007-05-22/virtual-key-codes

static inline RGMInputMask RGMInputMaskFromKeyCode(unsigned short keyCode) {
    switch (keyCode) {
        case kVK_Space:
            return RGMInputMaskJump;
        case kVK_LeftArrow:
            return RGMInputMaskLeft;
        case kVK_RightArrow:
            return RGMInputMaskRight;
        case kVK_DownArrow:
            return RGMInputMaskDown;
        case kVK_UpArrow:
            return RGMInputMaskUp;
        default:
            return 0;
    }
}

- (void)keyDown:(NSEvent *)event {
    [self handleKeyEvent:event keyDown:YES];
}

- (void)keyUp:(NSEvent *)event {
    [self handleKeyEvent:event keyDown:NO];
}

- (void)handleKeyEvent:(NSEvent *)event keyDown:(BOOL)keyDown {
    if (keyDown) {
        _inputMask |= RGMInputMaskFromKeyCode([event keyCode]);
    } else {
        _inputMask &= ~RGMInputMaskFromKeyCode([event keyCode]);
    }
}

- (RGMInputMask)inputMask {
    return _inputMask;
}

#endif

@end
