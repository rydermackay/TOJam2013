//
//  RGMEvent.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMEvent.h"

NSString * const RGMEventPreyKey        = @"prey";
NSString * const RGMEventPredatorKey    = @"predator";
NSString * const RGMEventIdentifierKey  = @"identifier";
NSString * const RGMEventAttributesKey  = @"attributes";

@interface RGMEvent ()

@property (nonatomic, assign, readwrite) RGMEventType type;
@property (nonatomic, copy, readwrite) NSDictionary *userInfo;
@property (nonatomic, strong, readwrite) NSDate *date;

@end


@implementation RGMEvent

+ (instancetype)eventWithType:(RGMEventType)type userInfo:(NSDictionary *)userInfo
{
    return [[self alloc] initWithType:type userInfo:userInfo];
}

- (instancetype)initWithType:(RGMEventType)type userInfo:(NSDictionary *)userInfo
{
    if (self = [super init]) {
        _type = type;
        
        switch (type) {
            case RGMEventTypeCreate:
            case RGMEventTypeUpdate:
                NSParameterAssert(userInfo[RGMEventIdentifierKey] && userInfo[RGMEventAttributesKey]);
                break;
            case RGMEventTypeDestroy:
                NSParameterAssert(userInfo[RGMEventIdentifierKey]);
                break;
            case RGMEventTypeCapture:
            case RGMEventTypeEscape:
                NSParameterAssert(userInfo[RGMEventPredatorKey] && userInfo[RGMEventPreyKey]);
                break;
            default:
                break;
        }
        
        _userInfo = [userInfo copy];
        _date = [NSDate date];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _type = [aDecoder decodeIntegerForKey:@"type"];
        _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        _date = [aDecoder decodeObjectForKey:@"date"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

@end
