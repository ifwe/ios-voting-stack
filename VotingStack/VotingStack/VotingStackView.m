//
//  VSContainerView.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VotingStackView.h"
#import "iCarousel+votingStackView.h"




@interface VotingStackView () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, weak) iCarousel *carousel;

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
        
        [self addSubview:car];
        self.carousel = car;
    });
}


- (void)popFront
{
    [self.carousel itemViewAtIndex:self.carousel.currentItemIndex+1].layer.opacity = 0.0;
    [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex+1 animated:YES];
}


#pragma mark - View layout

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self setup];
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



- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel
{
    
}


@end
