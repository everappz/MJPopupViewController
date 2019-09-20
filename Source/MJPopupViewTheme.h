
#import <UIKit/UIKit.h>

@interface MJPopupViewTheme : NSObject

@property (nonatomic, strong) NSShadow *mj_popupShadow;
@property (nonatomic, strong) UIColor *mj_popupBackgroundColor;
@property (nonatomic, assign) CGFloat mj_popupCornerRadius;
@property (nonatomic, assign) NSTimeInterval mj_popupModalAnimationDuration;

@end
