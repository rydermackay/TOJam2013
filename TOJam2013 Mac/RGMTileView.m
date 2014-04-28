//
//  RGMTileView.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2014-04-26.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import "RGMTileView.h"
#import "RGMDefines.h"

@implementation RGMTileView

- (BOOL)isFlipped {
    return YES;
}

- (NSUInteger)zoomFactor {
    return 2;
}

- (void)setTileMap:(RGMTileMap *)tileMap {
    _tileMap = tileMap;
    CGFloat size = RGMTileSize * [self zoomFactor];
    [self setFrameSize:NSMakeSize(_tileMap.size.width * size, _tileMap.size.height * size)];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    [self.tileMap enumerateTilesWithBlock:^(RGMTile *tile, RGMTilePosition position) {
        NSRect rect = [self frameForTilePosition:position];
        if (NSIntersectsRect(dirtyRect, rect)) {
            [tile.image drawInRect:rect];
        }
    }];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    RGMTilePosition position = [self tilePositionForPoint:point];
}

- (RGMTilePosition)tilePositionForPoint:(NSPoint)point {
    CGFloat x = floor(self.tileMap.size.width / NSWidth(self.bounds) * point.x);
    CGFloat y = floor(self.tileMap.size.height / NSHeight(self.bounds) * point.y);
    if (self.isFlipped) {
        y = self.tileMap.size.height - 1 - y;
    }
    return (RGMTilePosition){x,y};
}

- (NSRect)frameForTilePosition:(RGMTilePosition)position {
    CGFloat x = floor(NSWidth(self.bounds) / self.tileMap.size.width * position.x);
    CGFloat y = floor(NSHeight(self.bounds) / self.tileMap.size.height * position.y);
    return NSMakeRect(x, y, RGMTileSize * [self zoomFactor], RGMTileSize * [self zoomFactor]);
}

@end
