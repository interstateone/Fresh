//
//  FSHSoundRowView.m
//  Fresh
//
//  Created by Brandon on 2014-04-01.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSoundRowView.h"

@implementation FSHSoundRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    NSColor *selectionColor = [NSColor orangeColor];

    switch (self.selectionHighlightStyle) {
        case NSTableViewSelectionHighlightStyleRegular: {
            if (self.selected) {
                if (!self.emphasized) {
                    selectionColor = [selectionColor colorWithAlphaComponent:0.5];
                }
                [selectionColor set];
                NSRect bounds = self.bounds;
                const NSRect *rects = NULL;
                NSInteger count = 0;
                [self getRectsBeingDrawn:&rects count:&count];
                for (NSInteger i = 0; i < count; i++) {
                    NSRect rect = NSIntersectionRect(bounds, rects[i]);
                    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
                }
            }
            break;
        }
        default: {
            [super drawSelectionInRect:dirtyRect];
            break;
        }
    }
}

@end
