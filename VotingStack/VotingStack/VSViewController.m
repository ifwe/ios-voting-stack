//
//  VSViewController.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VSViewController.h"

@interface VSViewController () <VotingStackViewDataSource>

@end

@implementation VSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.voteView.dataSource = self;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stepForward:(id)sender {
    [self.voteView popFront];
}

#pragma mark - VotingStackViewDataSource

- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView{
    return 1;
}


- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    NSString *imgName = [NSString stringWithFormat:@"img %d", (index % 12)];
    UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    imgView.frame = CGRectMake(0, 0, 200, 250);
    return imgView;
    
}

@end
