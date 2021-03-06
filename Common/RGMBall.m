//
//  RGMBall.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2015-05-01.
//  Copyright (c) 2015 Ryder Mackay. All rights reserved.
//

#import "RGMBall.h"
#import "RGMTile.h"
#import "RGMGame.h"
#import "RGMBug.h"

@implementation RGMBall

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self = [super initWithIdentifier:identifier]) {
        self.texture = [[SKTextureAtlas atlasNamed:@"Textures"] textureNamed:@"ball"];
        self.size = self.texture.size;
    }
    return self;
}

- (RGMHitTestMask)hitTestWithTile:(RGMTile *)tile fromRect:(CGRect)fromRect proposedRect:(CGRect)proposedRect {
    CGPoint v = self.velocity;
    RGMHitTestMask mask = [super hitTestWithTile:tile fromRect:fromRect proposedRect:proposedRect];
    if (mask & (RGMHitTestTop | RGMHitTestBottom)) {
        v.y *= -0.9;
    }
    if (mask & (RGMHitTestLeft | RGMHitTestRight)) {
        v.x *= -1;
    }
    self.velocity = v;
    return mask;
}

- (void)didHitEntity:(RGMEntity *)entity mask:(RGMHitTestMask)mask {
    if ([entity isKindOfClass:[RGMBug class]]) {
        [self.game destroyEntity:entity.identifier];
        [self.game destroyEntity:self.identifier];
    }
}

@end
