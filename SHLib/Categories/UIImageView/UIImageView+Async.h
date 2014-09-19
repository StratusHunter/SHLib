//
//  UIImageView+Async.h
//


#import <UIKit/UIKit.h>

typedef void(^ImageLoadComplete)(UIImage *image);

@interface UIImageView (Async)

-(void)loadAsyncImage:(NSString *)imagePath withCache:(BOOL)cache;
-(void)loadAsyncVideoThumbnail:(NSString *)videoPath withCache:(BOOL)cache;

@end
