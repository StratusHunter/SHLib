//
// Created by Terence Baker on 06/02/2014.
// Copyright (c) 2014 Terence Baker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Container)

- (void)addSubviewToContainer:(UIView *)subView;
- (void)transitionedViewControllerInContainer:(UIView *)subview;
- (void)removeOldContainerConstraints:(UIView *)subview;

@end