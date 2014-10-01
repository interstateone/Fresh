//
//  FSHWaveformSliderView.m
//  Fresh
//
//  Created by Brandon on 2014-03-31.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHWaveformSliderView.h"

#import <QuartzCore/CoreImage.h>
#import <GPUImage/GPUImageLuminanceThresholdFilter.h>
#import <GPUImage/GPUImageColorInvertFilter.h>
#import <GPUImage/GPUImageCropFilter.h>
#import <GPUImage/GPUImagePicture.h>

#import "FSHWaveformSliderCell.h"

@implementation FSHWaveformSliderView

#pragma mark - NSControl

+ (Class)cellClass {
    return [FSHWaveformSliderCell class];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.cell drawWithFrame:self.bounds inView:self];
}

#pragma mark - Properties

- (void)setWaveformImage:(NSImage *)waveformImage {
    _waveformImage = waveformImage;

    if (!waveformImage) return;

    // Fill background with black
    NSImage *image = [self.waveformImage copy];
    [image lockFocus];
    [[NSColor blackColor] set];
    NSRectFill(NSMakeRect(0, 0, self.waveformImage.size.width, self.waveformImage.size.height));
    [self.waveformImage drawAtPoint:CGPointZero fromRect:CGRectMake(0, 0, self.waveformImage.size.width, self.waveformImage.size.height) operation:NSCompositeSourceOver fraction:1.0];
    [image unlockFocus];

    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];

    // Crop it to half height
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0f, 0.0f, 1.0f, 0.5f)];
    [picture addTarget:cropFilter];

    // Invert
    GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc] init];
    [cropFilter addTarget:invertFilter];

    // Convert to B&W
    GPUImageLuminanceThresholdFilter *thresholdFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
    thresholdFilter.threshold = 0.1;
    [invertFilter addTarget:thresholdFilter];

    [thresholdFilter useNextFrameForImageCapture];
    [picture processImage];
    image = [thresholdFilter imageFromCurrentFramebuffer];

    // Mask
    CIImage *maskedImage = [CIImage imageWithData:[image TIFFRepresentation]];
    CIFilter *alphaFilter = [CIFilter filterWithName:@"CIMaskToAlpha"];
    [alphaFilter setValue:maskedImage forKey:kCIInputImageKey];
    CIImage *result = [alphaFilter valueForKey:kCIOutputImageKey];

    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:result];
    image = [[NSImage alloc] initWithSize:image.size];
    [image addRepresentation:rep];

    _maskImage = image;
}

- (void)setDoubleValue:(double)doubleValue {
    doubleValue = fmax(doubleValue, 0.0);
    doubleValue = fmin(doubleValue, self.maxValue);

    _doubleValue = doubleValue;
    FSHWaveformSliderCell *cell = (FSHWaveformSliderCell *)self.cell;
    cell.doubleValue = doubleValue;

    [self setNeedsDisplay:YES];
}

- (void)setMaxValue:(double)maxValue {
    maxValue = fmax(maxValue, 0.0);
    maxValue = fmin(maxValue, DBL_MAX);

    _maxValue = maxValue;
    FSHWaveformSliderCell *cell = (FSHWaveformSliderCell *)self.cell;
    cell.maxValue = maxValue;

    [self setNeedsDisplay:YES];
}

#pragma mark - Mouse events

- (void)mouseDown:(NSEvent *)event {
    NSPoint mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];

    if ([[(FSHWaveformSliderCell *)self.cell knobPath] containsPoint:mousePoint]) {
        [self trackMouseWithStartPoint:mousePoint];
    }
    else if (CGRectContainsPoint(self.bounds, mousePoint)) {
        self.doubleValue = [self valueForPoint:mousePoint];
        [NSApp sendAction: [self action] to: [self target] from: self];
        [self trackMouseWithStartPoint:mousePoint];
    }
}

- (double)valueForPoint:(NSPoint)point {
    return point.x / CGRectGetWidth(self.bounds) * self.maxValue;
}

- (void)trackMouseWithStartPoint:(NSPoint)point {
    // Compute the value offset: this makes the pointer stay on the
    // same piece of the knob when dragging
    double valueOffset = [self valueForPoint:point] - self.doubleValue;

    NSEvent *event;
    while ([event type] != NSLeftMouseUp) {
        event = [[self window] nextEventMatchingMask: NSLeftMouseDraggedMask | NSLeftMouseUpMask];
        NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
        double value = [self valueForPoint:p];
        [self setDoubleValue:value - valueOffset];
        [NSApp sendAction: [self action] to: [self target] from: self];
    }
}

@end
