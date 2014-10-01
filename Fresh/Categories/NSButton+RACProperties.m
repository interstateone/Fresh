//
//  NSButton+RACProperties.m
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "NSButton+RACProperties.h"

@implementation NSButton (RACProperties)

- (BOOL)enabled {
    return [self isEnabled];
}

- (void)setIsEnabled:(BOOL)enabled {
    [self setEnabled:enabled];
}

@end
