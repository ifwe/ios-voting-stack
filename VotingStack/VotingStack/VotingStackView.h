//
//  VSContainerView.h
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol VotingStackViewDataSource;

@interface VotingStackView : UIView

@property (nonatomic, weak) id<VotingStackViewDataSource> dataSource;
- (void) stepForward;


@end




@protocol VotingStackViewDataSource <NSObject>
@required

- (UIView *) VotingStackView: (VotingStackView *) vsView viewForItemAtIndex: (NSInteger) index;
@optional



@end