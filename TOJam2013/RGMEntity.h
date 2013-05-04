//
//  RGMEntity.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGMEntity : NSObject

- (id)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, strong) UIImage *image;

- (NSDictionary *)serializedCopy;
- (void)setValuesWithJSON:(NSDictionary *)JSON;

- (void)updateForDuration:(NSTimeInterval)interval;

- (void)jump;
- (void)endJump;

@end
