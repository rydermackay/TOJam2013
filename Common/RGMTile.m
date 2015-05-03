//
//  RGMObstacle.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMTile.h"

@implementation RGMTileType

- (instancetype)initWithJSONObject:(NSDictionary * __nonnull)JSONObject {
    NSObject <NSCopying, NSCoding> *identifier = JSONObject[@"id"];
    RGMObstacleMask mask = [JSONObject[@"mask"] unsignedIntegerValue];
    NSString *imageName = JSONObject[@"imageName"];
    NSString *name = JSONObject[@"name"];
    return [self initWithIdentifier:identifier mask:mask imageName:imageName name:name];
}

- (instancetype)initWithIdentifier:(NSObject <NSCoding, NSCopying> *__nonnull)identifier mask:(RGMObstacleMask)mask imageName:(NSString * __nonnull)imageName name:(NSString * __nullable)name {
    if (self = [super init]) {
        _identifier = [identifier copy];
        _imageName = [imageName copy];
        _name = [name copy];
        _mask = mask;
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

@end

@implementation RGMTile

@dynamic mask, imageName; // forwarded

- (instancetype)initWithType:(RGMTileType * __nonnull)type position:(RGMTilePosition)position {
    NSParameterAssert(type != nil);
    if (self = [super init]) {
        _type = [type copy];
        _position = position;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.type respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.type;
}

- (CGRect)frame {
    return RGMFrameForTilePosition(self.position);
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

@end

#if !TARGET_OS_IPHONE

@implementation RGMTileType (Editor)

+ (NSArray *)tileTypes {
    return nil;
}

- (NSImage *)image {
    return [NSImage imageNamed:self.imageName];
}

@end

@implementation RGMTile (Editor)

@dynamic image;

@end

#endif // !TARGET_OS_IPHONE