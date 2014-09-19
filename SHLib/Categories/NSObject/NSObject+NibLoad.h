//
//  NSObject+NibLoad.h
//  CLEngine
//
//  Created by Callum Abele on 19/07/2013.
//  Copyright (c) 2013 CrowdLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NibLoad)

+ (id)loadFromNib:(NSString*)nibName;

//If the nib name you are loading has the same name as the class then just call this function
+ (id)loadFromDefaultNib;

@end
