//
// Created by Terence Baker on 06/02/2014.
// Copyright (c) 2014 Terence Baker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (Container)

- (void)containerTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(5_0);

@end