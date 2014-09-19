//
//  NSObject+NibLoad.m
//  CLEngine
//
//  Created by Callum Abele on 19/07/2013.
//  Copyright (c) 2013 CrowdLab. All rights reserved.
//

#import "NSObject+NibLoad.h"


@implementation NSObject (NibLoad)

+ (id)loadFromNib:(NSString*)nibName {
    
    NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    
    for (id currentObject in topLevelObjects) {
        
        if([[self class] isSubclassOfClass:[currentObject class]]) {
            
            return currentObject;
        }
    }
    return nil;
}

+ (id)loadFromDefaultNib {
    
    return [self loadFromNib:NSStringFromClass([self class])];
}

@end
