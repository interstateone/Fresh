//
//  FSHSoundCellView.h
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import <RACDisposable.h>

@interface FSHSoundCellView : NSTableCellView

@property (strong, nonatomic) NSTextField *trackNameField;
@property (strong, nonatomic) NSTextField *authorNameField;
@property (assign, nonatomic) BOOL playing;

@end
