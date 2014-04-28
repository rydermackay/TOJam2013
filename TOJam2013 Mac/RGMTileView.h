//
//  RGMTileView.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2014-04-26.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RGMTileMap.h"

@class RGMEditorController;

@interface RGMTileView : NSView

@property (nonatomic) RGMTileMap *tileMap;
@property (weak) RGMEditorController *editor;

- (RGMTilePosition)tilePositionForPoint:(NSPoint)point;
- (NSRect)frameForTilePosition:(RGMTilePosition)position;

@end
