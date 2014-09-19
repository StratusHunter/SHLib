//
// Created by Terence Baker on 04/02/2014.
// Copyright (c) 2014 Bulb Studios. All rights reserved.
//

#import "DoubleRect.h"

@implementation DoubleRect

#define X @"x"
#define Y @"y"
#define WIDTH @"width"
#define HEIGHT @"height"

- (id)init {

    if (self = [super init]) {

        self.x = 0;
        self.y = 0;
        self.width = 0;
        self.height = 0;
    }

    return self;
}

- (id)initWithCGRect:(CGRect)rect {

    if (self = [self init]) {

        self.x = rect.origin.x;
        self.y = rect.origin.y;
        self.width = rect.size.width;
        self.height = rect.size.height;
    }

    return self;
}

- (id)initWithDict:(NSDictionary *)dict {

    self = [self init];

    if (self != nil && dict != nil) {

        self.x = [dict[X] doubleValue];
        self.y = [dict[Y] doubleValue];
        self.width = [dict[WIDTH] doubleValue];
        self.height = [dict[HEIGHT] doubleValue];
    }

    return self;
}

- (NSDictionary *)toDict {

    return @{X : @(self.x), Y : @(self.y), WIDTH : @(self.width), HEIGHT : @(self.height)};
}

- (CGRect)toCGRect {

    return CGRectMake(self.x, self.y, self.width, self.height);
}

@end