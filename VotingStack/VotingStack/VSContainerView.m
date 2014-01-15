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
    self.startingIndex = 0;
    UIView *contentView = [[UIView alloc] init];
    for (int idx = _startingIndex; idx < _startingIndex + 5; idx++) {
        [contentView addSubview:[self layoutItemView:idx]];
    }
    [self addSubview:contentView];
    self.contenterView = contentView;
}

#pragma mark - getter & setter




#pragma mark - View layout


- (void) layoutSubviews
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setup];
    });
    
    [super layoutSubviews];
    self.contenterView.bounds = self.bounds;
    [self layOutItemViews];
}

- (void) layOutItemViews
{
}

- (UIView *) layoutItemView:(NSUInteger)idx
{
    UIView * view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img"]]; //[[UIView alloc] init];
    view.frame = CGRectMake(10.0f, 10.0f , 100.0f, 150.0f);
    
    CATransform3D identity = CATransform3DIdentity;
    // TODO: Set the correct projection matrix
    identity.m34 = 1.0/ -2000;
//    CATransform3D rotated = CATransform3DRotate(identity, idx * RADIANS(-20), 1, 0, 0);
    CATransform3D translate = CATransform3DTranslate(identity, 0, idx * 5.0f, idx*-100.0f);
    
    view.layer.transform = translate;
    
    return view;
}



#pragma mark - View Actions


- (void) stepForward
{
    self.startingIndex++;
    [UIView animateWithDuration:100 animations:^{
        [self layOutItemViews];
    }];
}







@end
