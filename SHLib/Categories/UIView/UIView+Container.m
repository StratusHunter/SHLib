//
// Created by Terence Baker on 06/02/2014.
// Copyright (c) 2014 Terence Baker. All rights reserved.
//

#import "UIView+Container.h"

@implementation UIView (Container)

- (void)addSubviewToContainer:(UIView *)subview {

    [self addSubview:subview];
    [self transitionedViewControllerInContainer:subview];
}

- (void)transitionedViewControllerInContainer:(UIView *)subview {

    [self removeOldContainerConstraints:subview];

    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];

    if (subview.superview != nil) {
        
        NSDictionary *views = NSDictionaryOfVariableBindings(subview);

        NSArray *newWidthConst = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views];

        NSArray *newHeightConst = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views];

        [self addConstraints:newWidthConst];
        [self addConstraints:newHeightConst];
    }
}

- (void)removeOldContainerConstraints:(UIView *)subview {

    NSMutableArray *oldConsts = [NSMutableArray new];

    for (NSLayoutConstraint *constraint in self.constraints) {

        if (constraint.firstItem == subview || constraint.secondItem == subview) {

            [oldConsts addObject:constraint];
        }
    }

    [subview removeConstraints:oldConsts];
}

@end