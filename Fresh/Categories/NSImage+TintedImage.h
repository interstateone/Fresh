//
//  NSImage+TintedImage.h
//  Fresh
//
//  Created by Brandon on 2014-03-12.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (TintedImage)

- (NSImage *)imageTintedWithColor:(NSColor *)tint;

@end
