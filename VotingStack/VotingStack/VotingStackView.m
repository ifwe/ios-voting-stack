//
//  VSContainerView.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VotingStackView.h"



#pragma mark - Macros
#define RADIANS(deg)  ((deg) * M_PI / 180)
#define DEGREES(rad)  ((rad) * 180 / M_PI)



@interface VotingStackView ()

@property (nonatomic, weak) UIView *contenterView;
@property (nonatomic) NSInteger startingIndex;
@property (nonatomic) NSUInteger numberOfViewVisable;


@end


@implementation VotingStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void) setup
{
    // setup basic index numbers
    self.startingIndex = -1;
    self.numberOfViewVisable = 5;
    
    // setup views
    // the container view
    UIView *contentView = [[UIView alloc] init];
    [self addSubview:contentView];
    self.contenterView = contentView;
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    self.contenterView.frame = rect;
    
    // the subviews
    __weak VotingStackView *weakSelf = self;
    for (NSInteger idx = self.startingIndex;
         idx < (self.startingIndex + (NSInteger)self.numberOfViewVisable);
         idx++) {
        
        UIView *dataView = [self.dataSource VotingStackView:weakSelf viewForItemAtIndex:idx];
        CGRect dataViewRect = dataView.frame;
        dataViewRect.origin = CGPointMake(0, 0);
        dataViewRect.size = CGSizeMake(100.0f, 150.0f);
        dataView.frame = dataViewRect;
        
        dataViewRect.origin = CGPointMake(10.0f, 10.0f);
        UIView *itemContainerView = [[UIView alloc] initWithFrame:dataViewRect];
        [itemContainerView addSubview:dataView];
        
        CATransform3D idenitiy = CATransform3DIdentity;
        idenitiy.m34 = 1.0/ -2000;
        
        itemContainerView.layer.transform = idenitiy;
        itemContainerView.layer.transform = [self stepTransformationForView:itemContainerView andIndex:idx];
        [contentView addSubview:itemContainerView];
    }
    
}

#pragma mark - getter & setter




#pragma mark - View layout

- (void) layoutSubviews
{
    // system setup
    [super layoutSubviews];
    self.contenterView.bounds = self.bounds;
    
    // voting stack setup
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setup];
    });
    [self layOutItemViews];
}

- (void) layOutItemViews
{
    [self.contenterView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [self layoutItemView:view andIndex:(self.startingIndex + idx)];
    }];
}

- (UIView *) layoutItemView: (UIView *)view andIndex:(NSInteger)idx
{
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
    
    CATransform3D translateFrom = [self stepTransformationForView:view andIndex:idx+1];
    CATransform3D translateTo = [self stepTransformationForView:view andIndex:idx];
    
    transformAnimation.fillMode = kCAFillModeForwards;
    transformAnimation.removedOnCompletion = NO;
    
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:translateFrom];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:translateTo];
    transformAnimation.duration = 0.5;
    [view.layer addAnimation:transformAnimation forKey:@"transform"];
    
    return view;
}

- (CATransform3D) stepTransformationForView: (UIView *) view andIndex: (NSInteger) idx
{
    return CATransform3DTranslate(view.layer.transform, 0.0, 5.0f * idx, -100.0f*idx);
}



#pragma mark - View Actions


- (void) stepForward
{
    self.startingIndex ++;
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self layOutItemViews];
    } completion:^(BOOL finished) {
        __block UIView *tempView = nil;
        [self.contenterView.subviews
         enumerateObjectsWithOptions:NSEnumerationReverse
         usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
             if (tempView != nil) {
                 UIView * myView = [obj.subviews lastObject];
                 assert(obj.subviews.count == 1);
                 [[obj.subviews lastObject] removeFromSuperview];
                 
                 assert(tempView.superview == nil);
                 [obj addSubview:tempView];
                 
                 tempView = myView;
             } else {
                 tempView = [obj.subviews lastObject];
                 [tempView removeFromSuperview];
                 assert(obj.subviews.count == 0);
             }
        }];
    }];
}






@end
