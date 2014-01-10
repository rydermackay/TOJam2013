//
//  RGMTileMap.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGMTileMap : NSObject

- (id)initWithName:(NSString *)name;
@property (nonatomic, copy, readonly) NSArray *obstacles;

@end
