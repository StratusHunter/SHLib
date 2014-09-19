//
//  NSObject+NibLoad.h
//

#import <Foundation/Foundation.h>

@interface NSObject (NibLoad)

+ (id)loadFromNib:(NSString *)nibName;

//If the nib name you are loading has the same name as the class then just call this function
+ (id)loadFromDefaultNib;

@end
