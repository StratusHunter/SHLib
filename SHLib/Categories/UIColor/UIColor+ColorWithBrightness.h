//
//  UIColor+ColorWithBrightness.h
//  SwipeStats
//
//  Created by BulbMBP5 on 30/01/2013.
//  Copyright (c) 2013 Terence Baker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorWithBrightness)

+ (UIColor*) colorWithColor:(UIColor*)color andBrightness:(float)brightness;

@end
