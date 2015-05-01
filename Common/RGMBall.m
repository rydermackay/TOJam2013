//
//  RGMBall.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2015-05-01.
//  Copyright (c) 2015 Ryder Mackay. All rights reserved.
//

#import "RGMBall.h"
#import "RGMTile.h"

@implementation RGMBall

- (id)initWithIdentifier:(NSString *)identifier {
    if (self = [super initWithIdentifier:identifier]) {
        self.texture = [[SKTextureAtlas atlasNamed:@"Textures"] textureNamed:@"ball"];
        self.size = self.texture.size;
        self.velocity = CGPointMake(120, 500);
    }
    return self;
}

- (BOOL)hitTestWithTile:(RGMTile *)tile {
    CGPoint v = self.velocity;
    BOOL result = [super hitTestWithTile:tile];
    if (result) {
        if (v.y != self.velocity.y) {
            v.y *= -0.7;
        }
        if (v.x != self.velocity.x) {
            v.x *= -1;
        }
        self.velocity = v;
    }
    return result;
}

@end
