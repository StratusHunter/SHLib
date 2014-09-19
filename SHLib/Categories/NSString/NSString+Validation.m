//
//  NSString+Validation.m
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

-(BOOL)isEmail {
    
    //NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    return [self validateWithRegex:laxString];
}

-(BOOL)isPhone {
    
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    return [self validateWithRegex:phoneRegex];
}

- (BOOL)isNumeric {
    
    NSString *numericRegex = @"[0-9]*";
    return [self validateWithRegex:numericRegex];    
}

- (BOOL)validateWithRegex:(NSString *)regex {
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailTest evaluateWithObject:self];
}

@end
