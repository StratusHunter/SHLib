//
//  NSString+Contains.m
//

#import "NSString+Contains.h"

@implementation NSString (Contains)

- (BOOL)containsString:(NSString *)substring {

    return [self rangeOfString:substring].location != NSNotFound;
}

@end
