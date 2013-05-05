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
#import "RGMGame.h"
#import "RGMInput.h"

@interface RGMMainViewController () <GLKViewDelegate, RGMInput>

@property (strong, nonatomic) IBOutlet UIView *overlay;
@property (strong, nonatomic) IBOutlet UIButton *toggleOverlayButton;
@property (nonatomic, assign, getter = isOverlayVisible) BOOL overlayVisible;
- (IBAction)toggleOverlay:(id)sender;
- (IBAction)quit:(id)sender;

@end



@implementation RGMMainViewController {
    CADisplayLink *_displayLink;
    CMMotionManager *_motionManager;
    UIView *_gameScene;
    RGMInputMask _inputMask;

    NSMutableDictionary *_entityViews;
    NSMutableArray *_obstacleViews;
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
    
    _entityViews = [NSMutableDictionary new];
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
    
    [self.game.tileMap.obstacles enumerateObjectsUsingBlock:^(RGMObstacle *obstacle, NSUInteger idx, BOOL *stop) {
        UIView *view = [[UIView alloc] initWithFrame:obstacle.frame];
        view.layer.magnificationFilter = kCAFilterNearest;
        
        if (obstacle.mask == RGMObstacleMaskSolid) {
            view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile-solid"]];
        } else if (obstacle.mask == RGMObstacleMaskSolidTop) {
            view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile-top"]];
        }
        
        [_obstacleViews addObject:view];
        [_gameScene addSubview:view];
    }];
    
    [self.game addObserver:self forKeyPath:@"localPlayer" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"localPlayer"]) {
        if (self.game.localPlayer) {
            [self.game addInput:self toEntity:self.game.localPlayer];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
    _inputMask |= RGMInputMaskJump;
}

- (void)endJump
{
    _inputMask &= ~RGMInputMaskJump;
}


- (void)localPlayerChanged:(NSNotification *)note
{
//    NSString *newID = [GKLocalPlayer localPlayer].playerID;
//    
//    if (!newID) {
//        return;
//    }
//    
//    if ([_entities objectForKey:newID]) {
//        return;
//    }
//    
//    NSString *oldID = @"me";
//    RGMEntity *entity = [self entityForPlayerID:oldID];
//    [_entities removeObjectForKey:oldID];
//    
//    RGMEntity *newEntity = [[RGMPredator alloc] initWithIdentifier:newID];
//    newEntity.x = entity.x;
//    newEntity.y = entity.y;
//    newEntity.velocity = entity.velocity;
//    _views[newID] = _views[oldID];
//    [_views removeObjectForKey:oldID];
//    _entities[newID] = newEntity;
//    
//    [[GKLocalPlayer localPlayer] loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
//        if (photo) {
//            newEntity.image = photo;
//        } else {
//            NSLog(@"error loading photo: %@", error);
//        }
//    }];
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

#pragma mark - RGMInput

- (RGMInputMask)inputMask
{
    return _inputMask;
}

#pragma mark - Game
 
- (void)startGame
{
    [self.game start];
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1.0/60.0f;
    [_motionManager startDeviceMotionUpdates];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopGame
{
    [self.game end];
    
    [_displayLink invalidate];
    _displayLink = nil;
    [_motionManager stopDeviceMotionUpdates];
    _motionManager = nil;
}

- (void)update:(CADisplayLink *)sender
{
    NSTimeInterval duration = sender.duration;
    
    CMDeviceMotion *motion = [_motionManager deviceMotion];
    
    _inputMask &= ~RGMInputMaskLeft;
    _inputMask &= ~RGMInputMaskRight;
    
    const double gravityThreshold = 0.2;
    if (fabs(motion.gravity.y) > gravityThreshold) {
        UIInterfaceOrientation orientation = self.interfaceOrientation;
        double horizontalGravity = orientation == UIInterfaceOrientationLandscapeLeft ? motion.gravity.y : -motion.gravity.y;
        if (horizontalGravity > 0) {
            _inputMask |= RGMInputMaskRight;
        } else {
            _inputMask |= RGMInputMaskLeft;
        }
    }
    
    NSParameterAssert(_inputMask != (RGMInputMaskLeft | RGMInputMaskRight));
    
    [self.game updateWithTimestamp:sender.timestamp duration:sender.duration];
    
//    [_entities enumerateKeysAndObjectsUsingBlock:^(id key, RGMEntity *entity, BOOL *stop) {
//        [entity updateForDuration:duration];
//        
//        CGRect frame = entity.frame;
//        CGRect bounds = _gameScene.bounds;
//        
//        if (CGRectGetMinX(frame) < CGRectGetMinX(bounds)) {
//            entity.x = CGRectGetMinX(bounds);
//            entity.velocity = CGPointMake(0, entity.velocity.y);
//        }
//        if (CGRectGetMaxX(frame) > CGRectGetMaxX(bounds)) {
//            entity.x = CGRectGetMaxX(bounds) - CGRectGetWidth(frame);
//            entity.velocity = CGPointMake(0, entity.velocity.y);
//        }
//        if (CGRectGetMaxY(frame) > CGRectGetMaxY(bounds)) {
//            entity.y = CGRectGetMaxY(bounds) - CGRectGetHeight(frame);
//            entity.velocity = CGPointMake(entity.velocity.x, 0);
//            entity.canJump = YES;
//        }
//    }];
//    
//    [_entities enumerateKeysAndObjectsUsingBlock:^(id key, RGMEntity *entity, BOOL *stop) {
//        [_obstacles enumerateObjectsUsingBlock:^(RGMObstacle *obstacle, NSUInteger idx, BOOL *stop) {
//            UIView *view = _obstacleViews[idx];
//            [obstacle hitTestEntity:entity obstacleRect:view.frame];
//        }];
//        
//        for (NSString *otherKey in _entities) {
//            if ([otherKey isEqualToString:key]) {
//                continue;
//            }
//            
//            RGMEntity *otherEntity = _entities[otherKey];
//            CGRect frame = entity.frame;
//            CGRect otherFrame = otherEntity.frame;
//            
//            if ([entity isKindOfClass:[RGMPredator class]] && [otherEntity isKindOfClass:[RGMPrey class]]) {
//                if (CGRectIntersectsRect(frame, otherFrame)) {
//                    [(RGMPredator *)entity capturePrey:(RGMPrey *)otherEntity];
//                }
//            } else if ([otherEntity isKindOfClass:[RGMPredator class]] && [entity isKindOfClass:[RGMPrey class]]) {
//                if (CGRectIntersectsRect(frame, otherFrame)) {
//                    [(RGMPredator *)otherEntity capturePrey:(RGMPrey *)entity];
//                }
//            }
//            
//            return;
//            
//            if (CGRectGetMaxX(frame) > CGRectGetMinX(otherFrame) &&
//                CGRectGetMinX(frame) < CGRectGetMaxX(otherFrame) &&
//                CGRectGetMaxY(frame) > CGRectGetMinY(otherFrame) &&
//                CGRectGetMinY(frame) < CGRectGetMaxY(otherFrame)) {
//                entity.y = CGRectGetMinY(otherFrame) - CGRectGetHeight(frame);
//                entity.velocity = CGPointMake(entity.velocity.x, 0);
//                entity.canJump = YES;
//            }
//        }
//    }];
//
    for (NSString *identifier in self.game.identifiers) {
        RGMEntity *entity = [self.game entityForIdentifier:identifier];
        UIImageView *view = [_entityViews objectForKey:identifier];
        if (view == nil) {
            view = [[UIImageView alloc] initWithFrame:entity.frame];
            _entityViews[identifier] = view;
            [_gameScene addSubview:view];
        }
        view.hidden = NO;
        view.frame = entity.frame;
        view.image = entity.image;
        view.backgroundColor = [entity color] ?: [UIColor yellowColor];
        if (entity.isInvincible && ((NSInteger)((sender.timestamp + duration) * 5) % 2 == 0)) {
            view.hidden = YES;
        }
    }
//
//    [_glkView display];
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

//- (UIImageView *)viewForPlayerID:(NSString *)playerID
//{
//    if (_views == nil) {
//        _views = [NSMutableDictionary new];
//    }
//    
//    UIImageView *view = [_views objectForKey:playerID];
//    if (view == nil) {
//        view = [[UIImageView alloc] initWithImage:nil];
//        view.backgroundColor = [UIColor redColor];
//        [_gameScene addSubview:view];
//        view.frame = CGRectMake(0, 0, RGMTileSize, RGMTileSize);
//        _views[playerID] = view;
//    }
//    
//    return view;
//}

- (void)dealloc
{
    [self.game end];
}

@end
