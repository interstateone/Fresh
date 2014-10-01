//
//  FSHWaveformSliderView.h
//  Fresh
//
//  Created by Brandon on 2014-03-31.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSHWaveformSliderView : NSControl

@property (nonatomic, strong) NSImage *waveformImage;
@property (nonatomic, strong, readonly) NSImage *maskImage;

@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) double maxValue;

@end
