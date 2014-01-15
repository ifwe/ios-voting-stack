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
@property (nonatomic) NSUInteger startingIndex;
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
    _startingIndex = 0;
    _numberOfViewVisable = 5;
    
    // setup views
    // the container view
    UIView *contentView = [[UIView alloc] init];
    [self addSubview:contentView];
    self.contenterView = contentView;
    self.contenterView.frame = self.frame;
    
    // the subviews
    for (int idx = self.startingIndex;
         idx < (self.startingIndex + self.numberOfViewVisable);
         idx++) {
        
        UIView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img"]];
        
        view.frame = CGRectMake(10.0f, 10.0f, 100.0f, 150.0f);
        
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

- (UIView *) layoutItemView: (UIView *)view andIndex:(NSUInteger)idx
{
    CATransform3D identity = CATransform3DIdentity;
    // TODO: Set the correct projection matrix
    identity.m34 = 1.0/ -2000;
    //CATransform3D rotated = CATransform3DRotate(identity, idx * RADIANS(-20), 1, 0, 0);
    CATransform3D translate = CATransform3DTranslate(identity, 0.0, idx * 50.0f, idx*-100.0f);
    
    view.layer.transform = translate;
    
    return view;
}



#pragma mark - View Actions


- (void) stepForward
{
    self.startingIndex++;
    
    [UIView animateWithDuration:100 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self layOutItemViews];
    } completion:nil];
}







@end
