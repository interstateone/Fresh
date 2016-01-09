//
//  FSHWaveformSliderView.h
//  Fresh
//
//  Created by Brandon on 2014-03-31.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FSHWaveform;

@interface FSHWaveformSliderView : NSControl

@property (nonatomic, strong, readonly) NSImage *maskImage;
@property (nonatomic, strong) FSHWaveform *waveform;

@property (nonatomic, assign) double maxValue;

@end
