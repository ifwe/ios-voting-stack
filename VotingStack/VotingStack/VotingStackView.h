//
//  VSContainerView.h
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

#define VOTING_STACK_DEBUG (YES)


@class VotingStackView;

@protocol VotingStackViewDataSource <NSObject>
@required

// stack proportion
- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView;
- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view;


// selection proportion
- (NSUInteger)votingStack:(VotingStackView *)vsView numberOfSelectionForIndex:(NSUInteger) index;
- (CGFloat)votingStack:(VotingStackView *)vsView valueForSliceAtIndex:(NSUInteger)index forItem:(NSUInteger) itemIndex;

@optional

@end






@protocol VotingStackViewDelegate <NSObject>

@required
- (NSInteger) votingstack:(VotingStackView *) vsView translateIndexForAngle: (CGFloat) angle;

@optional

- (void) votingStack:(VotingStackView *) vsView willSelectItemAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex;
- (void) votingStack:(VotingStackView *) vsView didSelectItemAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex;

@end







@interface VotingStackView : UIView
@property (nonatomic, weak) IBOutlet id<VotingStackViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<VotingStackViewDelegate> delegate;
@property (nonatomic) CGFloat selectionCommitThresholdSquared;

- (void) popFront;
//- (void) pushFront;

@end


