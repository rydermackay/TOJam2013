//
//  RGMEvent.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RGMEventType) {
    RGMEventTypeCreate,
    RGMEventTypeUpdate,
    RGMEventTypeDestroy,
    RGMEventTypeCapture,
    RGMEventTypeEscape,
};

extern NSString * const RGMEventPreyKey;        // identifier
extern NSString * const RGMEventPredatorKey;    // identifier
extern NSString * const RGMEventIdentifierKey;  // identifier
extern NSString * const RGMEventAttributesKey;  // attributes

@interface RGMEvent : NSObject <NSCoding>

+ (instancetype)eventWithType:(RGMEventType)type userInfo:(NSDictionary *)userInfo;
- (id)initWithType:(RGMEventType)type userInfo:(NSDictionary *)userInfo;

@property (nonatomic, assign, readonly) RGMEventType type;
@property (nonatomic, copy, readonly) NSDictionary *userInfo;
@property (nonatomic, strong, readonly) NSDate *date;

@end
