//
//  NSImage+TintedImage.m
//  Fresh
//
//  Created by Brandon on 2014-03-12.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSImage+TintedImage.h"

@implementation NSImage (TintedImage)

- (NSImage *)imageTintedWithColor:(NSColor *)tint {
    NSImage *image = [self copy];
    if (tint) {
        [image lockFocus];
        [tint set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        [image unlockFocus];
    }
    return image;
}

@end
