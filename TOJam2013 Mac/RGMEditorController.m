//
//  RGMEditorController.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2014-04-26.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import "RGMEditorController.h"
#import "RGMTile.h"
#import "RGMTileMap.h"
#import "RGMTileView.h"

@interface RGMImageView : NSImageView

@end

@implementation RGMImageView

- (void)setLayer:(CALayer *)newLayer {
    newLayer.magnificationFilter = kCAFilterNearest;
    [super setLayer:newLayer];
}

@end

@interface RGMEditorController () <NSCollectionViewDelegate>
@property RGMTileMap *tileMap;
@property (copy) NSArray *tiles;
@property (weak) IBOutlet RGMTileView *tileView;
@property (weak) IBOutlet NSArrayController *arrayController;
@end

@implementation RGMEditorController

- (NSString *)windowNibName {
    return @"Editor";
}

- (void)windowDidLoad {
    NSMutableArray *tiles = [NSMutableArray array];
    for (NSNumber *number in [RGMTile tileTypes]) {
        [tiles addObject:[[RGMTile alloc] initWithTileType:number.unsignedIntegerValue position:(RGMTilePosition){0,0}]];
    }
    self.tiles = tiles;
    self.tileView.tileMap = self.tileMap;
    self.tileView.editor = self;
}

- (RGMTileType)currentType {
    return [(RGMTile *)[self.arrayController selectedObjects].firstObject type];
}

#pragma mark - Tile View

- (void)tileView:(RGMTileView *)tileView clickedTileAtPosition:(RGMTilePosition)position {
    [self setTileType:self.currentType atPosition:position];
}

- (void)setTileType:(RGMTileType)type atPosition:(RGMTilePosition)position {
    RGMTileType oldType = [self.tileMap tileTypeAtPosition:position];
    if (oldType != type) {
        [[self.window.undoManager prepareWithInvocationTarget:self] setTileType:oldType atPosition:position];
        [self.tileMap setTileType:type position:position];
        [self.tileView setNeedsDisplayInRect:[self.tileView frameForTilePosition:position]];
    }
}

@end
