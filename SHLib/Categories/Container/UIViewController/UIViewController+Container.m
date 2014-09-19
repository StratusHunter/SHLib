//
//  UIViewController+Container.h
//

#import "UIViewController+Container.h"
#import "UIView+Container.h"

@implementation UIViewController (Container)

- (void)containerTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(5_0) {

    [toViewController willMoveToParentViewController:self];
    [toViewController.view setFrame:fromViewController.view.bounds];

    __weak typeof(self) weakSelf = self;

    [self transitionFromViewController:fromViewController toViewController:toViewController duration:duration options:options animations:animations completion:^(BOOL finished) {

        [weakSelf.view transitionedViewControllerInContainer:toViewController.view];

        completion(finished);
    }];
}

@end