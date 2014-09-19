//
//  UIScrollView+VisibleRect.h
//  ImageViewer
//
//  Created by Dave Leverton on 02/05/2013.
//  Copyright (c) 2013 BulbMBP5. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DoubleRect;

@interface UIScrollView (VisibleRect)

- (DoubleRect *)visibleRect;
- (DoubleRect *)normalizedRect;
- (DoubleRect *)normalizedToVisible:(DoubleRect *)normalizedRect;

@end
