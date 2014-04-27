//
//  RGMEditorController.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2014-04-26.
//  Copyright (c) 2014 Ryder Mackay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RGMEditorController : NSWindowController
@property (nonatomic, copy, readonly) NSArray *tiles;
@end

@interface RGMTileCollectionViewItem : NSCollectionViewItem

@end
