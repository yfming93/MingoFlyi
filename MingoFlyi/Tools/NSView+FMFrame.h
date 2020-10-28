//
//  NSView+FMFrame.h
//  MingoFlyi
//
//  Created by iMac on 2020/10/28.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

CGPoint fm_CGRectGetCenter(CGRect rect);
CGRect  fm_CGRectMoveToCenter(CGRect rect, CGPoint center);
double fm_radians(float degrees);
CATransform3D fm_getTransForm3DWithAngle(CGFloat angle);
CATransform3D fm_getTransForm3DWithAngle_r(CGFloat angle);
CATransform3D fm_getTransForm3DWithScale(CGFloat scale);


@interface NSView (FMFrame)

@property (nonatomic ,assign) CGFloat x;
@property (nonatomic ,assign) CGFloat y;

// shortcuts for frame properties
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;


@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic,readonly) CGPoint bottomLeft;
@property (nonatomic,readonly) CGPoint bottomRight;
@property (nonatomic,readonly) CGPoint topRight;

- (void)fm_scaleBy: (CGFloat) scaleFactor;
- (void)fm_fitInSize: (CGSize) aSize;
- (void)removeAllSubviews;
@end

NS_ASSUME_NONNULL_END
