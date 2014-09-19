//
//  UIImageView+Async.h
//  bulbraries
//
//  Created by Terence Baker on 28/10/2013.
//  Copyright (c) 2013 Bulb Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImageLoadComplete)(UIImage *image);

@interface UIImageView (Async)

-(void)loadAsyncImage:(NSString *)imagePath withCache:(BOOL)cache;
-(void)loadAsyncVideoThumbnail:(NSString *)videoPath withCache:(BOOL)cache;

@end
