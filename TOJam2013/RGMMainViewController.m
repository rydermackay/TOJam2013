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
#import "RGMObstacle.h"
#import "RGMPredator.h"
#import "RGMPrey.h"

@interface RGMMainViewController () <GKMatchDelegate, GLKViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *overlay;
@property (strong, nonatomic) IBOutlet UIButton *toggleOverlayButton;
- (IBAction)toggleOverlay:(id)sender;
@property (nonatomic, assign, getter = isOverlayVisible) BOOL overlayVisible;
- (IBAction)quit:(id)sender;

@end



@implementation RGMMainViewController {
    GKVoiceChat *_chat;
    CADisplayLink *_displayLink;
    NSMutableDictionary *_entities;
    NSMutableArray *_obstacles;
    NSMutableArray *_obstacleViews;
    NSMutableDictionary *_views;
    NSTimer *_transmissionTimer;
    CMMotionManager *_motionManager;
    
    EAGLContext *_context;
    GLKView *_glkView;
    GLKBaseEffect *_effect;
    
    UIView *_gameScene;
}

- (IBAction)quit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleOverlay:(id)sender
{
    self.overlayVisible = !self.isOverlayVisible;
}

- (void)setOverlayVisible:(BOOL)overlayVisible
{
    if (_overlayVisible == overlayVisible) {
        return;
    }
    
    self.overlay.alpha = overlayVisible ? 0 : 1;
    self.overlay.hidden = NO;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.overlay.alpha = overlayVisible ? 1 : 0;
                     } completion:^(BOOL finished) {
                         _overlayVisible = overlayVisible;
                         self.overlay.hidden = !overlayVisible;
                         if (overlayVisible) {
                             [self.overlay addSubview:self.toggleOverlayButton];
                         } else {
                             [self.view insertSubview:self.toggleOverlayButton belowSubview:self.overlay];
                         }
                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localPlayerChanged:) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
    
    RGMInputView *input = (RGMInputView *)self.view;
    [input addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchDown];
    [input addTarget:self action:@selector(endJump) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    
//    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:nil];
//    _glkView = [[GLKView alloc] initWithFrame:CGRectZero context:_context];
//    _glkView.delegate = self;
//    _glkView.enableSetNeedsDisplay = NO;
    
//    _effect = [[GLKBaseEffect alloc] init];
    
//    [self.view addSubview:_glkView];
    
    _obstacles = [NSMutableArray new];
    _obstacleViews = [NSMutableArray new];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _gameScene = [[UIView alloc] initWithFrame:CGRectZero];
    _gameScene.translatesAutoresizingMaskIntoConstraints = YES;
    _gameScene.backgroundColor = [UIColor whiteColor];
    _gameScene.layer.magnificationFilter = kCAFilterNearest;
    _gameScene.layer.minificationFilter = kCAFilterTrilinear;
    _gameScene.userInteractionEnabled = NO;
    _gameScene.autoresizesSubviews = NO;
    _gameScene.autoresizingMask = UIViewAutoresizingNone;
    _gameScene.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile-clear"]];
    [self.view insertSubview:_gameScene atIndex:0];
    
    NSData *mapData = [[NSData alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Map" withExtension:@"json"]];
    NSError *error;
    NSDictionary *map = [NSJSONSerialization JSONObjectWithData:mapData options:0 error:&error];
    if (!map) {
        NSLog(@"error loading map: %@", error);
    }
    
    NSArray *obstacles = map[@"obstacles"];
    for (NSDictionary *dictionary in obstacles) {
        RGMObstacle *obstacle = [[RGMObstacle alloc] init];
        
        CGPoint start = CGPointMake([[dictionary valueForKeyPath:@"start.x"] floatValue], [[dictionary valueForKeyPath:@"start.y"] floatValue]);
        CGPoint end = CGPointMake([[dictionary valueForKeyPath:@"end.x"] floatValue], [[dictionary valueForKeyPath:@"end.y"] floatValue]);
        UIView *obstacleView = [[UIView alloc] initWithFrame:RGMFrameFromTile(start, end)];
        
        if ([[dictionary objectForKey:@"type"] isEqual:@"solid"]) {
            obstacle.mask = RGMObstacleMaskSolid;
            obstacleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile-solid"]];
        } else {
            obstacle.mask = RGMObstacleMaskSolidTop;
            obstacleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile-top"]];
        }
        
        obstacleView.layer.magnificationFilter = kCAFilterNearest;
        
        [_gameScene addSubview:obstacleView];
        [_obstacleViews addObject:obstacleView];
        [_obstacles addObject:obstacle];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    _glkView.frame = self.view.bounds;
    
    CGRect bounds = self.view.bounds;
    CGFloat scale = MIN((CGRectGetWidth(bounds) / (RGMFieldSize.width * RGMTileSize)),
                        (CGRectGetHeight(bounds) / (RGMFieldSize.height * RGMTileSize)));
    
    _gameScene.bounds = CGRectMake(0, 0, RGMFieldSize.width * RGMTileSize, RGMFieldSize.height * RGMTileSize);
    _gameScene.transform = CGAffineTransformMakeScale(scale, scale);
    _gameScene.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

- (void)jump
{
    NSString *playerID = [self myID];
    RGMEntity *entity = [self entityForPlayerID:playerID];
    [entity jump];
    
    if (self.match) {
        NSError *error;
        NSData *serializedData = [NSJSONSerialization dataWithJSONObject:@{playerID: [entity serializedCopy]} options:0 error:&error];
        if (!serializedData) {
            NSLog(@"error serializing data after jump: %@", error);
        }
        
        if (![self.match sendDataToAllPlayers:serializedData withDataMode:GKMatchSendDataReliable error:&error]) {
            NSLog(@"error sending reliable data: %@", error);
        }
    }
}

- (void)endJump
{
    [[self entityForPlayerID:[self myID]] endJump];
}


- (void)localPlayerChanged:(NSNotification *)note
{
    NSString *newID = [GKLocalPlayer localPlayer].playerID;
    
    if (!newID) {
        return;
    }
    
    if ([_entities objectForKey:newID]) {
        return;
    }
    
    NSString *oldID = @"me";
    RGMEntity *entity = [self entityForPlayerID:oldID];
    [_entities removeObjectForKey:oldID];
    
    RGMEntity *newEntity = [[RGMPredator alloc] initWithIdentifier:newID];
    newEntity.x = entity.x;
    newEntity.y = entity.y;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_displayLink.isPaused) {
        _displayLink.paused = NO;
        return;
    }
    
    [self startGame];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _displayLink.paused = YES;
    
    if (self.isBeingDismissed || self.isMovingFromParentViewController) {
        [self stopGame];
    }
}

- (NSString *)myID
{
    NSString *myID = [GKLocalPlayer localPlayer].playerID;
    if (!myID) {
        myID = @"me";
    }
    
    return myID;
}
 
- (void)startGame
{
    _entities = [NSMutableDictionary new];
    _entities[[self myID]] = [[RGMPredator alloc] initWithIdentifier:[self myID]];
    
    RGMPrey *prey = [[RGMPrey alloc] initWithIdentifier:@"prey"];
    prey.x = RGMFieldSize.width * 0.5 * RGMTileSize;
    prey.y = RGMFieldSize.height * 0.5 * RGMTileSize;
    _entities[@"prey"] = prey;
    
    RGMPrey *prey2 = [[RGMPrey alloc] initWithIdentifier:@"prey2"];
    prey.x = RGMFieldSize.width * 0.75 * RGMTileSize;
    prey.y = RGMFieldSize.height * 0.75 * RGMTileSize;
    prey2.color = [UIColor greenColor];
    _entities[@"prey2"] = prey2;
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1.0/60.0f;
    [_motionManager startDeviceMotionUpdates];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopGame
{
    [self.match disconnect];
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
    
    const double gravityThreshold = 0.2;
    
    RGMEntity *me = [self entityForPlayerID:[self myID]];
    CGPoint velocity = me.velocity;
    const CGFloat maxHorizontalVelocity = 1000;
    
    velocity.x *= 0.9;
    if (fabs(motion.gravity.y) > gravityThreshold) {
        UIInterfaceOrientation orientation = self.interfaceOrientation;
        double horizontalGravity = orientation == UIInterfaceOrientationLandscapeLeft ? motion.gravity.y : -motion.gravity.y;
        velocity.x = (velocity.x * 0.9) + (maxHorizontalVelocity * horizontalGravity * 0.1);
    }
    
    if (velocity.x > maxHorizontalVelocity) {
        velocity.x = maxHorizontalVelocity;
    } else if (velocity.x < -maxHorizontalVelocity) {
        velocity.x = -maxHorizontalVelocity;
    }
    
    me.velocity = velocity;
    
    [_entities enumerateKeysAndObjectsUsingBlock:^(id key, RGMEntity *entity, BOOL *stop) {
        [entity updateForDuration:duration];
        
        CGRect frame = entity.frame;
        CGRect bounds = _gameScene.bounds;
        
        if (CGRectGetMinX(frame) < CGRectGetMinX(bounds)) {
            entity.x = CGRectGetMinX(bounds);
            entity.velocity = CGPointMake(0, entity.velocity.y);
        }
        if (CGRectGetMaxX(frame) > CGRectGetMaxX(bounds)) {
            entity.x = CGRectGetMaxX(bounds) - CGRectGetWidth(frame);
            entity.velocity = CGPointMake(0, entity.velocity.y);
        }
        if (CGRectGetMaxY(frame) > CGRectGetMaxY(bounds)) {
            entity.y = CGRectGetMaxY(bounds) - CGRectGetHeight(frame);
            entity.velocity = CGPointMake(entity.velocity.x, 0);
            entity.canJump = YES;
        }
    }];
    
    [_entities enumerateKeysAndObjectsUsingBlock:^(id key, RGMEntity *entity, BOOL *stop) {
        [_obstacles enumerateObjectsUsingBlock:^(RGMObstacle *obstacle, NSUInteger idx, BOOL *stop) {
            UIView *view = _obstacleViews[idx];
            [obstacle hitTestEntity:entity obstacleRect:view.frame];
        }];
        
        for (NSString *otherKey in _entities) {
            if ([otherKey isEqualToString:key]) {
                continue;
            }
            
            RGMEntity *otherEntity = _entities[otherKey];
            CGRect frame = entity.frame;
            CGRect otherFrame = otherEntity.frame;
            
            if ([entity isKindOfClass:[RGMPredator class]] && [otherEntity isKindOfClass:[RGMPrey class]]) {
                if (CGRectIntersectsRect(frame, otherFrame)) {
                    [(RGMPredator *)entity capturePrey:(RGMPrey *)otherEntity];
                }
            } else if ([otherEntity isKindOfClass:[RGMPredator class]] && [entity isKindOfClass:[RGMPrey class]]) {
                if (CGRectIntersectsRect(frame, otherFrame)) {
                    [(RGMPredator *)otherEntity capturePrey:(RGMPrey *)entity];
                }
            }
            
            return;
            
            if (CGRectGetMaxX(frame) > CGRectGetMinX(otherFrame) &&
                CGRectGetMinX(frame) < CGRectGetMaxX(otherFrame) &&
                CGRectGetMaxY(frame) > CGRectGetMinY(otherFrame) &&
                CGRectGetMinY(frame) < CGRectGetMaxY(otherFrame)) {
                entity.y = CGRectGetMinY(otherFrame) - CGRectGetHeight(frame);
                entity.velocity = CGPointMake(entity.velocity.x, 0);
                entity.canJump = YES;
            }
        }
    }];
    
    [_entities enumerateKeysAndObjectsUsingBlock:^(id key, RGMEntity *entity, BOOL *stop) {
        UIImageView *view = [self viewForPlayerID:key];
        view.hidden = NO;
        view.frame = [entity frame];
        view.image = entity.image;
        view.backgroundColor = [entity color] ?: [UIColor yellowColor];
        if (entity.isInvincible && ((NSInteger)((sender.timestamp + duration) * 5) % 2 == 0)) {
            view.hidden = YES;
        }
    }];
    
    [_glkView display];
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
//    [_effect prepareToDraw];
//    _effect.transform.modelviewMatrix;
//    _effect.transform.projectionMatrix;
//    
//    glBindVertexArrayOES(<#GLuint array#>)
//    glDrawArrays(GL_TRIANGLES, 0, 3);
}

#pragma mark - stuff

- (UIImageView *)viewForPlayerID:(NSString *)playerID
{
    if (_views == nil) {
        _views = [NSMutableDictionary new];
    }
    
    UIImageView *view = [_views objectForKey:playerID];
    if (view == nil) {
        view = [[UIImageView alloc] initWithImage:nil];
        view.backgroundColor = [UIColor redColor];
        [_gameScene addSubview:view];
        view.frame = CGRectMake(0, 0, RGMTileSize, RGMTileSize);
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
    
    if (![self.match sendDataToAllPlayers:data withDataMode:mode error:&error]){
        NSLog(@"error transmitting data: %@", error);
    }
}

- (void)dealloc
{
    [self.match disconnect];
}

#pragma mark - Matches

- (void)setMatch:(GKMatch *)match
{
    if ([_match isEqual:match]) {
        return;
    }
    
    [_match disconnect];
    _match.delegate = nil;
    
    [_chat stop];
    _chat.active = NO;
    
    _match = match;
    _match.delegate = self;
    
    _chat = [self.match voiceChatWithName:@"Chat"];
    [_chat start];
    _chat.active = YES;
    
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
        _entities[playerID] = entity;
    }
    
    return entity;
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
