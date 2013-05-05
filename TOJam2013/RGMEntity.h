//
//  RGMEntity.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSTimeInterval invincibilityDuration;

@class RGMGame;

@interface RGMEntity : NSObject <NSCoding>

- (id)initWithIdentifier:(NSString *)identifier;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;
@property (nonatomic, assign) CGRect frameBeforeStepping;
@property (nonatomic, assign) CGSize size;
- (CGRect)frame;

@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *color;

- (void)updateForDuration:(NSTimeInterval)interval;

@property (nonatomic, assign, getter = isInvincible) BOOL invincible;
- (void)reset;

@property (nonatomic, assign) BOOL canJump;
- (void)jump;
- (void)endJump;


- (BOOL)hitTestWithEntity:(RGMEntity *)entity;

@property (nonatomic, weak) RGMGame *game;

@end
