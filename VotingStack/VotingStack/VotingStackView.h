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

- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView;
- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view;

@optional

@end






@protocol VotingStackViewDelegate <NSObject>

@optional

- (void) votingStack:(VotingStackView *) vsView didSelectionItemAtIndex: (NSInteger) index;

@end







@interface VotingStackView : UIView
@property (nonatomic, weak) IBOutlet id<VotingStackViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<VotingStackViewDelegate> delegate;

- (void) popFront;

@end


