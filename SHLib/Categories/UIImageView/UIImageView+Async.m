//
//  UIImageView+Async.m
//


#import "UIImageView+Async.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImageView (Async)

static NSCache *_imageCache;

+ (NSCache *)getImageCache {

    if (_imageCache != nil) {

        _imageCache = [[NSCache alloc] init];
    }

    return _imageCache;
}

- (void)loadAsyncImage:(NSString *)imagePath withCache:(BOOL)cache {

    __weak typeof(self) weakSelf = self;

    [self loadImage:imagePath withFinishBlock:^(UIImage *image) {

        [weakSelf setAsyncImage:image];
    }     withCache:cache];
}

- (void)loadImage:(NSString *)imagePath withFinishBlock:(ImageLoadComplete)finishBlock withCache:(BOOL)cache {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @autoreleasepool {

            UIImage *image = nil;

            if (cache) {

                image = [[UIImageView getImageCache] objectForKey:imagePath];
            }

            if (image == nil) {

                image = [UIImage imageWithContentsOfFile:imagePath];

                if (cache) {

                    [[UIImageView getImageCache] setObject:image forKey:imagePath];
                }
            }

            finishBlock(image);
        }
    });
}

- (void)loadAsyncVideoThumbnail:(NSString *)videoPath withCache:(BOOL)cache {

    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @autoreleasepool {

            UIImage *image = nil;

            if (cache) {

                image = [[UIImageView getImageCache] objectForKey:videoPath];
            }

            if (image == nil) {

                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
                AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                generator.appliesPreferredTrackTransform = YES;
                generator.maximumSize = CGSizeMake(weakSelf.frame.size.width, weakSelf.frame.size.height);

                CMTime thumbTime = CMTimeMakeWithSeconds(0, 1);
                [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:thumbTime]]
                                                completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {

                                                    NSLog(@"%@", generator); //Keeps the generator from being dealloc

                                                    UIImage *thumbnail = [UIImage imageWithCGImage:im];

                                                    if (cache) {

                                                        [[UIImageView getImageCache] setObject:thumbnail forKey:videoPath];
                                                    }

                                                    [weakSelf setAsyncImage:thumbnail];
                                                }];
            }
            else {

                [weakSelf setAsyncImage:image];
            }
        }
    });
}

- (void)setAsyncImage:(UIImage *)thumbnail {

    __weak typeof(self) weakSelf = self;

    dispatch_sync(dispatch_get_main_queue(), ^{

        if (weakSelf != nil) {

            [weakSelf setImage:thumbnail];
        }
    });
}

@end
