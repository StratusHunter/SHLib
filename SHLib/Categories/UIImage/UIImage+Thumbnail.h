//
//  UIImage+Thumbnail.h
//


#import <UIKit/UIKit.h>

@interface UIImage (Thumbnail)

- (UIImage *)createThumbnailAtSize:(CGSize)size;
- (CGSize)getScaledSize:(CGSize)desiredSize;

@end
