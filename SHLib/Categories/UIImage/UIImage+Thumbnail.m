//
//  UIImage+Thumbnail.m
//


#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)

- (UIImage *)createThumbnailAtSize:(CGSize)newSize {

    CGSize scaledSize = [self getScaledSize:newSize];

    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, [UIScreen mainScreen].scale);

    [self drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return newImage;
}

- (CGSize)getScaledSize:(CGSize)desiredSize {

    CGSize scaledSize = desiredSize;

    if (self.size.width > self.size.height) {

        float scaleFactor = self.size.width / self.size.height;
        scaledSize.width = desiredSize.width;
        scaledSize.height = desiredSize.height / scaleFactor;
    }
    else {

        float scaleFactor = self.size.height / self.size.width;
        scaledSize.height = desiredSize.height;
        scaledSize.width = desiredSize.width / scaleFactor;
    }

    return scaledSize;
}

@end
