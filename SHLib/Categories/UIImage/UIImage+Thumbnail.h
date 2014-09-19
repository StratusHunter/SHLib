//
//  UIImage+Thumbnail.h
//  bulbraries
//
//  Created by Terence Baker on 14/11/2013.
//  Copyright (c) 2013 Bulb Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Thumbnail)

-(UIImage *)createThumbnailAtSize:(CGSize)size;
-(CGSize)getScaledSize:(CGSize)desiredSize;

@end
