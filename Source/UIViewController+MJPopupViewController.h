//
//  UIViewController+MJPopupViewController.h
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPopupBackgroundView;
@class MJPopupViewTheme;

typedef enum {
    MJPopupViewAnimationNone = 0,
    MJPopupViewAnimationFade = 1,
    MJPopupViewAnimationSlideBottomTop,
    MJPopupViewAnimationSlideBottomBottom,
    MJPopupViewAnimationSlideTopTop,
    MJPopupViewAnimationSlideTopBottom,
    MJPopupViewAnimationSlideLeftLeft,
    MJPopupViewAnimationSlideLeftRight,
    MJPopupViewAnimationSlideRightLeft,
    MJPopupViewAnimationSlideRightRight,
} MJPopupViewAnimation;

@interface UIViewController (MJPopupViewController)

@property (nonatomic, strong) UIViewController *mj_popupViewController;

- (void)presentPopupViewController:(UIViewController*)popupViewController
                             theme:(MJPopupViewTheme *)theme
                     animationType:(MJPopupViewAnimation)animationType;

- (void)presentPopupViewController:(UIViewController*)popupViewController
                             theme:(MJPopupViewTheme *)theme
                     animationType:(MJPopupViewAnimation)animationType
                         dismissed:(void(^)(void))dismissed;

- (void)dismissPopupViewControllerWithAnimationType:(MJPopupViewAnimation)animationType;

@end
