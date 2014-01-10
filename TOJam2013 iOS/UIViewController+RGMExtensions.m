//
//  UIViewController+RGMExtensions.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "UIViewController+RGMExtensions.h"

@implementation UIViewController (RGMExtensions)

- (void)rgm_presentError:(NSError *)error
{
    if (!error) {
        return;
    }
    
    [[[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
