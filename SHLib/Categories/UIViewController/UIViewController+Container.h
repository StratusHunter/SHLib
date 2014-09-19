//
//  UIViewController+Container.h
//

#import <UIKit/UIKit.h>

@interface UIViewController (Container)

- (void)containerTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(5_0);

@end