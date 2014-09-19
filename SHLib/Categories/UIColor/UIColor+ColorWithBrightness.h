//
//  UIColor+ColorWithBrightness.h
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorWithBrightness)

+ (UIColor*) colorWithColor:(UIColor*)color andBrightness:(float)brightness;

@end
