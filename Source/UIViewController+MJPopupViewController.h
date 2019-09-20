//
//  UIViewController+MJPopupViewController.h
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPopupBackgroundView;

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
@property (nonatomic, strong) UIView *mj_popupBackgroundView;
@property (nonatomic, strong) NSShadow *mj_popupShadow;
@property (nonatomic, strong) UIColor *mj_popupBackgroundColor;
@property (nonatomic, strong) NSNumber *mj_popupCornerRadius;
@property (nonatomic, strong) NSNumber *mj_popupModalAnimationDuration;

- (void)presentPopupViewController:(UIViewController*)popupViewController
                     animationType:(MJPopupViewAnimation)animationType;

- (void)presentPopupViewController:(UIViewController*)popupViewController
                     animationType:(MJPopupViewAnimation)animationType
                         dismissed:(void(^)(void))dismissed;

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(MJPopupViewAnimation)animationType;
- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(MJPopupViewAnimation)animationType dismissed:(void(^)(void))dismissed;
- (void)dismissPopupViewControllerWithAnimationType:(MJPopupViewAnimation)animationType;

@end
