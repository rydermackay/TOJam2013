//
//  RGMSprite.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGMSprite : NSObject

- (id)initWithImage:(UIImage *)image;
- (void)render;

- (void)setImage:(UIImage *)image;

@end
