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

@property (nonatomic, strong) NSMutableArray *arrayOfSelection;
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
//    [self.voteView pushFront];
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


- (NSMutableArray *)arrayOfSelection
{
    if (!_arrayOfSelection) {
        _arrayOfSelection = [NSMutableArray new];
        [_arrayOfSelection addObject:[NSValue valueWithRange:NSMakeRange(0, 90)]];
        [_arrayOfSelection addObject:[NSValue valueWithRange:NSMakeRange(90, 90)]];
        [_arrayOfSelection addObject:[NSValue valueWithRange:NSMakeRange(180, 90)]];
        [_arrayOfSelection addObject:[NSValue valueWithRange:NSMakeRange(270, 30)]];
        [_arrayOfSelection addObject:[NSValue valueWithRange:NSMakeRange(300, 60)]];
    }
    return _arrayOfSelection;
}
#pragma mark - VotingStackViewDataSource

- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView{
    return [self.arrayOfView count];
}


- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    return [self.arrayOfView objectAtIndex:index];
}



- (NSUInteger)votingStack:(VotingStackView *)vsView numberOfSelectionForIndex:(NSUInteger) index{
    return self.arrayOfSelection.count;
}

- (CGFloat)votingStack:(VotingStackView *)vsView valueForSliceAtIndex:(NSUInteger)index forItem:(NSUInteger) itemIndex{
    NSRange theRange = [self.arrayOfSelection[index] rangeValue];
    return theRange.length;
}



- (NSInteger) votingstack:(VotingStackView *) vsView translateIndexForAngle: (CGFloat) angle{
    __block NSInteger index = -1;
    [self.arrayOfSelection enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        if (NSLocationInRange((NSUInteger)angle, [obj rangeValue])){
            index = (NSInteger)idx;
            *stop = YES;
        }
    }];
    return index;
}


@end
