//
//  VSContainerView.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VotingStackView.h"
#import "iCarousel+votingStackView.h"
#import "XYPieChart.h"


#pragma mark - Macros
#define RADIANS(deg)  ((deg) * M_PI / 180)
#define DEGREES(rad)  ((rad) * 180 / M_PI)


@interface VotingStackView () <iCarouselDataSource, iCarouselDelegate, XYPieChartDataSource, XYPieChartDelegate>

@property (nonatomic, weak) iCarousel *carousel;

@property (nonatomic, weak) UIView *oldCarouselContainerView;

@property (nonatomic, weak) UIView *SelectionView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) XYPieChart *pieChart;

@property (nonatomic) BOOL shouldLoadUserSelectionData;

// -1 is cancel. By default currentSelection is -1
@property (nonatomic) NSInteger currentSelection;
//
//@property (nonatomic, strong)

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
        
        _carousel = car;
        [self addSubview:_carousel];
        
        UIView * selectionTempView = [[UIView alloc] initWithFrame:self.bounds];
        selectionTempView.userInteractionEnabled = YES;
        
        _SelectionView = selectionTempView;
        [self addSubview:_SelectionView];
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        
        
        
        XYPieChart *pieChartTemp = [[XYPieChart alloc] initWithFrame:_SelectionView.frame Center:_SelectionView.center Radius:sqrtf(self.selectionCommitThresholdSquared)];
        pieChartTemp.dataSource = self;
        pieChartTemp.delegate = self;
        pieChartTemp.userInteractionEnabled = NO;
        pieChartTemp.startPieAngle = M_PI;
        
        _pieChart = pieChartTemp;
        [self addSubview:pieChartTemp];
        
        self.currentSelection = -1;
        
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
        [self.carousel itemViewAtIndex:self.carousel.currentItemIndex].layer.opacity = 0.0f;
        [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex+1 animated:YES];
    }
}

- (void) pushFront
{
    if ([self.carousel numberOfItems] > 1) {
        [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex-1 animated:YES];
    }
}

- (UIView *) currentSelectedView {
    NSArray * arrayOfSelectionView = [self.SelectionView subviews];
    assert([arrayOfSelectionView count] != 0);
    return [arrayOfSelectionView lastObject];
}


- (void) selectionShouldCommit:(BOOL) shouldCommit WithAngle:(CGFloat) angle
{
    if (!shouldCommit) {
        if (self.currentSelection >= 0) {
            [self.pieChart setSliceDeselectedAtIndex:self.currentSelection];
            self.currentSelection = -1;
        }
        return;
    }
    
    NSInteger newItemSelectionIndex = [self.delegate votingstack:self translateIndexForAngle:DEGREES(angle)];
    
    if (self.currentSelection != newItemSelectionIndex) {
//        [self.delegate votingStack:self willSelectItemAtIndex:self.carousel.currentItemIndex atIndex:newItemSelectionIndex];
        
        if (self.currentSelection >= 0) {
            [self.pieChart setSliceDeselectedAtIndex:self.currentSelection];
        }
        self.currentSelection = newItemSelectionIndex;
        [self.pieChart setSliceSelectedAtIndex:self.currentSelection];
    }
}



- (void) shouldShowUserSelectionCategory: (BOOL) shouldShow atTouchPoint: (CGPoint) centerPoint
{
    self.shouldLoadUserSelectionData = shouldShow;
    if (shouldShow) {
        [self.pieChart setCenter:centerPoint];
    }
    [self.pieChart reloadData];
}

#pragma mark - Getter & Setter

- (CGFloat)selectionCommitThresholdSquared
{
    return 100.0f*100.0f;
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
        
        UIView * currentView = [self currentSelectedView];
        
        [currentView removeGestureRecognizer:self.panGesture];
        
        currentView.layer.opacity = 0.0f;
        
        CGRect restoringFrame = currentView.frame;
        restoringFrame.origin = CGPointZero;
        currentView.frame = restoringFrame;
        
        [currentView removeFromSuperview];
        
        [self.oldCarouselContainerView addSubview:currentView];

    }
}


- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    UIView * topView = [self.carousel itemViewAtIndex:self.carousel.currentItemIndex];
    topView.frame = topView.superview.frame;
    topView.layer.opacity = 1.0f;
    topView.userInteractionEnabled = YES;
    
    [topView addGestureRecognizer:self.panGesture];
    
    self.oldCarouselContainerView = topView.superview;
    
    [self.SelectionView addSubview:topView];
}


#pragma mark - XYPieChartDataSource


- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    if (self.shouldLoadUserSelectionData) {
        NSUInteger numSlice = [self.dataSource votingStack:self numberOfSelectionForIndex:self.carousel.currentItemIndex];
        return numSlice;
    }else{
        return 0;
    }
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    if (self.shouldLoadUserSelectionData) {
        return [self.dataSource votingStack:self valueForSliceAtIndex:index forItem:self.carousel.currentItemIndex];
    } else {
        return 0.0f;
    }
}



- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    NSArray * arrColor = [NSArray arrayWithObjects:
     [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:0.5f],
     [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:0.5f],
     [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:0.5f],
     [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:0.5f],
                          [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:0.5f],nil];
    return [arrColor objectAtIndex:(index % arrColor.count)];
}



//#pragma mark - XYPieChartDelegate




#pragma mark - UIPanGestureRecognizer


- (void) pan:(UIPanGestureRecognizer *) panGesture
{
    CGPoint dxPointFromOrigin = [panGesture translationInView:self.SelectionView];
    
//    CGPoint locationOnScreen = [panGesture locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    CGFloat halfSelectionViewHeight = [[self currentSelectedView] bounds].size.height/2.0f;
    
    
    CGFloat angleFromLastTouchPoint = atan2f(dxPointFromOrigin.y, dxPointFromOrigin.x) + M_PI;
    
    // offset to the bottom point
    dxPointFromOrigin.y -= halfSelectionViewHeight;
    
    CGFloat angleFromCardBottomEdge = atan2f(dxPointFromOrigin.y, dxPointFromOrigin.x) + M_PI;
    
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateChanged:
        {
            
#ifdef VOTING_STACK_DEBUG
            NSLog(@"2: %f, dx=(x=%f, y=%f)", DEGREES(angleFromCardBottomEdge), dxPointFromOrigin.x, dxPointFromOrigin.y);
#endif
            CATransform3D translateRotation = CATransform3DMakeTranslation(dxPointFromOrigin.x, dxPointFromOrigin.y+halfSelectionViewHeight, 0.0f);
            
            translateRotation = CATransform3DRotate(translateRotation, angleFromCardBottomEdge - M_PI_2, 0, 0, 1);
            [self currentSelectedView].layer.transform = translateRotation;
            
            
            
            
            CGFloat SqDistanceFromrOrigin = dxPointFromOrigin.x * dxPointFromOrigin.x + (dxPointFromOrigin.y+halfSelectionViewHeight) * (dxPointFromOrigin.y+halfSelectionViewHeight);
            
            [self selectionShouldCommit:(SqDistanceFromrOrigin > self.selectionCommitThresholdSquared) WithAngle:angleFromLastTouchPoint];
            
        }
            break;
        case UIGestureRecognizerStateBegan:
        {
            [self shouldShowUserSelectionCategory:YES atTouchPoint:[panGesture locationInView:self]];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self shouldShowUserSelectionCategory:NO atTouchPoint:[panGesture locationInView:self]];
            [self currentSelectedView].layer.transform = CATransform3DIdentity;
        }
            break;
        default:
            break;
    }
}


@end
