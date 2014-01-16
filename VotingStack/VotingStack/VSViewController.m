//
//  VSViewController.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VSViewController.h"

@interface VSViewController ()

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
    [self.voteView stepForward];
}

#pragma mark - VotingStackViewDataSource


- (UIView *) VotingStackView: (VotingStackView *) vsView viewForItemAtIndex: (NSInteger) index
{
    NSString *imgName = [NSString stringWithFormat:@"img %d", (index % 12)];
    NSLog(@"%@", imgName);
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
}

@end
