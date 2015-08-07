//
//  FSHWaveformSliderView.m
//  Fresh
//
//  Created by Brandon on 2014-03-31.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHWaveformSliderView.h"
#import <QuartzCore/CoreImage.h>
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

- (void)setWaveform:(FSHWaveform *)waveform {
    _waveform = waveform;
    if (!waveform) return;

    NSBitmapImageRep *offscreenRep = [[NSBitmapImageRep alloc]
                                      initWithBitmapDataPlanes:NULL
                                      pixelsWide:self.bounds.size.width
                                      pixelsHigh:self.bounds.size.height
                                      bitsPerSample:8
                                      samplesPerPixel:4
                                      hasAlpha:YES
                                      isPlanar:NO
                                      colorSpaceName:NSDeviceRGBColorSpace
                                      bitmapFormat:NSAlphaFirstBitmapFormat
                                      bytesPerRow:0
                                      bitsPerPixel:0];
    
    // set offscreen context
    NSGraphicsContext *g = [NSGraphicsContext graphicsContextWithBitmapImageRep:offscreenRep];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:g];

    CGContextRef ctx = [g graphicsPort];
    CGContextSetFillColorWithColor(ctx, [NSColor blackColor].CGColor);
    CGFloat width = self.bounds.size.width / waveform.values.count;
    CGFloat maxValue = (CGFloat)waveform.maxValue;
    [waveform.values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        CGRect rect = CGRectIntegral(CGRectMake(idx * width, 0, width, value.floatValue / maxValue * self.bounds.size.height));
        CGContextFillRect(ctx, rect);
    }];

    [NSGraphicsContext restoreGraphicsState];

    NSImage *img = [[NSImage alloc] initWithSize:self.bounds.size];
    [img addRepresentation:offscreenRep];

    _maskImage = img;
}

- (void)setDoubleValue:(double)doubleValue {
    doubleValue = fmax(doubleValue, 0.0);
    doubleValue = fmin(doubleValue, self.maxValue);

    [super setDoubleValue:doubleValue];
    FSHWaveformSliderCell *cell = (FSHWaveformSliderCell *)self.cell;
    cell.objectValue = @(doubleValue);

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
        [NSApp sendAction:[self action] to:[self target] from:self];
        [self trackMouseWithStartPoint:mousePoint];
    }
}

- (double)valueForPoint:(NSPoint)point {
    return point.x / CGRectGetWidth(self.bounds) * self.maxValue;
}

- (void)trackMouseWithStartPoint:(NSPoint)point {
    // Compute the value offset: this makes the pointer stay on the
    // same piece of the knob when dragging
    double valueOffset = [self valueForPoint:point] - ((NSNumber *)self.objectValue).doubleValue;

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
