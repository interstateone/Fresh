//
//  FSHWaveformSliderCell.h
//  Fresh
//
//  Created by Brandon on 2014-03-31.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

@interface FSHWaveformSliderCell : NSActionCell

@property (nonatomic, assign) double maxValue;
@property (nonatomic, assign) double doubleValue;

- (NSBezierPath *)knobPath;

@end
