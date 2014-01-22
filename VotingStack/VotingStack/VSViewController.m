//
//  VSViewController.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VSViewController.h"

@interface VSViewController () <VotingStackViewDataSource>

@property (nonatomic, strong) NSMutableArray *arrayOfView;

@end

@implementation VSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.voteView.backgroundColor = [UIColor grayColor];
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

- (IBAction)pushFront:(UIButton *)sender {
    [self.voteView pushFront];
}

- (NSMutableArray *) arrayOfView
{
    if (!_arrayOfView) {
        _arrayOfView = [[NSMutableArray alloc] init];
        for (int i = 0; i < 12; i++) {
            
            NSString *imgName = [NSString stringWithFormat:@"img %d", (i % 12)];
            UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
            imgView.frame = CGRectMake(0, 0, 200, 250);
            
            [_arrayOfView addObject:imgView];
        }
    }
    return _arrayOfView;
}

#pragma mark - VotingStackViewDataSource

- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView{
    return [self.arrayOfView count];
}


- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    return [self.arrayOfView objectAtIndex:index];
}

@end
