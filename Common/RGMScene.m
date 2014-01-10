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
#import "RGMObstacle.h"
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
    }
    
    return self;
}

- (void)loadMap
{
    _obstacleNodes = [NSMutableArray new];
    
    [self.game.tileMap.obstacles enumerateObjectsUsingBlock:^(RGMObstacle *obstacle, NSUInteger idx, BOOL *stop) {
        SKSpriteNode *node = [SKSpriteNode node];
        node.size = obstacle.frame.size;
        node.position = CGPointMake(CGRectGetMinX(obstacle.frame) + floorf(CGRectGetWidth(node.frame) * 0.5),
                                    CGRectGetMinY(obstacle.frame) + floorf(CGRectGetHeight(node.frame) * 0.5));
        
        if (obstacle.mask == RGMObstacleMaskSolid) {
            node.texture = [SKTexture textureWithImageNamed:@"tile-solid"];
        } else if (obstacle.mask == RGMObstacleMaskSolidTop) {
            node.texture = [SKTexture textureWithImageNamed:@"tile-top"];
        }
        
        [_obstacleNodes addObject:node];
        [self addChild:node];
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
            [self addChild:node];
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

- (void)keyDown:(NSEvent *)theEvent {
    _inputMask |= RGMInputMaskFromKeyCode([theEvent keyCode]);
}

- (void)keyUp:(NSEvent *)theEvent {
    _inputMask &= ~RGMInputMaskFromKeyCode([theEvent keyCode]);
}

- (RGMInputMask)inputMask
{
    return _inputMask;
}

#endif

@end
