//
//  NSView+RACProperties.m
//  Fresh
//
//  Created by Brandon on 2014-03-10.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "NSView+RACProperties.h"

@implementation NSView (RACProperties)

- (BOOL)hidden {
    return [self isHidden];
}

- (void)setIsHidden:(BOOL)hidden {
    [self setHidden:hidden];
}

@end
