//
//  VSViewController.m
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import "VSViewController.h"

#define MAGIC_TAG (78)

@interface VSViewController () <VotingStackViewDataSource>

@property (nonatomic, strong) NSMutableArray *arrayOfString;

@property (nonatomic, strong) NSMutableArray *arrayOfView;

@property (nonatomic, strong) NSMutableArray *arrayOfSelection;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *CurrentSelection;

@property (nonatomic, strong) UIAlertView *alertBox;

@property (nonatomic) BOOL shouldDisablePopup;

@end

@implementation VSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.voteView.backgroundColor = [UIColor grayColor];
    self.shouldDisablePopup = NO;
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

- (IBAction)togglePie:(UIBarButtonItem *)sender {
    self.voteView.shouldShowSelectionPie = !self.voteView.shouldShowSelectionPie;
    sender.title = self.voteView.shouldShowSelectionPie?@"pie: visible":@"pie: invisible";
}

- (IBAction)disablePopup:(UIBarButtonItem *)sender {
    self.shouldDisablePopup = !self.shouldDisablePopup;
    sender.title = self.shouldDisablePopup?(@"EnablePopup"):(@"DisablePopup");
}

- (UIAlertView *)alertBox
{
    if (self.shouldDisablePopup) {
        return nil;
    }
    if (!_alertBox) {
        _alertBox = [[UIAlertView alloc] initWithTitle:@"Last person got a" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    return _alertBox;
}

- (NSMutableArray *) arrayOfView
{
    if (!_arrayOfView) {
        _arrayOfView = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            
            NSString *imgName = [NSString stringWithFormat:@"img %d", (i % 5)];
            UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
            imgView.frame = CGRectMake(0, 0, 250, 300);
            
            [_arrayOfView addObject:imgView];
        }
    }
    return _arrayOfView;
}

- (IBAction)shouldWarp:(UIBarButtonItem *)sender {
    self.voteView.shouldWrap = !self.voteView.shouldWrap;
    sender.title = self.voteView.shouldWrap?@"warp: ON":@"warp: OFF";
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


- (NSMutableArray *)arrayOfString
{
    if (!_arrayOfString) {
        _arrayOfString = [[NSMutableArray alloc] initWithArray:@[@"cat", @"dog", @"bird", @"kid", @"turtle"]];
    }
    return _arrayOfString;
}

#pragma mark - VotingStackViewDataSource

- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView{
    return [self.arrayOfView count];
}


- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    UIView * theView = [self.arrayOfView objectAtIndex:index];
    UIView * taggedView = [theView viewWithTag:MAGIC_TAG];
    if (taggedView) {
        [taggedView removeFromSuperview];
    }
    return theView;
}



- (NSUInteger)votingStack:(VotingStackView *)vsView numberOfSelectionForIndex:(NSUInteger) index{
    return self.arrayOfSelection.count;
}

- (CGFloat)votingStack:(VotingStackView *)vsView valueForSliceAtIndex:(NSUInteger)index forItem:(NSUInteger) itemIndex{
    NSRange theRange = [self.arrayOfSelection[index] rangeValue];
    return theRange.length;
}



- (NSInteger) votingstack:(VotingStackView *) vsView translateIndexForAngle: (CGFloat) angle atIndex:(NSUInteger)itemIndex{
    __block NSInteger index = -1;
    [self.arrayOfSelection enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        if (NSLocationInRange((NSUInteger)angle, [obj rangeValue])){
            index = (NSInteger)idx;
            *stop = YES;
        }
    }];
    return index;
}



- (NSString *)votingstack:(VotingStackView *)vsView textForSliceAtIndex:(NSUInteger)index atIndex: (NSUInteger) itemIndex{
    return [self.arrayOfString objectAtIndex:(index % self.arrayOfString.count)];
}


- (UIColor *)votingstack:(VotingStackView *)vsView colorForSliceAtIndex:(NSUInteger)index atIndex: (NSUInteger) itemIndex{
        NSArray * arrColor = [NSArray arrayWithObjects:
         [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:0.5f],
         [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:0.5f],
         [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:0.5f],
         [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:0.5f],
                              [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:0.5f],nil];
        return [arrColor objectAtIndex:(index % arrColor.count)];
}



- (void) votingStack:(VotingStackView *) vsView willSelectChoiceAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex{
//    NSLog(@"%@, %d", NSStringFromSelector(_cmd), index);
    
    
    self.selectionIndex.text = [NSString stringWithFormat:@"%d", index];
    self.currentSelectionCategory.text = (index <0)?@"Cancel":self.arrayOfString[index%self.arrayOfString.count];
    
    UILabel * label = (UILabel *)[self.voteView.currentSelectionView viewWithTag:MAGIC_TAG];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 300)];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [label.font fontWithSize:25.0f];
        label.tag = MAGIC_TAG;
        [self.voteView.currentSelectionView addSubview:label];
    }
    
    if (index >= 0) {
        label.text = self.currentSelectionCategory.text;
    }else{
        label.text = @"";
    }
}

- (void) votingStack:(VotingStackView *) vsView didSelectChoiceAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex{
//    NSLog(@"%@, %d", NSStringFromSelector(_cmd), index);
    if (index != -1) {
        NSString * selection = [self.arrayOfString objectAtIndex:(index % self.arrayOfString.count)];
        
        [self.alertBox setMessage:selection];
        [self.alertBox show];
        
        [self.voteView popFront];
    }
}







@end
