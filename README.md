Purpose
--------------
Voting Stack View is an simple and easy-to-use selection visual representation. It takes advantage of iCarousel and XYPieChart to give the world class animation.

![Demo](https://s3.amazonaws.com/uploads.hipchat.com/30/602337/hCHDPFvF8scRG2H/selection.gif)

Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 6.1 (Xcode 4.6, Apple LLVM compiler 4.2)

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

As of version 1.0, VotingStackView requires ARC. If you wish to use VotingStackView in a non-ARC project, just add the -fobjc-arc compiler flag to the VotingStackView.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click VotingStackView.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in VotingStackView.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including VotingStackView.m) are checked.


Thread Safety
--------------

VotingStackView is derived from UIView and - as with all UIKit components - it should only be accessed from the main thread. You may wish to use threads for loading or updating content views or items, but always ensure that once your content has loaded, you switch back to the main thread before updating the carousel.


Installation
--------------

To use the VotingStackView class in an app, just drag the VotingStackView class files (demo files and assets are not needed) into your project and add the QuartzCore framework.

Voting Stack View require you to implement some 5 delegate method for it to be useable.



