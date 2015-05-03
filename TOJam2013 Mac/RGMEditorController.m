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
    NSArray *sortedKeys = [self.tileMap.tileDefinitions.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *tileTypes = [NSMutableArray new];
    for (NSString *key in sortedKeys) {
        [tileTypes addObject:self.tileMap.tileDefinitions[key]];
    }
    self.tiles = tileTypes;
    self.tileView.tileMap = self.tileMap;
    self.tileView.editor = self;
}

- (RGMTileType *)currentType {
    return [self.arrayController selectedObjects].firstObject;
}

#pragma mark - Tile View

- (void)tileView:(RGMTileView *)tileView clickedTileAtPosition:(RGMTilePosition)position {
    [self setTileType:self.currentType atPosition:position];
}

- (void)setTileType:(RGMTileType *)type atPosition:(RGMTilePosition)position {
    RGMTileType *oldType = [self.tileMap tileAtPosition:position].type;
    if (oldType != type) {
        [[self.window.undoManager prepareWithInvocationTarget:self] setTileType:oldType atPosition:position];
        [self.tileMap setTileType:type position:position];
        [self.tileView setNeedsDisplayInRect:[self.tileView frameForTilePosition:position]];
    }
}

@end
