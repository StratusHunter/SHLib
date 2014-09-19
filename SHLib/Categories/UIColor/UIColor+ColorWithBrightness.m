//
//  UIColor+ColorWithBrightness.m
//  SwipeStats
//
//  Created by BulbMBP5 on 30/01/2013.
//  Copyright (c) 2013 Terence Baker. All rights reserved.
//

#import "UIColor+ColorWithBrightness.h"

@implementation UIColor (ColorWithBrightness)

+ (UIColor*) colorWithColor:(UIColor*)color andBrightness:(float)brightness {
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat alpha;
    
    [color getHue:&hue saturation:&saturation brightness:nil alpha:&alpha];
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

@end
