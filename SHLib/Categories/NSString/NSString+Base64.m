//
//  NSString+Base64.m
//  ImageViewer
//
//  Created by Terence Baker on 16/05/2013.
//  Copyright (c) 2013 BulbMBP5. All rights reserved.
//

#import "NSString+Base64.h"
#import "NSData+Base64.h"

@implementation NSString (Base64)

-(NSString *)base64Encode {
    
    NSData *plainTextData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainTextData base64EncodedString];
    return base64String;
}

-(NSString *)base64Decode {
    
    NSData *plainTextData = [NSData dataFromBase64String:self];
    NSString *plainText = [[NSString alloc] initWithData:plainTextData encoding:NSUTF8StringEncoding];
    return plainText;
}

@end
