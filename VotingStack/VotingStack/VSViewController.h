//
//  VSViewController.h
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VotingStackView.h"

@interface VSViewController : UIViewController <VotingStackViewDataSource>
@property (weak, nonatomic) IBOutlet VotingStackView *voteView;

@property (weak, nonatomic) IBOutlet UILabel *selectionIndex;

@end
