//
//  RGMBug.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2015-05-01.
//  Copyright (c) 2015 Ryder Mackay. All rights reserved.
//

#import "RGMBug.h"
#import "RGMTile.h"
#import "RGMGame.h"

@implementation RGMBug

- (id)initWithIdentifier:(NSString *)identifier {
    if (self = [super initWithIdentifier:identifier]) {
        self.texture = [[SKTextureAtlas atlasNamed:@"Textures"] textureNamed:@"bug"];
        self.size = self.texture.size;
        self.velocity = CGPointMake(-20, self.velocity.y);
    }
    return self;
}

- (BOOL)hitTestWithTile:(RGMTile *)tile {
    CGPoint v = self.velocity;
    BOOL result = [super hitTestWithTile:tile];
    if (result && self.velocity.x != v.x) {
        v.x = -v.x;
        self.velocity = v;
    }
    return result;
}

- (void)updateForDuration:(NSTimeInterval)interval {
    [super updateForDuration:interval];
    
    RGMEntity *player = self.game.localPlayer;
    if (fabs([self distanceFrom:player].x) >= RGMTileSize * 2) {
        if ([self isMovingTowards:player axis:RGMAxisHorizontal]) {
            self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
        }
    }
}

@end
