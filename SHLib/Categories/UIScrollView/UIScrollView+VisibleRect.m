//
//  UIScrollView+VisibleRect.m
//  ImageViewer
//
//  Created by Dave Leverton on 02/05/2013.
//  Copyright (c) 2013 BulbMBP5. All rights reserved.
//

#import "UIScrollView+VisibleRect.h"
#import "DoubleRect.h"

@implementation UIScrollView (VisibleRect)

- (DoubleRect *)visibleRect {

    DoubleRect *visibleRect = [DoubleRect new];
    visibleRect.x = self.contentOffset.x;
    visibleRect.y = self.contentOffset.y;

    visibleRect.width = self.bounds.size.width;
    visibleRect.height = self.bounds.size.height;

    double theScale = 1.0 / self.zoomScale;

    visibleRect.x *= theScale;
    visibleRect.y *= theScale;
    visibleRect.width *= theScale;
    visibleRect.height *= theScale;

    return visibleRect;
}

- (DoubleRect *)normalizedRect {

    DoubleRect *rect = [self visibleRect];
    rect.x /= self.bounds.size.width;
    rect.y /= self.bounds.size.height;
    rect.width /= self.bounds.size.width;
    rect.height /= self.bounds.size.height;

    return rect;
}

- (DoubleRect *)normalizedToVisible:(DoubleRect *)normalizedRect {

    DoubleRect *visibleRect = normalizedRect;
    visibleRect.x *= self.bounds.size.width;
    visibleRect.y *= self.bounds.size.height;
    visibleRect.width *= self.bounds.size.width;
    visibleRect.height *= self.bounds.size.height;

    return visibleRect;
}

@end
