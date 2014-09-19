//
//  UIView+Container.h
//

#import <UIKit/UIKit.h>

@interface UIView (Container)

- (void)addSubviewToContainer:(UIView *)subView;
- (void)transitionedViewControllerInContainer:(UIView *)subview;

@end