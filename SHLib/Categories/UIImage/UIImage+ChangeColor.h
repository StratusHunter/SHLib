//
//  UIImage+ChangeColor.h
//  SwipeStats
//
//  Created by BulbMBP5 on 30/01/2013.
//  Copyright (c) 2013 Terence Baker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ChangeColor)

- (UIImage*) changeImageColour:(UIColor*)color withRetina:(BOOL)withRetina;
- (UIImage *) grayScaleImage:(UIColor *)color;
@end
