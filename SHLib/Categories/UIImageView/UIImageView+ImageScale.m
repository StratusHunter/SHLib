//
//  UIImageView+ImageScale.m
//  AudiTraining
//
//  Created by BulbMBP5 on 03/09/2012.
//  Copyright (c) 2012 BulbMBP5. All rights reserved.
//

#import "UIImageView+ImageScale.h"

@implementation UIImageView (ImageScale)

- (CGSize)imageScale {
    
    CGFloat sx = self.frame.size.width;
    CGFloat sy = self.frame.size.height;
    
    if (self.image != nil) {
        
        sx /= self.image.size.width;
        sy /= self.image.size.height;
    }
    
    CGFloat s = 1.0;
    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFit:
            s = fminf(sx, sy);
            return CGSizeMake(s, s);

        case UIViewContentModeScaleAspectFill:
            s = fmaxf(sx, sy);
            return CGSizeMake(s, s);

        case UIViewContentModeScaleToFill:
            return CGSizeMake(sx, sy);
            
        default:
            return CGSizeMake(s, s);
    }
}

- (CGRect) imageFrame{
    
    // Size of image within the view;
    CGSize size = [self imageScale];
    
    if (self.image != nil) {
    
        size.width *= self.image.size.width;
        size.height *= self.image.size.height;
    }
    
    // Size of imageView
    CGSize imageViewSize = self.frame.size;
    
    // Difference in width and height
    int widthDif = imageViewSize.width - size.width;
    int heightDif = imageViewSize.height - size.height;
    
    // Image is Centered within view, get origin
    CGPoint origin = CGPointMake(widthDif / 2, heightDif / 2);

    return CGRectMake(origin.x, origin.y, size.width, size.height);
    
}

@end
