//
//  VSContainerView.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VotingStackView.h"
#import "iCarousel+votingStackView.h"


#pragma mark - Macros
#define RADIANS(deg)  ((deg) * M_PI / 180)
#define DEGREES(rad)  ((rad) * 180 / M_PI)


@interface VotingStackView () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, weak) iCarousel *carousel;
@property (nonatomic, weak) UIView *SelectionView;
@property (nonatomic, strong) UIPanGestureRecognizer * panGesture;

@end


@implementation VotingStackView


- (void) setup
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iCarousel * car = [[iCarousel alloc] initWithFrame:self.bounds];
        car.type = iCarouselTypeInvertedTimeMachine;
        car.vertical = YES;
        car.dataSource = self;
        car.delegate = self;
        car.userInteractionEnabled = NO;
        
        self.carousel = car;
        [self addSubview:car];
        
        
        UIView * selectionTempView = [[UIView alloc] initWithFrame:self.bounds];
        self.SelectionView.userInteractionEnabled = YES;
        
        self.SelectionView = selectionTempView;
        [self addSubview:self.SelectionView];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        
    });
}

- (void) cleanUp
{
    
}


#pragma mark - View layout

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self setup];
}

- (void) removeFromSuperview
{
    [self cleanUp];
    [super removeFromSuperview];
}


#pragma mark - View functions

- (void)popFront
{
    if ([self.carousel numberOfItems] > 1) {
        [self.carousel itemViewAtIndex:self.carousel.currentItemIndex].layer.opacity = 0.0;
        [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex+1 animated:YES];
    }
}

- (UIView *) currentSelectedView {
    NSArray * arrayOfSelectionView = [self.SelectionView subviews];
    assert([arrayOfSelectionView count] != 0);
    return [arrayOfSelectionView lastObject];
}

#pragma mark - iCarouselDataSource

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [self.dataSource numberOfItemsInVotingStack:self];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    return [self.dataSource votingStack:self viewForItemAtIndex:index reusingView:view];
}



- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
    switch (option) {
        case iCarouselOptionTilt:
            return 0.5f;
        case iCarouselOptionSpacing:
            return 1.8f;
        case iCarouselOptionWrap:
            return YES;
        default:
            return value;
    }
}

#pragma mark - iCarouselDelegate

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel
{
    if ([[self.SelectionView subviews] count] != 0) {
        
        [[self currentSelectedView] removeGestureRecognizer:self.panGesture];
        
        [[self currentSelectedView] removeFromSuperview];
    }
}


- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    UIView * topView = [self.carousel itemViewAtIndex:self.carousel.currentItemIndex];
    topView.frame = topView.superview.frame;
    topView.layer.opacity = 1.0f;
    topView.userInteractionEnabled = YES;
    
    [topView addGestureRecognizer:self.panGesture];
    
    [self.SelectionView addSubview:topView];
}

#pragma mark - UIPanGestureRecognizer


- (void) pan:(UIPanGestureRecognizer *) panGesture
{
    CGPoint dxPointFromOrigin = [panGesture translationInView:self.SelectionView];
    CGFloat halfViewHeight = [[self currentSelectedView] frame].size.height/2.0f;
    
    dxPointFromOrigin.y -= halfViewHeight;
    
    CGFloat angle = atan2f(dxPointFromOrigin.y, dxPointFromOrigin.x) + M_PI;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateChanged:
        {
            
#ifdef VOTING_STACK_DEBUG
            NSLog(@"%f, dx=(x=%f, y=%f)", DEGREES(angle), dxPointFromOrigin.x, dxPointFromOrigin.y);
#endif
            CATransform3D rotation = CATransform3DMakeTranslation(dxPointFromOrigin.x, dxPointFromOrigin.y+halfViewHeight, 0.0f);
            
            rotation = CATransform3DRotate(rotation, angle - M_PI_2, 0, 0, 1);
            
            [self currentSelectedView].layer.transform = rotation;
        }
            break;
        case UIGestureRecognizerStateBegan:
        {
            [self currentSelectedView].layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        }
        case UIGestureRecognizerStateEnded:
        {
            [self currentSelectedView].layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            [self currentSelectedView].layer.transform = CATransform3DIdentity;
        }
            break;
        default:
            break;
    }
}


@end
