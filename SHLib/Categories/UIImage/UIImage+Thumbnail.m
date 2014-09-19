//
//  UIImage+Thumbnail.m
//  bulbraries
//
//  Created by Terence Baker on 14/11/2013.
//  Copyright (c) 2013 Bulb Studios. All rights reserved.
//

#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)

-(UIImage *)createThumbnailAtSize:(CGSize)newSize {
    
    CGSize scaledSize = [self getScaledSize:newSize];

    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, [UIScreen mainScreen].scale);
    
    [self drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(CGSize)getScaledSize:(CGSize)desiredSize {
    
    CGSize scaledSize = desiredSize;
    float scaleFactor = 1.0;
    
    if (self.size.width > self.size.height) {
        
        scaleFactor = self.size.width / self.size.height;
        scaledSize.width = desiredSize.width;
        scaledSize.height = desiredSize.height / scaleFactor;
    }
    else {
        
        scaleFactor = self.size.height / self.size.width;
        scaledSize.height = desiredSize.height;
        scaledSize.width = desiredSize.width / scaleFactor;
    }
    
    return scaledSize;
}

@end
