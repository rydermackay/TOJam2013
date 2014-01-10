//
//  RGMDefines.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

extern CGFloat  RGMTileSize;
extern CGSize   RGMFieldSize;

extern CGRect RGMFrameFromTile(CGPoint from, CGPoint to);
extern CGRect RGMFrameForTile(CGPoint tile);