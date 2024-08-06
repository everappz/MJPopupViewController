//
//  UIViewController+MJPopupViewController.m
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import "UIViewController+MJPopupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MJPopupBackgroundView.h"
#import "MJPopupViewTheme.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#define kPopupModalAnimationDuration 0.25

static const void *kMJPopupViewController = &kMJPopupViewController;
static const void *kMJPopupBackgroundView = &kMJPopupBackgroundView;
static const void *kMJPopupTheme = &kMJPopupTheme;
static const void *MJPopupViewDismissedCallback = &MJPopupViewDismissedCallback;

#define kMJSourceViewTag 11000
#define kMJPopupViewTag 11001
#define kMJOverlayViewTag 11002
#define kMJShadowViewTag 11003



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public

@implementation UIViewController (MJPopupViewController)

- (void)mj_presentPopupViewController:(UIViewController*)popupViewController
                                theme:(MJPopupViewTheme *)theme
                        animationType:(MJPopupViewAnimation)animationType
                    presentCompletion:(nullable dispatch_block_t)presentCompletion
                    dismissCompletion:(nullable dispatch_block_t)dismissCompletion
{
    self.mj_popupViewController = popupViewController;
    [self mj_presentPopupView:popupViewController.view
                        theme:theme
                animationType:animationType
            presentCompletion:presentCompletion
            dismissCompletion:dismissCompletion];
}

- (void)mj_presentPopupViewController:(UIViewController*)popupViewController
                                theme:(MJPopupViewTheme *)theme
                        animationType:(MJPopupViewAnimation)animationType
{
    [self mj_presentPopupViewController:popupViewController
                                  theme:theme
                          animationType:animationType
                      presentCompletion:nil
                      dismissCompletion:nil];
}

- (void)mj_dismissPopupViewControllerWithAnimationType:(MJPopupViewAnimation)animationType
                                            completion:(nullable dispatch_block_t)completion
{
    UIView *sourceView = [self mj_topView];
    UIView *popupView = [sourceView viewWithTag:kMJPopupViewTag];
    UIView *overlayView = [sourceView viewWithTag:kMJOverlayViewTag];
    
    switch (animationType) {
        case MJPopupViewAnimationSlideBottomTop:
        case MJPopupViewAnimationSlideBottomBottom:
        case MJPopupViewAnimationSlideTopTop:
        case MJPopupViewAnimationSlideTopBottom:
        case MJPopupViewAnimationSlideLeftLeft:
        case MJPopupViewAnimationSlideLeftRight:
        case MJPopupViewAnimationSlideRightLeft:
        case MJPopupViewAnimationSlideRightRight:
            [self mj_slideViewOut:popupView
                       sourceView:sourceView
                      overlayView:overlayView
                withAnimationType:animationType
                       completion:completion];
            break;
            
        case MJPopupViewAnimationFade:
            [self mj_fadeViewOut:popupView
                      sourceView:sourceView
                     overlayView:overlayView
                        animated:YES
                      completion:completion];
            break;
            
        default:
            [self mj_fadeViewOut:popupView
                      sourceView:sourceView
                     overlayView:overlayView
                        animated:NO
                      completion:completion];
            break;
    }
    
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Handling

- (void)mj_presentPopupView:(UIView*)popupView
                      theme:(MJPopupViewTheme *)theme
              animationType:(MJPopupViewAnimation)animationType
{
    [self mj_presentPopupView:popupView
                        theme:theme
                animationType:animationType
            presentCompletion:nil
            dismissCompletion:nil];
}

- (void)mj_presentPopupView:(UIView *)popupView
                      theme:(MJPopupViewTheme *)theme
              animationType:(MJPopupViewAnimation)animationType
          presentCompletion:(nullable dispatch_block_t)presentCompletion
          dismissCompletion:(nullable dispatch_block_t)dismissCompletion
{
    self.mj_popupTheme = theme;
    
    UIView *sourceView = [self mj_topView];
    sourceView.tag = kMJSourceViewTag;
    popupView.autoresizingMask = 
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleRightMargin;
    popupView.tag = kMJPopupViewTag;
    
    // check if source view controller is not in destination
    if ([sourceView.subviews containsObject:popupView]) return;
    
    // customize popupView
    if(self.mj_popupTheme.mj_popupCornerRadius>0){
        popupView.layer.cornerRadius = self.mj_popupTheme.mj_popupCornerRadius;
        popupView.layer.masksToBounds = YES;
    }
    
    // Add shadow view
    UIView *shadowView = [[UIView alloc] initWithFrame:popupView.frame];
    shadowView.autoresizingMask = popupView.autoresizingMask;
    shadowView.tag = kMJShadowViewTag;
    shadowView.backgroundColor = [UIColor clearColor];
    
    if(self.mj_popupTheme.mj_popupShadow){
        shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:popupView.bounds].CGPath;
        shadowView.layer.masksToBounds = NO;
        shadowView.layer.shadowOffset = self.mj_popupTheme.mj_popupShadow.shadowOffset;
        shadowView.layer.shadowRadius = self.mj_popupTheme.mj_popupShadow.shadowBlurRadius;
        shadowView.layer.shadowColor = [self.mj_popupTheme.mj_popupShadow.shadowColor CGColor];
        shadowView.layer.shadowOpacity = 1.0;
        shadowView.layer.shouldRasterize = YES;
        shadowView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    }
    
    // Add semi overlay
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.tag = kMJOverlayViewTag;
    overlayView.backgroundColor = [UIColor clearColor];
    
    // Make the Background Clickable
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.accessibilityHint = NSLocalizedString(@"Double-tap to dismiss popup window.", @"all");
    dismissButton.accessibilityLabel = NSLocalizedString(@"Dismiss popup", @"all");
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.bounds;
    [overlayView addSubview:dismissButton];
    
    popupView.alpha = 0.0f;
    shadowView.alpha = 0.0f;
    
    [overlayView addSubview:shadowView];
    [overlayView addSubview:popupView];
    [sourceView addSubview:overlayView];
    
    [dismissButton addTarget:self action:@selector(mj_dismissPopupViewControllerWithAnimation:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *bgView = [[UIView alloc] initWithFrame:sourceView.bounds];
    bgView.alpha = 0.0;
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bgView.backgroundColor = self.mj_popupTheme.mj_popupBackgroundColor;
    [sourceView insertSubview:bgView belowSubview:overlayView];
    
    self.mj_popupBackgroundView = bgView;
    
    switch (animationType) {
        case MJPopupViewAnimationSlideBottomTop:
        case MJPopupViewAnimationSlideBottomBottom:
        case MJPopupViewAnimationSlideTopTop:
        case MJPopupViewAnimationSlideTopBottom:
        case MJPopupViewAnimationSlideLeftLeft:
        case MJPopupViewAnimationSlideLeftRight:
        case MJPopupViewAnimationSlideRightLeft:
        case MJPopupViewAnimationSlideRightRight:
            dismissButton.tag = animationType;
            [self mj_slideViewIn:popupView
                      sourceView:sourceView
                     overlayView:overlayView
               withAnimationType:animationType
                      completion:presentCompletion];
            break;
            
        case MJPopupViewAnimationFade:
            dismissButton.tag = MJPopupViewAnimationFade;
            [self mj_fadeViewIn:popupView
                     sourceView:sourceView
                    overlayView:overlayView
                       animated:YES
                     completion:presentCompletion];
            break;
            
        default:
            dismissButton.tag = MJPopupViewAnimationNone;
            [self mj_fadeViewIn:popupView
                     sourceView:sourceView
                    overlayView:overlayView
                       animated:NO
                     completion:presentCompletion];
            break;
            
    }
    
    self.mj_popupDismissedCallback = dismissCompletion;
}

- (UIView *_Nullable)mj_topView {
    UIViewController *recentView = self;
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}

- (void)mj_dismissPopupViewControllerWithAnimation:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* dismissButton = sender;
        switch (dismissButton.tag) {
            case MJPopupViewAnimationSlideBottomTop:
            case MJPopupViewAnimationSlideBottomBottom:
            case MJPopupViewAnimationSlideTopTop:
            case MJPopupViewAnimationSlideTopBottom:
            case MJPopupViewAnimationSlideLeftLeft:
            case MJPopupViewAnimationSlideLeftRight:
            case MJPopupViewAnimationSlideRightLeft:
            case MJPopupViewAnimationSlideRightRight:
                [self mj_dismissPopupViewControllerWithAnimationType:(MJPopupViewAnimation)dismissButton.tag completion:nil];
                break;
            default:
                [self mj_dismissPopupViewControllerWithAnimationType:MJPopupViewAnimationFade completion:nil];
                break;
        }
    } else {
        [self mj_dismissPopupViewControllerWithAnimationType:MJPopupViewAnimationFade completion:nil];
    }
}

//////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animations

#pragma mark --- Slide

- (void)mj_slideViewIn:(UIView*)popupView
            sourceView:(UIView*)sourceView
           overlayView:(UIView*)overlayView
     withAnimationType:(MJPopupViewAnimation)animationType
            completion:(nullable dispatch_block_t)animationCompletion
{
    
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupStartRect;
    switch (animationType) {
        case MJPopupViewAnimationSlideBottomTop:
        case MJPopupViewAnimationSlideBottomBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                        sourceSize.height,
                                        popupSize.width,
                                        popupSize.height);
            
            break;
        case MJPopupViewAnimationSlideLeftLeft:
        case MJPopupViewAnimationSlideLeftRight:
            popupStartRect = CGRectMake(-sourceSize.width,
                                        (sourceSize.height - popupSize.height) / 2,
                                        popupSize.width,
                                        popupSize.height);
            break;
            
        case MJPopupViewAnimationSlideTopTop:
        case MJPopupViewAnimationSlideTopBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                        -popupSize.height,
                                        popupSize.width,
                                        popupSize.height);
            break;
            
        default:
            popupStartRect = CGRectMake(sourceSize.width,
                                        (sourceSize.height - popupSize.height) / 2,
                                        popupSize.width,
                                        popupSize.height);
            break;
    }
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width,
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupStartRect;
    popupView.alpha = 1.0f;
    UIView *shadowView = [overlayView viewWithTag:kMJShadowViewTag];
    shadowView.frame = popupView.frame;
    shadowView.alpha = popupView.alpha;
    [UIView animateWithDuration:self.mjPopUpViewAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        [self.mj_popupViewController viewWillAppear:NO];
        self.mj_popupBackgroundView.alpha = 1.0f;
        popupView.frame = popupEndRect;
        shadowView.frame = popupView.frame;
    } completion:^(BOOL finished) {
        [self.mj_popupViewController viewDidAppear:NO];
        if (animationCompletion) {
            animationCompletion();
        }
    }];
}

- (NSTimeInterval)mjPopUpViewAnimationDuration{
    if (self.mj_popupTheme.mj_popupModalAnimationDuration > 0) {
        return self.mj_popupTheme.mj_popupModalAnimationDuration;
    }
    return kPopupModalAnimationDuration;
}

- (void)mj_slideViewOut:(UIView*)popupView
             sourceView:(UIView*)sourceView
            overlayView:(UIView*)overlayView
      withAnimationType:(MJPopupViewAnimation)animationType
             completion:(nullable dispatch_block_t)animationCompletion
{
    
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect;
    switch (animationType) {
        case MJPopupViewAnimationSlideBottomTop:
        case MJPopupViewAnimationSlideTopTop:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                      -popupSize.height,
                                      popupSize.width,
                                      popupSize.height);
            break;
        case MJPopupViewAnimationSlideBottomBottom:
        case MJPopupViewAnimationSlideTopBottom:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                      sourceSize.height,
                                      popupSize.width,
                                      popupSize.height);
            break;
        case MJPopupViewAnimationSlideLeftRight:
        case MJPopupViewAnimationSlideRightRight:
            popupEndRect = CGRectMake(sourceSize.width,
                                      popupView.frame.origin.y,
                                      popupSize.width,
                                      popupSize.height);
            break;
        default:
            popupEndRect = CGRectMake(-popupSize.width,
                                      popupView.frame.origin.y,
                                      popupSize.width,
                                      popupSize.height);
            break;
    }
    
    UIView *shadowView = [overlayView viewWithTag:kMJShadowViewTag];
    
    [UIView animateWithDuration:self.mjPopUpViewAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        
        [self.mj_popupViewController viewWillDisappear:NO];
        popupView.frame = popupEndRect;
        shadowView.frame = popupView.frame;
        self.mj_popupBackgroundView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [shadowView removeFromSuperview];
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        
        [self.mj_popupViewController viewDidDisappear:NO];
        self.mj_popupViewController = nil;
        [self.mj_popupBackgroundView removeFromSuperview];
        self.mj_popupBackgroundView = nil;
        
        if (animationCompletion) {
            animationCompletion();
        }
        
        id dismissed = [self mj_popupDismissedCallback];
        if (dismissed != nil){
            ((void(^)(void))dismissed)();
            self.mj_popupDismissedCallback = nil;
        }
    }];
}

#pragma mark --- Fade

- (void)mj_fadeViewIn:(UIView*)popupView
           sourceView:(UIView*)sourceView
          overlayView:(UIView*)overlayView
             animated:(BOOL)animated
           completion:(nullable dispatch_block_t)animationCompletion
{
    
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width,
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupEndRect;
    popupView.alpha = 0.0f;
    
    UIView *shadowView = [overlayView viewWithTag:kMJShadowViewTag];
    shadowView.frame = popupView.frame;
    shadowView.alpha = popupView.alpha;
    
    void(^animations)(void) = ^{
        [self.mj_popupViewController viewWillAppear:NO];
        self.mj_popupBackgroundView.alpha = 1.0f;
        popupView.alpha = 1.0f;
        shadowView.alpha = popupView.alpha;
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
        [self.mj_popupViewController viewDidAppear:NO];
        
        if (animationCompletion) {
            animationCompletion();
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:self.mjPopUpViewAnimationDuration
                         animations:animations
                         completion:completion];
    }
    else {
        animations();
        completion(YES);
    }
}

- (void)mj_fadeViewOut:(UIView*)popupView
            sourceView:(UIView*)sourceView
           overlayView:(UIView*)overlayView
              animated:(BOOL)animated
            completion:(nullable dispatch_block_t)animationCompletion
{
    
    UIView *shadowView = [overlayView viewWithTag:kMJShadowViewTag];
    
    void(^animations)(void) = ^{
        [self.mj_popupViewController viewWillDisappear:NO];
        self.mj_popupBackgroundView.alpha = 0.0f;
        popupView.alpha = 0.0f;
        shadowView.alpha = popupView.alpha;
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
        [shadowView removeFromSuperview];
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        
        [self.mj_popupViewController viewDidDisappear:NO];
        self.mj_popupViewController = nil;
        
        [self.mj_popupBackgroundView removeFromSuperview];
        self.mj_popupBackgroundView = nil;
        
        if (animationCompletion) {
            animationCompletion();
        }
        
        id dismissed = [self mj_popupDismissedCallback];
        if (dismissed != nil){
            ((void(^)(void))dismissed)();
            self.mj_popupDismissedCallback = nil;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:self.mjPopUpViewAnimationDuration
                         animations:animations
                         completion:completion];
    }
    else {
        animations();
        completion(YES);
    }
    
}

#pragma mark -
#pragma mark Category Accessors

#pragma mark --- Dismissed

- (void)setMj_popupDismissedCallback:(nullable dispatch_block_t)dismissed{
    objc_setAssociatedObject(self, MJPopupViewDismissedCallback, dismissed, OBJC_ASSOCIATION_COPY);
}

- (nullable dispatch_block_t)mj_popupDismissedCallback{
    return objc_getAssociatedObject(self, MJPopupViewDismissedCallback);
}

- (UIViewController *_Nullable)mj_popupViewController {
    return objc_getAssociatedObject(self, kMJPopupViewController);
}

- (void)setMj_popupViewController:(UIViewController *_Nullable)mj_popupViewController {
    objc_setAssociatedObject(self, kMJPopupViewController, mj_popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *_Nullable)mj_popupBackgroundView {
    return objc_getAssociatedObject(self, kMJPopupBackgroundView);
}

- (void)setMj_popupBackgroundView:(UIView *_Nullable)mj_popupBackgroundView {
    objc_setAssociatedObject(self, kMJPopupBackgroundView, mj_popupBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MJPopupViewTheme *_Nullable)mj_popupTheme{
    return objc_getAssociatedObject(self, kMJPopupTheme);
}

- (void)setMj_popupTheme:(MJPopupViewTheme *_Nullable)mj_popupTheme{
    objc_setAssociatedObject(self, kMJPopupTheme, mj_popupTheme, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

NS_ASSUME_NONNULL_END
