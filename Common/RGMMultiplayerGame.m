//
//  RGMMultiplayerGame.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMMultiplayerGame.h"
#import "RGMGame_Private.h"
#import "RGMEvent.h"
#import "RGMPrey.h"
#import "RGMPredator.h"

@interface RGMMultiplayerGame () <GKMatchDelegate>

@property (nonatomic, copy) NSString *hostPlayer;
@property (nonatomic, strong) GKVoiceChat *chat;
@property (nonatomic, strong) NSTimer *transmissionTimer;
@property (nonatomic, strong) NSMutableDictionary *lastEventByPlayerID;
@property (nonatomic, strong) NSMutableArray *eventProcessingQueue;
@property (nonatomic, strong) NSMutableArray *eventSendingQueue;

- (void)enqueueEventForProcessing:(RGMEvent *)event;
- (void)enqueueEventForSending:(RGMEvent *)event;
- (void)processEvents;
- (void)sendEvents;

@end



@implementation RGMMultiplayerGame

- (id)initWithMapName:(NSString *)mapName match:(GKMatch *)match
{
    NSParameterAssert(match);
    if (self = [super initWithMapName:mapName]) {
        _match = match;
        _match.delegate = self;
        _lastEventByPlayerID = [NSMutableDictionary new];
        _eventProcessingQueue = [NSMutableArray new];
        _eventSendingQueue = [NSMutableArray new];
    }
    
    return self;
}

- (void)start
{
    _chat = [self.match voiceChatWithName:@"Chat"];
    [_chat start];
    _chat.active = YES;
    
    [self loadImagesForPlayers:_match.playerIDs];
    
    const NSTimeInterval transmissionRate = 1.0f / 60.f * 2.0f;
    _transmissionTimer = [[NSTimer alloc] initWithFireDate:nil interval:transmissionRate target:self selector:@selector(transmitData) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_transmissionTimer forMode:NSRunLoopCommonModes];
    
    if ([self isHostPlayer]) {
        for (NSString *player in _match.playerIDs) {
            [self createEntity:[RGMPrey class] identifier:player];
        }
        
        [self createEntity:[RGMPredator class] identifier:[GKLocalPlayer localPlayer].playerID];
    }
}

- (void)loadImagesForPlayers:(NSArray *)players
{
    NSParameterAssert(players.count > 0);
    
    [GKPlayer loadPlayersForIdentifiers:players
                  withCompletionHandler:^(NSArray *players, NSError *error) {
                      if (players) {
                          for (GKPlayer *player in players) {
                              [player loadPhotoForSize:GKPhotoSizeNormal
                                 withCompletionHandler:^(id photo, NSError *error) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (photo) {
                                             [self entityForIdentifier:player.playerID].image = photo;
                                         } else {
                                             NSLog(@"error loading photo: %@", error);
                                         }
                                     });
                                 }];
                          }
                      } else {
                          NSLog(@"error loading players: %@", error);
                      }
                  }];
}

- (void)transmitData
{
    void (^action)(NSString *, RGMEntity *) = ^(NSString *identifier, RGMEntity *entity){
        NSDictionary *userInfo = @{RGMEventIdentifierKey : identifier, RGMEventAttributesKey : entity};
        RGMEvent *event = [RGMEvent eventWithType:RGMEventTypeUpdate userInfo:userInfo];
        [self enqueueEventForSending:event];
    };
    
    if ([self isHostPlayer]) {
        [self.entities enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, RGMEntity *entity, BOOL *stop) {
            action(identifier, entity);
        }];
    } else {
        NSString *identifier = [GKLocalPlayer localPlayer].playerID;
        RGMEntity *entity = [self entityForIdentifier:identifier];
        if (!entity) {
            return;
        }
        action(identifier, entity);
    }
}

- (NSString *)hostPlayer
{
    NSArray *IDs = [self.match.playerIDs arrayByAddingObject:[GKLocalPlayer localPlayer].playerID];
    return [IDs sortedArrayUsingSelector:@selector(compare:)][0];
}

- (BOOL)isHostPlayer
{
    return [[GKLocalPlayer localPlayer].playerID isEqual:[self hostPlayer]];
}

- (void)end
{
    [super end];
    
    [_transmissionTimer invalidate];
    [_match disconnect];
}

#pragma mark - Overrides

- (RGMEntity *)createEntity:(Class)entityClass identifier:(NSString *)identifier
{
    [super createEntity:entityClass identifier:identifier];

    RGMEntity *entity = self.entities[identifier];
    
    if ([identifier isEqual:[GKLocalPlayer localPlayer].playerID]) {
        self.localPlayer = entity;
    }
    
    RGMEvent *event = [RGMEvent eventWithType:RGMEventTypeCreate userInfo:@{ RGMEventIdentifierKey : identifier, RGMEventAttributesKey : entity }];
    [self enqueueEventForSending:event];
    
    return entity;
}

- (void)updateEntity:(RGMEntity *)entity attributes:(RGMEntity *)attributes
{
    entity.x = attributes.x;
    entity.y = attributes.y;
    entity.velocity = attributes.velocity;
    entity.size = attributes.size;
}

- (void)destroyEntity:(NSString *)identifier
{
    [super destroyEntity:identifier];
    
    [self enqueueEventForSending:[RGMEvent eventWithType:RGMEventTypeDestroy userInfo:@{RGMEventIdentifierKey: identifier}]];
}

- (void)willUpdate
{
    [self processEvents];
}

- (void)didUpdate
{
    [self sendEvents];
}

#pragma mark - Event handling

- (void)enqueueEventForSending:(RGMEvent *)event
{
    [self.eventSendingQueue addObject:event];
}

- (void)sendEvents
{
    for (RGMEvent *event in self.eventSendingQueue) {
        [self sendEvent:event];
    }
    
    [self.eventSendingQueue removeAllObjects];
}

- (void)sendEvent:(RGMEvent *)event
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event];
    if (!data) {
        NSLog(@"error encoding event: %@", event);
    }
    
    GKMatchSendDataMode mode;
    
    switch (event.type) {
        case RGMEventTypeUpdate:
            mode = GKMatchSendDataUnreliable;
            break;
        default:
            mode = GKMatchSendDataReliable;
            break;
    }
    
    NSError *error;
    if ([self isHostPlayer]) {
        if (![self.match sendDataToAllPlayers:data withDataMode:mode error:&error]) {
            NSLog(@"error queueing event: %@", error);
        }
    } else {
        if (![self.match sendData:data toPlayers:@[self.hostPlayer] withDataMode:mode error:&error]) {
            NSLog(@"error queueing event: %@", error);
        }
    }
}

- (void)enqueueEventForProcessing:(RGMEvent *)event
{
    [self.eventProcessingQueue addObject:event];
}

- (void)processEvents
{
    for (RGMEvent *event in self.eventProcessingQueue) {
        [self processEvent:event];
    }
    
    [self.eventProcessingQueue removeAllObjects];
}

- (void)processEvent:(RGMEvent *)event
{
    NSDictionary *userInfo = event.userInfo;
    
    switch (event.type) {
        case RGMEventTypeCreate: {
            RGMEntity *entity = userInfo[RGMEventAttributesKey];
            entity.game = self;
            self.entities[userInfo[RGMEventIdentifierKey]] = entity;
            if ([userInfo[RGMEventIdentifierKey] isEqual:[GKLocalPlayer localPlayer].playerID]) {
                self.localPlayer = userInfo[RGMEventAttributesKey];
            }
            break;
        }
        case RGMEventTypeUpdate:
            if ([userInfo[RGMEventIdentifierKey] isEqual:[GKLocalPlayer localPlayer].playerID]) {
                return; // TODO: need drift correction event if client gets out of sync
            }
            [self updateEntity:self.entities[userInfo[RGMEventIdentifierKey]] attributes:userInfo[RGMEventAttributesKey]];
            break;
        case RGMEventTypeCapture:{
            RGMPredator *predator = (RGMPredator *)[self entityForIdentifier:userInfo[RGMEventPredatorKey]];
            RGMPrey *prey = (RGMPrey *)[self entityForIdentifier:userInfo[RGMEventPreyKey]];
            [predator capturePrey:prey];
            break;
        }
        case RGMEventTypeDestroy:
            [self.entities removeObjectForKey:userInfo[RGMEventIdentifierKey]];
            break;
        case RGMEventTypeEscape: {
            [(RGMPredator *)[self entityForIdentifier:userInfo[RGMEventPredatorKey]] dropPrey];
            break;
        }
        default:
            break;
    }
}

#pragma mark - GKMatchDelegate

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error
{
#if TARGET_OS_IPHONE
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] rgm_presentError:error];
#else
    [NSApp presentError:error];
#endif
    [match disconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    RGMEvent *event = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!event) {
        NSLog(@"error unarchiving data from player: %@", playerID);
        [match disconnect];
        return;
    }
    
    RGMEvent *lastEvent = [self.lastEventByPlayerID objectForKey:playerID];
    if (lastEvent && [lastEvent.date compare:event.date] == NSOrderedDescending) {
        return; // ignore late events
    }
    
    self.lastEventByPlayerID[playerID] = event;
    
    [self enqueueEventForProcessing:event];
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    switch (state) {
        case GKPlayerStateConnected:
            if ([self isHostPlayer]) {
                [self createEntity:[RGMPrey class] identifier:playerID];
            }
            break;
        case GKPlayerStateDisconnected:
            if ([self isHostPlayer]) {
                [self destroyEntity:playerID];
            }
            break;
        case GKPlayerStateUnknown:
            break;
        default:
            break;
    }
}

- (BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID
{
    return YES;
}

@end
