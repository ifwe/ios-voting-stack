//
//  VSContainerView.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VotingStackView.h"



#pragma mark - Macros
#define RADIANS(deg)  ((deg) * M_PI / 180.0f)
#define DEGREES(rad)  ((rad) * 180.0f / M_PI)

#define DISTANCE_FROM_SCREEN (1500.0f);



@interface VotingStackView ()

@property (nonatomic, weak) UIView *contenterView;
@property (nonatomic) NSInteger startingIndex;
@property (nonatomic) NSUInteger numberOfViewVisable;

typedef enum{
    votingStackItemView,
} votingStack;

typedef enum{
    votingStackPresetKeyFrameOffStageEntrance,
    votingStackPresetKeyFrameAtPosition,
} votingStackPresetKeyFrame;

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
    self.startingIndex = 0;
    self.numberOfViewVisable = 12;
    
    CATransform3D perceptive = self.layer.transform;
    perceptive.m34 = -1.0f/DISTANCE_FROM_SCREEN;
    self.layer.sublayerTransform = perceptive;
    
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
        
        UIView *itemView = [self.dataSource VotingStackView:weakSelf viewForItemAtIndex:idx];
        CGRect dataViewRect = itemView.frame;
        dataViewRect.origin = CGPointMake(50, 50);
        dataViewRect.size = CGSizeMake(100.0f, 150.0f);
        itemView.frame = dataViewRect;
//
//        dataViewRect.origin = CGPointMake(10.0f, 10.0f);
//        UIView *itemContainerView = [[UIView alloc] initWithFrame:dataViewRect];
//        [itemContainerView addSubview:dataView];
        
        CATransform3D idenitiy = CATransform3DIdentity;
        idenitiy.m34 = 1.0/ -2000;
        
        itemView.layer.transform = idenitiy;
//        itemView.layer.transform = [self stepTransformationForView:itemView andIndex:idx];
        
        [contentView addSubview:itemView];
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
    [self layOutItemViewsAnimated:NO];
}

- (void) layOutItemViewsAnimated: (BOOL) animated
{
    [self.contenterView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [self layoutItemView:view andIndex:(self.startingIndex + idx) animated:animated];
    }];
}

- (UIView *) layoutItemView: (UIView *)view andIndex:(NSInteger)idx animated:(BOOL) animated
{
    
    CABasicAnimation *transformAnimation = [self animationForViewType:votingStackItemView
                                                         fromKeyFrame:votingStackPresetKeyFrameAtPosition
                                                           toKeyFrame:votingStackPresetKeyFrameAtPosition
                                                              atIndex:idx ];
    view.layer.transform = [transformAnimation.toValue CATransform3DValue];
    
    if (animated) {
        [view.layer addAnimation:transformAnimation forKey:@"transform"];
    }
    
    
    return view;
}


#pragma mark - Animations

- (CABasicAnimation *) animationForViewType: (votingStack) viewType fromKeyFrame: (votingStackPresetKeyFrame) fromKey toKeyFrame: (votingStackPresetKeyFrame) toKey atIndex: (NSInteger) index
{
    switch (viewType) {
        case votingStackItemView:
        {
            return [self animationForItemViewFromKeyFrame:fromKey toKeyFrame:toKey atIndex:index];
        }
        default:
            break;
    }
    return nil;
}

- (CABasicAnimation *) animationForItemViewFromKeyFrame: (votingStackPresetKeyFrame) fromFrame toKeyFrame: (votingStackPresetKeyFrame) toFrame atIndex: (NSInteger) index
{
    CATransform3D fromTran = CATransform3DIdentity;
    CATransform3D toTran = CATransform3DIdentity;
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
    
    
    if (fromFrame == votingStackPresetKeyFrameAtPosition) {
        fromTran = [self votingStackItemKeyFrame:votingStackPresetKeyFrameAtPosition atIndex:index+1];
    }
    
    if (toFrame == votingStackPresetKeyFrameAtPosition) {
        toTran = [self votingStackItemKeyFrame:votingStackPresetKeyFrameAtPosition atIndex:(index)];
    }
    
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:fromTran];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:toTran];
    transformAnimation.duration = 0.5f;
    
    return transformAnimation;
}



#pragma mark - Animation Element

- (CATransform3D) votingStackItemKeyFrame: (votingStackPresetKeyFrame) keyFrame atIndex:(NSInteger) index
{
    switch (keyFrame) {
        case votingStackPresetKeyFrameAtPosition:
        {
            CATransform3D tran = CATransform3DIdentity;
//            tran = CATransform3DRotate(tran, RADIANS(index*-5.0f), 0, 0, 1);
//            tran = CATransform3DRotate(tran, RADIANS(index*-5.0f), 0, 1, 0);
            return CATransform3DTranslate(tran, 0.0, 6.0f * index, -100.0f*index);
        }
        default:
            break;
    }
    return CATransform3DIdentity;
}

#pragma mark - View Actions


- (void) stepForward
{
    [self.contenterView.subviews[0] removeFromSuperview];
    [self layOutItemViewsAnimated:YES];
}






@end
