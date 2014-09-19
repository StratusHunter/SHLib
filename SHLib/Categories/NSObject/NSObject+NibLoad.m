//
//  NSObject+NibLoad.m
//

#import <UIKit/UIKit.h>
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
