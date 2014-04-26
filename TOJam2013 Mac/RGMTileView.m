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

- (CGFloat)zoomFactor {
    return 2;
}

- (NSSize)intrinsicContentSize {
    return NSMakeSize(RGMFieldSize.width * RGMTileSize * [self zoomFactor],
                      RGMFieldSize.height * RGMTileSize * [self zoomFactor]);
}

- (void)drawRect:(NSRect)dirtyRect {
    
}

@end
