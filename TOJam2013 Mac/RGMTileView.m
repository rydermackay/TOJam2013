//
//  RGMTileView.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2014-04-26.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import "RGMTileView.h"
#import "RGMDefines.h"
#import "RGMEditorController.h"

@implementation RGMTileView

- (BOOL)isFlipped {
    return YES;
}

- (NSUInteger)tileSize {
    return RGMTileSize * [self zoomFactor];
}

- (NSUInteger)zoomFactor {
    return 2;
}

- (NSSize)intrinsicContentSize {
    return NSMakeSize(self.tileMap.size.width * [self tileSize] , self.tileMap.size.height * [self tileSize]);
}

- (void)setTileMap:(RGMTileMap *)tileMap {
    _tileMap = tileMap;
    [self invalidateIntrinsicContentSize];
    [self setFrameSize:[self intrinsicContentSize]];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    for (RGMTile *tile in self.tileMap.tiles) {
        NSRect rect = [self frameForTilePosition:tile.position];
        if (NSIntersectsRect(dirtyRect, rect)) {
            [tile.image drawInRect:rect];
        }
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self.undoManager beginUndoGrouping];
    [self handleEvent:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    [self handleEvent:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self.undoManager endUndoGrouping];
}

- (void)handleEvent:(NSEvent *)theEvent {
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    RGMTilePosition position = [self tilePositionForPoint:point];
    if (position.x < self.tileMap.size.width && position.y < self.tileMap.size.height) {
        [self setTileType:self.editor.currentType position:position];
    }
}

- (void)setTileType:(RGMTileType)type position:(RGMTilePosition)position {
    RGMTileType oldType = [self.tileMap tileTypeAtPosition:position];
    if (oldType != type) {
        NSRect rect = [self frameForTilePosition:position];
        [[self.undoManager prepareWithInvocationTarget:self] setTileType:oldType position:position];
        [self.tileMap setTileType:type position:position];
        [self setNeedsDisplayInRect:rect];
    }
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
    CGFloat size = [self tileSize];
    CGFloat x = position.x * size;
    CGFloat y = (self.isFlipped ? self.tileMap.size.height - 1 - position.y : position.y) * size;
    return NSMakeRect(x, y, size, size);
}

@end
