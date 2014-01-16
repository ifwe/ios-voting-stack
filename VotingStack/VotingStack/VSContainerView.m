//
//  VSContainerView.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VSContainerView.h"



#pragma mark - Macros
#define RADIANS(deg)  ((deg) * M_PI / 180)
#define DEGREES(rad)  ((rad) * 180 / M_PI)



@interface VSContainerView ()

@property (nonatomic, weak) UIView *contenterView;
@property (nonatomic) NSInteger startingIndex;
@property (nonatomic) NSUInteger numberOfViewVisable;


@end


@implementation VSContainerView

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
    self.contenterView.frame = self.frame;
    
    // the subviews
    for (NSInteger idx = self.startingIndex;
         idx < (self.startingIndex + (NSInteger)self.numberOfViewVisable);
         idx++) {
        
        UIView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img"]];
        
        view.frame = CGRectMake(10.0f, 10.0f, 100.0f, 150.0f);
        CATransform3D idenitiy = CATransform3DIdentity;
        idenitiy.m34 = 1.0/ -2000;
        
        view.layer.transform = idenitiy;
        view.layer.transform = [self stepTransformationForView:view andIndex:idx];
        [contentView addSubview:view];
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
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self layOutItemViews];
    } completion:^(BOOL finished) {
        
    }];
}







@end
