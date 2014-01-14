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


@end


@implementation VSContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



#pragma mark - View layout


- (void) layoutSubviews
{
    [super layoutSubviews];
    self.contenterView.bounds = self.bounds;
    [self layOutItemViews];
}

- (void) layOutItemViews
{
    UIView *contentView = [[UIView alloc] init];
    [@[@(0), @(1), @(2)] enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [contentView addSubview:[self layoutItemView:idx]];
    }];
    [self addSubview:contentView];
    self.contenterView = contentView;
}

- (UIView *) layoutItemView:(NSUInteger)idx
{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(10.0f, 10.0f , 100.0f, 150.0f);
    
    CATransform3D identity = CATransform3DIdentity;
    identity.m34 = 1.0/ -1000;
    CATransform3D rotated = CATransform3DRotate(identity, idx * RADIANS(20), 1, 0, 0);
    CATransform3D translateAndRoate = CATransform3DTranslate(rotated, idx * 100, idx * 30, idx * 10);
    
    view.layer.transform = translateAndRoate;
    
    view.backgroundColor = [UIColor redColor];
    return view;
}














@end
