//
//  NSString+Validation.h
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

-(BOOL)isEmail;
-(BOOL)isPhone;
-(BOOL)isNumeric;
-(BOOL)validateWithRegex:(NSString *)regex;

@end
