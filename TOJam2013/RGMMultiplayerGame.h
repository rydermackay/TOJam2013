//
//  RGMMultiplayerGame.h
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMGame.h"

@class GKMatch;
@class RGMEvent;

@interface RGMMultiplayerGame : RGMGame

- (id)initWithMapName:(NSString *)mapName match:(GKMatch *)match;

@property (nonatomic, strong, readonly) GKMatch *match;

- (void)enqueueEventForSending:(RGMEvent *)event;

@end
