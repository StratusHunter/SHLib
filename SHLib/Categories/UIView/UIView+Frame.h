//
//  UIView+Frame.h
//  GE Marine
//
//  Created on 25/02/2013.
//  Copyright (c) 2013 GE Marine. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Used as a shortcut for iOS frame/bounds management
 */

/** Method overriding CGRectMake to stop blur due to half pixel calculations */
CG_INLINE CGRect BSRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    
    return CGRectMake((int) x, (int) y, (int) width, (int) height);
}

/** Method overriding CGPointMake to stop blur due to half pixel calculations */
CG_INLINE CGPoint BSPointMake(CGFloat x, CGFloat y) {
    
    return CGPointMake((int) x, (int) y);
}

/** Method overriding CGSizeMake to stop blur due to half pixel calculations */
CG_INLINE CGSize BSSizeMake(CGFloat width, CGFloat height) {
    
    return CGSizeMake((int) width, (int) height);
}

@interface UIView (Frame)

/**
 Sets the width of the view
 @param width Width to set the view
 */
- (void)setWidth:(CGFloat)width;

/**
 Sets the height of the view
 @param height Height to set the view
 */
- (void)setHeight:(CGFloat)height;

/**
 Sets the x origin of the view
 @param x X origin to set the view
 */
- (void)setX:(CGFloat)x;

/**
 Sets the y origin of the view
 @param y Y origin to set the view
 */
- (void)setY:(CGFloat)y;

/**
 Sets the x centre of the view
 @param x X centre to set the view
 */
- (void)setCenterX:(CGFloat)x;

/**
 Sets the y centre of the view
 @param y Y centre to set the view
 */
- (void)setCenterY:(CGFloat)y;

/**
 Gets the x origin of the view
 @return X origin of the view
 */
- (CGFloat)getX;

/**
 Gets the y origin of the view
 @return Y origin of the view
 */
- (CGFloat)getY;

/**
 Gets the width of the view
 @return Width of the view
 */
- (CGFloat)getWidth;

/**
 Gets the height of the view
 @return Height of the view
 */
- (CGFloat)getHeight;

/**
 Gets the x centre of the view
 @return X centre of the view
 */
- (CGFloat)getCenterX;

/**
 Gets the y centre of the view
 @return Y centre of the view
 */
- (CGFloat)getCenterY;

/**
 Gets the x end edge of the view
 @return X end edge of the view
 */
- (CGFloat)getEndX;

/**
 Gets the y end edge of the view
 @return Y end edge of the view
 */
- (CGFloat)getEndY;

/**
 Gets the mid width of the view
 @return Mid width of the view
 */
- (CGFloat)getHalfWidth;

/**
 Gets the mid height of the view
 @return Mid height of the view
 */
- (CGFloat)getHalfHeight;

@end