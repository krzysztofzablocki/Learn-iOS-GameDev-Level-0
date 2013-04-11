//
//  Created by merowing on 03/02/2013.
//
//
//


#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PhysicalView.h"


@implementation PhysicalView {
  ChipmunkBody *_body;
  ChipmunkShape *_shape;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    _isStatic = YES;
    _mass = 1;
  }

  return self;
}

+ (NSMutableDictionary *)handlers
{
  static NSMutableDictionary *handlers;
  if (!handlers) {
    handlers = [[NSMutableDictionary alloc] init];
  }
  return handlers;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  [self setup];
}

- (void)setup
{
  float moment;
  CGFloat width = CGRectGetWidth(self.bounds);
  CGFloat height = CGRectGetHeight(self.bounds);

  if (!_isCircle) {
    moment = cpMomentForBox(_mass, width, height);
  } else {
    moment = cpMomentForCircle(_mass, 0, width * 0.5, cpvzero);
  }

  //! setup physics
  if (_isStatic) {
    _body = [[ChipmunkBody alloc] initStaticBody];
  } else {
    _body = [[ChipmunkBody alloc] initWithMass:_mass andMoment:moment];
  }
  _body.pos = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

  if (!_isCircle) {
    _shape = [ChipmunkPolyShape boxWithBody:_body width:width height:height];
  } else {
    _shape = [ChipmunkCircleShape circleWithBody:_body radius:width * 0.5 offset:cpvzero];
  }

  _shape.elasticity = 0.3;
  _shape.friction = 0.5;
  _shape.collisionType = @(self.tag);
  if (_collisionType) {
    [PhysicalView handlers][_collisionType] = _collisionType;
    _shape.collisionType = [PhysicalView handlers][_collisionType];
  }

  _shape.sensor = _isSensor;
  [self setBackgroundColor:[UIColor clearColor]];
}

- (void)update
{
  self.center = _body.pos;
  self.transform = CGAffineTransformMakeRotation(_body.angle);
}

- (NSSet *)chipmunkObjects
{
  if (_isStatic) {
    return [NSSet setWithObjects:_shape, nil];
  }

  return [NSSet setWithObjects:_shape, _body, nil];
}

@end