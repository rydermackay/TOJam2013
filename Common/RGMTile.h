//
//  RGMObstacle.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

@import Foundation;

@class RGMTileMap;

NS_ASSUME_NONNULL_BEGIN

@interface RGMTileType : NSObject <NSCopying>

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject;
- (instancetype)initWithIdentifier:(id <NSCoding, NSCopying>)identifier mask:(RGMObstacleMask)mask imageName:(NSString *)imageName name:(NSString * __nullable)name NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) id <NSCoding, NSCopying> identifier; // key into tile map def
@property (nonatomic, readonly) RGMObstacleMask mask;
@property (nonatomic, copy, readonly) NSString *imageName;
@property (nonatomic, copy, readonly) NSString *__nullable name;

@end

@interface RGMTile : NSObject <NSCopying>
- (instancetype)initWithType:(RGMTileType *)type position:(RGMTilePosition)position;
@property (nonatomic, readonly) RGMTileType *type;
@property (nonatomic, readonly) RGMObstacleMask mask;   // forwarded to type
@property (nonatomic, readonly) NSString *imageName;    // forwarded to type

// instance-specific
@property (nonatomic, readonly) RGMTilePosition position;
@property (nonatomic, readonly) CGRect frame;   // calculated from position

@end



#if !TARGET_OS_IPHONE

@interface RGMTileType (Editor)
@property (nonatomic, readonly) NSImage *image;
@end

@interface RGMTile (Editor)
@property (nonatomic, readonly) NSImage *image;
@end

#endif // !TARGET_OS_IPHONE

NS_ASSUME_NONNULL_END
