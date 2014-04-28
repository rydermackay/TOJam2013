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

@interface RGMEditorController () <NSCollectionViewDelegate>
@property (nonatomic, copy) NSArray *tiles;
@property (nonatomic) RGMTileMap *tileMap;
@property (nonatomic, strong) NSMutableArray *map;
@property (weak) IBOutlet RGMTileView *tileView;
@end

@implementation RGMEditorController

- (NSString *)windowNibName {
    return @"Editor";
}

- (void)windowDidLoad {
    self.tileView.tileMap = self.tileMap;
    [self.tileView setNeedsDisplay:YES];
}

- (NSArray *)tiles {
    if (!_tiles) {
        NSMutableArray *tiles = [NSMutableArray array];
        for (NSNumber *number in [RGMTile tileTypes]) {
            RGMTile *tile = [[RGMTile alloc] initWithTileType:number.unsignedIntegerValue];
            if (tile) {
                [tiles addObject:tile];
            }
        }
        _tiles = tiles;
    }
    return _tiles;
}

- (IBAction)reload:(id)sender {
    
}

@end
