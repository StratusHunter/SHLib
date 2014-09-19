//
//  UIImage+ChangeColor.m
//  SwipeStats
//
//  Created by BulbMBP5 on 30/01/2013.
//  Copyright (c) 2013 Terence Baker. All rights reserved.
//

#import "UIImage+ChangeColor.h"

@implementation UIImage (ChangeColor)

- (UIImage*) changeImageColour:(UIColor*)color withRetina:(BOOL)withRetina{
    
    // begin a new image context, to draw our colored image onto
    if (withRetina) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    }
    else {
        UIGraphicsBeginImageContext(self.size);
    }
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();

    // set the fill color
    
    if (CGColorGetNumberOfComponents(color.CGColor) < 4 && color != nil) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
    }
        
    [color setFill];

    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextDrawImage(context, rect, self.CGImage);

    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);

    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
        
    return coloredImg;
}

- (UIImage *) grayScaleImage:(UIColor *)color {
    CGFloat white, alpha;
    [color getWhite:&white alpha:&alpha];
    return [self changeImageColour:[UIColor colorWithWhite:white alpha:alpha] withRetina:NO];
}

@end
