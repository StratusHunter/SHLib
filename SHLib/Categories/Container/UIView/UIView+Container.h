//
//  UIView+Container.h
//

#import <UIKit/UIKit.h>

@interface UIView (Container)

/** Add a subview to a container making sure the subview will resize to the size of it's container **/
- (void)addSubviewToContainer:(UIView *)subView;

/** Make a subview resize to the size of the container **/
- (void)constrainSubview:(UIView *)subview;

@end