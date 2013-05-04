//
//  RGMMainViewController.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMMainViewController.h"
#import "RGMEntity.h"
#import "RGMInputView.h"

@interface RGMMainViewController () <GKMatchmakerViewControllerDelegate, GKMatchDelegate>
- (IBAction)joinGameTapped:(id)sender;

@end



@implementation RGMMainViewController {
    GKMatch *_match;
    GKVoiceChat *_chat;
    CADisplayLink *_displayLink;
    NSMutableDictionary *_entities;
    NSMutableDictionary *_views;
    NSTimer *_transmissionTimer;
    CMMotionManager *_motionManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localPlayerChanged:) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
    
    RGMInputView *input = (RGMInputView *)self.view;
    [input addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchDown];
    [input addTarget:self action:@selector(endJump) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}

- (void)jump
{
    [[self entityForPlayerID:[self myID]] jump];
}

- (void)endJump
{
    [[self entityForPlayerID:[self myID]] endJump];
}


- (void)localPlayerChanged:(NSNotification *)note
{
    NSString *oldID = @"me";
    RGMEntity *entity = [self entityForPlayerID:oldID];
    [_entities removeObjectForKey:oldID];
    
    NSString *newID = [GKLocalPlayer localPlayer].playerID;
    RGMEntity *newEntity = [[RGMEntity alloc] initWithIdentifier:newID];
    newEntity.center = entity.center;
    newEntity.velocity = entity.velocity;
    _views[newID] = _views[oldID];
    [_views removeObjectForKey:oldID];
    _entities[newID] = newEntity;
    
    [[GKLocalPlayer localPlayer] loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (photo) {
            newEntity.image = photo;
        } else {
            NSLog(@"error loading photo: %@", error);
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_match) {
//        [self joinGameTapped:nil];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    
    _entities = [NSMutableDictionary new];
    _entities[[self myID]] = [[RGMEntity alloc] initWithIdentifier:[self myID]];
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1.0/60.0f;
    [_motionManager startDeviceMotionUpdates];
    
    [self startGame];
}

- (NSString *)myID
{
    NSString *myID = [GKLocalPlayer localPlayer].playerID;
    if (!myID) {
        myID = @"me";
    }
    
    return myID;
}

- (IBAction)tap:(id)sender
{
    NSString *playerID = [self myID];
    RGMEntity *entity = [self entityForPlayerID:playerID];
    [entity jump];
    
    if (_match) {
        NSError *error;
        NSData *serializedData = [NSJSONSerialization dataWithJSONObject:@{playerID: [entity serializedCopy]} options:0 error:&error];
        if (!serializedData) {
            NSLog(@"error serializing data after jump: %@", error);
        }
        
        if (![_match sendDataToAllPlayers:serializedData withDataMode:GKMatchSendDataReliable error:&error]) {
            NSLog(@"error sending reliable data: %@", error);
        }
    }
}

- (IBAction)joinGameTapped:(id)sender
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.defaultNumberOfPlayers = request.minPlayers;
    request.maxPlayers = 4;
    
    GKMatchmakerViewController *controller = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    controller.matchmakerDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}
 
- (void)startGame
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopGame
{
    [_match disconnect];
    [_transmissionTimer invalidate];
    _transmissionTimer = nil;
    [_displayLink invalidate];
    _displayLink = nil;
    [_motionManager stopDeviceMotionUpdates];
    _motionManager = nil;
}

- (void)update:(CADisplayLink *)sender
{
    NSTimeInterval duration = sender.duration;
    
    CMDeviceMotion *motion = [_motionManager deviceMotion];
    
    const double gravityThreshold = 0.1;
    
    RGMEntity *me = [self entityForPlayerID:[self myID]];
    CGPoint velocity = me.velocity;
    const CGFloat maxHorizontalVelocity = 500;
    
    velocity.x *= 0.98;
    if (fabs(motion.gravity.y) > gravityThreshold) {
        velocity.x = (velocity.x * 0.9) + (maxHorizontalVelocity * motion.gravity.y * 0.1);
    }
    
    if (velocity.x > maxHorizontalVelocity) {
        velocity.x = maxHorizontalVelocity;
    } else if (velocity.x < -maxHorizontalVelocity) {
        velocity.x = -maxHorizontalVelocity;
    }
    
    me.velocity = velocity;
    
    [_entities enumerateKeysAndObjectsUsingBlock:^(id key, RGMEntity *entity, BOOL *stop) {
        [entity updateForDuration:duration];
    }];
    
    [_entities enumerateKeysAndObjectsUsingBlock:^(id key, RGMEntity *entity, BOOL *stop) {
        UIImageView *view = [self viewForPlayerID:key];
        view.center = entity.center;
        view.image = entity.image;
    }];
}

- (UIImageView *)viewForPlayerID:(NSString *)playerID
{
    if (_views == nil) {
        _views = [NSMutableDictionary new];
    }
    
    UIImageView *view = [_views objectForKey:playerID];
    if (view == nil) {
        view = [[UIImageView alloc] initWithImage:nil];
        view.backgroundColor = [UIColor redColor];
        [self.view addSubview:view];
        view.frame = CGRectMake(0, 0, 44, 44);
        _views[playerID] = view;
    }
    
    return view;
}

- (void)transmitData
{
    [self transmitDataWithMode:GKMatchSendDataUnreliable];
}

- (void)transmitDataWithMode:(GKMatchSendDataMode)mode
{
    NSString *playerID = [self myID];
    NSDictionary *entity = @{playerID: [[self entityForPlayerID:playerID] serializedCopy]};
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:entity options:0 error:&error];
    if (!data) {
        NSLog(@"error encoding JSON object: %@", error);
    }
    
    if (![_match sendDataToAllPlayers:data withDataMode:mode error:&error]){
        NSLog(@"error transmitting data: %@", error);
    }
}

- (void)dealloc
{
    [_match disconnect];
}

#pragma mark - GKMatchmakerViewControllerDelegate

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self rgm_presentError:error];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _match = match;
    _match.delegate = self;
    
    _chat = [_match voiceChatWithName:@"Chat"];
    [_chat start];
    [_chat setActive:YES];
    
    [GKPlayer loadPlayersForIdentifiers:[_match.playerIDs arrayByAddingObject:[self myID]]
                  withCompletionHandler:^(NSArray *players, NSError *error) {
                      if (players) {
                          for (GKPlayer *player in players) {
                              [player loadPhotoForSize:GKPhotoSizeNormal
                                 withCompletionHandler:^(UIImage *photo, NSError *error) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (photo) {
                                             [self entityForPlayerID:player.playerID].image = photo;
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
    
    const NSTimeInterval transmissionRate = 1.0f / 60.f * 3.0f;
    _transmissionTimer = [[NSTimer alloc] initWithFireDate:nil interval:transmissionRate target:self selector:@selector(transmitData) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_transmissionTimer forMode:NSRunLoopCommonModes];
}

- (RGMEntity *)entityForPlayerID:(NSString *)playerID
{
    RGMEntity *entity = _entities[playerID];
    if (entity == nil) {
        entity = [[RGMEntity alloc] initWithIdentifier:playerID];
        entity.center = CGPointMake(25.0 + (CGFloat)arc4random_uniform(50), 25.0 + (CGFloat)arc4random_uniform(50));
        _entities[playerID] = entity;
    }
    
    return entity;
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs
{
    NSLog(@"did find players: %@", playerIDs);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID
{
    NSLog(@"accept from hosted: %@", playerID);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GKMatchDelegate

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error
{
    [self rgm_presentError:error];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSError *error;
    NSDictionary *boxData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!boxData) {
        NSLog(@"error reading JSON data: %@", error);
    }
    NSParameterAssert(boxData.allKeys.count == 1);
    NSParameterAssert(![boxData.allKeys[0] isEqual:[[GKLocalPlayer localPlayer] playerID]]);
    [boxData enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *JSON, BOOL *stop) {
        [[self entityForPlayerID:key] setValuesWithJSON:JSON];
    }];
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    NSLog(@"player: %@ changed state: %d", playerID, state);
    
    switch (state) {
        case GKPlayerStateConnected:
            NSLog(@"a challenger appears!!!!");
            break;
        case GKPlayerStateDisconnected:
            NSLog(@"BYE!");
            [_entities removeObjectForKey:playerID];
            [[_views objectForKey:playerID] removeFromSuperview];
            [_views removeObjectForKey:playerID];
            break;
        case GKPlayerStateUnknown:
        default:
            break;
    }
}

- (BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID
{
    return YES;
}

@end
