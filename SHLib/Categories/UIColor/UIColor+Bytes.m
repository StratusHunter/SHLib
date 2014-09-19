//
//  UIColor+Bytes.m
//  bulbraries
//
//  Created by Terence Baker on 29/10/2013.
//  Copyright (c) 2013 Bulb Studios. All rights reserved.
//

#import "UIColor+Bytes.h"

@implementation UIColor (Bytes)

+ (UIColor*) colorWithBytesRed:(int)red green:(int)green blue:(int)blue alpha:(int)alpha {
    
    float fRed = (float)red/255.f;
    float fGreen = (float)green/255.f;
    float fBlue = (float)blue/255.f;
    float fAlpha = (float)alpha/255.f;
    
    return [UIColor colorWithRed:fRed green:fGreen blue:fBlue alpha:fAlpha];
}

@end
