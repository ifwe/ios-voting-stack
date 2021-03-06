//
//  VSContainerView.h
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

//#define VOTING_STACK_DEBUG (YES)


@class VotingStackView;

@protocol VotingStackViewDataSource <NSObject>
@required

// stack portion
- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView;
- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view;


// selection portion
- (NSUInteger)votingStack:(VotingStackView *)vsView numberOfSelectionForIndex:(NSUInteger) index;
- (CGFloat)votingStack:(VotingStackView *)vsView valueForSliceAtIndex:(NSUInteger)index forItem:(NSUInteger) itemIndex;

@optional

@end






@protocol VotingStackViewDelegate <NSObject>

@required
- (NSInteger) votingstack:(VotingStackView *) vsView translateIndexForAngle: (CGFloat) angle atIndex: (NSUInteger) itemIndex;

@optional



- (NSString *)votingstack:(VotingStackView *)vsView textForSliceAtIndex:(NSUInteger)index atIndex: (NSUInteger) itemIndex;

- (UIColor *)votingstack:(VotingStackView *)vsView colorForSliceAtIndex:(NSUInteger)index atIndex: (NSUInteger) itemIndex;


- (void) votingStack:(VotingStackView *) vsView willSelectChoiceAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex;
- (void) votingStack:(VotingStackView *) vsView didSelectChoiceAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex;


- (CGFloat) votingStackTiltOption;

- (CGFloat) votingStackSpacingOption;

@end







@interface VotingStackView : UIView

@property (nonatomic, weak) IBOutlet id<VotingStackViewDataSource> dataSource;

@property (nonatomic, weak) IBOutlet id<VotingStackViewDelegate> delegate;

// the radius of the pie, squared.
@property (nonatomic) CGFloat selectionCommitThresholdSquared;

@property (nonatomic) BOOL shouldWrap;

@property (nonatomic) BOOL shouldShowSelectionPie;

@property (nonatomic, readonly) UIView *currentSelectionView;

@property (nonatomic, readonly) BOOL isAnimatedMovement;

- (void) popFront;

- (void) reloadData;

- (void) animatedPanFrom: (CGPoint) fromLocation to: (CGPoint) toLocation;
//- (void) pushFront;

@end


