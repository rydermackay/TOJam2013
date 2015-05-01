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
    const CGPoint v = self.velocity;
    BOOL result = [super hitTestWithTile:tile];
    if (result && (tile.mask & RGMTileSolidTop)) {  // …but you don't actually know if it collided BECAUSE it hit the top!!
        self.velocity = CGPointMake(v.x, v.y * -0.7);
    }
    return result;
}

@end
