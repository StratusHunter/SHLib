//
//  NSString+Contains.m
//  Airshare
//
//  Created by Terence Baker on 28/10/2013.
//  Copyright (c) 2013 Bulb Studios. All rights reserved.
//

#import "NSString+Contains.h"

@implementation NSString (Contains)

-(BOOL)hasString:(NSString *)substring {
    
    return [self rangeOfString:substring].location != NSNotFound;
}

@end
