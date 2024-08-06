//
//  UIViewController+MJPopupViewController.h
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

@property (nonatomic, strong, nullable) UIViewController *mj_popupViewController;
@property (nonatomic, strong, nullable) UIView *mj_popupBackgroundView;
@property (nonatomic, strong, nullable) MJPopupViewTheme *mj_popupTheme;

- (void)mj_presentPopupViewController:(UIViewController*)popupViewController
                                theme:(MJPopupViewTheme *)theme
                        animationType:(MJPopupViewAnimation)animationType;

- (void)mj_presentPopupViewController:(UIViewController*)popupViewController
                                theme:(MJPopupViewTheme *)theme
                        animationType:(MJPopupViewAnimation)animationType
                    presentCompletion:(nullable dispatch_block_t)presentCompletion
                    dismissCompletion:(nullable dispatch_block_t)dismissCompletion;

- (void)mj_dismissPopupViewControllerWithAnimationType:(MJPopupViewAnimation)animationType
                                            completion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
