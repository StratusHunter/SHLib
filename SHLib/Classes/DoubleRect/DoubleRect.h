//
// Created by Terence Baker on 04/02/2014.
// Copyright (c) 2014 Bulb Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoubleRect : NSObject

@property(nonatomic, assign) double x;
@property(nonatomic, assign) double y;
@property(nonatomic, assign) double width;
@property(nonatomic, assign) double height;

-(id)initWithCGRect:(CGRect)rect;
-(id)initWithDict:(NSDictionary *)dict;

-(NSDictionary *)toDict;
-(CGRect)toCGRect;
@end