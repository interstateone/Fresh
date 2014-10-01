//
//  FSHWaveformSliderCell.m
//  Fresh
//
//  Created by Brandon on 2014-03-31.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHWaveformSliderCell.h"

#import "FSHWaveformSliderView.h"

const CGFloat kKnobRadius = 5.0f;

@implementation FSHWaveformSliderCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [super drawWithFrame:cellFrame inView:controlView];

    FSHWaveformSliderView *sliderView = (FSHWaveformSliderView *)controlView;
    if (!sliderView.waveformImage) return;

    [self drawWaveformInRect:sliderView.bounds inView:sliderView enabled:[sliderView.window isKeyWindow]];
    [self drawKnob:sliderView.bounds];
}

#pragma mark - Drawing

- (NSBezierPath *)knobPath {
    CGFloat x = ceilf(self.doubleValue / self.maxValue * CGRectGetWidth(self.controlView.frame)) - kKnobRadius;
    if (self.maxValue == 0.0) {
        x = -kKnobRadius;
    }
    NSBezierPath *knobPath = [[NSBezierPath alloc] init];
    [knobPath moveToPoint:NSMakePoint(x, 0.0f)];
    CGFloat y = sqrtf(powf(kKnobRadius, 2.0f) - powf(kKnobRadius / 2.0f, 2.0f));
    [knobPath lineToPoint:NSMakePoint(x + kKnobRadius, y)];
    [knobPath lineToPoint:NSMakePoint(x + kKnobRadius * 2.0f, 0.0f)];
    [knobPath closePath];
    return knobPath;
}

- (void)drawWaveformInRect:(NSRect)rect inView:(FSHWaveformSliderView *)controlView enabled:(BOOL)enabled {
    CGFloat innerShadowBlurRadius = 1.0;

    NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
    CGContextRef context = [graphicsContext graphicsPort];

    [graphicsContext saveGraphicsState];

    CGRect deviceRect = CGContextConvertRectToDeviceSpace(context, rect);
    CGFloat scale = CGRectGetHeight(deviceRect) / CGRectGetHeight(rect);

    if ([graphicsContext isFlipped]) {
        CGContextTranslateCTM(context, 0.0f, rect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
    }

    //Create mask image:
    NSRect maskRect = rect;
    CGImageRef maskImage = [controlView.maskImage CGImageForProposedRect:&maskRect context:graphicsContext hints:nil];
    CGContextClipToMask(context, NSRectToCGRect(maskRect), maskImage);

    //Draw gradient:
    NSColor *startColor;
    NSColor *endColor;
    startColor = [NSColor colorWithDeviceWhite:0.46 alpha:1.0];
    endColor = [NSColor colorWithDeviceWhite:0.25 alpha:1.0];

    if (!enabled) {
        startColor = [startColor colorWithAlphaComponent:0.5];
        endColor = [endColor colorWithAlphaComponent:0.5];
    }

    // Draw inner gradient
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
    [gradient drawInRect:maskRect angle:90.0];

    // Draw progress gradient
    startColor = [NSColor colorWithCalibratedRed:1.0 green:0.49 blue:0.0 alpha:1.0];
    endColor = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0];

    if (!enabled) {
        startColor = [startColor colorWithAlphaComponent:0.5];
        endColor = [endColor colorWithAlphaComponent:0.5];
    }

    CGRect progressRect = CGRectIntegral(CGRectMake(0, 0, rect.size.width * (self.doubleValue / self.maxValue), rect.size.height));
    NSGradient *progressGradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
    [progressGradient drawInRect:progressRect angle:90.0];

    //Draw inner shadow with inverted mask:
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), innerShadowBlurRadius, [[NSColor colorWithCalibratedWhite:0.1 alpha:0.75] CGColor]);
    CGRect cgRect = CGRectMake(0, 0, maskRect.size.width * scale, maskRect.size.height * scale);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef maskContext = CGBitmapContextCreate(NULL, CGImageGetWidth(maskImage), CGImageGetHeight(maskImage), 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(maskContext, kCGBlendModeXOR);
    CGContextDrawImage(maskContext, cgRect, maskImage);
    CGContextSetRGBFillColor(maskContext, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(maskContext, cgRect);
    CGImageRef invertedMaskImage = CGBitmapContextCreateImage(maskContext);

    CGContextDrawImage(context, maskRect, invertedMaskImage);

    CGImageRelease(invertedMaskImage);
    CGContextRelease(maskContext);

    [graphicsContext restoreGraphicsState];
}

- (void)drawKnob:(NSRect)rect {
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowOffset:NSMakeSize(0.0, -2.0)];
    [shadow setShadowBlurRadius:5.0f];
    [shadow set];
    [[NSColor whiteColor] setFill];
    [[self knobPath] fill];
}

@end
