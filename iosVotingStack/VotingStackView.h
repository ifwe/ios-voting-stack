//
//  VSContainerView.h
//  VotingStack
//
//  Created by Yong Xin Dai on 1/13/14.
//  Copyright (c) 2014 Tagged. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

//#define VOTING_STACK_DEBUG (YES)


@class VotingStackView;

@protocol VotingStackViewDataSource <NSObject>
@required
/*
 *  There are two parts to VotingStackView.
 *  One is the stack's depth effect (the stack portion) and another is selection of the top most view (the selection portion).
 */


// stack portion
/*
 *  This define the number of items in the voting stack view's stack
 */
- (NSUInteger)numberOfItemsInVotingStack:(VotingStackView *)vsView;
/*
 *  Returns the view for each stack
 */
- (UIView *)votingStack:(VotingStackView *)vsView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view;


// selection portion
/*
 *  Each time, when a view is being selected.
 *  Selection view will ask its dataSource, how many selection are there for each view.
 *
 *  Example: return 4 would tell selection view the item currently selected have 4 possible selections
 */
- (NSUInteger)votingStack:(VotingStackView *)vsView numberOfSelectionForIndex:(NSUInteger) index;
/*
 *  Will ask size of each slice of selection for that slice in degree
 *
 *  Example: When argunment [index] is 3 and return 70. This would tell selection view that slice 3 would have a angle of 70 degree in the selection pie
 */
- (CGFloat)votingStack:(VotingStackView *)vsView valueForSliceAtIndex:(NSUInteger)index forItem:(NSUInteger) itemIndex;

@optional

@end






@protocol VotingStackViewDelegate <NSObject>

@required

/*
 *  When user's selection goes above the [selectionCommitThreshold]
 *  SelectionView will ask delegate which slice should be highlight for the argunment [angle]
 */
- (NSInteger) votingstack:(VotingStackView *) vsView translateIndexForAngle: (CGFloat) angle atIndex: (NSUInteger) itemIndex;

@optional


/*
 *  Will ask for text for each slice of selection pie
 *
 *  Default would be @""
 */
- (NSString *)votingstack:(VotingStackView *)vsView textForSliceAtIndex:(NSUInteger)index atIndex: (NSUInteger) itemIndex;
/*
 *  Will ask for the color of each selection pie
 *
 *  Default would be (arc4random() % 74 +1) generated HPB color
 */
- (UIColor *)votingstack:(VotingStackView *)vsView colorForSliceAtIndex:(NSUInteger)index atIndex: (NSUInteger) itemIndex;

/*
 *  When user's has gone above [selectionCommitThreshold]
 */
- (void) votingStack:(VotingStackView *) vsView willSelectChoiceAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex;

/*
 *  When user release finger from selection process
 */
- (void) votingStack:(VotingStackView *) vsView didSelectChoiceAtIndex: (NSInteger) index atIndex: (NSUInteger) itemIndex;

/*
 * when user tap on the selectable view
 */
- (void) votingStack:(VotingStackView *)vsView didTapOnItemAtIndex:(NSUInteger)itemIndex;


/*
 *  When view become selectable
 */
- (void) votingStack: (VotingStackView *) vsView viewDidBecomeSelectable:(UIView *) selectableView atIndex: (NSUInteger) itemIndex;

/*
 *  The stack's titlt option
 */
- (CGFloat) votingStackTiltOption;

/*
 *  The stack's spaing option
 */
- (CGFloat) votingStackSpacingOption;

@end







@interface VotingStackView : UIView

@property (nonatomic, weak) IBOutlet id<VotingStackViewDataSource> dataSource;

@property (nonatomic, weak) IBOutlet id<VotingStackViewDelegate> delegate;

@property (nonatomic) CGFloat selectionCommitThreshold; // also controls the radius of the selection pie

@property (nonatomic) BOOL shouldWrap;

@property (nonatomic) BOOL shouldShowSelectionPie;

@property (nonatomic, readonly) UIView *currentSelectionView;

@property (nonatomic, readonly) BOOL isAnimatedMovement;

@property (nonatomic) CGFloat animationInterval;

@property (nonatomic) CGFloat currentAnimationMovementChangeRate;

- (void) popFront;

- (void) reloadData;

- (void) animatedPanFrom: (CGPoint) fromLocation to: (CGPoint) toLocation;
//- (void) pushFront;

@end


