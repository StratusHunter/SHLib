//
//  NSString+Base64.h
//  ImageViewer
//
//  Created by Terence Baker on 16/05/2013.
//  Copyright (c) 2013 BulbMBP5. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

-(NSString *)base64Encode;
-(NSString *)base64Decode;

@end
