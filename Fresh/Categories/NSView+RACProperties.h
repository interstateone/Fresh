//
//  NSView+RACProperties.h
//  Fresh
//
//  Created by Brandon on 2014-03-10.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (RACProperties)

@property (assign, nonatomic, getter = hidden, setter = setIsHidden:) BOOL hidden;

@end
