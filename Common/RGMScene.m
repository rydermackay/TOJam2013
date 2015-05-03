//
//  RGMScene.m
//  TOJam2013
//
//  Created by Ryder Mackay on 1/9/2014.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import "RGMScene.h"
#import "RGMInput.h"
#import "RGMGame.h"
#import "RGMTileMap.h"
#import "RGMTile.h"
#import "RGMEntity.h"
#import "RGMBug.h"

#if !TARGET_OS_IPHONE
#import <Carbon/Carbon.h>
#endif

@implementation RGMScene {
    SKSpriteNode *_sprite;
    RGMInputMask _inputMask;
    
    NSMutableArray *_obstacleNodes;
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
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
    [self.game.tileMap enumerateTiles:^(RGMTile *tile) {
        SKSpriteNode *node = [SKSpriteNode node];
        node.size = tile.frame.size;
        node.anchorPoint = CGPointZero;
        node.position = tile.frame.origin;
        node.texture = [SKTexture textureWithImageNamed:tile.imageName];
        node.texture.filteringMode = SKTextureFilteringNearest;
        node.blendMode = SKBlendModeReplace;
        
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
        SKSpriteNode *node = self.world[identifier].firstObject;
        if (node == nil) {
            node = [SKSpriteNode new];
            [self.world addChild:node];
            node.texture = entity.texture ?: entity.image ? [SKTexture textureWithImage:entity.image] : nil;    // this is so dumb
            node.texture.filteringMode = SKTextureFilteringNearest;
            node.hidden = NO;
            node.size = entity.size;  // setting size & xScale at the same time doesn't work
            node.name = identifier;
        }
        node.position = CGPointMake(entity.x + floorf(CGRectGetWidth(node.frame) * 0.5),
                                    entity.y + floorf(CGRectGetHeight(node.frame) * 0.5));
        
#warning wat
        if ([entity isKindOfClass:[RGMBug class]]) {
            NSString *key = @"bug-walk";
            if (![node actionForKey:key]) {
                SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Textures"];
                NSArray *textures = @[[atlas textureNamed:@"bug"], [atlas textureNamed:@"bug2"]];
                SKAction *action = [SKAction animateWithTextures:textures timePerFrame:1.0/10.0];
                [node runAction:action withKey:key];
            }
        }
        node.xScale = entity.velocity.x >= 0 ? -1.0 : 1.0;
        node.color = [entity color] ?: [SKColor yellowColor];
        if (entity.isInvincible && ((NSInteger)((currentTime) * 5) % 2 == 0)) {
            node.hidden = YES;
        }
    }
    
    NSMutableSet *nodesToKill = [NSMutableSet set];
    for (SKNode *node in _world.children) {
        if (node.name != nil && ![self.game.identifiers containsObject:node.name]) {
            [nodesToKill addObject:node];
        }
    }
    [nodesToKill makeObjectsPerformSelector:@selector(removeFromParent)];
    
    SKSpriteNode *node = self.world[@"me"].firstObject;
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
        case kVK_ANSI_Z:
            return RGMInputMaskFire;
        case kVK_ANSI_X:
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
