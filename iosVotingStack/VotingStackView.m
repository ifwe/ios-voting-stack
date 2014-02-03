//
//  VSContainerView.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VotingStackView.h"
#import "iCarousel.h"
#import "XYPieChart.h"
#import "CGPointExtension.h"



#pragma mark - Macros
#define RADIANS(deg)  ((deg) * M_PI / 180)
#define DEGREES(rad)  ((rad) * 180 / M_PI)


@implementation NSObject (VotingStackView)



- (NSString *)votingstack:(VotingStackView *)vsView textForSliceAtIndex:(NSUInteger)index atIndex: (NSUInteger) itemIndex{return @"";}

- (UIColor *)votingstack:(VotingStackView *)vsView colorForSliceAtIndex:(NSUInteger)index atIndex: (NSUInteger) itemIndex{
    CGFloat randomBase = arc4random() % 74 +1 ;
    CGFloat topNum = ((CGFloat)(arc4random() % (NSInteger)randomBase));
    return [UIColor colorWithHue:topNum/randomBase
                      saturation:topNum/randomBase
                      brightness:topNum/randomBase
                           alpha:0.5];
};

- (void) votingStack:(VotingStackView *) vsView willSelectChoiceAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex{}
- (void) votingStack:(VotingStackView *) vsView didSelectChoiceAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex{}


- (CGFloat) votingStackTiltOption{return 0.6f;}

- (CGFloat) votingStackSpacingOption{return 0.2f;}


@end



@interface VotingStackView () <iCarouselDataSource, iCarouselDelegate, XYPieChartDataSource, XYPieChartDelegate>

@property (nonatomic, weak) iCarousel *carousel;

@property (nonatomic, weak) UIView *oldCarouselContainerView;

@property (nonatomic) BOOL shouldShowLastItemAgain;

@property (nonatomic, weak) UIView *SelectionView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) XYPieChart *pieChart;

@property (nonatomic) CGFloat selectionCommitThresholdSquared;

@property (nonatomic) BOOL shouldLoadUserSelectionData;

@property (nonatomic, weak) UIView *currentSelectionView;

@property (nonatomic, weak) UIView *disableUserTouchView;

// -1 is cancel. By default currentSelection is -1
@property (nonatomic) NSInteger currentSelection;

@property (nonatomic) UIGestureRecognizerState currentAnimationMovementState;

@property (nonatomic) CGPoint currentAnimationMovementStartPoint;

@property (nonatomic) CGPoint currentAnimationMovementEndPoint;

@property (nonatomic) CGFloat currentAnimationMovementPercentage;


@end


@implementation VotingStackView
@synthesize selectionCommitThresholdSquared = _selectionCommitThresholdSquared;

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
        _shouldWrap = YES;
        _shouldShowLastItemAgain = YES;
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
        pieChartTemp.showPercentage = NO;
        pieChartTemp.userInteractionEnabled = NO;
        pieChartTemp.startPieAngle = M_PI;
        pieChartTemp.alpha = (_shouldShowSelectionPie)?1.0f:0.0f;
        
        _pieChart = pieChartTemp;
        [self addSubview:pieChartTemp];
        
        self.currentSelection = -1;
        
        UIView *disableUserTouch = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:disableUserTouch];
        _disableUserTouchView = disableUserTouch;
        _disableUserTouchView.userInteractionEnabled = NO;
        
        _isAnimatedMovement = NO;
        _animationInterval = 0.008;
        _currentAnimationMovementState = UIGestureRecognizerStateFailed;
        _currentAnimationMovementChangeRate = 0.01f;
        _currentAnimationMovementStartPoint = CGPointZero;
        _currentAnimationMovementEndPoint = CGPointZero;
        
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


- (void)reloadData
{
    [self restoreTopMostViewFromCarousel];
    [self.carousel reloadData];
    [self borrowTopMostViewFromCarousel];
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
            [self.delegate votingStack:self willSelectChoiceAtIndex:self.currentSelection
                               atIndex:self.carousel.currentItemIndex];
        }
        return;
    }
    
    
    
    NSInteger newItemSelectionIndex = [self.delegate votingstack:self translateIndexForAngle:DEGREES(angle) atIndex:self.carousel.currentItemIndex];
    
    if (self.currentSelection != newItemSelectionIndex) {
        
        [self.delegate votingStack:self willSelectChoiceAtIndex:newItemSelectionIndex
                           atIndex:self.carousel.currentItemIndex];
        
        if (self.currentSelection >= 0) {
            [self.pieChart setSliceDeselectedAtIndex:self.currentSelection];
        }
        self.currentSelection = newItemSelectionIndex;
        if (self.currentSelection >= 0) {
            [self.pieChart setSliceSelectedAtIndex:self.currentSelection];
        }
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

- (void) borrowTopMostViewFromCarousel
{
    UIView * topView = [self.carousel itemViewAtIndex:self.carousel.currentItemIndex];
    
    topView.frame = [topView convertRect:topView.frame toView:self.SelectionView];
    
    topView.layer.opacity = 1.0f;
    topView.userInteractionEnabled = YES;
    
    [topView addGestureRecognizer:self.panGesture];
    
    self.oldCarouselContainerView = topView.superview;
    
    [self.SelectionView addSubview:topView];
}

- (void) restoreTopMostViewFromCarousel
{
    if ([self.SelectionView.subviews count]!= 0) {
        UIView * view = [self currentSelectedView];
        
        [view removeGestureRecognizer:self.panGesture];
        view.layer.opacity = 0.0f;
        view.frame = view.bounds;
        [view removeFromSuperview];
        
        [self.oldCarouselContainerView addSubview:view];
    }
}


- (CATransform3D) offStageTransformation: (CGPoint) releasePoint forAngle: (CGFloat) angle
{
    if (angle < 0) {
        return CATransform3DIdentity;
    }
    CGPoint offStagePoint = CGPointMake(releasePoint.x*3.0f, releasePoint.y*3.0f);
    
    CATransform3D translateRotation = CATransform3DMakeTranslation(offStagePoint.x, offStagePoint.y, 0.0f);
    translateRotation = CATransform3DRotate(translateRotation, angle, 0, 0, 1);
    return translateRotation;
    
}


- (void) setUserTouchInputDisable : (BOOL) shouldDisable
{
    self.disableUserTouchView.userInteractionEnabled = shouldDisable;
}

#pragma mark - Getter & Setter

- (CGFloat)selectionCommitThresholdSquared
{
    return _selectionCommitThresholdSquared;
}

- (void)setSelectionCommitThresholdSquared:(CGFloat)selectionCommitThresholdSquared
{
    _selectionCommitThresholdSquared = selectionCommitThresholdSquared;
    self.pieChart.pieRadius = sqrtf(_selectionCommitThresholdSquared);
}


- (CGFloat)selectionCommitThreshold
{
    return sqrtf(_selectionCommitThresholdSquared);
}

- (void)setSelectionCommitThreshold:(CGFloat)selectionCommitThreshold
{
    [self setSelectionCommitThresholdSquared:selectionCommitThreshold * selectionCommitThreshold];
}

- (void)setShouldWrap:(BOOL)shouldWrap
{
    [self restoreTopMostViewFromCarousel];
    
    _shouldWrap = shouldWrap;
    [self.carousel reloadData];
    
    [self borrowTopMostViewFromCarousel];
}

- (void)setShouldShowSelectionPie:(BOOL)shouldShowSelectionPie
{
    _shouldShowSelectionPie = shouldShowSelectionPie;
    self.pieChart.layer.opacity = (_shouldShowSelectionPie)?1.0f:0.0f;
}

- (UIView *)currentSelectionView
{
    if ([self.SelectionView subviews].count != 0) {
        return [self currentSelectedView];
    }
    return nil;
}

#pragma mark - iCarouselDataSource

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [self.dataSource numberOfItemsInVotingStack:self];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    UIView * theView = [self.dataSource votingStack:self viewForItemAtIndex:index reusingView:view];
    theView.layer.opacity = 1.0f;
    return theView;
}



- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
    switch (option) {
        case iCarouselOptionTilt:
            return [self.delegate votingStackTiltOption];
        case iCarouselOptionSpacing:
            return [self.delegate votingStackSpacingOption];
        case iCarouselOptionWrap:
            return self.shouldWrap;
        default:
            return value;
    }
}

#pragma mark - iCarouselDelegate

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel
{
    [self restoreTopMostViewFromCarousel];
}


- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if (!self.carousel.isWrapEnabled &&
        (self.carousel.currentItemIndex +1 == self.carousel.numberOfItems)) {
        if (self.shouldShowLastItemAgain) {
            self.shouldShowLastItemAgain = NO;
        }else{
            return;
        }
        [self borrowTopMostViewFromCarousel];
    } else {
        self.shouldShowLastItemAgain = YES;
        [self borrowTopMostViewFromCarousel];
    }
}


#pragma mark - XYPieChartDataSource


- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    if (self.shouldLoadUserSelectionData) {
        NSUInteger numSlice = [self.dataSource votingStack:self numberOfSelectionForIndex:self.carousel.currentItemIndex];
        return numSlice;
    } else {
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
    return [self.delegate votingstack:self colorForSliceAtIndex:index atIndex:self.carousel.currentItemIndex];
}



- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index{
    return [self.delegate votingstack:self textForSliceAtIndex:index atIndex:self.carousel.currentItemIndex];

}


//#pragma mark - XYPieChartDelegate




#pragma mark - UIPanGestureRecognizer


- (void)userCurrentItemSelection:(CGPoint)dxPointFromOrigin locationOnScreen:(CGPoint)locationOnScreen currentState:(UIGestureRecognizerState)currentState andEndOfCurrentStateBlock:(void (^)(void))callbackBlock;
{
    //    CGPoint locationOnScreen = [panGesture locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    CGFloat halfSelectionViewHeight = [[self currentSelectedView] bounds].size.height/2.0f;
    
    CGFloat angleFromLastTouchPoint = atan2f(dxPointFromOrigin.y, dxPointFromOrigin.x) + M_PI;
    
    // offset to the bottom point
    dxPointFromOrigin.y -= halfSelectionViewHeight;
    
    CGFloat angleFromCardBottomEdge = atan2f(dxPointFromOrigin.y, dxPointFromOrigin.x) + M_PI;
    
    
    switch (currentState) {
        case UIGestureRecognizerStateChanged:
        {
            
#ifdef VOTING_STACK_DEBUG
            NSLog(@"2: %f, dx=(x=%f, y=%f), locS=(x=%f, y=%f)", DEGREES(angleFromCardBottomEdge), dxPointFromOrigin.x, dxPointFromOrigin.y, locationOnScreen.x, locationOnScreen.y);
#endif
            CATransform3D translateRotation = CATransform3DMakeTranslation(dxPointFromOrigin.x, dxPointFromOrigin.y+halfSelectionViewHeight, 0.0f);
            
            translateRotation = CATransform3DRotate(translateRotation, angleFromCardBottomEdge - M_PI_2, 0, 0, 1);
            [self currentSelectedView].layer.transform = translateRotation;
            
            CGFloat SqDistanceFromrOrigin = dxPointFromOrigin.x * dxPointFromOrigin.x + (dxPointFromOrigin.y+halfSelectionViewHeight) * (dxPointFromOrigin.y+halfSelectionViewHeight);
            
            [self selectionShouldCommit:(SqDistanceFromrOrigin > self.selectionCommitThresholdSquared) WithAngle:angleFromLastTouchPoint];
            
            if (callbackBlock) callbackBlock();
        }
            break;
        case UIGestureRecognizerStateBegan:
        {
            [self shouldShowUserSelectionCategory:YES atTouchPoint:locationOnScreen];
            if (callbackBlock) callbackBlock();
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            [self shouldShowUserSelectionCategory:NO atTouchPoint:locationOnScreen];
            
            
            CGPoint offStagePoint = CGPointMake(dxPointFromOrigin.x, dxPointFromOrigin.y+halfSelectionViewHeight);
            CATransform3D offStageTransformation = [self offStageTransformation:offStagePoint forAngle:(self.currentSelection<0)?-1.0f:angleFromLastTouchPoint];
            //[self offStageTransformation:offStagePoint andCurrentSelection:self.currentSelection withCurrentTransformation:[self currentSelectedView].layer.transform];
            
            [UIView animateWithDuration:0.3f animations:^{
                [self currentSelectedView].layer.transform = offStageTransformation;
            } completion:^(BOOL finished) {
                [self currentSelectedView].layer.transform = CATransform3DIdentity;
                [self.delegate votingStack:self didSelectChoiceAtIndex:self.currentSelection
                                   atIndex:self.carousel.currentItemIndex];
                
                if (callbackBlock) callbackBlock();
            }];
            
            
        }
            break;
        default:
            break;
    }
}



- (void) pan:(UIPanGestureRecognizer *) panGesture
{
    CGPoint dxPointFromOrigin = [panGesture translationInView:self.SelectionView];
    
    CGPoint locationOnScreen = [panGesture locationInView:self];
    
    UIGestureRecognizerState currentState = panGesture.state;
    
    [self userCurrentItemSelection:dxPointFromOrigin locationOnScreen:locationOnScreen currentState:currentState andEndOfCurrentStateBlock:nil];
}


/*
 DFA for animated pan:
 [UIGestureRecognizerStateFailed]                           -> [UIGestureRecognizerStateBegan]      ; disable user touch & update start & 
                                                                                                    ; end point & percentage = 0.0f & isAnimatedMovement = YES
 [UIGestureRecognizerStateBegan]                            -> [UIGestureRecognizerStateChanged]    ; percentage += changeRate
 [UIGestureRecognizerStateChanged]                          -> [UIGestureRecognizerStateChanged]    ; percentage += changeRate
 [percentage >= 100.0f && UIGestureRecognizerStateChanged]  -> [UIGestureRecognizerStateEnded]
 [UIGestureRecognizerStateEnded][END STATE]                 -> [UIGestureRecognizerStateFailed]     ; enable user touch & start & end point & percentage = 0.0f 
                                                                                                    ; isAnimatedMovement = NO
 */

- (void) animatedPanFrom: (CGPoint) fromLocation to: (CGPoint) toLocation
{
    if (self.SelectionView.subviews.count == 0) {
        return;
    }
    
    if (self.currentAnimationMovementState != UIGestureRecognizerStateFailed &&
         CGPointEqualToPoint(fromLocation, CGPointZero)
        && CGPointEqualToPoint(toLocation, CGPointZero)) {
        
        // animated movement in process
    } else if (self.currentAnimationMovementState == UIGestureRecognizerStateFailed){
        
        // ready for another animation
    }else {
        // other wise anything will be ignored.
        
        return;
    }
    
    
    switch (self.currentAnimationMovementState) {
        case UIGestureRecognizerStateFailed:
        {
            self.currentAnimationMovementState = UIGestureRecognizerStateBegan;
            _isAnimatedMovement = YES;
            
            [self setUserTouchInputDisable:YES];
            self.currentAnimationMovementStartPoint = fromLocation;
            self.currentAnimationMovementEndPoint = toLocation;
            self.currentAnimationMovementPercentage = 0.0f;
            
            assert(_currentAnimationMovementChangeRate > 0.0f);
            
        }
            break;
        case UIGestureRecognizerStateBegan:
        {
            self.currentAnimationMovementState = UIGestureRecognizerStateChanged;
            
            self.currentAnimationMovementPercentage += self.currentAnimationMovementChangeRate;
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
#ifdef VOTING_STACK_DEBUG
            NSLog(@"%f", self.currentAnimationMovementPercentage);
#endif
            if (self.currentAnimationMovementPercentage >= 1.0f){
                self.currentAnimationMovementState = UIGestureRecognizerStateEnded;
            }else{
                self.currentAnimationMovementPercentage += self.currentAnimationMovementChangeRate;
            }
        }
            break;
        default: //UIGestureRecognizerStateEnded or others
        {
            
        }
            return; // END STATE
            
    }
    
    // using line equation: L(t) = A + t(B-A)
    
    CGPoint tMultBMinusA = CGPointMult(CGPointSub(self.currentAnimationMovementEndPoint, self.currentAnimationMovementStartPoint),
                                                    self.currentAnimationMovementPercentage);
    
    CGPoint dxPointFromOrigin = tMultBMinusA;
    
    CGPoint locationOnScreen = CGPointAdd(self.currentAnimationMovementStartPoint, tMultBMinusA);
    
    __weak VotingStackView * weakSelf = self;
    
    [self userCurrentItemSelection:dxPointFromOrigin locationOnScreen:locationOnScreen currentState:self.currentAnimationMovementState andEndOfCurrentStateBlock:^{
        double delayInSeconds = weakSelf.animationInterval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if (self.currentAnimationMovementState == UIGestureRecognizerStateEnded){
                self.currentAnimationMovementState = UIGestureRecognizerStateFailed;
                _isAnimatedMovement = NO;
                
                
                [self setUserTouchInputDisable:NO];
                
                self.currentAnimationMovementStartPoint = CGPointZero;
                self.currentAnimationMovementEndPoint = CGPointZero;
                self.currentAnimationMovementPercentage = 0.0f;
            }
            [weakSelf animatedPanFrom:CGPointZero to:CGPointZero];
        });
        
    }];
    
}


@end
