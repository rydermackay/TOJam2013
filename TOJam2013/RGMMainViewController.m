//
//  RGMMainViewController.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMMainViewController.h"

@interface RGMMainViewController () <GKMatchmakerViewControllerDelegate, GKMatchDelegate>
- (IBAction)joinGameTapped:(id)sender;

@end



@implementation RGMMainViewController {
    GKMatch *_match;
    GKVoiceChat *_chat;
    CADisplayLink *_displayLink;
    NSMutableDictionary *_boxes;
    NSMutableDictionary *_views;
    NSTimer *_transmissionTimer;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_match) {
        [self joinGameTapped:nil];
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
    const NSTimeInterval transmissionRate = 1.0f / 60.f * 5.0f;
    _transmissionTimer = [[NSTimer alloc] initWithFireDate:nil interval:transmissionRate target:self selector:@selector(transmitData:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_transmissionTimer forMode:NSRunLoopCommonModes];
}

- (void)stopGame
{
    [_match disconnect];
    [_transmissionTimer invalidate];
    _transmissionTimer = nil;
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)update:(CADisplayLink *)sender
{
    NSTimeInterval duration = sender.duration;
    
    const CGFloat gravity = 20;
    const CGFloat maxDownwardVelocity = 500;
    const CGFloat ground = 500;
    
    for (NSString *playerID in [_match.playerIDs arrayByAddingObject:[GKLocalPlayer localPlayer].playerID]) {
        NSMutableDictionary *data = [self dataForPlayerID:playerID];
        CGPoint velocity = [data[@"velocity"] CGPointValue];
        velocity.y += gravity * duration;
        velocity.y = MIN(maxDownwardVelocity, velocity.y);
        data[@"velocity"] = [NSValue valueWithCGPoint:velocity];
        
        CGPoint position = [data[@"position"] CGPointValue];
        position.x += velocity.x * duration;
        position.y += velocity.y * duration;
        if (position.y > ground) {
            position.y = ground;
            velocity.y = velocity.y * -0.9;
            data[@"velocity"] = [NSValue valueWithCGPoint:velocity];
        }
        data[@"position"] = [NSValue valueWithCGPoint:position];
    }
    
    [_boxes enumerateKeysAndObjectsUsingBlock:^(id key, id data, BOOL *stop) {
        UIView *view = [self viewForPlayerID:key];
        view.center = [data[@"position"] CGPointValue];
    }];
}

- (UIView *)viewForPlayerID:(NSString *)playerID
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

- (void)transmitData:(id)sender
{
    NSString *playerID = [[GKLocalPlayer localPlayer] playerID];
    NSDictionary *boxData = @{playerID: [self dataForPlayerID:playerID]};
    NSError *error;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:boxData];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:boxData options:0 error:&error];
//    if (!data) {
//        NSLog(@"error serializing game data: %@", error);
//    }
    
    if (![_match sendDataToAllPlayers:data withDataMode:GKMatchSendDataUnreliable error:&error]){
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
    NSLog(@"found match: %@", match);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _match = match;
    _match.delegate = self;
    _boxes = [NSMutableDictionary new];
    
    for (NSString *playerID in _match.playerIDs) {
        _boxes[playerID] = [NSMutableDictionary new];
    }
    
    _chat = [_match voiceChatWithName:@"Chat"];
    [_chat start];
    [_chat setActive:YES];
    
//    [self greetPlayers];
    
    [GKPlayer loadPlayersForIdentifiers:[_match.playerIDs arrayByAddingObject:[GKLocalPlayer localPlayer].playerID]
                  withCompletionHandler:^(NSArray *players, NSError *error) {
                      for (GKPlayer *player in players) {
                          [player loadPhotoForSize:GKPhotoSizeNormal
                             withCompletionHandler:^(UIImage *photo, NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [(UIImageView *)[self viewForPlayerID:player.playerID] setImage:photo];
                                 });
                             }];
                      }
                  }];
    
    [self startGame];
}

- (void)setData:(NSDictionary *)data forPlayerID:(NSString *)playerID
{
    NSParameterAssert(data && playerID.length > 0);
    _boxes[playerID] = [data mutableCopy];
}

- (id)dataForPlayerID:(NSString *)playerID
{
    NSMutableDictionary *data = _boxes[playerID];
    if (data == nil) {
        data = [NSMutableDictionary new];
        data[@"position"] = [NSValue valueWithCGPoint:CGPointMake(25 + arc4random_uniform(200), 25 + arc4random_uniform(50))];
        data[@"velocity"] = [NSValue valueWithCGPoint:CGPointZero];
        _boxes[playerID] = data;
    }
    
    return data;
}

- (void)greetPlayers
{
    NSString *message = [NSString stringWithFormat:@"Hi! I’m %@.", [[GKLocalPlayer localPlayer] alias]];
    NSError *error;
    if (![_match sendDataToAllPlayers:[message dataUsingEncoding:NSUTF8StringEncoding] withDataMode:GKMatchSendDataReliable error:&error]) {
        [self rgm_presentError:error];
    };
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
    NSDictionary *boxData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSParameterAssert(boxData.allKeys.count == 1);
    NSParameterAssert(![boxData.allKeys[0] isEqual:[[GKLocalPlayer localPlayer] playerID]]);
    [boxData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setData:obj forPlayerID:key];
    }];
    
//    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    [[[UIAlertView alloc] initWithTitle:@"Message Received!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    NSLog(@"player: %@ changed state: %d", playerID, state);
}

- (BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID
{
    return YES;
}

@end
