//
//  UIViewController+Container.h
//

#import <UIKit/UIKit.h>

@interface UIViewController (Container)

/** Swap sub controllers making sure that both controllers views conform to the size of the parent **/
- (void)containerTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(5_0);

@end