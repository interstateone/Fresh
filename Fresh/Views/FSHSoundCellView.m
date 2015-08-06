//
//  FSHSoundCellView.m
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSoundCellView.h"

@interface FSHSoundCellView ()

@property (strong, nonatomic) NSImageView *playingImageView;

@end

@implementation FSHSoundCellView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;

    self.trackNameField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 23, CGRectGetWidth(self.frame), 20)];
    self.trackNameField.autoresizingMask = NSViewWidthSizable;
    self.trackNameField.backgroundColor = [NSColor clearColor];
    [self.trackNameField setBordered:NO];
    [self.trackNameField setBezeled:NO];
    [self.trackNameField setEditable:NO];
    [self.trackNameField.cell setUsesSingleLineMode:YES];
    [self.trackNameField.cell setLineBreakMode:NSLineBreakByTruncatingTail];

    self.authorNameField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.frame), 20)];
    self.authorNameField.autoresizingMask = NSViewWidthSizable;
    self.authorNameField.backgroundColor = [NSColor clearColor];
    [self.authorNameField setBordered:NO];
    [self.authorNameField setBezeled:NO];
    [self.authorNameField setEditable:NO];
    self.authorNameField.textColor = [NSColor darkGrayColor];
    self.authorNameField.font = [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]];
    [self.authorNameField.cell setUsesSingleLineMode:YES];
    [self.authorNameField.cell setLineBreakMode:NSLineBreakByTruncatingTail];

    CGFloat dimension = 15;
    CGFloat spacing = 8;
    self.playingImageView = [[NSImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - dimension - spacing, CGRectGetMidY(self.frame) - dimension / 2.0, dimension, dimension)];
    self.playingImageView.image = [NSImage imageNamed:NSImageNameStatusAvailable];
    self.playingImageView.hidden = !self.playing;

    [self addSubview:self.trackNameField];
    [self addSubview:self.authorNameField];
    [self addSubview:self.playingImageView];

    return self;
}

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
