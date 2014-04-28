//
//  RGMEditorController.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2014-04-26.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RGMTile.h"

@class RGMTileView;

@interface RGMEditorController : NSWindowController

- (void)tileView:(RGMTileView *)tileView clickedTileAtPosition:(RGMTilePosition)position;

@end
