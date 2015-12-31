//
//  FSHNowPlayingPresenter.h
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSound.h"

@class RACCommand;
@class FSHAccount;
@class FSHWaveform;

@interface FSHNowPlayingPresenter : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSString *formattedDuration;
@property (nonatomic, strong) NSNumber *progress;
@property (nonatomic, strong) NSString *formattedProgress;
@property (nonatomic, strong) NSURL *permalinkURL;
@property (nonatomic, strong) FSHWaveform *waveform;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) BOOL hidden;

@property (nonatomic, strong, readonly) RACCommand *toggleCurrentSound;
@property (nonatomic, strong, readonly) RACCommand *toggleFavorite;

@property (nonatomic, strong) NSViewController *view;

- (instancetype)initWithAccount:(FSHAccount *)account;

- (void)seekToProgress:(NSNumber *)progress;

@end
