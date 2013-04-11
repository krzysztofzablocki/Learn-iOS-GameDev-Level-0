//
//  Created by merowing on 03/02/2013.
//
//
//


#import <Foundation/Foundation.h>
#import "ObjectiveChipmunk.h"

//! default is static, box shape with mass 1
@interface PhysicalView : UIImageView <ChipmunkObject>
@property(nonatomic, assign) BOOL isStatic;
@property(nonatomic, assign) BOOL isCircle;
@property(nonatomic, assign) BOOL isSensor;
@property(nonatomic, assign) CGFloat mass;
@property(nonatomic, copy) NSString *collisionType;

+ (NSMutableDictionary *)handlers;

- (void)setup;

- (void)update;
@end