//
//  FSHSoundCellView.m
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSoundCellView.h"

@interface FSHSoundCellView ()

@property (strong, nonatomic) IBOutlet NSImageView *playingImageView;

@end

@implementation FSHSoundCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    NSTableRowView *row = (NSTableRowView *)self.superview;
    if (row.isSelected) {
        self.trackNameField.textColor = [NSColor whiteColor];
        self.authorNameField.textColor = [NSColor whiteColor];
    } else {
        self.trackNameField.textColor = [NSColor blackColor];
        self.authorNameField.textColor = [NSColor darkGrayColor];
    }
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    self.playingImageView.hidden = !playing;
}

@end
