//
//  UIView+Frame.m
//  GE Marine
//
//  Created on 25/02/2013.
//  Copyright (c) 2013 GE Marine. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

-(void)setWidth:(CGFloat)width {
    [self setFrame:BSRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height)];
}

-(void)setHeight:(CGFloat)height {
    [self setFrame:BSRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height)];
}

-(void)setX:(CGFloat)x {
    [self setFrame:BSRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
}

-(void)setY:(CGFloat)y {
    [self setFrame:BSRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height)];
}

-(void)setCenterX:(CGFloat)x {
    [self setFrame:BSRectMake(x - ([self getWidth] / 2), [self getY], [self getWidth], [self getHeight])];
}

-(void)setCenterY:(CGFloat)y {
    [self setFrame:BSRectMake([self getX], y - ([self getHeight] / 2), [self getWidth], [self getHeight])];
}

-(CGFloat)getX {
    return self.frame.origin.x;
}

-(CGFloat)getY {
    return self.frame.origin.y;
}

-(CGFloat)getWidth {
    return self.frame.size.width;
}

-(CGFloat)getHeight {
    return self.frame.size.height;
}

-(CGFloat)getEndX {
    return self.frame.size.width + self.frame.origin.x;
}

-(CGFloat)getEndY {
    return self.frame.size.height + self.frame.origin.y;
}

-(CGFloat)getHalfWidth {
    return self.bounds.size.width / 2;
}

-(CGFloat)getHalfHeight {
    return self.bounds.size.height / 2;
}

-(CGFloat)getCenterX {
    return self.center.x;
}

-(CGFloat)getCenterY {
    return self.center.y;
}

@end
