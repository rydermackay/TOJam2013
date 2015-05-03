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
#import "RGMTile.h"
#import "RGMPredator.h"
#import "RGMPrey.h"
#import "RGMGame.h"
#import "RGMInput.h"
#import "RGMScene.h"
@import SpriteKit;

@interface RGMMainViewController () <RGMInput>

@property (strong, nonatomic) IBOutlet UIView *overlay;
@property (strong, nonatomic) IBOutlet UIButton *toggleOverlayButton;
@property (nonatomic, assign, getter = isOverlayVisible) BOOL overlayVisible;
- (IBAction)toggleOverlay:(id)sender;
- (IBAction)quit:(id)sender;

@end



@implementation RGMMainViewController {
    CMMotionManager *_motionManager;
    RGMInputMask _inputMask;
    SKView *_sceneView;
    RGMScene *_scene;
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
    [input addTarget:self action:@selector(resetJump) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    
    _sceneView = [[SKView alloc] initWithFrame:self.view.bounds];
    _sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _sceneView.autoresizesSubviews = NO;
    _sceneView.translatesAutoresizingMaskIntoConstraints = YES;
    _sceneView.backgroundColor = [UIColor whiteColor];
    _sceneView.layer.magnificationFilter = kCAFilterNearest;
    _sceneView.layer.minificationFilter = kCAFilterTrilinear;
    _sceneView.userInteractionEnabled = NO;
    _sceneView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile-clear"]];
    [self.view insertSubview:_sceneView atIndex:0];
    _scene = [[RGMScene alloc] initWithSize:CGSizeMake(640, 480)];
    _scene.scaleMode = SKSceneScaleModeAspectFit;
    [_sceneView presentScene:_scene];
    
    [self.game addObserver:self forKeyPath:@"localPlayer" options:NSKeyValueObservingOptionNew context:NULL];
    
    _scene.game = self.game;
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

- (void)jump
{
    _inputMask |= RGMInputMaskJump;
}

- (void)resetJump
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
    
    if (_sceneView.isPaused) {
        _scene.paused = NO;
        return;
    }
    
    [self startGame];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _scene.paused = YES;
    
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
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                        withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                            [self update];
                                        }];
}

- (void)stopGame
{
    [self.game end];
    
    [_motionManager stopDeviceMotionUpdates];
    _motionManager = nil;
}

- (void)update
{
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
}

- (void)dealloc
{
    [self.game end];
}

@end
