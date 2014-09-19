//
//  UIColor+Grayscale.m
//

#import "UIColor+Grayscale.h"

@implementation UIColor (Grayscale)

-(UIColor *)grayScaleColor {

    CGFloat hue, saturation, brightness, alpha;
    
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {

        if (brightness > 0.85f && brightness != 1.0f) { //stop it being too bright
            
            brightness = 0.85f;
        }
        
        return [UIColor colorWithHue:hue saturation:0.0f brightness:brightness alpha:alpha];
    }
    
    return self;
}
@end
