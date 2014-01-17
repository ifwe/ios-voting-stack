//
//  VSContainerView.h
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import <UIKit/UIKit.h>



@class VotingStackView;

@protocol VotingStackViewDataSource <NSObject>
@required

- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView;
- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view;



@optional



@end





@interface VotingStackView : UIView
@property (nonatomic, weak) IBOutlet id<VotingStackViewDataSource> dataSource;

- (void) popFront;

@end


