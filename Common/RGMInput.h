//
//  RGMInput.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, RGMInputMask) {
    RGMInputMaskJump    = 1,
    RGMInputMaskLeft    = 1 << 1,
    RGMInputMaskRight   = 1 << 2,
    RGMInputMaskUp      = 1 << 3,
    RGMInputMaskDown    = 1 << 4
};

@protocol RGMInput <NSObject>

- (RGMInputMask)inputMask;

@end
