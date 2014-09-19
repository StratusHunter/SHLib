//
//  NSString+Validation.h
//  ImageViewer
//
//  Created by Terence Baker on 22/05/2013.
//  Copyright (c) 2013 BulbMBP5. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

-(BOOL)isEmail;
-(BOOL)isPhone;
-(BOOL)isNumeric;

@end
