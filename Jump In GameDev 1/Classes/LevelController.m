//
//  ViewController.m
//  Jump In GameDev 1
//
//  Created by Krzysztof Zablocki on 01/02/2013.
//  Copyright (c) 2013 pixle. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LevelController.h"
#import "ObjectiveChipmunk.h"
#import "PhysicalView.h"

static NSUInteger currentLevel = 1;

@interface LevelController () <UIAccelerometerDelegate>

@end

@implementation LevelController {
  ChipmunkSpace *_space;
  CADisplayLink *_displayLink;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupPhysics];
  self.view.layer.contents = (id)[UIImage imageNamed:@"background.png"].CGImage;
}

- (void)setupPhysics
{
  _space = [ChipmunkSpace new];
  [_space addBounds:self.view.bounds thickness:10.0f elasticity:1.0f friction:1.0f layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:nil];
  _space.gravity = cpv(0, 100);

  [self addObjectsFromScene];

  [_space addCollisionHandler:self typeA:[PhysicalView handlers][@"Hole"] typeB:[PhysicalView handlers][@"Player"] begin:@selector(gameOver:space:) preSolve:nil postSolve:nil separate:nil];
  [_space addCollisionHandler:self typeA:[PhysicalView handlers][@"Player"] typeB:[PhysicalView handlers][@"Finish"] begin:@selector(gameWon:space:) preSolve:nil postSolve:nil separate:nil];
}

- (void)addObjectsFromScene
{
  for (UIView <ChipmunkObject> *view in self.view.subviews) {
    if ([view isKindOfClass:[UIImageView class]] && ![view valueForKeyPath:@"collisionType"]) {
      UIImageView *imgView = (UIImageView *)view;
      imgView.image = [imgView.image resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    }

    if ([view conformsToProtocol:@protocol(ChipmunkObject)]) {
      [_space add:view];
    }
  }
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
  [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

  [self setupAccelerometer];
}

- (void)setupAccelerometer
{
  UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
  accelerometer.updateInterval = 1.0f / 30.0f;
  accelerometer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_displayLink invalidate];
  _displayLink = nil;
}

#pragma mark - Updates

- (void)tick:(CADisplayLink *)link
{
  [_space step:(cpFloat)link.duration * link.frameInterval];

  for (id view in self.view.subviews) {
    if ([view respondsToSelector:@selector(update)]) {
      [view update];
    }
  }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
  [_space setGravity:cpvmult(cpv((cpFloat const)acceleration.x, (cpFloat const)-acceleration.y), 400)];
}

- (BOOL)gameOver:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You lost!" message:@"I've told you already: You lost!" delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil];
  [alertView show];
  return YES;
}

- (BOOL)gameWon:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You won!" message:@"I've told you already: You won!" delegate:self cancelButtonTitle:@"Next level" otherButtonTitles:nil];
  alertView.tag = 1;
  [alertView show];
  return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alertView.tag == 1) {
    [self nextLevel];
    return;
  }

  [self loadLevel:1];
}

- (void)nextLevel
{
  [self loadLevel:currentLevel + 1];
}

- (void)loadLevel:(NSUInteger)level
{
    UIViewController *controller = nil;
    @try {
        controller= [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"Level%d",level]];
    }
    @catch (NSException *exception) {
        level = 1;
        controller = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"Level%d",level]];
    }
    @finally {
        [self.navigationController setViewControllers:@[controller] animated:YES];
        currentLevel = level;
    }
}

@end
